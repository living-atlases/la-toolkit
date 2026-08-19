import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:la_toolkit/dependencies_manager.dart';
import 'package:la_toolkit/models/deployment_type.dart';
import 'package:la_toolkit/models/la_project.dart';
import 'package:la_toolkit/models/la_releases.dart';
import 'package:la_toolkit/models/la_server.dart';
import 'package:la_toolkit/models/la_service_constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Docker Compose Lint Tests', () {
    test(
      'getDockerComposeVMWarnings returns warning when service is assigned directly to VMs and Docker Compose is in use',
      () {
        final LAProject p = LAProject();
        final LAServer vm1 = LAServer(
          id: 'vm1',
          name: 'vm1',
          ip: '10.0.0.1',
          projectId: p.id,
        );
        p.upsertServer(vm1);
        p.serviceInUse(dockerCompose, true);
        p.assign(vm1, <String>[dockerCompose, collectory]); // Assigned both to VM

        final List<String> warnings = p.getDockerComposeVMWarnings();
        // One warning for the server, naming the misplaced services -- not one
        // warning per service, which used to bury the user in identical alerts.
        expect(warnings, hasLength(1));
        expect(warnings[0], contains('vm1 is a Docker Compose host'));
        expect(warnings[0], contains('collections'));
      },
    );

    test(
      'getDockerComposeVMWarnings returns no warning when service is assigned to Docker Cluster',
      () {
        final LAProject p = LAProject();
        final LAServer vm1 = LAServer(
          id: 'vm1',
          name: 'vm1',
          ip: '10.0.0.1',
          projectId: p.id,
        );
        p.upsertServer(vm1);
        p.serviceInUse(dockerCompose, true);
        p.assign(vm1, <String>[dockerCompose]);
        p.assignByType(vm1.id, DeploymentType.dockerCompose, <String>[collectory]);

        final List<String> warnings = p.getDockerComposeVMWarnings();
        expect(warnings, isEmpty);
      },
    );

    test(
      'getDockerComposeVMWarnings returns no warning if Docker Compose is not used',
      () {
        final LAProject p = LAProject();
        final LAServer vm1 = LAServer(
          id: 'vm1',
          name: 'vm1',
          ip: '10.0.0.1',
          projectId: p.id,
        );
        p.upsertServer(vm1);
        p.assign(vm1, <String>[collectory]);

        final List<String> warnings = p.getDockerComposeVMWarnings();
        expect(warnings, isEmpty);
      },
    );
  });

  group('Services with nowhere to run', () {
    test('legacy solr is stranded when the only server is a compose host', () {
      final LAProject p = LAProject();
      final LAServer vm1 = LAServer(
        id: 'vm1',
        name: 'vm1',
        ip: '10.0.0.1',
        projectId: p.id,
      );
      p.upsertServer(vm1);
      p.serviceInUse(dockerCompose, true);
      p.serviceInUse(solr, true);
      p.assign(vm1, <String>[dockerCompose]);

      // solr has no docker support, so the compose cluster will not take it, and
      // there is no plain VM left to host it either.
      expect(p.servicesWithNowhereToRun(), contains(solr));
      // It must not keep the project from validating: the user gets told what to
      // disable instead of a dead end with no way forward.
      expect(p.servicesNotAssigned(), isNot(contains(solr)));
    });

    test('nothing is stranded in a mixed project, a VM can still host it', () {
      final LAProject p = LAProject();
      final LAServer vm1 = LAServer(
        id: 'vm1',
        name: 'vm1',
        ip: '10.0.0.1',
        projectId: p.id,
      );
      final LAServer vm2 = LAServer(
        id: 'vm2',
        name: 'vm2',
        ip: '10.0.0.2',
        projectId: p.id,
      );
      p.upsertServer(vm1);
      p.upsertServer(vm2);
      p.serviceInUse(dockerCompose, true);
      p.serviceInUse(solr, true);
      p.assign(vm1, <String>[dockerCompose]);

      expect(p.servicesWithNowhereToRun(), isEmpty);
    });

    test('nothing is stranded without docker compose at all', () {
      final LAProject p = LAProject();
      final LAServer vm1 = LAServer(
        id: 'vm1',
        name: 'vm1',
        ip: '10.0.0.1',
        projectId: p.id,
      );
      p.upsertServer(vm1);
      p.serviceInUse(solr, true);

      expect(p.servicesWithNowhereToRun(), isEmpty);
    });
  });

  group('Assignment overlapping bug', () {
    test(
      'Assigning to VM does not remove from Docker Cluster (allowing temporary overlap)',
      () {
        final LAProject p = LAProject();
        final LAServer vm1 = LAServer(
          id: 'vm1',
          name: 'vm1',
          ip: '10.0.0.1',
          projectId: p.id,
        );
        p.upsertServer(vm1);
        p.serviceInUse(dockerCompose, true);
        p.assign(vm1, <String>[dockerCompose]);

        // 1. Assign to Docker Cluster
        p.assignByType(vm1.id, DeploymentType.dockerCompose, <String>[collectory]);
        expect(
          p.getClusterServices(clusterId: p.clusters.first.id),
          contains(collectory),
        );

        // 2. Assign to VM
        p.assign(vm1, <String>[collectory]);

        // 3. Verify it is in BOTH (Relaxing exclusivity)
        expect(p.getServerServices(serverId: vm1.id), contains(collectory));
        expect(
          p.getClusterServices(clusterId: p.clusters.first.id),
          contains(collectory),
          reason: 'Should still be in cluster',
        );

        // 4. Unassign from VM
        p.unAssign(vm1, collectory);

        // 5. Verify it is still in Cluster
        expect(
          p.getServerServices(serverId: vm1.id),
          isNot(contains(collectory)),
        );
        expect(
          p.getClusterServices(clusterId: p.clusters.first.id),
          contains(collectory),
          reason: 'Should remain in cluster after unassign from VM',
        );
      },
    );
  });

  group('dependency lint on the shipped sample', () {
    // Just the slice of the backend matrix this exercises, so the test does not
    // need the network: pipelines wants a namematching >= 1.0.0, and 'any'
    // dependencies never warn for a missing version.
    const String depsYaml = '''
pipelines:
  any:
    - namematching-service: '>= 1.0.0'
    - solrcloud: '>= 8.9.0'
biocache-service:
  any:
    - pipelines: any
''';

    List<Map<String, dynamic>> loadTemplates() {
      final String content = File(
        'assets/la-toolkit-templates.json',
      ).readAsStringSync();
      return (jsonDecode(content) as List<dynamic>)
          .map((dynamic t) => t as Map<String, dynamic>)
          .toList();
    }

    Map<String, dynamic> promptValues() =>
        (loadTemplates()[0]['generator-living-atlas']
                as Map<String, dynamic>)['promptValues']
            as Map<String, dynamic>;

    setUp(() => DependenciesManager.setDeps(depsYaml));

    List<String> lintsFor(LAProject p) => DependenciesManager.verifyLAReleases(
      p.getServicesNameListInUse(),
      p.getServiceDeployReleases(),
    );

    test('warns, and says why, when namematching has no version', () {
      final List<String> lints = lintsFor(
        LAProject.fromObject(promptValues()),
      );
      expect(lints, hasLength(1));
      expect(
        lints[0],
        'pipelines depends on namematching >=1.0.0 (no version selected yet)',
      );
    });

    test('is quiet once the import seeds the version', () {
      final LAProject p = LAProject.fromObject(
        promptValues(),
        laReleases: <String, LAReleases>{
          '${namematchingService}_nexus': const LAReleases(
            name: 'ala-namematching-service',
            artifacts: 'ala-namematching-service',
            latest: 'v2.0',
            versions: <String>['v2.0'],
          ),
        },
      );
      expect(lintsFor(p), isEmpty);
    });
  });

  group('la-docker-compose to la-generator constraint', () {
    // The matrix key is 'docker-compose', matching LAServiceName.docker_compose;
    // 'la-docker-compose' would normalize to nothing and be skipped in silence.
    const String depsYaml = '''
docker-compose:
  '>= 1.4.0':
    - la-generator: '>= 1.9.7'
''';

    setUp(() => DependenciesManager.setDeps(depsYaml));

    List<String> lintsFor(String composeRelease, String generatorRelease) =>
        DependenciesManager.verifyLAReleases(
          <String>[dockerCompose, generator],
          <String, String>{
            dockerCompose: composeRelease,
            generator: generatorRelease,
          },
        );

    test('warns when the generator is older than 1.4.0 needs', () {
      // The release comes from the git tags, so it arrives with the leading 'v'
      // that StringUtils.semantize strips.
      expect(lintsFor('v1.4.0', '1.9.5'), <String>[
        'docker compose depends on la-generator >=1.9.7',
      ]);
    });

    test('is quiet once the generator meets the constraint', () {
      expect(lintsFor('v1.4.0', '1.9.7'), isEmpty);
    });

    test('does not apply to releases before 1.4.0', () {
      expect(lintsFor('v1.3.1', '1.9.5'), isEmpty);
    });

    test('skips the upstream sentinel instead of failing to parse it', () {
      expect(lintsFor('upstream', '1.9.5'), isEmpty);
    });
  });
}
