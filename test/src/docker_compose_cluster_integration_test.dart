import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:la_toolkit/models/deployment_type.dart';
import 'package:la_toolkit/models/la_project.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Docker Compose Project Integration Tests', () {
    late Map<String, dynamic> sampleProjectJson;

    setUpAll(() {
      // This is a sample project JSON that represents a real project
      // with docker-compose clusters that have serverId set.
      // This data structure mimics what would be persisted in the backend,
      // based on real LA_LADemo project data.
      sampleProjectJson = {
        'id': 'test-project-docker-compose-1',
        'longName': 'Test Project with Docker Compose',
        'shortName': 'TPDC',
        'domain': 'test-docker.example.com',
        'dirName': 'test-docker',
        'theme': 'clean',
        'useSSL': true,
        'isCreated': true,
        'isHub': false,
        'status': 'basicDefined',
        'advancedEdit': false,
        'advancedTune': false,
        'additionalVariables': '',
        'alaInstallRelease': '2.3.4',
        'generatorRelease': '1.6.9',
        'createdAt': 1677571200000,
        'mapZoom': 5.0,
        'mapBoundsFstPoint': {
          'latitude': 7.874575060529807,
          'longitude': 4.449218749999986,
        },
        'mapBoundsSndPoint': {
          'latitude': -57.29206142558941,
          'longitude': 180.0,
        },
        'fstDeployed': false,
        'servers': [
          {
            'id': 'server-docker-cluster-1',
            'projectId': 'test-project-docker-compose-1',
            'name': 'gbif-es-docker-cluster-2023-1',
            'ip': '172.16.16.114',
            'sshPort': 22,
            'sshUser': 'ubuntu',
            'gateways': [],
            'reachable': 'unknown',
            'sshReachable': 'unknown',
            'sudoEnabled': 'unknown',
            'osName': 'Ubuntu',
            'osVersion': '22.04 LTS',
            'sshKey': {
              'name': 'test-key',
              'desc': 'test key',
              'encrypted': false,
              'private': '-----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAKCAQEA...',
              'public': 'ssh-rsa AAAAB3NzaC1yc2EAAAA...',
            },
          },
          {
            'id': 'server-docker-cluster-2',
            'projectId': 'test-project-docker-compose-1',
            'name': 'gbif-es-docker-cluster-2023-2',
            'ip': '172.16.16.78',
            'sshPort': 22,
            'sshUser': 'ubuntu',
            'gateways': [],
            'reachable': 'unknown',
            'sshReachable': 'unknown',
            'sudoEnabled': 'unknown',
            'osName': 'Ubuntu',
            'osVersion': '22.04 LTS',
            'sshKey': {
              'name': 'test-key',
              'desc': 'test key',
              'encrypted': false,
              'private': '-----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAKCAQEA...',
              'public': 'ssh-rsa AAAAB3NzaC1yc2EAAAA...',
            },
          },
          {
            'id': 'server-docker-cluster-3',
            'projectId': 'test-project-docker-compose-1',
            'name': 'gbif-es-docker-cluster-2023-3',
            'ip': '172.16.16.56',
            'sshPort': 22,
            'sshUser': 'ubuntu',
            'gateways': [],
            'reachable': 'unknown',
            'sshReachable': 'unknown',
            'sudoEnabled': 'unknown',
            'osName': 'Ubuntu',
            'osVersion': '22.04 LTS',
            'sshKey': {
              'name': 'test-key',
              'desc': 'test key',
              'encrypted': false,
              'private': '-----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAKCAQEA...',
              'public': 'ssh-rsa AAAAB3NzaC1yc2EAAAA...',
            },
          },
        ],
        'clusters': [
          {
            'id': 'cluster-docker-compose-1',
            'projectId': 'test-project-docker-compose-1',
            'serverId': 'server-docker-cluster-1',
            'name': 'Docker Compose on gbif-es-docker-cluster-2023-1',
            'type': 'dockerCompose',
          },
          {
            'id': 'cluster-docker-compose-2',
            'projectId': 'test-project-docker-compose-1',
            'serverId': 'server-docker-cluster-2',
            'name': 'Docker Compose on gbif-es-docker-cluster-2023-2',
            'type': 'dockerCompose',
          },
          {
            'id': 'cluster-docker-compose-3',
            'projectId': 'test-project-docker-compose-1',
            'serverId': 'server-docker-cluster-3',
            'name': 'Docker Compose on gbif-es-docker-cluster-2023-3',
            'type': 'dockerCompose',
          },
        ],
        'services': [],
        'serviceDeploys': [],
        'variables': [],
        'cmdHistoryEntries': [],
        'serverServices': {
          'server-docker-cluster-1': [],
          'server-docker-cluster-2': [],
          'server-docker-cluster-3': [],
        },
        'clusterServices': {
          'cluster-docker-compose-1': [],
          'cluster-docker-compose-2': [],
          'cluster-docker-compose-3': [],
        },
        'checkResults': {},
        'runningVersions': {},
        'selectedVersions': {},
        'parent': null,
        'hubs': [],
        'lastCmdEntry': null,
        'lastCmdDetails': null,
      };
    });

    test('Project deserializes with multiple docker-compose clusters', () {
      final LAProject project = LAProject.fromJson(sampleProjectJson);

      expect(project.id, equals('test-project-docker-compose-1'));
      expect(
        project.clusters.length,
        equals(3),
        reason: 'project must have 3 docker-compose clusters',
      );

      // Find all docker-compose clusters
      final dockerComposeClusters = project.clusters
          .where((c) => c.type == DeploymentType.dockerCompose)
          .toList();

      expect(
        dockerComposeClusters.length,
        equals(3),
        reason: 'should have 3 docker-compose clusters',
      );

      // Verify each cluster has correct serverId
      expect(dockerComposeClusters[0].id, equals('cluster-docker-compose-1'));
      expect(
        dockerComposeClusters[0].serverId,
        equals('server-docker-cluster-1'),
        reason: 'first cluster should be linked to first server',
      );

      expect(dockerComposeClusters[1].id, equals('cluster-docker-compose-2'));
      expect(
        dockerComposeClusters[1].serverId,
        equals('server-docker-cluster-2'),
        reason: 'second cluster should be linked to second server',
      );

      expect(dockerComposeClusters[2].id, equals('cluster-docker-compose-3'));
      expect(
        dockerComposeClusters[2].serverId,
        equals('server-docker-cluster-3'),
        reason: 'third cluster should be linked to third server',
      );
    });

    test('All docker-compose clusters have non-null serverId', () {
      final LAProject project = LAProject.fromJson(sampleProjectJson);

      final dockerComposeClusters = project.clusters
          .where((c) => c.type == DeploymentType.dockerCompose)
          .toList();

      for (final cluster in dockerComposeClusters) {
        expect(
          cluster.serverId,
          isNotNull,
          reason: '${cluster.name} must have serverId set',
        );
      }
    });

    test(
      'Serialized and re-deserialized project preserves cluster serverId',
      () {
        // First deserialization
        LAProject project = LAProject.fromJson(sampleProjectJson);

        // Verify initial state
        final dockerComposeCluster = project.clusters.firstWhere(
          (c) => c.type == DeploymentType.dockerCompose,
        );
        expect(
          dockerComposeCluster.serverId,
          isNotNull,
          reason: 'initial cluster must have serverId',
        );

        // Serialize to JSON
        final serializedJson = project.toJson();

        // Re-deserialize
        project = LAProject.fromJson(serializedJson);

        // Verify serverId is still present after round-trip
        final restoredDockerCluster = project.clusters.firstWhere(
          (c) => c.type == DeploymentType.dockerCompose,
        );
        expect(
          restoredDockerCluster.serverId,
          equals(dockerComposeCluster.serverId),
          reason: 'cluster serverId must survive serialization round-trip',
        );

        // Verify all clusters still have serverId
        final allRestoredClusters = project.clusters
            .where((c) => c.type == DeploymentType.dockerCompose)
            .toList();
        for (final cluster in allRestoredClusters) {
          expect(
            cluster.serverId,
            isNotNull,
            reason: '${cluster.name} serverId must survive round-trip',
          );
        }
      },
    );

    test('Project toJson includes cluster serverId in output', () {
      final LAProject project = LAProject.fromJson(sampleProjectJson);

      final Map<String, dynamic> serialized = project.toJson();

      expect(
        serialized.containsKey('clusters'),
        true,
        reason: 'clusters must be in serialized output',
      );

      final List<dynamic> clustersJson =
          serialized['clusters'] as List<dynamic>;
      expect(
        clustersJson.isNotEmpty,
        true,
        reason: 'clusters list must not be empty',
      );

      // Check that all clusters have serverId in the JSON
      for (final clusterJson in clustersJson) {
        final Map<String, dynamic> cluster =
            clusterJson as Map<String, dynamic>;
        expect(
          cluster.containsKey('serverId'),
          true,
          reason: 'each cluster in JSON must have serverId field',
        );

        if (cluster['type'] == 'dockerCompose') {
          expect(
            cluster['serverId'],
            isNotNull,
            reason:
                'docker compose cluster must have non-null serverId in JSON',
          );
        }
      }
    });

    test(
      'Multiple clusters on different servers maintain correct serverIds',
      () {
        final LAProject project = LAProject.fromJson(sampleProjectJson);

        final dockerComposeClusters = project.clusters
            .where((c) => c.type == DeploymentType.dockerCompose)
            .toList();

        expect(dockerComposeClusters.isNotEmpty, true);

        // Each cluster should reference a different server
        final serverIds = dockerComposeClusters.map((c) => c.serverId).toSet();

        expect(
          serverIds.length,
          equals(3),
          reason: 'each cluster should reference a different server',
        );

        // All should be different cluster IDs
        final clusterIds = dockerComposeClusters.map((c) => c.id).toSet();
        expect(
          clusterIds.length,
          equals(3),
          reason: 'all clusters should have different IDs',
        );
      },
    );

    test('Cluster services are correctly mapped to docker-compose cluster', () {
      final LAProject project = LAProject.fromJson(sampleProjectJson);

      final dockerComposeClusterId = project.clusters
          .firstWhere((c) => c.type == DeploymentType.dockerCompose)
          .id;

      final servicesInCluster =
          project.clusterServices[dockerComposeClusterId] ?? <String>[];

      // In this test data, clusters have no services assigned
      expect(
        servicesInCluster,
        isEmpty,
        reason: 'clusters in test data have no services assigned',
      );
    });

    test('Project JSON string serialization/deserialization works', () {
      final LAProject original = LAProject.fromJson(sampleProjectJson);

      // Convert to JSON and then to string (like backend API would do)
      final String jsonString = jsonEncode(original.toJson());

      // Parse the JSON string back
      final Map<String, dynamic> parsed =
          jsonDecode(jsonString) as Map<String, dynamic>;

      // Deserialize
      final LAProject restored = LAProject.fromJson(parsed);

      // Find docker cluster
      final originalDockerCluster = original.clusters.firstWhere(
        (c) => c.type == DeploymentType.dockerCompose,
      );
      final restoredDockerCluster = restored.clusters.firstWhere(
        (c) => c.type == DeploymentType.dockerCompose,
      );

      expect(
        restoredDockerCluster.serverId,
        equals(originalDockerCluster.serverId),
        reason:
            'cluster serverId must survive JSON string serialization/deserialization',
      );
    });
  });
}
