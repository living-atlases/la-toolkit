import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_toolkit/models/deployment_type.dart';
import 'package:la_toolkit/models/la_project.dart';
import 'package:la_toolkit/models/la_server.dart';
import 'package:la_toolkit/models/la_variable.dart';
import 'package:la_toolkit/models/la_service_name.dart';
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
