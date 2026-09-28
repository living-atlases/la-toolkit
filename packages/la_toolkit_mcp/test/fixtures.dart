import 'dart:convert';

import 'package:la_toolkit_core/models/deployment_type.dart';
import 'package:la_toolkit_core/models/la_project.dart';
import 'package:la_toolkit_core/models/la_server.dart';
import 'package:la_toolkit_core/models/la_service_constants.dart';
import 'package:la_toolkit_mcp/la_toolkit_mcp.dart';

/// A project in the shape `get-conf` returns, with only the fields the MCP
/// server reads. [compose] puts the workload on a docker-compose cluster,
/// [vm] assigns services straight to the server; both makes it hybrid.
Json project({
  String id = 'p1',
  String dirName = 'demo',
  bool compose = true,
  bool vm = false,
  bool isHub = false,
  List<Json> hubs = const <Json>[],
  List<Json> history = const <Json>[],
}) => <String, dynamic>{
  'id': id,
  'longName': 'Demo portal',
  'shortName': dirName,
  'dirName': dirName,
  'domain': 'example.com',
  'status': 'firstDeploy',
  'isHub': isHub,
  'useSSL': true,
  'generatorRelease': '1.7.0',
  'dockerComposeRelease': compose ? 'v1.5.1' : null,
  'alaInstallRelease': vm ? 'v2.4.1' : null,
  'genConf': <String, dynamic>{
    'LA_pkg_name': dirName,
    'LA_variable_ansible_user': 'ubuntu',
  },
  'servers': <Json>[
    <String, dynamic>{
      'id': 's1',
      'name': 'la-1',
      'ip': '10.0.0.5',
      'osName': 'Ubuntu',
      'osVersion': '22.04',
    },
  ],
  'clusters': <Json>[
    if (compose)
      <String, dynamic>{
        'id': 'c1',
        'name': 'Docker Compose on la-1',
        'type': 'dockerCompose',
        'serverId': 's1',
      },
  ],
  'services': <Json>[
    <String, dynamic>{'id': 'sv1', 'nameInt': 'collectory', 'use': true},
    <String, dynamic>{'id': 'sv2', 'nameInt': 'docker_compose', 'use': compose},
  ],
  'serverServices': <String, dynamic>{
    's1': <String>[if (compose) 'docker_compose', if (vm) 'collectory'],
  },
  'clusterServices': <String, dynamic>{
    if (compose) 'c1': <String>['collectory'],
  },
  'serviceDeploys': <Json>[],
  'cmdHistoryEntries': history,
  'hubs': hubs,
};

Json run(String id, int createdAt, {String suffix = '2026-09-20_10:00:00'}) =>
    <String, dynamic>{
      'id': id,
      'createdAt': createdAt,
      'desc': 'Deploy $id',
      'logsPrefix': 'demo',
      'logsSuffix': suffix,
      'result': 'unknown',
      'rawCmd': './ansiblew --user ubuntu all',
    };

/// A real hybrid portal as `get-conf` returns it (a JSON round trip of the
/// core model, genConf included): collectory and branding on the VM `vm1`,
/// ala-hub, biocache-service and cas on the compose cluster of `dc1`, which
/// also carries [vmOnComposeHost] as VM services.
Json hybridPortal({List<String> vmOnComposeHost = const <String>[]}) {
  final LAProject p = LAProject(
    longName: 'Hybrid portal',
    shortName: 'Hybrid',
    domain: 'example.org',
    alaInstallRelease: 'v2.4.2',
    dockerComposeRelease: 'v1.5.1',
    generatorRelease: '1.8.32',
  );
  p.upsertServer(LAServer(name: 'vm1', ip: '10.0.0.1', projectId: p.id));
  p.upsertServer(LAServer(name: 'dc1', ip: '10.0.0.2', projectId: p.id));
  final String vm1 = p.servers.firstWhere((LAServer s) => s.name == 'vm1').id;
  final String dc1 = p.servers.firstWhere((LAServer s) => s.name == 'dc1').id;
  p.assignByType(vm1, DeploymentType.vm, <String>[collectory, branding]);
  p.assignByType(dc1, DeploymentType.vm, <String>[
    dockerCompose,
    ...vmOnComposeHost,
  ]);
  p.assignByType(dc1, DeploymentType.dockerCompose, <String>[
    alaHub,
    biocacheService,
    cas,
  ]);
  for (final String s in <String>[
    collectory,
    branding,
    alaHub,
    biocacheService,
    cas,
    dockerCompose,
    ...vmOnComposeHost,
  ]) {
    p.getService(s).use = true;
  }
  return json.decode(json.encode(p.toApiJson())) as Json;
}
