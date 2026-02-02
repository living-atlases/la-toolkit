import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_toolkit/models/deployment_type.dart';
import 'package:la_toolkit/models/la_project.dart';
import 'package:la_toolkit/models/la_server.dart';
import 'package:la_toolkit/models/la_service_name.dart';
import 'package:la_toolkit/models/la_variable.dart';
import 'package:objectid/objectid.dart';

void main() {
  group('LAProject Conversion Tests', () {
    test('Test Case 1: Mixed Deployment (VM + Docker Compose)', () {
      final project = LAProject(
        longName: 'Test Project',
        shortName: 'testproj',
        domain: 'test.com',
        alaInstallRelease: '1.0.0',
        generatorRelease: '1.0.0',
      );

      // Create a server
      final server = LAServer(
        id: ObjectId().toString(),
        name: 's1',
        ip: '192.168.1.1',
        projectId: project.id,
      );
      project.upsertServer(server);

      // Assign ala_hub to VM
      project.serviceInUse('ala_hub', true);
      project.assign(server, ['ala_hub']);

      // Assign solrcloud and collectory to Docker Compose on the same server
      // First enable services
      project.serviceInUse('docker_compose', true);
      project.serviceInUse('solrcloud', true);
      project.serviceInUse('collectory', true);

      // Simulate assigning services to a docker compose cluster on s1
      project.assignByType(server.id, DeploymentType.dockerCompose, [
        'solrcloud',
        'collectory',
      ]);

      final json = project.toGeneratorJson();

      // Assertions
      expect(json['LA_use_ala_hub'], isTrue);
      expect(json['LA_use_solrcloud'], isTrue);

      // Let's assume for now we just want to verify what we DID change.
      expect(json['LA_use_docker_compose'], isTrue);

      // LA_solrcloud_hostname should contain s1 because it's hosted there (even if inside docker)
      expect(json['LA_solrcloud_hostname'], contains('s1'));

      // LA_collectory_hostname should contain s1 because it's hosted there (even if inside docker)
      expect(json['LA_collectory_hostname'], contains('s1'));

      // LA_docker_compose_hostname should contain s1
      expect(json['LA_docker_compose_hostname'], contains('s1'));

      // LA_nginx_docker_internal_aliases_by_host should contain alias for solrcloud
      final aliases =
          json['LA_nginx_docker_internal_aliases_by_host']
              as Map<String, dynamic>?;
      debugPrint(aliases.toString());
      expect(aliases, isNotNull);
      expect(aliases!.containsKey('s1'), isTrue);
    });

    test('Test Case 2: Inactive Docker Compose', () {
      final project = LAProject(
        longName: 'Test Project 2',
        shortName: 'testproj2',
        domain: 'test2.com',
        alaInstallRelease: '1.0.0',
        generatorRelease: '1.0.0',
      );

      final server = LAServer(
        id: ObjectId().toString(),
        name: 's2',
        ip: '192.168.1.2',
        projectId: project.id,
      );
      project.upsertServer(server);

      project.serviceInUse('docker_compose', true);
      project.assign(server, ['docker_compose']);

      project.unAssign(server, 'docker_compose');
      project.serviceInUse('docker_compose', true); // just the flag

      final json2 = project.toGeneratorJson();
      expect(json2['LA_use_docker_compose'], isNull);
      expect(json2['LA_docker_compose_hostname'], isNull);
    });

    test('Test Case 3: Bidirectional Consistency', () {
      final projectA = LAProject(
        longName: 'Test Project Bi',
        shortName: 'testbi',
        domain: 'bi.test.com',
        alaInstallRelease: '1.0.0',
        generatorRelease: '1.0.0',
      );
      final server = LAServer(
        id: ObjectId().toString(),
        name: 'sbi',
        ip: '10.0.0.1',
        projectId: projectA.id,
      );
      projectA.upsertServer(server);
      projectA.serviceInUse('ala_hub', true);
      projectA.assign(server, ['ala_hub']);

      projectA.serviceInUse('solrcloud', true);
      projectA.assignByType(server.id, DeploymentType.dockerCompose, [
        'solrcloud',
      ]);

      final jsonA = projectA.toGeneratorJson();
      final projectB = LAProject.fromObject(jsonA);

      expect(projectB.longName, projectA.longName);
      expect(projectB.shortName, projectA.shortName);
      expect(projectB.domain, projectA.domain);

      expect(projectB.getService('ala_hub').use, isTrue);
      expect(projectB.getService('solrcloud').use, isTrue);

      final hubHosts = projectB.getHostnames('ala_hub');
      expect(hubHosts, contains('sbi'));

      final solrHosts = projectB.getHostnames('solrcloud');
      expect(solrHosts, contains('sbi'));

      final jsonB = projectB.toGeneratorJson();

      expect(jsonB['LA_use_docker_compose'], jsonA['LA_use_docker_compose']);
      expect(
        jsonB['LA_docker_compose_hostname'],
        jsonA['LA_docker_compose_hostname'],
      );
      expect(jsonB['LA_solrcloud_hostname'], jsonA['LA_solrcloud_hostname']);
    });

    test('Test Case 4: Verify Non-Empty Hostnames and Generator Keys', () {
      final LAProject project = createProjectWithDockerAndVM();

      // Ensure required services for key check are enabled
      // The helper enables: ala_hub, docker_compose, solr.
      // We also want to check CAS, Species (ala_bie), Species Lists.
      project.serviceInUse('cas', true);
      project.serviceInUse('ala_bie', true);
      project.serviceInUse('species_lists', true);

      // Add custom variables for verification
      project.variables.add(
        LAVariable(
          nameInt: 'enable_data_quality',
          value: true,
          projectId: project.id,
          service: LAServiceName.ala_hub, // Dummy service assignment
        ),
      );
      project.variables.add(
        LAVariable(
          nameInt: 'ansible_user',
          value: 'ubuntu',
          projectId: project.id,
          service: LAServiceName.ala_hub,
        ),
      );

      final Map<String, dynamic> json = project.toGeneratorJson();

      expect(json['LA_use_docker_compose'], isTrue);
      expect(
        json['LA_docker_compose_hostname'],
        isNotEmpty,
        reason: 'Docker Compose hostname should not be empty',
      );
      expect(
        json['LA_solrcloud_hostname'],
        isNotEmpty,
        reason: 'Solrcloud hostname should not be empty',
      );
      expect(
        json['LA_hostnames'],
        isNotEmpty,
        reason: 'LA_hostnames should not be empty',
      );

      // Key mappings verification
      expect(
        json['LA_use_CAS'],
        isNotNull,
        reason: 'LA_use_CAS should be present (remapped from cas)',
      );
      expect(
        json['LA_use_species'],
        isNotNull,
        reason: 'LA_use_species should be present (remapped from ala_bie)',
      );
      expect(
        json['LA_use_species_lists'],
        isNotNull,
        reason: 'LA_use_species_lists should be present',
      );
      // Verify Lists maps hostname key correctly
      expect(
        json.containsKey('LA_lists_hostname'),
        isTrue,
        reason:
            'LA_lists_hostname should be present (remapped from species_lists hostname)',
      );

      // Defaults
      expect(json['LA_use_git'], isTrue);
      expect(json['LA_generate_branding'], isTrue);

      // Variable Mappings
      expect(
        json['LA_enable_data_quality'],
        isTrue,
        reason: 'LA_enable_data_quality should be mapped from variable',
      );
      expect(
        json['LA_variable_ansible_user'],
        equals('ubuntu'),
        reason: 'LA_variable_ansible_user should be mapped',
      );

      // Verify specific structure correctness
      expect(json['LA_docker_compose_hostname'], contains('s1'));
    });

    test(
      'Test Case 5: Single server with Docker Compose - hostnames should not be empty',
      () {
        final project = LAProject(
          longName: 'Test Docker Hostnames',
          shortName: 'testdh',
          domain: 'testdh.com',
          alaInstallRelease: '1.0.0',
          generatorRelease: '1.0.0',
        );

        final server = LAServer(
          id: ObjectId().toString(),
          name: 'docker-server-1',
          ip: '192.168.1.100',
          projectId: project.id,
        );
        project.upsertServer(server);

        // Enable and assign solrcloud to docker compose
        project.serviceInUse('docker_compose', true);
        project.serviceInUse('solrcloud', true);
        project.assignByType(server.id, DeploymentType.dockerCompose, [
          'solrcloud',
        ]);

        final json = project.toGeneratorJson();

        debugPrint('LA_solrcloud_hostname: ${json['LA_solrcloud_hostname']}');
        debugPrint(
          'LA_docker_compose_hostname: ${json['LA_docker_compose_hostname']}',
        );
        debugPrint('serverServices: ${project.serverServices}');
        debugPrint('clusterServices: ${project.clusterServices}');
        debugPrint(
          'clusters: ${project.clusters.map((c) => '${c.name} (id: ${c.id}, serverId: ${c.serverId})').toList()}',
        );

        expect(
          json['LA_use_solrcloud'],
          isTrue,
          reason: 'solrcloud should be in use',
        );
        expect(
          json['LA_use_docker_compose'],
          isTrue,
          reason: 'docker_compose should be in use',
        );
        expect(
          json['LA_solrcloud_hostname'],
          isNotEmpty,
          reason: 'solrcloud hostname should not be empty',
        );
        expect(
          json['LA_solrcloud_hostname'],
          contains('docker-server-1'),
          reason: 'solrcloud hostname should contain the server name',
        );
        expect(
          json['LA_docker_compose_hostname'],
          isNotEmpty,
          reason: 'docker_compose hostname should not be empty',
        );
        expect(
          json['LA_docker_compose_hostname'],
          contains('docker-server-1'),
          reason: 'docker_compose hostname should contain the server name',
        );
      },
    );

    test('Test Case 6: Multiple services in Docker Compose cluster', () {
      final project = LAProject(
        longName: 'Test Multiple Docker Services',
        shortName: 'testmds',
        domain: 'testmds.com',
        alaInstallRelease: '1.0.0',
        generatorRelease: '1.0.0',
      );

      final server = LAServer(
        id: ObjectId().toString(),
        name: 'docker-multi',
        ip: '192.168.1.200',
        projectId: project.id,
      );
      project.upsertServer(server);

      // Enable multiple services
      project.serviceInUse('docker_compose', true);
      project.serviceInUse('solrcloud', true);
      project.serviceInUse('collectory', true);
      project.serviceInUse('ala_hub', true);

      // Assign services to docker compose
      project.assignByType(server.id, DeploymentType.dockerCompose, [
        'solrcloud',
        'collectory',
        'ala_hub',
      ]);

      final json = project.toGeneratorJson();

      debugPrint('Test Case 6:');
      debugPrint('LA_solrcloud_hostname: ${json['LA_solrcloud_hostname']}');
      debugPrint('LA_collectory_hostname: ${json['LA_collectory_hostname']}');
      debugPrint('LA_ala_hub_hostname: ${json['LA_ala_hub_hostname']}');
      debugPrint(
        'clusters: ${project.clusters.map((c) => 'name=${c.name}, serverId=${c.serverId}').toList()}',
      );

      expect(json['LA_solrcloud_hostname'], contains('docker-multi'));
      expect(json['LA_collectory_hostname'], contains('docker-multi'));
      expect(json['LA_ala_hub_hostname'], contains('docker-multi'));
    });

    test(
      'Test Case 7: Mixed deployment - VM and Docker Compose on same server',
      () {
        final project = LAProject(
          longName: 'Test Mixed Deployment',
          shortName: 'testmixed',
          domain: 'testmixed.com',
          alaInstallRelease: '1.0.0',
          generatorRelease: '1.0.0',
        );

        final server = LAServer(
          id: ObjectId().toString(),
          name: 'mixed-server',
          ip: '192.168.1.50',
          projectId: project.id,
        );
        project.upsertServer(server);

        // Assign CAS to VM
        project.serviceInUse('cas', true);
        project.assign(server, ['cas']);

        // Assign solrcloud to Docker Compose
        project.serviceInUse('docker_compose', true);
        project.serviceInUse('solrcloud', true);
        project.assignByType(server.id, DeploymentType.dockerCompose, [
          'solrcloud',
        ]);

        final json = project.toGeneratorJson();

        debugPrint('Test Case 7:');
        debugPrint('LA_cas_hostname: ${json['LA_cas_hostname']}');
        debugPrint('LA_solrcloud_hostname: ${json['LA_solrcloud_hostname']}');

        expect(json['LA_cas_hostname'], contains('mixed-server'));
        expect(json['LA_solrcloud_hostname'], contains('mixed-server'));
      },
    );

    test('Test Case 8: Two servers with separate Docker Compose clusters', () {
      final project = LAProject(
        longName: 'Test Two Docker Servers',
        shortName: 'testtds',
        domain: 'testtds.com',
        alaInstallRelease: '1.0.0',
        generatorRelease: '1.0.0',
      );

      final server1 = LAServer(
        id: ObjectId().toString(),
        name: 'docker-srv1',
        ip: '192.168.1.10',
        projectId: project.id,
      );
      final server2 = LAServer(
        id: ObjectId().toString(),
        name: 'docker-srv2',
        ip: '192.168.1.11',
        projectId: project.id,
      );
      project.upsertServer(server1);
      project.upsertServer(server2);

      // Enable services
      project.serviceInUse('docker_compose', true);
      project.serviceInUse('solrcloud', true);
      project.serviceInUse('collectory', true);

      // Assign solrcloud to server1's docker compose
      project.assignByType(server1.id, DeploymentType.dockerCompose, [
        'solrcloud',
      ]);

      // Assign collectory to server2's docker compose
      project.assignByType(server2.id, DeploymentType.dockerCompose, [
        'collectory',
      ]);

      final json = project.toGeneratorJson();

      debugPrint('Test Case 8:');
      debugPrint('LA_solrcloud_hostname: ${json['LA_solrcloud_hostname']}');
      debugPrint('LA_collectory_hostname: ${json['LA_collectory_hostname']}');
      debugPrint(
        'LA_docker_compose_hostname: ${json['LA_docker_compose_hostname']}',
      );

      expect(json['LA_solrcloud_hostname'], contains('docker-srv1'));
      expect(json['LA_collectory_hostname'], contains('docker-srv2'));
      expect(json['LA_docker_compose_hostname'], contains('docker-srv1'));
      expect(json['LA_docker_compose_hostname'], contains('docker-srv2'));
    });

    test(
      'Test Case 9: getHostnames method directly for Docker Compose service',
      () {
        final project = LAProject(
          longName: 'Test GetHostnames',
          shortName: 'testgh',
          domain: 'testgh.com',
          alaInstallRelease: '1.0.0',
          generatorRelease: '1.0.0',
        );

        final server = LAServer(
          id: ObjectId().toString(),
          name: 'hostname-test-srv',
          ip: '192.168.1.99',
          projectId: project.id,
        );
        project.upsertServer(server);

        project.serviceInUse('docker_compose', true);
        project.serviceInUse('solrcloud', true);
        project.assignByType(server.id, DeploymentType.dockerCompose, [
          'solrcloud',
        ]);

        final hostnames = project.getHostnames('solrcloud');

        debugPrint('Test Case 9:');
        debugPrint('Direct getHostnames for solrcloud: $hostnames');
        debugPrint('Server ID: ${server.id}');
        debugPrint(
          'Clusters: ${project.clusters.map((c) => 'id=${c.id}, serverId=${c.serverId}, type=${c.type}').toList()}',
        );
        debugPrint('clusterServices: ${project.clusterServices}');

        expect(
          hostnames,
          isNotEmpty,
          reason: 'getHostnames should return at least one hostname',
        );
        expect(
          hostnames,
          contains('hostname-test-srv'),
          reason: 'getHostnames should return the correct server name',
        );
      },
    );
  });
}

LAProject createProjectWithDockerAndVM() {
  final project = LAProject(
    longName: 'Test Project',
    shortName: 'testproj',
    domain: 'test.com',
    alaInstallRelease: '1.0.0',
    generatorRelease: '1.0.0',
  );

  // Create a server
  final server = LAServer(
    id: ObjectId().toString(),
    name: 's1',
    ip: '192.168.1.1',
    projectId: project.id,
  );
  project.upsertServer(server);

  // Assign ala_hub to VM
  project.serviceInUse('ala_hub', true);
  project.assign(server, ['ala_hub']);

  // Assign solrcloud to Docker Compose on the same server
  project.serviceInUse('docker_compose', true);
  project.serviceInUse('solrcloud', true);
  project.assignByType(server.id, DeploymentType.dockerCompose, ['solrcloud']);

  return project;
}
