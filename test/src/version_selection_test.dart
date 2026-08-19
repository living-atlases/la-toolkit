import 'package:flutter_test/flutter_test.dart';
import 'package:la_toolkit/la_releases_selectors.dart';
import 'package:la_toolkit/models/deployment_type.dart';
import 'package:la_toolkit/models/la_project.dart';
import 'package:la_toolkit/models/la_releases.dart';
import 'package:la_toolkit/models/la_server.dart';
import 'package:la_toolkit/models/la_service_constants.dart';
import 'package:la_toolkit/models/la_service_deploy.dart';

void main() {
  test('assignByType selects Nexus version for Docker Compose', () {
    final LAProject project = LAProject();
    final LAServer server = LAServer(
      name: 'test-server',
      projectId: project.id,
      ip: '127.0.0.1',
    );
    project.upsertServer(server);

    // Initial check: Service should not be assigned
    expect(
      project
          .getServerServices(serverId: server.id)
          .contains(sensitiveDataService),
      equals(false),
    );

    // Prepare mock releases
    final Map<String, LAReleases> mockReleases = <String, LAReleases>{
      sensitiveDataService: LAReleases(
        name: sensitiveDataService,
        latest: '1.0.0-apt',
        versions: const <String>['1.0.0-apt'],
        artifacts: 'sensitive_data_service',
      ),
      '${sensitiveDataService}_nexus': LAReleases(
        name: '${sensitiveDataService}_nexus',
        latest: '2.0.0-nexus',
        versions: const <String>['2.0.0-nexus'],
        artifacts: 'ala-sensitive-data-server',
      ),
    };

    final String sdsId = project.getService(sensitiveDataService).id;

    // 1. Assign to VM (Standard) - Should use Apt version
    project.assignByType(
      server.id,
      DeploymentType.vm,
      <String>[sensitiveDataService],
      null,
      mockReleases,
    );

    LAServiceDeploy deploy = project.serviceDeploys.firstWhere(
      (LAServiceDeploy d) =>
          d.serviceId == sdsId && d.type == DeploymentType.vm,
    );

    // Expect Apt version
    expect(deploy.softwareVersions[sensitiveDataService], equals('1.0.0-apt'));

    // 2. Assign to Docker Compose - Should use Nexus version
    project.assignByType(
      server.id, // assignByType handles creating cluster if needed
      DeploymentType.dockerCompose,
      <String>[sensitiveDataService],
      null,
      mockReleases,
    );

    deploy = project.serviceDeploys.firstWhere(
      (LAServiceDeploy d) =>
          d.serviceId == sdsId && d.type == DeploymentType.dockerCompose,
    );

    // Expect Nexus version
    expect(
      deploy.softwareVersions[sensitiveDataService],
      equals('2.0.0-nexus'),
    );
  });

  test('assignByType respects selectedVersions for Docker Compose', () {
    final LAProject project = LAProject();
    final LAServer server = LAServer(
      name: 'test-server',
      projectId: project.id,
      ip: '127.0.0.1',
    );
    project.upsertServer(server);

    // Prepare mock releases
    final Map<String, LAReleases> mockReleases = <String, LAReleases>{
      sensitiveDataService: LAReleases(
        name: sensitiveDataService,
        latest: '1.0.0-apt',
        versions: const <String>['1.0.0-apt'],
        artifacts: 'sensitive_data_service',
      ),
      '${sensitiveDataService}_nexus': LAReleases(
        name: '${sensitiveDataService}_nexus',
        latest: '2.0.0-nexus',
        versions: const <String>['2.0.0-nexus'],
        artifacts: 'ala-sensitive-data-server',
      ),
    };

    final String sdsId = project.getService(sensitiveDataService).id;

    // 3. User manually selects a version (e.g., specific Nexus or even Apt)
    // - Should respect user selection over auto-Nexus logic
    project.selectedVersions[sensitiveDataService] = '1.0.0-apt';

    project.assignByType(
      server.id,
      DeploymentType.dockerCompose,
      <String>[sensitiveDataService],
      null,
      mockReleases,
    );

    final LAServiceDeploy manualDeploy = project.serviceDeploys.firstWhere(
      (LAServiceDeploy d) =>
          d.serviceId == sdsId && d.type == DeploymentType.dockerCompose,
    );

    // Expect Manual/Apt version because user selected it
    expect(
      manualDeploy.softwareVersions[sensitiveDataService],
      equals('1.0.0-apt'),
    );
  });

  test(
    'assignByType falls back to default if Nexus version missing for Docker',
    () {
      final LAProject project = LAProject();
      final LAServer server = LAServer(
        name: 'test-server',
        projectId: project.id,
        ip: '127.0.0.1',
      );
      project.upsertServer(server);

      final String sdsId = project.getService(sensitiveDataService).id;

      // Prepare mock releases WITHOUT Nexus key
      final Map<String, LAReleases> mockReleases = <String, LAReleases>{
        sensitiveDataService: LAReleases(
          name: sensitiveDataService,
          latest: '1.0.0-apt',
          versions: const <String>['1.0.0-apt'],
          artifacts: 'sensitive_data_service',
        ),
      };

      // Assign to Docker Compose
      project.assignByType(
        server.id,
        DeploymentType.dockerCompose,
        <String>[sensitiveDataService],
        null,
        mockReleases,
      );

      final LAServiceDeploy deploy = project.serviceDeploys.firstWhere(
        (LAServiceDeploy d) =>
            d.serviceId == sdsId && d.type == DeploymentType.dockerCompose,
      );

      // Expect fallback to Apt version (or standard default)
      expect(
        deploy.softwareVersions[sensitiveDataService],
        equals('1.0.0-apt'),
      );
    },
  );

  // gbif-es, 2026-07-28: the docker leg deployed collectory 1.3.12 — a version with no
  // Docker image — after 6.0.0 had been picked in the UI. The version read from the
  // imported inventory (the VM leg's [all:vars]) was applied last and overrode it.
  test('assignByType keeps the selected version over the imported inventory one', () {
    final LAProject project = LAProject();
    final LAServer server = LAServer(
      name: 'test-server',
      projectId: project.id,
      ip: '127.0.0.1',
    );
    project.upsertServer(server);

    final Map<String, LAReleases> mockReleases = <String, LAReleases>{
      collectory: LAReleases(
        name: collectory,
        latest: '1.6.4',
        versions: const <String>['1.3.12', '1.6.4'],
        artifacts: 'collectory',
      ),
      '${collectory}_nexus': LAReleases(
        name: '${collectory}_nexus',
        latest: '5.1.1',
        versions: const <String>['5.1.1', '6.0.0'],
        artifacts: 'collectory',
      ),
    };

    // What the legacy VM inventory carries, and what the user picked in the UI.
    final Map<String, String> importedVersions = <String, String>{
      'collectory_version': '1.3.12',
    };
    project.selectedVersions[collectory] = '6.0.0';

    project.assignByType(
      server.id,
      DeploymentType.dockerCompose,
      <String>[collectory],
      importedVersions,
      mockReleases,
    );

    final String collectoryId = project.getService(collectory).id;
    final LAServiceDeploy deploy = project.serviceDeploys.firstWhere(
      (LAServiceDeploy d) =>
          d.serviceId == collectoryId && d.type == DeploymentType.dockerCompose,
    );

    expect(deploy.softwareVersions[collectory], equals('6.0.0'));
  });

  // gh-22 (NLPHH, 2026-08-16): a dropdown that already showed the desired
  // version at first render deployed a different one, because the displayed
  // default was never written to the model. The only workaround was flipping
  // every dropdown to another value and back.
  group('untouched dropdown: display == deploy (gh-22)', () {
    test('the displayed version of an untouched dropdown, once persisted, '
        'is what the generator emits', () {
      final LAProject project = LAProject();
      final LAServer server = LAServer(
        name: 'test-server',
        projectId: project.id,
        ip: '127.0.0.1',
      );
      project.upsertServer(server);

      // The service is assigned BEFORE laReleases has loaded (real startup
      // order), so the seed misses the nexus branch and stores no version.
      project.assignByType(
        server.id,
        DeploymentType.dockerCompose,
        <String>[collectory],
      );
      expect(project.getServiceDeployRelease(collectory), isNull);

      // What the dropdown displays once the (nexus) list has loaded.
      final List<String> dropdownVersions = <String>['6.0.0', '5.1.1'];
      final String displayed = LAReleasesSelectors.resolveDisplayedVersion(
        project: project,
        swName: collectory,
        versions: dropdownVersions,
      );
      expect(displayed, equals('6.0.0'));

      // What onInitialVersionsPersist does with it, without any user touch.
      project.setServiceDeployRelease(collectory, displayed);

      expect(project.getServiceDeployRelease(collectory), equals('6.0.0'));
      // And from now on the dropdown keeps showing the stored value.
      expect(
        LAReleasesSelectors.resolveDisplayedVersion(
          project: project,
          swName: collectory,
          versions: dropdownVersions,
        ),
        equals('6.0.0'),
      );
    });

    test('resolution is the same whether laReleases had loaded or not when '
        'the serviceDeploy was created', () {
      final Map<String, LAReleases> mockReleases = <String, LAReleases>{
        collectory: LAReleases(
          name: collectory,
          latest: '1.6.4',
          versions: const <String>['1.3.12', '1.6.4'],
          artifacts: 'collectory',
        ),
        '${collectory}_nexus': LAReleases(
          name: '${collectory}_nexus',
          latest: '6.0.0',
          versions: const <String>['6.0.0', '5.1.1'],
          artifacts: 'collectory',
        ),
      };
      final List<String> dropdownVersions = <String>['6.0.0', '5.1.1'];

      String resolveFor({required bool laReleasesLoaded}) {
        final LAProject project = LAProject();
        final LAServer server = LAServer(
          name: 'test-server',
          projectId: project.id,
          ip: '127.0.0.1',
        );
        project.upsertServer(server);
        project.assignByType(
          server.id,
          DeploymentType.dockerCompose,
          <String>[collectory],
          null,
          laReleasesLoaded ? mockReleases : null,
        );
        final String displayed = LAReleasesSelectors.resolveDisplayedVersion(
          project: project,
          swName: collectory,
          versions: dropdownVersions,
        );
        // The persist step that runs after first render.
        if (project.getServiceDeployRelease(collectory) == null) {
          project.setServiceDeployRelease(collectory, displayed);
        }
        return project.getServiceDeployRelease(collectory)!;
      }

      expect(
        resolveFor(laReleasesLoaded: true),
        equals(resolveFor(laReleasesLoaded: false)),
        reason:
            'The effective version must not depend on whether laReleases '
            'had loaded when the serviceDeploy was created',
      );
    });

    test('a session-selected version wins over the list default for an '
        'unassigned service', () {
      final LAProject project = LAProject();
      project.selectedVersions[collectory] = '5.1.1';

      final String displayed = LAReleasesSelectors.resolveDisplayedVersion(
        project: project,
        swName: collectory,
        versions: <String>['6.0.0', '5.1.1'],
      );

      expect(displayed, equals('5.1.1'));
    });

    test('the running version is preferred over the newest when nothing is '
        'stored or selected', () {
      final LAProject project = LAProject();

      final String displayed = LAReleasesSelectors.resolveDisplayedVersion(
        project: project,
        swName: collectory,
        versions: <String>['6.0.0', '5.1.1'],
        runningVersion: '5.1.1',
      );

      expect(displayed, equals('5.1.1'));
    });
  });
}
