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
        p.assign(vm1, [dockerCompose, collectory]); // Assigned both to VM

        final List<String> warnings = p.getDockerComposeVMWarnings();
        expect(warnings, isNotEmpty);
        expect(
          warnings[0],
          contains('directly, but this VM is a Docker Compose host'),
        );
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
        p.assign(vm1, [dockerCompose]);
        p.assignByType(vm1.id, DeploymentType.dockerCompose, [collectory]);

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
        p.assign(vm1, [collectory]);

        final List<String> warnings = p.getDockerComposeVMWarnings();
        expect(warnings, isEmpty);
      },
    );
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
        p.assign(vm1, [dockerCompose]);

        // 1. Assign to Docker Cluster
        p.assignByType(vm1.id, DeploymentType.dockerCompose, [collectory]);
        expect(
          p.getClusterServices(clusterId: p.clusters.first.id),
          contains(collectory),
        );

        // 2. Assign to VM
        p.assign(vm1, [collectory]);

        // 3. Verify it is in BOTH (Relaxing exclusivity)
        expect(p.getServerServices(serverId: vm1.id), contains(collectory));
        expect(
          p.getClusterServices(clusterId: p.clusters.first.id),
          contains(collectory),
          reason: "Should still be in cluster",
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
          reason: "Should remain in cluster after unassign from VM",
        );
      },
    );
  });
}
