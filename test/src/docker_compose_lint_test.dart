import 'package:flutter_test/flutter_test.dart';
import 'package:la_toolkit/models/deployment_type.dart';
import 'package:la_toolkit/models/la_project.dart';
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
}
