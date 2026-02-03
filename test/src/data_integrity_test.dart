import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_toolkit/models/deployment_type.dart';
import 'package:la_toolkit/models/la_cluster.dart';
import 'package:la_toolkit/models/la_project.dart';
import 'package:la_toolkit/models/la_server.dart';
import 'package:la_toolkit/models/la_service.dart';
import 'package:la_toolkit/models/la_service_constants.dart';
import 'package:la_toolkit/models/la_service_deploy.dart';
import 'package:objectid/objectid.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Data Integrity Tests - Docker Compose on VMs', () {
    test('No duplicate services between serverServices and clusterServices', () {
      final LAProject p = LAProject();
      final LAServer vm1 = LAServer(
        name: 'vm1',
        ip: '10.0.0.1',
        projectId: p.id,
      );
      p.upsertServer(vm1);

      // Assign collectory to VM
      p.assign(vm1, <String>[collectory]);

      // Check that collectory is in serverServices
      expect(
        p.getServicesNameListInServer(vm1.id),
        contains(collectory),
        reason: 'collectory should be in serverServices for vm1',
      );

      // Manually trigger docker-compose creation (like in assignByType)
      p.assignByType(vm1.id, DeploymentType.dockerCompose, <String>[
        dockerCompose,
      ]);

      // Check that collectory is NOT in any cluster's services
      final List<LACluster> clusters = p.clusters
          .where((c) => c.serverId == vm1.id)
          .toList();
      for (final LACluster cluster in clusters) {
        final List<String> clusterServices =
            p.clusterServices[cluster.id] ?? <String>[];
        expect(
          clusterServices,
          isNot(contains(collectory)),
          reason:
              'collectory should NOT be in cluster services when assigned to VM',
        );
      }

      // Validate data integrity
      final List<String> errors = p.validateDataIntegrity();
      expect(errors, isEmpty, reason: 'No integrity errors should be detected');
    });

    test('Cannot have multiple docker-compose clusters in same VM', () {
      final LAProject p = LAProject();
      final LAServer vm1 = LAServer(
        name: 'vm1',
        ip: '10.0.0.1',
        projectId: p.id,
      );
      p.upsertServer(vm1);

      // Create first docker-compose cluster
      p.assignByType(vm1.id, DeploymentType.dockerCompose, <String>[
        dockerCompose,
        collectory,
      ]);

      final int clustersAfterFirst = p.clusters
          .where(
            (c) =>
                c.serverId == vm1.id && c.type == DeploymentType.dockerCompose,
          )
          .length;
      expect(
        clustersAfterFirst,
        equals(1),
        reason: 'Should have exactly 1 docker-compose cluster',
      );

      // Try to create second docker-compose cluster (should not create duplicate)
      p.assignByType(vm1.id, DeploymentType.dockerCompose, <String>[alaHub]);

      final int clustersAfterSecond = p.clusters
          .where(
            (c) =>
                c.serverId == vm1.id && c.type == DeploymentType.dockerCompose,
          )
          .length;
      expect(
        clustersAfterSecond,
        equals(1),
        reason:
            'Should still have exactly 1 docker-compose cluster (no duplicates)',
      );

      final List<String> errors = p.validateDataIntegrity();
      expect(errors, isEmpty, reason: 'No integrity errors should be detected');
    });

    test(
      'Docker services should only be in serverServices, never in clusterServices',
      () {
        final LAProject p = LAProject();
        final LAServer vm1 = LAServer(
          name: 'vm1',
          ip: '10.0.0.1',
          projectId: p.id,
        );
        p.upsertServer(vm1);

        // Assign docker-compose to VM (use assign() which uses DeploymentType.vm)
        p.assign(vm1, <String>[dockerCompose, collectory]);

        // Check that dockerCompose is in serverServices
        final List<String> serverServices = p.getServicesNameListInServer(
          vm1.id,
        );
        expect(
          serverServices,
          contains(dockerCompose),
          reason: 'dockerCompose should be in serverServices',
        );

        // Check that dockerCompose is NOT in any clusterServices
        for (final LACluster cluster in p.clusters.where(
          (c) => c.serverId == vm1.id,
        )) {
          final List<String> clusterServices =
              p.clusterServices[cluster.id] ?? <String>[];
          expect(
            clusterServices,
            isNot(contains(dockerCompose)),
            reason: 'dockerCompose should NOT be in clusterServices',
          );
        }

        final List<String> errors = p.validateDataIntegrity();
        expect(
          errors,
          isEmpty,
          reason: 'No docker service misplacement errors',
        );
      },
    );

    test('Assignments can overlap between VM and Cluster', () {
      final LAProject p = LAProject();
      final LAServer vm1 = LAServer(
        name: 'vm1',
        ip: '10.0.0.1',
        projectId: p.id,
      );
      p.upsertServer(vm1);

      // Assign collectory to VM first
      p.assign(vm1, <String>[collectory]);
      expect(
        p.getServicesNameListInServer(vm1.id),
        contains(collectory),
        reason: 'collectory should be in VM',
      );

      // Create cluster
      p.assignByType(vm1.id, DeploymentType.dockerCompose, <String>[
        dockerCompose,
      ]);

      final LACluster? cluster = p.clusters.firstWhereOrNull(
        (c) => c.serverId == vm1.id && c.type == DeploymentType.dockerCompose,
      );
      expect(cluster, isNotNull, reason: 'Cluster should be created');

      // Now assign collectory to cluster (should NOT remove from VM)
      p.assignByType(cluster!.id, DeploymentType.dockerCompose, <String>[
        collectory,
      ]);

      // Verify collectory is STILL in VM (Overlap allowed)
      expect(
        p.getServicesNameListInServer(vm1.id),
        contains(collectory),
        reason: 'collectory should be in VM and in cluster',
      );

      // Verify collectory is in cluster
      expect(
        p.clusterServices[cluster.id],
        contains(collectory),
        reason: 'collectory should be in cluster',
      );

      // Unassign from VM should NOT remove from Cluster
      p.unAssign(vm1, collectory);

      // Verify removed from VM
      expect(
        p.getServicesNameListInServer(vm1.id),
        isNot(contains(collectory)),
        reason: 'collectory should be removed from VM',
      );

      // Verify REMAINS in Cluster
      expect(
        p.clusterServices[cluster.id],
        contains(collectory),
        reason: 'collectory should remain in cluster after unassign from VM',
      );
    });

    test(
      'Multiple VMs with separate docker-compose clusters do not interfere',
      () {
        final LAProject p = LAProject();
        final LAServer vm1 = LAServer(
          name: 'vm1',
          ip: '10.0.0.1',
          projectId: p.id,
        );
        final LAServer vm2 = LAServer(
          name: 'vm2',
          ip: '10.0.0.2',
          projectId: p.id,
        );
        p.upsertServer(vm1);
        p.upsertServer(vm2);

        // Assign services to different VMs
        p.assign(vm1, <String>[collectory]);
        p.assign(vm2, <String>[alaHub]);

        // Create docker-compose on both
        p.assignByType(vm1.id, DeploymentType.dockerCompose, <String>[
          dockerCompose,
        ]);
        p.assignByType(vm2.id, DeploymentType.dockerCompose, <String>[
          dockerCompose,
        ]);

        // Check each VM has separate cluster
        final List<LACluster> vm1Clusters = p.clusters
            .where(
              (c) =>
                  c.serverId == vm1.id &&
                  c.type == DeploymentType.dockerCompose,
            )
            .toList();
        final List<LACluster> vm2Clusters = p.clusters
            .where(
              (c) =>
                  c.serverId == vm2.id &&
                  c.type == DeploymentType.dockerCompose,
            )
            .toList();

        expect(
          vm1Clusters.length,
          equals(1),
          reason: 'vm1 should have 1 docker-compose cluster',
        );
        expect(
          vm2Clusters.length,
          equals(1),
          reason: 'vm2 should have 1 docker-compose cluster',
        );
        expect(
          vm1Clusters[0].id,
          isNot(equals(vm2Clusters[0].id)),
          reason: 'Should be different clusters',
        );

        // Verify no service duplication
        final List<String> errors = p.validateDataIntegrity();
        expect(
          errors,
          isEmpty,
          reason: 'No integrity errors with separate VMs',
        );
      },
    );

    test(
      'fromJson prevents duplicate services when rebuilding from serviceDeploys',
      () {
        // Create a project where serviceDeploy has a service that's also in serverServices
        // This simulates corrupted data coming from server
        final LAProject originalP = LAProject(
          longName: 'Test Project',
          shortName: 'TP',
          domain: 'test.com',
        );
        final LAServer vm1 = LAServer(
          name: 'vm1',
          ip: '10.0.0.1',
          projectId: originalP.id,
        );
        originalP.upsertServer(vm1);

        // Assign collectory to VM
        originalP.serverServices[vm1.id] = <String>[collectory, dockerCompose];

        // Create cluster with serviceDeploy that also references collectory
        final LACluster cluster = LACluster(
          id: ObjectId().toString(),
          projectId: originalP.id,
          serverId: vm1.id,
          type: DeploymentType.dockerCompose,
        );
        originalP.clusters.add(cluster);

        // Add serviceDeploy for collectory in the cluster
        final LAService collectoryService = originalP.getService(collectory);
        final LAServiceDeploy deploy = LAServiceDeploy(
          projectId: originalP.id,
          serverId: vm1.id,
          clusterId: cluster.id,
          type: DeploymentType.dockerCompose,
          serviceId: collectoryService.id,
        );
        originalP.serviceDeploys.add(deploy);
        originalP.clusterServices[cluster.id] = <String>[];

        // Serialize and deserialize (this triggers _rebuildEmptyClusterServices)
        final Map<String, dynamic> json = originalP.toJson();
        final LAProject restoredP = LAProject.fromJson(json);

        // Find the restored server by name
        final LAServer? restoredServer = restoredP.servers.firstWhereOrNull(
          (s) => s.name == 'vm1',
        );
        expect(restoredServer, isNotNull);

        // Find the restored cluster using restored server's ID
        final LACluster? restoredCluster = restoredP.clusters.firstWhereOrNull(
          (c) =>
              c.serverId == restoredServer!.id &&
              c.type == DeploymentType.dockerCompose,
        );
        expect(restoredCluster, isNotNull);

        // CRITICAL: clusterServices should NOT include collectory because it's already in serverServices
        final List<String> restoredClusterServices =
            restoredP.clusterServices[restoredCluster!.id] ?? <String>[];
        expect(
          restoredClusterServices,
          isNot(contains(collectory)),
          reason:
              'collectory should NOT be in clusterServices because it is already in serverServices',
        );

        // collectory should still be in serverServices
        expect(
          restoredP.serverServices[restoredServer!.id],
          contains(collectory),
          reason: 'collectory should remain in serverServices',
        );

        // Verify no integrity errors
        final List<String> errors = restoredP.validateDataIntegrity();
        expect(
          errors,
          isEmpty,
          reason:
              'fromJson should prevent duplicates via _rebuildEmptyClusterServices',
        );
      },
    );

    test('fromJson detects corrupted data when manually created', () {
      // Create a project with manually created corruption (not through normal API)
      final LAProject originalP = LAProject(
        longName: 'Test Project',
        shortName: 'TP',
        domain: 'test.com',
      );
      final LAServer vm1 = LAServer(
        name: 'vm1',
        ip: '10.0.0.1',
        projectId: originalP.id,
      );
      originalP.upsertServer(vm1);

      // Manually create corruption (circumventing the API)
      originalP.serverServices[vm1.id] = <String>[collectory, dockerCompose];
      final LACluster cluster = LACluster(
        id: ObjectId().toString(),
        projectId: originalP.id,
        serverId: vm1.id,
        type: DeploymentType.dockerCompose,
      );
      originalP.clusters.add(cluster);
      originalP.clusterServices[cluster.id] = <String>[
        collectory,
      ]; // Manual corruption

      // Serialize and deserialize
      final Map<String, dynamic> json = originalP.toJson();
      final LAProject restoredP = LAProject.fromJson(json);

      // fromJson should DETECT the corruption via validateDataIntegrity
      final List<String> errors = restoredP.validateDataIntegrity();
      expect(
        errors,
        isNotEmpty,
        reason: 'fromJson should detect manually created corruption',
      );

      // Verify corruption is still there (fromJson detected it but did not auto-fix)
      expect(
        restoredP.clusterServices[cluster.id],
        contains(collectory),
        reason:
            'Manually created corruption should be preserved (not auto-fixed)',
      );
    });

    test(
      'clusterServices rebuilds from serviceDeploys when empty after fromJson',
      () {
        // Simulate the scenario where data loads from server with serviceDeploys
        // but empty clusterServices
        final LAProject p = LAProject();
        final LAServer vm1 = LAServer(
          name: 'vm1',
          ip: '10.0.0.1',
          projectId: p.id,
        );
        p.upsertServer(vm1);

        // Create a docker-compose cluster
        final LACluster cluster = LACluster(
          id: ObjectId().toString(),
          projectId: p.id,
          serverId: vm1.id,
          type: DeploymentType.dockerCompose,
        );
        p.clusters.add(cluster);

        // Add serviceDeploys (simulating they were loaded from server)
        final LAService collectoryService = p.getService(collectory);
        final LAServiceDeploy deploy = LAServiceDeploy(
          projectId: p.id,
          serverId: vm1.id,
          clusterId: cluster.id,
          type: DeploymentType.dockerCompose,
          serviceId: collectoryService.id,
        );
        p.serviceDeploys.add(deploy);

        // CRITICAL: Simulate empty clusterServices (as if loaded from server without it)
        p.clusterServices[cluster.id] = <String>[];

        // Verify it's empty before rebuild
        expect(
          p.clusterServices[cluster.id],
          isEmpty,
          reason: 'clusterServices should be empty initially',
        );

        // Serialize and deserialize (this triggers _rebuildEmptyClusterServices)
        final Map<String, dynamic> json = p.toJson();
        final LAProject restoredP = LAProject.fromJson(json);

        // Find the restored cluster
        final LACluster? restoredCluster = restoredP.clusters.firstWhereOrNull(
          (c) => c.serverId == vm1.id && c.type == DeploymentType.dockerCompose,
        );
        expect(
          restoredCluster,
          isNotNull,
          reason: 'Cluster should exist after restore',
        );

        // Verify clusterServices was rebuilt
        final List<String> restoredServices =
            restoredP.clusterServices[restoredCluster!.id] ?? <String>[];
        expect(
          restoredServices,
          contains(collectory),
          reason: 'clusterServices should be rebuilt from serviceDeploys',
        );
      },
    );

    test('clusterServices stays empty if no serviceDeploys for cluster', () {
      // Scenario: cluster exists but has no serviceDeploys
      final LAProject p = LAProject();
      final LAServer vm1 = LAServer(
        name: 'vm1',
        ip: '10.0.0.1',
        projectId: p.id,
      );
      p.upsertServer(vm1);

      final LACluster cluster = LACluster(
        id: ObjectId().toString(),
        projectId: p.id,
        serverId: vm1.id,
        type: DeploymentType.dockerCompose,
      );
      p.clusters.add(cluster);
      p.clusterServices[cluster.id] = <String>[];

      // No serviceDeploys for this cluster

      // Serialize and deserialize
      final Map<String, dynamic> json = p.toJson();
      final LAProject restoredP = LAProject.fromJson(json);

      final LACluster? restoredCluster = restoredP.clusters.firstWhereOrNull(
        (c) => c.serverId == vm1.id && c.type == DeploymentType.dockerCompose,
      );

      final List<String> restoredServices =
          restoredP.clusterServices[restoredCluster!.id] ?? <String>[];
      expect(
        restoredServices,
        isEmpty,
        reason: 'clusterServices should stay empty if no serviceDeploys',
      );
    });

    test('clusterServices rebuild works correctly', () {
      // Scenario: Manual serviceDeploy creation with clusterId set
      final LAProject p = LAProject();
      final LAServer vm1 = LAServer(
        name: 'vm1',
        ip: '10.0.0.1',
        projectId: p.id,
      );
      p.upsertServer(vm1);

      // Create a docker-compose cluster
      final LACluster cluster = LACluster(
        id: ObjectId().toString(),
        projectId: p.id,
        serverId: vm1.id,
        type: DeploymentType.dockerCompose,
      );
      p.clusters.add(cluster);

      // Create serviceDeploy with explicit clusterId
      final LAService collectoryService = p.getService(collectory);
      final LAServiceDeploy deploy = LAServiceDeploy(
        projectId: p.id,
        serverId: vm1.id,
        clusterId: cluster.id,
        // Explicit clusterId
        type: DeploymentType.dockerCompose,
        serviceId: collectoryService.id,
      );
      p.serviceDeploys.add(deploy);

      // Simulate empty clusterServices
      p.clusterServices[cluster.id] = <String>[];

      // Serialize and deserialize to trigger rebuild
      final Map<String, dynamic> json = p.toJson();
      final LAProject restoredP = LAProject.fromJson(json);

      // Find restored cluster
      final LACluster? restoredCluster = restoredP.clusters.firstWhereOrNull(
        (c) => c.serverId == vm1.id && c.type == DeploymentType.dockerCompose,
      );

      expect(restoredCluster, isNotNull);

      // Verify rebuild
      final List<String> services =
          restoredP.clusterServices[restoredCluster!.id] ?? <String>[];
      expect(
        services,
        contains(collectory),
        reason: 'clusterServices should be rebuilt from serviceDeploys',
      );
    });

    test('Cluster serverId is preserved when upserting by name (round-trip)', () {
      // This test prevents the bug where serverId becomes null after deserializing
      final LAProject p = LAProject();
      final LAServer vm1 = LAServer(
        name: 'vm1',
        ip: '10.0.0.1',
        projectId: p.id,
      );
      p.upsertServer(vm1);

      // Assign docker-compose to VM (creates cluster with serverId)
      p.assign(vm1, <String>[dockerCompose, collectory]);

      // Get the cluster that was created
      final LACluster? cluster = p.clusters.firstWhereOrNull(
        (c) => c.type == DeploymentType.dockerCompose && c.serverId == vm1.id,
      );
      expect(cluster, isNotNull);
      expect(cluster!.serverId, equals(vm1.id));

      // Simulate round-trip: serialize and deserialize
      final Map<String, dynamic> json = p.toJson();
      final LAProject restoredP = LAProject.fromJson(json);

      // Verify serverId is preserved after deserialization
      final LACluster? restoredCluster = restoredP.clusters.firstWhereOrNull(
        (c) => c.type == DeploymentType.dockerCompose,
      );
      expect(restoredCluster, isNotNull);
      expect(
        restoredCluster!.serverId,
        isNotNull,
        reason: 'serverId should NOT be null after deserialization',
      );
      expect(
        restoredCluster.serverId,
        equals(vm1.id),
        reason: 'serverId should match VM id',
      );
    });

    test(
      'Server recovery: Docker Compose services not duplicated in serverServices',
      () {
        // Simulate a project loaded from server where:
        // 1. collectory is assigned to Docker Compose cluster
        // 2. serviceDeploys reference the cluster with collectory
        // 3. clusterServices is empty (needs rebuild)

        final LAProject p = LAProject();
        final LAServer vm1 = LAServer(
          name: 'vm1',
          ip: '10.0.0.1',
          projectId: p.id,
        );
        p.upsertServer(vm1);

        // Assign docker_compose to VM
        p.serverServices[vm1.id] = <String>[dockerCompose];

        // Create docker-compose cluster
        final LACluster cluster = LACluster(
          id: ObjectId().toString(),
          projectId: p.id,
          serverId: vm1.id,
          type: DeploymentType.dockerCompose,
        );
        p.clusters.add(cluster);

        // Create serviceDeploy for collectory in the cluster
        final LAService collectoryService = p.getService(collectory);
        final LAServiceDeploy deploy = LAServiceDeploy(
          projectId: p.id,
          serverId: vm1.id,
          clusterId: cluster.id,
          type: DeploymentType.dockerCompose,
          serviceId: collectoryService.id,
        );
        p.serviceDeploys.add(deploy);
        p.clusterServices[cluster.id] = <String>[];

        // Serialize and deserialize (simulating server recovery)
        final Map<String, dynamic> json = p.toJson();
        final LAProject restoredP = LAProject.fromJson(json);

        // Find the restored server
        final LAServer? restoredServer = restoredP.servers.firstWhereOrNull(
          (s) => s.name == 'vm1',
        );
        expect(restoredServer, isNotNull);

        // Find the restored cluster using the restored server's ID
        final LACluster? restoredCluster = restoredP.clusters.firstWhereOrNull(
          (c) =>
              c.serverId == restoredServer!.id &&
              c.type == DeploymentType.dockerCompose,
        );
        expect(restoredCluster, isNotNull);

        // CRITICAL: collectory should be in clusterServices
        final List<String> clusterServices =
            restoredP.clusterServices[restoredCluster!.id] ?? <String>[];
        expect(
          clusterServices,
          contains(collectory),
          reason: 'collectory should be in clusterServices after recovery',
        );

        // CRITICAL: collectory should NOT be in serverServices
        final List<String> serverServices =
            restoredP.serverServices[restoredServer!.id] ?? <String>[];
        expect(
          serverServices,
          isNot(contains(collectory)),
          reason:
              'collectory should NOT be in serverServices (only docker_compose should be)',
        );

        // Only docker_compose should be in serverServices
        expect(
          serverServices,
          contains(dockerCompose),
          reason: 'docker_compose should be in serverServices',
        );

        // Verify no integrity errors
        final List<String> errors = restoredP.validateDataIntegrity();
        expect(
          errors,
          isEmpty,
          reason: 'No integrity errors after server recovery',
        );
      },
    );
  });
}
