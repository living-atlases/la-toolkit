import 'package:flutter_test/flutter_test.dart';
import 'package:la_toolkit/models/deployment_type.dart';
import 'package:la_toolkit/models/la_cluster.dart';
import 'package:la_toolkit/models/la_project.dart';
import 'package:la_toolkit/models/la_server.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LACluster Serialization Tests', () {
    test('LACluster with serverId serializes correctly', () {
      // Create a simple cluster with serverId
      const String projectId = 'project123';
      const String serverId = 'server456';
      const String clusterId = 'cluster789';

      final LACluster cluster = LACluster(
        id: clusterId,
        projectId: projectId,
        serverId: serverId,
        name: 'Docker Compose on test-server',
        type: DeploymentType.dockerCompose,
      );

      // Serialize to JSON
      final Map<String, dynamic> json = cluster.toJson();

      // Verify serverId is in the JSON
      expect(
        json.containsKey('serverId'),
        true,
        reason: 'serverId field must be present in serialized JSON',
      );
      expect(
        json['serverId'],
        equals(serverId),
        reason: 'serverId must be correctly serialized',
      );
      expect(
        json['projectId'],
        equals(projectId),
        reason: 'projectId must be correctly serialized',
      );
      expect(
        json['type'],
        equals('dockerCompose'),
        reason: 'type must be correctly serialized as string enum',
      );
    });

    test('LACluster without serverId (null) serializes correctly', () {
      const String projectId = 'project123';
      const String clusterId = 'cluster789';

      final LACluster cluster = LACluster(
        id: clusterId,
        projectId: projectId,
        name: 'Orphan cluster',
      );

      final Map<String, dynamic> json = cluster.toJson();

      // serverId should be present but null
      expect(
        json.containsKey('serverId'),
        true,
        reason: 'serverId key must be present even if null',
      );
      expect(
        json['serverId'],
        isNull,
        reason: 'serverId should be null when not set',
      );
    });

    test('LACluster deserializes from JSON with serverId correctly', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'id': 'cluster123',
        'projectId': 'project456',
        'serverId': 'server789',
        'name': 'Docker Compose on production',
        'type': 'dockerCompose',
      };

      final LACluster cluster = LACluster.fromJson(json);

      expect(cluster.id, equals('cluster123'));
      expect(cluster.projectId, equals('project456'));
      expect(
        cluster.serverId,
        equals('server789'),
        reason: 'serverId must be deserialized correctly from JSON',
      );
      expect(cluster.name, equals('Docker Compose on production'));
      expect(cluster.type, equals(DeploymentType.dockerCompose));
    });

    test('LACluster round-trip serialization preserves serverId', () {
      const String serverId = 'server_id_xyz';
      final LACluster originalCluster = LACluster(
        id: 'cluster_id_abc',
        projectId: 'project_id_def',
        serverId: serverId,
        name: 'Test Docker Cluster',
      );

      // Serialize and deserialize
      final Map<String, dynamic> json = originalCluster.toJson();
      final LACluster restoredCluster = LACluster.fromJson(json);

      expect(
        restoredCluster.serverId,
        equals(serverId),
        reason: 'serverId must be preserved during round-trip serialization',
      );
      expect(restoredCluster.id, equals(originalCluster.id));
      expect(restoredCluster.projectId, equals(originalCluster.projectId));
      expect(restoredCluster.type, equals(originalCluster.type));
    });

    test('LAProject with Docker Compose cluster preserves serverId', () {
      // Create a project with a server and a docker-compose cluster
      final LAServer testServer = LAServer(
        id: 'server_prod_1',
        projectId: 'project_test_1',
        name: 'prod-server-1',
        ip: '192.168.1.100',
      );

      final LAProject project = LAProject(
        id: 'project_test_1',
        longName: 'Test Project',
        shortName: 'TP',
        domain: 'test.example.com',
        servers: <LAServer>[testServer],
      );

      // Manually add a docker-compose cluster with serverId
      final LACluster dockerCluster = LACluster(
        id: 'docker_compose_1',
        projectId: project.id,
        serverId: testServer.id,
        name: 'Docker Compose on ${testServer.name}',
        type: DeploymentType.dockerCompose,
      );

      project.clusters.add(dockerCluster);

      // Serialize project
      final Map<String, dynamic> projectJson = project.toJson();
      final List<dynamic>? clustersJson =
          projectJson['clusters'] as List<dynamic>?;

      expect(clustersJson, isNotNull, reason: 'clusters list must be present');
      expect(
        clustersJson!.isNotEmpty,
        true,
        reason: 'clusters list must not be empty',
      );

      final Map<String, dynamic> serializedCluster =
          clustersJson.first as Map<String, dynamic>;

      expect(
        serializedCluster['serverId'],
        equals(testServer.id),
        reason: 'cluster.serverId must be preserved when serializing project',
      );
      expect(serializedCluster['type'], equals('dockerCompose'));
    });

    test('LAProject deserializes Docker Compose cluster with serverId', () {
      // Create a JSON representation of a project with a docker-compose cluster
      final Map<String, dynamic> projectJson = <String, dynamic>{
        'id': 'project_deser_1',
        'longName': 'Deserialization Test',
        'shortName': 'DT',
        'domain': 'deser.test.com',
        'theme': 'clean',
        'useSSL': true,
        'isCreated': false,
        'isHub': false,
        'status': 'created',
        'advancedEdit': false,
        'advancedTune': false,
        'additionalVariables': '',
        'createdAt': 1643587200,
        'mapBoundsFstPoint': <String, double>{'latitude': -44.0, 'longitude': 112.0},
        'mapBoundsSndPoint': <String, double>{'latitude': -9.0, 'longitude': 154.0},
        'mapZoom': 5.0,
        'servers': <dynamic>[],
        'clusters': <dynamic>[
          <String, String>{
            'id': 'docker_compose_deser_1',
            'projectId': 'project_deser_1',
            'serverId': 'server_deser_1',
            'name': 'Docker Compose on Prod',
            'type': 'dockerCompose',
          },
        ],
        'services': <dynamic>[],
        'serviceDeploys': <dynamic>[],
        'variables': <dynamic>[],
        'cmdHistoryEntries': <dynamic>[],
        'serverServices': <String, dynamic>{},
        'clusterServices': <String, dynamic>{},
        'checkResults': <String, dynamic>{},
        'runningVersions': <String, dynamic>{},
        'selectedVersions': <String, dynamic>{},
      };

      final LAProject project = LAProject.fromJson(projectJson);

      expect(
        project.clusters.isNotEmpty,
        true,
        reason: 'project must have clusters',
      );
      final LACluster deserializedCluster = project.clusters.first;

      expect(
        deserializedCluster.serverId,
        equals('server_deser_1'),
        reason:
            'cluster.serverId must be deserialized correctly from project JSON',
      );
      expect(deserializedCluster.type, equals(DeploymentType.dockerCompose));
    });

    test(
      'Multiple clusters with different serverIds serialize independently',
      () {
        const String projectId = 'project_multi_1';

        final LACluster cluster1 = LACluster(
          id: 'cluster_1',
          projectId: projectId,
          serverId: 'server_1',
          name: 'Docker Compose on Server 1',
          type: DeploymentType.dockerCompose,
        );

        final LACluster cluster2 = LACluster(
          id: 'cluster_2',
          projectId: projectId,
          serverId: 'server_2',
          name: 'Docker Swarm on Server 2',
        );

        final Map<String, dynamic> json1 = cluster1.toJson();
        final Map<String, dynamic> json2 = cluster2.toJson();

        expect(
          json1['serverId'],
          equals('server_1'),
          reason: 'cluster1 must have correct serverId',
        );
        expect(
          json2['serverId'],
          equals('server_2'),
          reason: 'cluster2 must have correct serverId',
        );
        expect(
          json1['serverId'],
          isNot(equals(json2['serverId'])),
          reason: 'clusters must have independent serverIds',
        );
      },
    );
  });
}
