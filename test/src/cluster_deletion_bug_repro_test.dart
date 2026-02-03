import 'package:flutter_test/flutter_test.dart';
import 'package:la_toolkit/models/deployment_type.dart';
import 'package:la_toolkit/models/la_cluster.dart';
import 'package:la_toolkit/models/la_project.dart';
import 'package:la_toolkit/models/la_server.dart';
import 'package:la_toolkit/models/la_service_constants.dart';
import 'package:la_toolkit/models/la_service_deploy.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'Deleting a docker-compose cluster via deleteCluster should remove the assignment from the server',
    () {
      final LAProject project = LAProject(
        longName: 'Test Project',
        shortName: 'TP',
        domain: 'test.com',
        alaInstallRelease: '1.0.0',
        generatorRelease: '1.0.0',
      );

      // Disable all services to start clean
      project.getServicesNameListInUse().forEach((String serviceName) {
        project.getService(serviceName).use = false;
      });

      // 1. Add a server
      final LAServer server = LAServer(name: 'server1', projectId: project.id);
      project.upsertServer(server);

      // 2. Assign docker-compose to the server (this creates the cluster automatically)
      project.assignByType(server.id, DeploymentType.vm, <String>[dockerCompose]);

      // Verify it's assigned and cluster was created
      expect(
        project.getServerServices(serverId: server.id).contains(dockerCompose),
        isTrue,
        reason: 'dockerCompose should be assigned to server',
      );
      expect(project.clusters.length, equals(1));
      expect(project.clusters.first.type, equals(DeploymentType.dockerCompose));
      expect(project.clusters.first.serverId, equals(server.id));

      final LACluster cluster = project.clusters.first;

      // 3. Delete the cluster using deleteCluster (simulates clicking trash icon)
      project.deleteCluster(cluster);

      // 4. Verify the state is consistent
      expect(
        project.clusters.length,
        equals(0),
        reason: 'Cluster should be removed from clusters list',
      );
      expect(
        project.getServerServices(serverId: server.id).contains(dockerCompose),
        isFalse,
        reason: 'dockerCompose should be unassigned from the server',
      );

      final bool hasDeploy = project.serviceDeploys.any(
        (LAServiceDeploy sd) =>
            sd.serverId == server.id &&
            sd.serviceId == project.getService(dockerCompose).id,
      );
      expect(
        hasDeploy,
        isFalse,
        reason: 'Service deployment for dockerCompose should be removed',
      );

      // Check if the service is still "in use" globally
      expect(
        project.getService(dockerCompose).use,
        isFalse,
        reason:
            'dockerCompose service should no longer be in use if no clusters remain',
      );

      // The project should be valid now
      expect(
        project.allServicesAssigned(),
        isTrue,
        reason: 'All services should be assigned or not in use',
      );

      // Check if docker is still "enabled" globally
      expect(
        project.isDockerEnabled,
        isFalse,
        reason: 'isDockerEnabled should be false if no clusters remain',
      );
    },
  );

  test(
    'Deleting a docker-compose cluster with services should clean up all service deployments',
    () {
      final LAProject project = LAProject(
        longName: 'Test Project',
        shortName: 'TP',
        domain: 'test.com',
        alaInstallRelease: '1.0.0',
        generatorRelease: '1.0.0',
      );

      // Disable all services to start clean
      project.getServicesNameListInUse().forEach((String serviceName) {
        project.getService(serviceName).use = false;
      });

      // 1. Add a server
      final LAServer server = LAServer(name: 'server1', projectId: project.id);
      project.upsertServer(server);

      // 2. Assign docker-compose to the server
      project.assignByType(server.id, DeploymentType.vm, <String>[dockerCompose]);

      // 3. Get the cluster and assign services to it
      final LACluster cluster = project.clusters.first;

      // Assign some services to the cluster (e.g., solr)
      project.getService(solr).use = true;
      project.assignByType(cluster.id, DeploymentType.dockerCompose, <String>[solr]);

      // Verify services are assigned
      expect(
        project.getClusterServices(clusterId: cluster.id).contains(solr),
        isTrue,
        reason: 'Solr should be assigned to cluster',
      );

      final int initialServiceDeployCount = project.serviceDeploys.length;
      expect(
        initialServiceDeployCount >= 2,
        isTrue,
        reason: 'Should have service deploys for dockerCompose and solr',
      );

      // 4. Delete the cluster
      project.deleteCluster(cluster);

      // 5. Verify complete cleanup
      expect(
        project.clusters.length,
        equals(0),
        reason: 'Cluster should be removed',
      );

      expect(
        project.getServerServices(serverId: server.id).contains(dockerCompose),
        isFalse,
        reason: 'dockerCompose should be unassigned from server',
      );

      expect(
        project.clusterServices.containsKey(cluster.id),
        isFalse,
        reason: 'Cluster services mapping should be removed',
      );

      final bool hasClusterDeploys = project.serviceDeploys.any(
        (LAServiceDeploy sd) => sd.clusterId == cluster.id,
      );
      expect(
        hasClusterDeploys,
        isFalse,
        reason: 'No service deploys should reference the deleted cluster',
      );

      expect(
        project.getService(solr).use,
        isTrue,
        reason: 'Solr service should still be enabled (just not assigned)',
      );

      expect(
        project.allServicesAssigned(),
        isFalse,
        reason:
            'Solr is enabled but not assigned, so not all services assigned',
      );
    },
  );

  test(
    'Two VMs with independent docker-compose clusters: deleting one should not affect the other',
    () {
      final LAProject project = LAProject(
        longName: 'Test Project',
        shortName: 'TP',
        domain: 'test.com',
        alaInstallRelease: '1.0.0',
        generatorRelease: '1.0.0',
      );

      // Disable all services to start clean
      project.getServicesNameListInUse().forEach((String serviceName) {
        project.getService(serviceName).use = false;
      });

      // Enable dockerCompose
      project.getService(dockerCompose).use = true;

      // Create two different servers
      final LAServer server1 = LAServer(name: 'server1', projectId: project.id);
      final LAServer server2 = LAServer(name: 'server2', projectId: project.id);
      project.upsertServer(server1);
      project.upsertServer(server2);

      // Assign docker-compose to both servers (each gets its own cluster)
      project.assignByType(server1.id, DeploymentType.vm, <String>[dockerCompose]);
      project.assignByType(server2.id, DeploymentType.vm, <String>[dockerCompose]);

      expect(project.clusters.length, equals(2));

      final LACluster cluster1 = project.clusters.firstWhere(
        (LACluster c) => c.serverId == server1.id,
      );
      final LACluster cluster2 = project.clusters.firstWhere(
        (LACluster c) => c.serverId == server2.id,
      );

      // Both servers should have dockerCompose assigned
      expect(
        project.getServerServices(serverId: server1.id).contains(dockerCompose),
        isTrue,
      );
      expect(
        project.getServerServices(serverId: server2.id).contains(dockerCompose),
        isTrue,
      );

      // Delete cluster2 (from server2)
      project.deleteCluster(cluster2);

      // Verify server2's assignment is removed
      expect(project.clusters.length, equals(1));
      expect(project.clusters.first.id, equals(cluster1.id));

      expect(
        project.getServerServices(serverId: server2.id).contains(dockerCompose),
        isFalse,
        reason: 'dockerCompose should be removed from server2',
      );

      // Server1 should still have dockerCompose assigned
      expect(
        project.getServerServices(serverId: server1.id).contains(dockerCompose),
        isTrue,
        reason: 'dockerCompose should still be assigned to server1',
      );

      expect(
        project.isDockerEnabled,
        isTrue,
        reason: 'isDockerEnabled should still be true (cluster1 remains)',
      );
    },
  );
}
