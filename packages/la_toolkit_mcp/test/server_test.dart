import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_mcp/client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:la_toolkit_mcp/la_toolkit_mcp.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

base class _Client extends MCPClient {
  _Client() : super(Implementation(name: 'test', version: '0'));
}

/// A fake backend recording every call; answers like la_toolkit_backend.
class _Backend {
  final List<String> calls = <String>[];
  bool somethingRunning = false;
  List<String>? diskNames;
  bool noDiskEndpoint = false;
  final List<Json> ansiblewBodies = <Json>[];
  final List<Json> addedProjects = <Json>[];
  Json? sshConfBody;

  /// GitHub: la-docker-compose tags and files, the dependency matrix (404, so
  /// the lint reports it as unchecked).
  http.Response? external(Uri url) {
    if (url.host == 'api.github.com') {
      return _json(<Json>[
        <String, dynamic>{'name': 'v1.9.0'},
        <String, dynamic>{'name': 'v1.8.0'},
      ]);
    }
    if (url.host != 'raw.githubusercontent.com') return null;
    calls.add('GET ${url.path}');
    if (url.path.endsWith('1host/.yo-rc.json')) {
      return http.Response(
        File(
          '../la_toolkit_core/test/fixtures/la-docker-compose-1host.yo-rc.json',
        ).readAsStringSync(),
        200,
      );
    }
    if (url.path.endsWith('1host.placement.json')) {
      return _json(<String, dynamic>{
        'skip_services': <String>['spatial', 'pipelines'],
      });
    }
    return http.Response('Not Found', 404);
  }

  final Json entry =
      run(
          'run1',
          DateTime.now().millisecondsSinceEpoch,
          suffix: '2026-09-21_09:00:00',
        )
        ..['rawCmd'] =
            './ansiblew --ladocker=/x --extra="auto_deploy=true" --user ubuntu all';

  late final List<Json> projects = <Json>[
    project(history: <Json>[entry])
      ..['genConf'] = <String, dynamic>{
        'LA_pkg_name': 'demo',
        'LA_variable_ansible_user': 'ubuntu',
        'LA_nginx_docker_internal_aliases_by_host': <String, dynamic>{
          'la-1': <String>['collections.example.com'],
        },
      }
      ..['servers'] = <Json>[
        <String, dynamic>{
          'id': 's1',
          'name': 'la-1',
          'ip': '10.0.0.5',
          'sshKey': <String, dynamic>{'name': 'k1'},
        },
        <String, dynamic>{'id': 's2', 'name': 'retired', 'ip': '10.0.0.9'},
      ],
  ];

  http.Client get client => MockClient((http.Request r) async {
    final http.Response? ext = external(r.url);
    if (ext != null) return ext;
    final String path = r.url.path.replaceFirst('/api/v1/', '');
    calls.add('${r.method} $path');
    Json? body() => r.body.isEmpty ? null : json.decode(r.body) as Json;
    switch (path) {
      case 'get-conf':
        return _json(<String, dynamic>{'projects': projects});
      case 'ansiblew':
        ansiblewBodies.add(body()!);
        return _json(<String, dynamic>{
          'cmdEntry': entry,
          'port': 2011,
          'ttydPid': 1,
          'deployPid': 2,
        });
      case 'test-connectivity':
        return _json(<String, dynamic>{
          'servers': (body()!['servers'] as List<dynamic>)
              .map(
                (dynamic s) => <String, dynamic>{
                  ...(s as Json),
                  'sshReachable': 'success',
                  'sudoEnabled': 'success',
                  'osName': 'Ubuntu',
                  'osVersion': '24.04',
                },
              )
              .toList(),
        });
      case 'disk-usage':
        if (noDiskEndpoint) return http.Response('Not Found', 404);
        diskNames = (body()!['names'] as List<dynamic>).cast<String>();
        return _json(<String, dynamic>{
          'servers': <Json>[
            <String, dynamic>{
              'name': 'la-1',
              'ok': true,
              'low': false,
              'filesystems': <Json>[],
            },
          ],
        });
      case 'ssh-key-scan':
        return _json(<String, dynamic>{
          'keys': <Json>[
            <String, dynamic>{
              'name': 'k1',
              'missing': false,
              'desc': 'k1',
              'encrypted': false,
            },
          ],
        });
      case 'get-generator-versions':
        return _json(<String, dynamic>{
          'versions': <String, dynamic>{
            '1.8.32': <String, dynamic>{},
            '1.8.33': <String, dynamic>{},
          },
        });
      case 'get-deps-versions':
        return http.Response(
          File(
            '../la_toolkit_core/test/fixtures/get-deps-versions.json',
          ).readAsStringSync(),
          200,
        );
      case 'get-backend-version':
        return _json(<String, dynamic>{'version': '1.7.1'});
      case 'add-projects':
        addedProjects.addAll(
          (body()!['projects'] as List<dynamic>).cast<Json>(),
        );
        return _json(<String, dynamic>{'projects': projects});
      case 'gen-ssh-conf':
        sshConfBody = body();
        return http.Response('', 200);
      case 'deploy-status':
        return _json(<String, dynamic>{'running': somethingRunning});
      case 'cmd-results':
        return _json(<String, dynamic>{
          'code': 0,
          'running': false,
          'results': <dynamic>[],
          'logs': base64.encode(
            utf8.encode(
              'env ANSIBLE_PIPELINING=True ansible-playbook site.yml\n',
            ),
          ),
        });
      default:
        return http.Response('', 200);
    }
  });

  static http.Response _json(Object o) => http.Response(
    json.encode(o),
    200,
    headers: <String, String>{'content-type': 'application/json'},
  );
}

void main() {
  late _Backend fake;
  late ServerConnection conn;

  setUp(() async {
    fake = _Backend();
    final StreamController<String> toServer = StreamController<String>();
    final StreamController<String> toClient = StreamController<String>();
    final LaToolkitMcpServer server = LaToolkitMcpServer(
      StreamChannel<String>.withCloseGuarantee(toServer.stream, toClient.sink),
      backend: BackendClient(
        Uri.parse('http://toolkit:2010'),
        client: fake.client,
      ),
      dryRunWait: const Duration(seconds: 2),
      resolve: (String host) async =>
          host == 'collections.example.com' ? <String>['10.0.0.5'] : <String>[],
    );
    final _Client client = _Client();
    conn = client.connectServer(
      StreamChannel<String>.withCloseGuarantee(toClient.stream, toServer.sink),
    );
    await conn.initialize(
      InitializeRequest(
        protocolVersion: ProtocolVersion.latestSupported,
        capabilities: client.capabilities,
        clientInfo: client.implementation,
      ),
    );
    conn.notifyInitialized(InitializedNotification());
    await server.initialized;
    addTearDown(() async {
      await client.shutdown();
      await server.shutdown();
    });
  });

  Future<CallToolResult> call(String name, Map<String, Object?> args) =>
      conn.callTool(CallToolRequest(name: name, arguments: args));

  String text(CallToolResult r) => (r.content.single as TextContent).text;

  test('lists the tools with read-only / destructive hints', () async {
    final ListToolsResult tools = await conn.listTools();
    final Map<String, Tool> byName = <String, Tool>{
      for (final Tool t in tools.tools) t.name: t,
    };
    expect(
      byName.keys,
      containsAll(<String>[
        'la_list_projects',
        'la_deploy',
        'la_deploy_status',
        'la_deploy_failures',
      ]),
    );
    expect(byName['la_list_projects']!.toolAnnotations!.readOnlyHint, isTrue);
    expect(byName['la_deploy']!.toolAnnotations!.destructiveHint, isTrue);
    // check-connectivity saves what it finds on the project.
    expect(
      byName['la_check_connectivity']!.toolAnnotations!.readOnlyHint,
      isFalse,
    );
  });

  test(
    'a dry run waits for the echoed command and closes the viewer',
    () async {
      final CallToolResult r = await call('la_deploy', <String, Object?>{
        'project': 'demo',
      });
      expect(r.isError, isNot(true), reason: text(r));
      final Json out = json.decode(text(r)) as Json;
      expect(out['dryRun'], isTrue);
      expect(out['verdict'], 'success');
      expect(out['output'], contains('ansible-playbook site.yml'));
      expect(fake.ansiblewBodies.single['cmd'], containsPair('dryRun', true));
      expect(
        fake.calls.where(
          (String c) => c.contains('select') || c.contains('gen'),
        ),
        isEmpty,
      );
      expect(
        fake.calls,
        containsAllInOrder(<String>['POST ansiblew', 'POST term-close']),
      );
    },
  );

  test('prepare: true on a dry run regenerates first', () async {
    await call('la_deploy', <String, Object?>{
      'project': 'demo',
      'prepare': true,
    });
    expect(
      fake.calls,
      containsAllInOrder(<String>['POST gen/p1/false', 'POST ansiblew']),
    );
  });

  test('refuses to prepare under a running deploy', () async {
    fake.somethingRunning = true;
    final CallToolResult r = await call('la_deploy', <String, Object?>{
      'project': 'demo',
      'prepare': true,
    });
    expect(r.isError, isTrue);
    expect(text(r), contains('still running'));
    expect(fake.ansiblewBodies, isEmpty);
  });

  test('a real deploy without confirm never reaches the backend', () async {
    final CallToolResult r = await call('la_deploy', <String, Object?>{
      'project': 'demo',
      'dryRun': false,
    });
    expect(r.isError, isTrue);
    expect(text(r), contains('confirm: true'));
    expect(fake.ansiblewBodies, isEmpty);
  });

  test(
    'a confirmed deploy prepares like the UI, then starts detached',
    () async {
      final CallToolResult r = await call('la_deploy', <String, Object?>{
        'project': 'demo',
        'dryRun': false,
        'confirm': true,
        'skipServices': <String>['spatial'],
      });
      expect(r.isError, isNot(true), reason: text(r));
      expect(fake.calls, <String>[
        'GET get-conf',
        'GET get-conf',
        'POST deploy-status',
        'GET docker-compose-select/v1.5.1',
        'GET generator-select/1.7.0',
        'POST gen/p1/false',
        'POST gen-ssh-conf',
        'POST ansiblew',
        'POST term-close',
      ]);
      expect((json.decode(text(r)) as Json)['runId'], 'run1');
      expect(
        fake.ansiblewBodies.single['cmd'],
        allOf(
          containsPair('dockerCompose', true),
          containsPair('dryRun', false),
        ),
      );
    },
  );

  test('status and failures default to the latest run', () async {
    final Json s =
        json.decode(
              text(
                await call('la_deploy_status', <String, Object?>{
                  'project': 'demo',
                }),
              ),
            )
            as Json;
    expect(s['runId'], 'run1');
    expect(s['verdict'], 'success');
    final Json f =
        json.decode(
              text(
                await call('la_deploy_failures', <String, Object?>{
                  'project': 'demo',
                }),
              ),
            )
            as Json;
    expect(f['failedTasks'], isEmpty);
    expect(f['logTail'], contains('ansible-playbook'));
  });

  test(
    'preconditions check only servers with services and report ready',
    () async {
      final CallToolResult r = await call(
        'la_check_preconditions',
        <String, Object?>{'project': 'demo'},
      );
      expect(r.isError, isNot(true), reason: text(r));
      final Json out = json.decode(text(r)) as Json;
      expect(out['ready'], isTrue, reason: text(r));
      expect(fake.diskNames, <String>['la-1']);
      expect(out['ignoredServers'], contains('1 server'));
      expect(
        (out['dns'] as List<dynamic>).single,
        containsPair('pointsToAProjectServer', true),
      );
    },
  );

  test('an older backend without disk-usage only costs a warning', () async {
    fake.noDiskEndpoint = true;
    final Json out =
        json.decode(
              text(
                await call('la_check_preconditions', <String, Object?>{
                  'project': 'demo',
                }),
              ),
            )
            as Json;
    expect(out['ready'], isTrue);
    expect((out['warnings'] as List<dynamic>).single, contains('disk-usage'));
  });

  test('unknown projects list the known ones', () async {
    final CallToolResult r = await call('la_get_project', <String, Object?>{
      'project': 'nope',
    });
    expect(r.isError, isTrue);
    expect(text(r), contains('Known: demo'));
  });

  test(
    'backend errors come back as tool errors, not protocol errors',
    () async {
      fake.projects.clear();
      final CallToolResult r = await call('la_deploy_cancel', <String, Object?>{
        'project': 'demo',
        'confirm': true,
      });
      expect(r.isError, isTrue);
    },
  );

  group('la_create_project', () {
    final Map<String, Object?> intent = <String, Object?>{
      'domain': 'example.com',
      'name': 'Example Portal',
      'shortName': 'Demo',
      'hostName': 'ex-1',
      'ip': '10.0.0.5',
      'sshKey': 'k1',
    };

    test('previews by default and stores nothing', () async {
      final CallToolResult r = await call('la_create_project', intent);
      expect(r.isError, isNot(true), reason: text(r));
      final Json out = json.decode(text(r)) as Json;
      expect(out['saved'], isFalse);
      expect(out['valid'], isTrue);
      expect(out['dockerComposeRelease'], 'v1.9.0');
      expect(out['generatorRelease'], '1.8.33');
      expect(out['deployWithSkipServices'], <String>['spatial', 'pipelines']);
      expect(out['publicNames'], contains('collections.example.com'));
      // "demo" is taken by the existing project.
      expect(out['dirName'], isNot('demo'));
      expect((out['lint'] as Json)['findings'], isEmpty);
      expect(fake.calls, isNot(contains('POST add-projects')));
      expect(
        fake.calls,
        contains(
          'GET /living-atlases/la-docker-compose/v1.9.0/inventories/testing/topologies/1host/.yo-rc.json',
        ),
      );
    });

    test('save needs confirm', () async {
      final CallToolResult r = await call(
        'la_create_project',
        <String, Object?>{...intent, 'save': true},
      );
      expect(r.isError, isTrue);
      expect(text(r), contains('confirm: true'));
      expect(fake.calls, isNot(contains('POST add-projects')));
    });

    test('an unknown ssh key is refused', () async {
      final CallToolResult r = await call(
        'la_create_project',
        <String, Object?>{...intent, 'sshKey': 'nope'},
      );
      expect(r.isError, isTrue);
      expect(text(r), contains('Known: k1'));
    });

    test('a bad intent is refused before anything is fetched', () async {
      final CallToolResult r = await call(
        'la_create_project',
        <String, Object?>{...intent, 'ip': '10.0.0'},
      );
      expect(r.isError, isTrue);
      expect(text(r), contains('IPv4'));
      expect(fake.calls, isEmpty);
    });

    test(
      'save + confirm stores it with its genConf and its ssh config',
      () async {
        final CallToolResult r = await call(
          'la_create_project',
          <String, Object?>{...intent, 'save': true, 'confirm': true},
        );
        expect(r.isError, isNot(true), reason: text(r));
        final Json out = json.decode(text(r)) as Json;
        expect(out['saved'], isTrue);
        final Json stored = fake.addedProjects.single;
        expect(stored['id'], out['id']);
        expect((stored['genConf'] as Json)['LA_domain'], 'example.com');
        expect((stored['genConf'] as Json)['LA_hostnames'], 'ex-1');
        expect(stored['dockerComposeRelease'], 'v1.9.0');
        expect(fake.sshConfBody!['id'], out['id']);
        expect(fake.sshConfBody!['user'], 'ubuntu');
      },
    );
  });
}
