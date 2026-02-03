import 'package:flutter_test/flutter_test.dart';
import 'package:la_toolkit/models/deployment_type.dart';
import 'package:la_toolkit/models/la_project.dart';
import 'package:la_toolkit/models/la_server.dart';
import 'package:objectid/objectid.dart';

void main() {
  test(
    'LA_nginx_docker_internal_aliases_by_host should include all docker hosts',
    () {
      final project = LAProject(
        longName: 'Test Nginx Aliases',
        shortName: 'testnga',
        domain: 'test.com',
        alaInstallRelease: '1.0.0',
        generatorRelease: '1.0.0',
      );

      // Create 3 servers
      final server1 = LAServer(
        id: ObjectId().toString(),
        name: 'host1',
        ip: '192.168.1.1',
        projectId: project.id,
      );
      final server2 = LAServer(
        id: ObjectId().toString(),
        name: 'host2',
        ip: '192.168.1.2',
        projectId: project.id,
      );
      final server3 = LAServer(
        id: ObjectId().toString(),
        name: 'host3',
        ip: '192.168.1.3',
        projectId: project.id,
      );
      project.upsertServer(server1);
      project.upsertServer(server2);
      project.upsertServer(server3);

      // Enable services
      project.serviceInUse('docker_compose', true);
      project.serviceInUse('collectory', true);
      project.serviceInUse('images', true);
      project.serviceInUse('ala_bie', true);

      // Assign services to clusters on different hosts
      project.assignByType(server1.id, DeploymentType.dockerCompose, [
        'collectory',
      ]);
      project.assignByType(server2.id, DeploymentType.dockerCompose, [
        'images',
      ]);
      project.assignByType(server3.id, DeploymentType.dockerCompose, [
        'ala_bie',
      ]);

      final json = project.toGeneratorJson();
      final aliases =
          json['LA_nginx_docker_internal_aliases_by_host']
              as Map<String, dynamic>?;

      print('Aliases: $aliases');

      expect(aliases, isNotNull);
      expect(
        aliases!.containsKey('host1'),
        isTrue,
        reason: 'host1 should be in aliases',
      );
      expect(
        aliases.containsKey('host2'),
        isTrue,
        reason: 'host2 should be in aliases',
      );
      expect(
        aliases.containsKey('host3'),
        isTrue,
        reason: 'host3 should be in aliases',
      );
    },
  );
}
