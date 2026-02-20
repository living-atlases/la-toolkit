import 'package:flutter_test/flutter_test.dart';
import 'package:la_toolkit/models/la_project.dart';

void main() {
  group('toGeneratorJson Pipelines Version Repro', () {
    late Map<String, dynamic> sampleProjectJson;

    setUp(() {
      sampleProjectJson = <String, dynamic>{
        'id': 'test-project-pipelines',
        'longName': 'Test Project Pipelines',
        'shortName': 'testpipe',
        'domain': 'test.example.com',
        'dirName': 'testpipe',
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
            'projectId': 'test-project-pipelines',
            'serverId': 'server-1',
            'name': 'Docker Compose Cluster',
            'type': 'dockerCompose',
          },
        ],
        'servers': <Map<String, Object>>[
          <String, Object>{
            'id': 'server-1',
            'projectId': 'test-project-pipelines',
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
            'projectId': 'test-project-pipelines',
            'serverId': 'server-1',
            'clusterId': 'cluster-docker-compose-1',
            'type': 'dockerCompose',
            'serviceId': 'docker_compose',
            'softwareVersions': <String, dynamic>{},
            'status': 'unknown',
          },
        ],
        'variables': <dynamic>[],
        'serverServices': <String, List<dynamic>>{'server-1': <dynamic>[]},
        'clusterServices': <String, List<dynamic>>{
          'cluster-docker-compose-1': <dynamic>['pipelines'],
        },
      };
    });

    test(
      'pipelines_version should be present in LA_software_versions even if not in serviceDeploys',
      () {
        final LAProject project = LAProject.fromJson(sampleProjectJson);
        project.serviceInUse('pipelines', true);
        project.setServiceDeployRelease('pipelines', '1.0.0-SNAPSHOT');

        // Ensure pipelines is actually used
        expect(project.getService('pipelines').use, isTrue);

        final Map<String, dynamic> conf = project.toGeneratorJson();

        final List<dynamic> swVersions =
            conf['LA_software_versions'] as List<dynamic>;
        final bool hasPipelines = swVersions.any(
          (v) => v[0] == 'pipelines_version' && v[1] == '1.0.0-SNAPSHOT',
        );

        expect(
          hasPipelines,
          isTrue,
          reason: 'pipelines_version not found in LA_software_versions',
        );
      },
    );
  });
}
