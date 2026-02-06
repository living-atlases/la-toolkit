import 'package:flutter_test/flutter_test.dart';
import 'package:la_toolkit/models/deployment_type.dart';
import 'package:la_toolkit/models/la_project.dart';
import 'package:la_toolkit/models/la_server.dart';
import 'package:objectid/objectid.dart';

void main() {
  test(
    'LA_nginx_docker_internal_aliases_by_host should be sorted by hostname',
    () {
      final LAProject project = LAProject(
        longName: 'Test Nginx Aliases Sorted',
        shortName: 'testngs',
        domain: 'test.com',
        alaInstallRelease: '1.0.0',
        generatorRelease: '1.0.0',
      );

      // Create servers with names that are NOT compliant with alphabetical order when inserted
      // "zebra", "alpha", "beta"
      final LAServer server1 = LAServer(
        id: ObjectId().toString(),
        name: 'zebra',
        ip: '192.168.1.1',
        projectId: project.id,
      );
      final LAServer server2 = LAServer(
        id: ObjectId().toString(),
        name: 'alpha',
        ip: '192.168.1.2',
        projectId: project.id,
      );
      final LAServer server3 = LAServer(
        id: ObjectId().toString(),
        name: 'beta',
        ip: '192.168.1.3',
        projectId: project.id,
      );

      // Insert order: zebra, alpha, beta
      project.upsertServer(server1);
      project.upsertServer(server2);
      project.upsertServer(server3);

      // Enable services
      project.serviceInUse('docker_compose', true);
      project.serviceInUse('collectory', true);
      project.serviceInUse('images', true);
      project.serviceInUse('ala_bie', true);

      // Assign to docker compose
      project.assignByType(server1.id, DeploymentType.dockerCompose, <String>[
        'collectory',
      ]);
      project.assignByType(server2.id, DeploymentType.dockerCompose, <String>[
        'images',
      ]);
      project.assignByType(server3.id, DeploymentType.dockerCompose, <String>[
        'ala_bie',
      ]);

      final Map<String, dynamic> json = project.toGeneratorJson();
      final Map<String, dynamic> aliases =
          json['LA_nginx_docker_internal_aliases_by_host']
              as Map<String, dynamic>;

      final List<String> keys = aliases.keys.toList();
      expect(keys, equals(['alpha', 'beta', 'zebra']));
    },
  );
}
