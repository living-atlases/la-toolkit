import 'package:la_toolkit_mcp/la_toolkit_mcp.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

Json conn(String name, {String ssh = 'success', String sudo = 'success', String os = 'Ubuntu', String v = '22.04'}) =>
    <String, dynamic>{'name': name, 'sshReachable': ssh, 'sudoEnabled': sudo, 'osName': os, 'osVersion': v};

Json disk(String name, {bool low = false}) => <String, dynamic>{
  'name': name,
  'ok': true,
  'low': low,
  'filesystems': <Json>[
    <String, dynamic>{'mount': '/', 'availableGB': low ? 4.6 : 40.0, 'usePct': low ? 77 : 20, 'low': low},
  ],
};

void main() {
  test('only servers that carry services are checked', () {
    final Json p = project()
      ..['servers'] = <Json>[
        <String, dynamic>{'id': 's1', 'name': 'la-1'},
        <String, dynamic>{'id': 'old', 'name': 'retired-vm'},
      ];
    expect(serversWithServices(p).map((Json s) => s['name']), <String>['la-1']);
    // VM assignment counts too.
    expect(serversWithServices(project(compose: false, vm: true)).map((Json s) => s['name']), <String>['la-1']);
  });

  test('public host names come from services in use, skipping junk', () {
    final Json p = project()
      ..['services'] = <Json>[
        <String, dynamic>{'id': '1', 'nameInt': 'collectory', 'use': true},
        <String, dynamic>{'id': '2', 'nameInt': 'species_lists', 'use': true},
        <String, dynamic>{'id': '3', 'nameInt': 'apikey', 'use': true},
        <String, dynamic>{'id': '4', 'nameInt': 'spatial', 'use': false},
      ]
      ..['genConf'] = <String, dynamic>{
        'LA_collectory_url': 'Collections.example.com',
        'LA_lists_url': 'lists.example.com',
        'LA_apikey_url': 'API keys.example.com',
        'LA_spatial_url': 'spatial.example.com',
      };
    expect(publicHostnames(p).hosts, <String>['collections.example.com', 'lists.example.com']);
    expect(publicHostnames(p).authoritative, isFalse);
  });

  test('compose projects use the nginx vhosts the generator computed', () {
    final Json p = project()
      ..['genConf'] = <String, dynamic>{
        'LA_cassandra_url': 'cassandra.example.com',
        'LA_nginx_docker_internal_aliases_by_host': <String, dynamic>{
          'la-1': <String>['records.example.com', 'Species.example.com'],
          'la-2': <String>['records.example.com'],
        },
      };
    expect(publicHostnames(p).hosts, <String>['records.example.com', 'species.example.com']);
    expect(publicHostnames(p).authoritative, isTrue);
  });

  test('without the vhost list, unresolved names are only warnings', () {
    final PreconditionReport r = evaluatePreconditions(
      project: project(),
      servers: <Json>[],
      connectivity: <Json>[],
      disk: <Json>[],
      keys: <Json>[],
      dns: <String, List<String>>{'cassandra.example.com': <String>[]},
      dnsAuthoritative: false,
    );
    expect(r.ready, isTrue);
    expect(r.warnings.single, contains('no public vhost'));
  });

  test('unreachable servers get no OS warning', () {
    final PreconditionReport r = evaluatePreconditions(
      project: project(),
      servers: <Json>[],
      connectivity: <Json>[conn('la-1', ssh: 'failed', os: '', v: '')],
      disk: <Json>[],
      keys: <Json>[],
      dns: <String, List<String>>{},
    );
    expect(r.warnings, isEmpty);
  });

  PreconditionReport eval({
    List<Json>? connectivity,
    List<Json>? diskR,
    List<Json>? keys,
    Map<String, List<String>>? dns,
    Json? server,
  }) => evaluatePreconditions(
    project: project(),
    servers: <Json>[
      server ?? <String, dynamic>{'id': 's1', 'name': 'la-1', 'ip': '10.0.0.5', 'sshKey': <String, dynamic>{'name': 'k1'}},
    ],
    connectivity: connectivity ?? <Json>[conn('la-1')],
    disk: diskR ?? <Json>[disk('la-1')],
    keys: keys ?? <Json>[<String, dynamic>{'name': 'k1', 'missing': false}],
    dns: dns ?? <String, List<String>>{'collections.example.com': <String>['203.0.113.7']},
  );

  test('all good is ready, and DNS elsewhere is only informative', () {
    final PreconditionReport r = eval();
    expect(r.ready, isTrue, reason: r.blocking.join('\n'));
    expect(r.warnings, isEmpty);
    expect((r.details['dns'] as List<dynamic>).single, containsPair('pointsToAProjectServer', false));
  });

  test('each missing piece is its own named blocker', () {
    final PreconditionReport r = eval(
      connectivity: <Json>[conn('la-1', sudo: 'failed')],
      diskR: <Json>[disk('la-1', low: true)],
      keys: <Json>[<String, dynamic>{'name': 'k1', 'missing': true}],
      dns: <String, List<String>>{'collections.example.com': <String>[]},
    );
    expect(r.ready, isFalse);
    expect(r.blocking, hasLength(4));
    expect(r.blocking.join('\n'), allOf(
      contains('ssh key "k1" is not in the toolkit'),
      contains('sudo does not'),
      contains('/ 4.6 GB free (77%)'),
      contains('collections.example.com does not resolve'),
    ));
  });

  test('no key, no ssh, old OS', () {
    final PreconditionReport r = eval(
      server: <String, dynamic>{'id': 's1', 'name': 'la-1'},
      connectivity: <Json>[conn('la-1', ssh: 'failed', v: '20.04')],
    );
    expect(r.blocking, containsAll(<String>['la-1: no ssh key assigned.', 'la-1: not reachable over ssh from the toolkit.']));
    expect(r.warnings.single, contains('20.04'));
  });
}
