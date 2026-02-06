import 'package:flutter_test/flutter_test.dart';
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
}
