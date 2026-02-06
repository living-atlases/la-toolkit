import 'package:flutter_test/flutter_test.dart';
import 'package:la_toolkit/models/la_project.dart';
import 'package:la_toolkit/models/la_variable_desc.dart';

void main() {
  group('toGeneratorJson Tests', () {
    late Map<String, dynamic> sampleProjectJson;

    setUp(() {
      sampleProjectJson = <String, dynamic>{
        'id': 'test-project-1',
        'longName': 'Test Project',
        'shortName': 'test',
        'domain': 'test.example.com',
        'dirName': 'test',
        'theme': 'clean',
        'useSSL': true,
        'isCreated': true,
        'isHub': false,
        'status': 'basicDefined',
        'advancedEdit': false,
        'advancedTune': false,
        'additionalVariables': '',
        'clusters': <Map<String, String>>[
          <String, String>{
            'id': 'cluster-docker-compose-1',
            'projectId': 'test-project-1',
            'serverId': 'server-1',
            'name': 'Docker Compose Cluster',
            'type': 'dockerCompose',
          },
        ],
        'servers': <Map<String, Object>>[
          <String, Object>{
            'id': 'server-1',
            'projectId': 'test-project-1',
            'name': 'server-1',
            'ip': '1.2.3.4',
            'sshPort': 22,
            'sshUser': 'ubuntu',
            'osName': 'Ubuntu',
            'osVersion': '22.04 LTS',
            'sshKey': <String, Object>{
              'name': 'key',
              'desc': 'desc',
              'encrypted': false,
              'private': 'priv',
              'public': 'pub',
            },
          },
        ],
        'serviceDeploys': <Map<String, dynamic>>[
          <String, dynamic>{
            'projectId': 'test-project-1',
            'serverId': 'server-1',
            'clusterId': 'cluster-docker-compose-1',
            'type': 'dockerCompose',
            'serviceId': 'docker_compose',
            'softwareVersions': <String, dynamic>{},
          },
        ],
        'variables': <dynamic>[],
        'serverServices': <String, List<dynamic>>{'server-1': <dynamic>[]},
        'clusterServices': <String, List<dynamic>>{
          'cluster-docker-compose-1': <dynamic>['docker_compose'],
        },
      };
    });

    test(
      'branding_source defaults to path and sets branding_build_source=local',
      () {
        final LAProject project = LAProject.fromJson(sampleProjectJson);
        project.serviceInUse('docker_compose', true);
        expect(project.isDockerClusterConfigured(), isTrue);

        final Map<String, dynamic> conf = project.toGeneratorJson();

        expect(
          conf['LA_variable_branding_source'],
          contains('../test-branding'),
        );
        expect(conf['LA_variable_branding_build_source'], equals('local'));
      },
    );

    test(
      'branding_build_source is git when branding_source is a git url (https)',
      () {
        final LAProject project = LAProject.fromJson(sampleProjectJson);
        project.serviceInUse('docker_compose', true);

        final LAVariableDesc brandingDesc = LAVariableDesc.get(
          'branding_source',
        );
        project.setVariable(
          brandingDesc,
          'https://github.com/living-atlases/branding.git',
        );

        final Map<String, dynamic> conf = project.toGeneratorJson();

        expect(
          conf['LA_variable_branding_source'],
          equals('https://github.com/living-atlases/branding.git'),
        );
        expect(conf['LA_variable_branding_build_source'], equals('git'));
      },
    );

    test(
      'branding_build_source is git when branding_source is a git url (ssh)',
      () {
        final LAProject project = LAProject.fromJson(sampleProjectJson);
        project.serviceInUse('docker_compose', true);

        final LAVariableDesc brandingDesc = LAVariableDesc.get(
          'branding_source',
        );
        project.setVariable(
          brandingDesc,
          'git@github.com:living-atlases/branding.git',
        );

        final Map<String, dynamic> conf = project.toGeneratorJson();

        expect(
          conf['LA_variable_branding_source'],
          equals('git@github.com:living-atlases/branding.git'),
        );
        expect(conf['LA_variable_branding_build_source'], equals('git'));
      },
    );

    test(
      'branding_build_source is local when branding_source is a directory path',
      () {
        final LAProject project = LAProject.fromJson(sampleProjectJson);
        project.serviceInUse('docker_compose', true);

        final LAVariableDesc brandingDesc = LAVariableDesc.get(
          'branding_source',
        );
        project.setVariable(brandingDesc, '/home/user/my-branding');

        final Map<String, dynamic> conf = project.toGeneratorJson();

        expect(
          conf['LA_variable_branding_source'],
          equals('/home/user/my-branding'),
        );
        expect(conf['LA_variable_branding_build_source'], equals('local'));
      },
    );
  });
}
