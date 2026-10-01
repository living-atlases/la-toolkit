import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_mcp/client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:la_toolkit_core/models/project_patch.dart'
    show MergeResult, ProjectPatch;
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
  final List<Json> updatedProjects = <Json>[];
  Json? sshConfBody;

  /// Store update-project bodies as the backend does (they replace the
  /// project's rows), for tools that read the project back.
  bool applyUpdates = false;

  /// Changes the stored projects right before a patch-project is merged:
  /// another session saving while the tool works.
  void Function(List<Json> projects)? beforePatch;

  final List<Json> patches = <Json>[];

  /// serverServices / clusterServices from the deploy rows, as the backend's
  /// populate-project builds them on every read.
  static Json withDerivedMaps(Json p) {
    final Map<String, String> names = <String, String>{
      for (final dynamic s in p['services'] as List<dynamic>? ?? <dynamic>[])
        (s as Json)['id'] as String: s['nameInt'] as String,
    };
    final List<Json> deploys =
        (p['serviceDeploys'] as List<dynamic>? ?? <dynamic>[]).cast<Json>();
    return <String, dynamic>{
      ...p,
      'serverServices': <String, dynamic>{
        for (final dynamic s in p['servers'] as List<dynamic>? ?? <dynamic>[])
          (s as Json)['id'] as String: <String>[
            for (final Json sd in deploys)
              if (sd['serverId'] == s['id'] &&
                  sd['clusterId'] == null &&
                  names[sd['serviceId']] != null)
                names[sd['serviceId']]!,
          ],
      },
      'clusterServices': <String, dynamic>{
        for (final dynamic c in p['clusters'] as List<dynamic>? ?? <dynamic>[])
          (c as Json)['id'] as String: <String>[],
        for (final String cid
            in deploys
                .map((Json sd) => sd['clusterId'])
                .whereType<String>()
                .toSet())
          cid: <String>[
            for (final Json sd in deploys)
              if (sd['clusterId'] == cid && names[sd['serviceId']] != null)
                names[sd['serviceId']]!,
          ],
      },
    };
  }

  /// The stored project [id], a hub looked up inside its portal.
  Json? stored(String id) {
    for (final Json p in projects) {
      if (p['id'] == id) return p;
      for (final dynamic h in p['hubs'] as List<dynamic>? ?? <dynamic>[]) {
        if ((h as Json)['id'] == id) return h;
      }
    }
    return null;
  }

  void replace(String id, Json next) {
    for (int i = 0; i < projects.length; i++) {
      if (projects[i]['id'] == id) {
        projects[i] = next;
        return;
      }
      final List<dynamic> hubs =
          projects[i]['hubs'] as List<dynamic>? ?? <dynamic>[];
      for (int j = 0; j < hubs.length; j++) {
        if ((hubs[j] as Json)['id'] == id) hubs[j] = next;
      }
    }
  }

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
    final RegExpMatch? topo = RegExp(
      r'/topologies/([a-z0-9-]+)/\.yo-rc\.json$',
    ).firstMatch(url.path);
    if (topo != null) {
      final File f = File(
        '../la_toolkit_core/test/fixtures/la-docker-compose-${topo.group(1)}.yo-rc.json',
      );
      return f.existsSync()
          ? http.Response(f.readAsStringSync(), 200)
          : http.Response('404: Not Found', 404);
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
      case 'update-project':
        final Json updated = body()!['project'] as Json;
        updatedProjects.add(updated);
        if (applyUpdates) {
          final int i = projects.indexWhere(
            (Json p) => p['id'] == updated['id'],
          );
          projects[i] = <String, dynamic>{...projects[i], ...updated};
        }
        return _json(<String, dynamic>{'projects': projects});
      case 'patch-project':
        // The backend's merge (api/libs/project-patch.js), same rules.
        final Json patch = body()!['patch'] as Json;
        patches.add(patch);
        beforePatch?.call(projects);
        final String id = patch['projectId'] as String;
        final Json current = stored(id)!;
        final MergeResult m = ProjectPatch.merge(current, patch);
        if (m.hasConflicts) {
          return http.Response(
            json.encode(<String, dynamic>{
              'conflicts': m.conflicts,
              'projects': projects,
            }),
            409,
          );
        }
        final Json merged = withDerivedMaps(
          ProjectPatch.applyWrites(current, m.writes),
        );
        updatedProjects.add(merged);
        if (applyUpdates) replace(id, merged);
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
  late Directory backups;

  setUp(() async {
    fake = _Backend();
    backups = Directory.systemTemp.createTempSync('la_mcp_backups');
    addTearDown(() => backups.deleteSync(recursive: true));
    final StreamController<String> toServer = StreamController<String>();
    final StreamController<String> toClient = StreamController<String>();
    final LaToolkitMcpServer server = LaToolkitMcpServer(
      StreamChannel<String>.withCloseGuarantee(toServer.stream, toClient.sink),
      backend: BackendClient(
        Uri.parse('http://toolkit:2010'),
        client: fake.client,
      ),
      dryRunWait: const Duration(seconds: 2),
      backupDir: backups,
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

  test('la_list_projects flattens the hubs after their portal', () async {
    fake.projects.add(
      project(
        id: 'p2',
        dirName: 'portal2',
        hubs: <Json>[project(id: 'h1', dirName: 'hub1', isHub: true)],
      ),
    );
    final List<dynamic> out =
        json.decode(text(await call('la_list_projects', <String, Object?>{})))
            as List<dynamic>;
    expect(out.map((dynamic p) => (p as Json)['dirName']), <String>[
      'demo',
      'portal2',
      'hub1',
    ]);
  });

  test('la_list_runs honours the limit', () async {
    fake.projects.first['cmdHistoryEntries'] = <Json>[
      for (int i = 0; i < 5; i++) run('r$i', 1000 + i),
    ];
    final List<dynamic> out =
        json.decode(
              text(
                await call('la_list_runs', <String, Object?>{
                  'project': 'demo',
                  'limit': 2,
                }),
              ),
            )
            as List<dynamic>;
    expect(out, hasLength(2));
    expect((out.first as Json)['runId'], 'r4');
  });

  test('la_check_connectivity sends the servers and sums up each', () async {
    final List<dynamic> out =
        json.decode(
              text(
                await call('la_check_connectivity', <String, Object?>{
                  'project': 'demo',
                }),
              ),
            )
            as List<dynamic>;
    expect(fake.calls, contains('POST test-connectivity'));
    expect(out.first, <String, dynamic>{
      'name': 'la-1',
      'reachable': null,
      'sshReachable': 'success',
      'sudoEnabled': 'success',
      'os': 'Ubuntu 24.04',
    });
  });

  test('la_check_connectivity refuses a project without servers', () async {
    fake.projects.first['servers'] = <Json>[];
    final CallToolResult r = await call(
      'la_check_connectivity',
      <String, Object?>{'project': 'demo'},
    );
    expect(r.isError, isTrue);
    expect(text(r), contains('no servers'));
    expect(fake.calls, isNot(contains('POST test-connectivity')));
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

    test('two hosts take the 2host topology, in slot order', () async {
      final CallToolResult r = await call(
        'la_create_project',
        <String, Object?>{
          for (final MapEntry<String, Object?> e in intent.entries)
            if (e.key != 'hostName' && e.key != 'ip') e.key: e.value,
          'hosts': <Json>[
            <String, dynamic>{'name': 'ex-1', 'ip': '10.0.0.5'},
            <String, dynamic>{'name': 'ex-2', 'ip': '10.0.0.6'},
          ],
        },
      );
      expect(r.isError, isNot(true), reason: text(r));
      final Json out = json.decode(text(r)) as Json;
      expect(out['topology'], '2host');
      expect(out['valid'], isTrue);
      final List<Json> hosts = (out['hosts'] as List<dynamic>).cast<Json>();
      expect(hosts.map((Json h) => h['name']), <String>['ex-1', 'ex-2']);
      expect(
        hosts.every((Json h) => (h['publicNames'] as List<dynamic>).isNotEmpty),
        isTrue,
      );
      // The placement file of 2host is not served: deploy everything.
      expect(out['deployWithSkipServices'], isEmpty);
    });

    test('an unknown topology is named in the error', () async {
      final CallToolResult r = await call(
        'la_create_project',
        <String, Object?>{...intent, 'topology': 'nope'},
      );
      expect(r.isError, isTrue);
      expect(text(r), contains('no topology "nope"'));
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

  group('hybrid portal', () {
    setUp(() => fake.projects.add(hybridPortal()));

    test('la_deploy without a leg is refused before the backend', () async {
      final CallToolResult r = await call('la_deploy', <String, Object?>{
        'project': 'Hybrid',
      });
      expect(r.isError, isTrue);
      expect(text(r), contains('leg'));
      expect(fake.ansiblewBodies, isEmpty);
    });

    test('the docker leg only reaches the compose host', () async {
      final CallToolResult r = await call('la_deploy', <String, Object?>{
        'project': 'Hybrid',
        'leg': 'docker',
      });
      expect(r.isError, isNot(isTrue), reason: text(r));
      final Json cmd = fake.ansiblewBodies.single['cmd'] as Json;
      expect(cmd['dockerCompose'], isTrue);
      expect(cmd['limitToServers'], <String>['dc1.docker_compose']);
    });

    test(
      'preconditions of the docker leg check only the compose host',
      () async {
        await call('la_check_preconditions', <String, Object?>{
          'project': 'Hybrid',
          'leg': 'docker',
        });
        expect(fake.diskNames, <String>['dc1']);
        final CallToolResult bad = await call(
          'la_check_preconditions',
          <String, Object?>{
            'project': 'Hybrid',
            'servers': <String>['nope'],
          },
        );
        expect(bad.isError, isTrue);
      },
    );
  });

  group('la_set_releases', () {
    setUp(() => fake.projects.add(hybridPortal()));

    test('previews by default and stores nothing', () async {
      final CallToolResult r = await call('la_set_releases', <String, Object?>{
        'project': 'Hybrid',
        'generatorRelease': '1.8.33',
        'dockerComposeRelease': 'upstream',
      });
      expect(r.isError, isNot(isTrue), reason: text(r));
      final Json out = json.decode(text(r)) as Json;
      expect(out['saved'], isFalse);
      expect((out['before'] as Json)['generator'], '1.8.32');
      expect((out['after'] as Json)['generator'], '1.8.33');
      expect((out['after'] as Json)['dockerCompose'], 'upstream');
      expect(out['genConfChanges'], contains('changed'));
      expect(fake.updatedProjects, isEmpty);
      expect(backups.listSync(), isEmpty);
    });

    test('save needs confirm', () async {
      final CallToolResult r = await call('la_set_releases', <String, Object?>{
        'project': 'Hybrid',
        'generatorRelease': '1.8.33',
        'save': true,
      });
      expect(r.isError, isTrue);
      expect(text(r), contains('confirm'));
      expect(fake.updatedProjects, isEmpty);
    });

    test('unknown releases are refused', () async {
      for (final Map<String, Object?> bad in <Map<String, Object?>>[
        <String, Object?>{'generatorRelease': '9.9.9'},
        <String, Object?>{'dockerComposeRelease': 'v0.0.1'},
        <String, Object?>{'generatorRelease': r'$(id)'},
        <String, Object?>{},
      ]) {
        final CallToolResult r = await call(
          'la_set_releases',
          <String, Object?>{'project': 'Hybrid', ...bad},
        );
        expect(r.isError, isTrue, reason: '$bad');
      }
      expect(fake.updatedProjects, isEmpty);
    });

    test('save + confirm backs the project up, then stores it', () async {
      final CallToolResult r = await call('la_set_releases', <String, Object?>{
        'project': 'Hybrid',
        'generatorRelease': '1.8.33',
        'dockerComposeRelease': 'v1.9.0',
        'save': true,
        'confirm': true,
      });
      expect(r.isError, isNot(isTrue), reason: text(r));
      final Json out = json.decode(text(r)) as Json;
      final Json stored = fake.updatedProjects.single;
      expect(stored['generatorRelease'], '1.8.33');
      expect(stored['dockerComposeRelease'], 'v1.9.0');
      expect(stored['genConf'], isA<Map<String, dynamic>>());
      final File backup = File(out['backup'] as String);
      final Json old = json.decode(backup.readAsStringSync()) as Json;
      expect(old['generatorRelease'], '1.8.32');
      expect(old['dockerComposeRelease'], 'v1.5.1');
    });
  });

  // Saves send what changed (patch-project), so a browser saving while the
  // tool works is merged, unless it changed the same setting.
  group('saving while another session saves', () {
    setUp(() => fake.projects.add(hybridPortal()));

    Json hybrid(List<Json> ps) =>
        ps.firstWhere((Json p) => p['shortName'] == 'Hybrid');

    Future<CallToolResult> setGenerator() =>
        call('la_set_releases', <String, Object?>{
          'project': 'Hybrid',
          'generatorRelease': '1.8.33',
          'save': true,
          'confirm': true,
        });

    test('a change to other settings stays', () async {
      fake.beforePatch = (List<Json> ps) =>
          hybrid(ps)['longName'] = 'Renamed in a browser';
      final CallToolResult r = await setGenerator();
      expect(r.isError, isNot(isTrue), reason: text(r));
      final Json stored = fake.updatedProjects.single;
      expect(stored['generatorRelease'], '1.8.33');
      expect(stored['longName'], 'Renamed in a browser');
      final Json patch = fake.patches.single;
      expect((patch['project'] as Json).keys, isNot(contains('longName')));
    });

    test('the same setting changed elsewhere refuses the save', () async {
      fake.beforePatch = (List<Json> ps) =>
          hybrid(ps)['generatorRelease'] = '1.8.31';
      final CallToolResult r = await setGenerator();
      expect(r.isError, isTrue);
      expect(text(r), contains('another session'));
      expect(text(r), contains('project.generatorRelease'));
      expect(fake.updatedProjects, isEmpty);
    });
  });

  group('la_set_placement', () {
    setUp(() => fake.projects.add(placementPortal()));

    Json stored() => fake.updatedProjects.single;
    String idOf(Json p, String server) =>
        ((p['servers'] as List<dynamic>).cast<Json>().firstWhere(
              (Json s) => s['name'] == server,
            ))['id']
            as String;
    String clusterOf(Json p, String server) =>
        ((p['clusters'] as List<dynamic>).cast<Json>().firstWhere(
              (Json c) => c['serverId'] == idOf(p, server),
            ))['id']
            as String;
    List<Json> rowsOf(Json p, String service) {
      final String sid =
          ((p['services'] as List<dynamic>).cast<Json>().firstWhere(
                (Json s) => s['nameInt'] == service,
              ))['id']
              as String;
      return (p['serviceDeploys'] as List<dynamic>)
          .cast<Json>()
          .where((Json d) => d['serviceId'] == sid)
          .toList();
    }

    const Map<String, Object?> spatialToDc2 = <String, Object?>{
      'project': 'Moving',
      'changes': <Object?>[
        <String, Object?>{'service': 'spatial-hub', 'to': 'dc2'},
      ],
    };

    test('previews by default and stores nothing', () async {
      final CallToolResult r = await call('la_set_placement', spatialToDc2);
      expect(r.isError, isNot(isTrue), reason: text(r));
      final Json out = json.decode(text(r)) as Json;
      expect(out['saved'], isFalse);
      final Json move = (out['changes'] as List<dynamic>).single as Json;
      expect(move['op'], 'move');
      expect(move['service'], 'spatial');
      expect(move['carries'], <String>['geoserver', 'spatial_service']);
      expect(move['from'], 'dc1 (docker-compose)');
      expect(move['to'], 'dc2 (docker-compose)');
      expect((move['versions'] as Json)['spatial'], '1.0.0');
      final Json servers = out['servers'] as Json;
      expect((servers['dc1'] as Json)['loses'], contains('spatial (docker)'));
      expect((servers['dc2'] as Json)['gains'], contains('spatial (docker)'));
      expect(servers.keys, unorderedEquals(<String>['dc1', 'dc2']));
      expect(out['integrityErrors'], isEmpty);
      expect(out['lint'], contains('new'));
      final List<String> notes = (out['deployNotes'] as List<dynamic>)
          .cast<String>();
      // The new host first, then the one it leaves.
      expect(notes.first, contains('dc2, dc1'));
      expect(notes.first, contains('leg: "docker"'));
      expect(notes, anyElement(contains('allow_service_removal')));
      expect(out['extraHosts'], isA<Map<String, dynamic>>());
      expect(fake.updatedProjects, isEmpty);
      expect(fake.sshConfBody, isNull);
      expect(backups.listSync(), isEmpty);
    });

    test('save needs confirm', () async {
      final CallToolResult r = await call('la_set_placement', <String, Object?>{
        ...spatialToDc2,
        'save': true,
      });
      expect(r.isError, isTrue);
      expect(text(r), contains('confirm'));
      expect(fake.updatedProjects, isEmpty);
    });

    test('refuses ambiguous, unknown and unsafe moves', () async {
      for (final (Object? changes, String why) in <(Object?, String)>[
        (
          <Object?>[
            <String, Object?>{'service': 'ala_hub', 'to': 'vm1'},
          ],
          'say which one with `from`',
        ),
        (
          <Object?>[
            <String, Object?>{'service': 'geoserver', 'to': 'dc2'},
          ],
          'moves with spatial',
        ),
        (
          <Object?>[
            <String, Object?>{'service': 'spatial', 'to': 'gbif-es-dc2'},
          ],
          'No server "gbif-es-dc2"',
        ),
        (
          <Object?>[
            <String, Object?>{'service': 'spatial', 'to': 'new1'},
          ],
          'assign docker_compose to it first',
        ),
        (
          <Object?>[
            <String, Object?>{'service': r'$(id)', 'to': 'dc2'},
          ],
          'is not a valid name',
        ),
        (
          <Object?>[
            <String, Object?>{'service': 'spatial', 'to': '--nodryrun'},
          ],
          'is not a valid name',
        ),
        (
          <Object?>[
            <String, Object?>{
              'service': 'spatial',
              'to': 'dc2',
              'toLeg': 'k8s',
            },
          ],
          '`toLeg` must be "vm" or "docker"',
        ),
        (<Object?>[], 'Give changes'),
      ]) {
        final CallToolResult r = await call(
          'la_set_placement',
          <String, Object?>{
            'project': 'Moving',
            'changes': changes,
            'save': true,
            'confirm': true,
          },
        );
        expect(r.isError, isTrue, reason: why);
        expect(text(r), contains(why));
      }
      expect(fake.updatedProjects, isEmpty);
      expect(backups.listSync(), isEmpty);
    });

    test(
      'save + confirm backs up, stores what the UI would, keeps versions',
      () async {
        final CallToolResult r = await call(
          'la_set_placement',
          <String, Object?>{...spatialToDc2, 'save': true, 'confirm': true},
        );
        expect(r.isError, isNot(isTrue), reason: text(r));
        final Json out = json.decode(text(r)) as Json;
        expect(out['saved'], isTrue);
        final Json p = stored();
        final Json cs = p['clusterServices'] as Json;
        expect(cs[clusterOf(p, 'dc1')], <String>['ala_hub']);
        expect(
          cs[clusterOf(p, 'dc2')],
          containsAll(<String>[
            'ala_hub',
            'spatial',
            'spatial_service',
            'geoserver',
          ]),
        );
        for (final String s in <String>[
          'spatial',
          'spatial_service',
          'geoserver',
        ]) {
          final Json row = rowsOf(p, s).single;
          expect(row['clusterId'], clusterOf(p, 'dc2'), reason: s);
          expect((row['softwareVersions'] as Json)[s], '1.0.0', reason: s);
        }
        expect(p['genConf'], isA<Map<String, dynamic>>());
        // As the app: the ssh config is regenerated after the save.
        expect(fake.sshConfBody!['id'], p['id']);
        expect(
          fake.calls.indexOf('POST gen-ssh-conf'),
          greaterThan(fake.calls.indexOf('PATCH update-project')),
        );
        final Json old =
            json.decode(File(out['backup'] as String).readAsStringSync())
                as Json;
        expect(
          (old['clusterServices'] as Json)[clusterOf(old, 'dc1')],
          contains('spatial'),
        );
      },
    );

    test(
      'docker_compose makes a compose host, then spatial moves in',
      () async {
        final CallToolResult r = await call(
          'la_set_placement',
          <String, Object?>{
            'project': 'Moving',
            'changes': <Object?>[
              <String, Object?>{
                'op': 'assign',
                'service': 'docker_compose',
                'to': 'new1',
              },
              <String, Object?>{'service': 'spatial', 'to': 'new1'},
            ],
            'save': true,
            'confirm': true,
          },
        );
        expect(r.isError, isNot(isTrue), reason: text(r));
        final Json out = json.decode(text(r)) as Json;
        expect(out['composeClustersCreatedOn'], <String>['new1']);
        final Json p = stored();
        expect((p['serverServices'] as Json)[idOf(p, 'new1')], <String>[
          'docker_compose',
        ]);
        expect(
          (p['clusterServices'] as Json)[clusterOf(p, 'new1')],
          containsAll(<String>['spatial', 'spatial_service', 'geoserver']),
        );
        expect(
          (rowsOf(p, 'spatial').single['softwareVersions'] as Json)['spatial'],
          '1.0.0',
        );
      },
    );
  });

  group('la_set_servers', () {
    setUp(() => fake.projects.add(placementPortal()));

    Json server(Json p, String name) => (p['servers'] as List<dynamic>)
        .cast<Json>()
        .firstWhere((Json s) => s['name'] == name);

    test('previews an added server, warns on a name clash', () async {
      final CallToolResult r = await call('la_set_servers', <String, Object?>{
        'project': 'Moving',
        'add': <Object?>[
          <String, Object?>{
            'name': 'la-1',
            'ip': '10.0.1.77',
            'sshKey': 'k1',
            'gateways': <String>['vm1'],
          },
        ],
      });
      expect(r.isError, isNot(isTrue), reason: text(r));
      final Json out = json.decode(text(r)) as Json;
      expect(out['saved'], isFalse);
      final Json added = (out['added'] as List<dynamic>).single as Json;
      expect(added['ip'], '10.0.1.77');
      expect(added['sshKey'], 'k1');
      expect(added['gateways'], <String>['vm1']);
      expect(
        (out['warnings'] as List<dynamic>).single,
        contains('Project demo also has a server "la-1", at 10.0.0.5'),
      );
      // Compose hosts list every server name in extra_hosts: they learn
      // the new one on their next deploy.
      expect(out['extraHosts'], contains('dc1'));
      expect((out['deployNotes'] as List<dynamic>).first, contains('dc1, dc2'));
      expect(fake.updatedProjects, isEmpty);
      expect(backups.listSync(), isEmpty);
    });

    test('save needs confirm', () async {
      final CallToolResult r = await call('la_set_servers', <String, Object?>{
        'project': 'Moving',
        'remove': <String>['new1'],
        'save': true,
      });
      expect(r.isError, isTrue);
      expect(text(r), contains('confirm'));
      expect(fake.updatedProjects, isEmpty);
    });

    test('refuses bad values and busy servers', () async {
      for (final (Map<String, Object?> args, String why)
          in <(Map<String, Object?>, String)>[
            (<String, Object?>{}, 'at least one of add, update, remove'),
            (
              <String, Object?>{
                'add': <Object?>[
                  <String, Object?>{'name': r'$(id)', 'ip': '10.0.1.9'},
                ],
              },
              'is not a valid name',
            ),
            (
              <String, Object?>{
                'add': <Object?>[
                  <String, Object?>{'name': 'x', 'ip': '10.0.1.9 ; id'},
                ],
              },
              'is not an IP address',
            ),
            (
              <String, Object?>{
                'add': <Object?>[
                  <String, Object?>{'name': 'x'},
                ],
              },
              'Required property "ip"',
            ),
            (
              <String, Object?>{
                'add': <Object?>[
                  <String, Object?>{
                    'name': 'x',
                    'ip': '10.0.1.9',
                    'sshKey': 'k9',
                  },
                ],
              },
              'no usable ssh key "k9"',
            ),
            (
              <String, Object?>{
                'remove': <String>['vm1'],
              },
              'vm1 still runs collectory',
            ),
            (
              <String, Object?>{
                'remove': <String>['--all'],
              },
              'is not a valid name',
            ),
            (
              <String, Object?>{
                'update': <Object?>[
                  <String, Object?>{'name': 'nope', 'ip': '10.0.1.9'},
                ],
              },
              'No server "nope"',
            ),
          ]) {
        final CallToolResult r = await call('la_set_servers', <String, Object?>{
          'project': 'Moving',
          ...args,
          'save': true,
          'confirm': true,
        });
        expect(r.isError, isTrue, reason: why);
        expect(text(r), contains(why));
      }
      expect(fake.updatedProjects, isEmpty);
      expect(backups.listSync(), isEmpty);
    });

    test('save + confirm adds, updates and removes as the UI would', () async {
      final CallToolResult r = await call('la_set_servers', <String, Object?>{
        'project': 'Moving',
        'add': <Object?>[
          <String, Object?>{'name': 'spatial-1', 'ip': '10.0.1.135'},
        ],
        'update': <Object?>[
          <String, Object?>{'name': 'dc1', 'ip': '10.0.1.99'},
        ],
        'remove': <String>['new1'],
        'save': true,
        'confirm': true,
      });
      expect(r.isError, isNot(isTrue), reason: text(r));
      final Json out = json.decode(text(r)) as Json;
      expect(out['saved'], isTrue);
      expect(out['removed'], <String>['new1']);
      expect(out['warnings'], contains(startsWith('spatial-1 has no ssh key')));
      expect(((out['updated'] as Json)['dc1'] as Json)['fields'], <String>[
        'ip',
      ]);
      // dc1's names now resolve elsewhere for dc2's containers.
      expect(out['extraHosts'], contains('dc2'));
      expect((out['deployNotes'] as List<dynamic>).first, contains('dc1'));
      final Json p = fake.updatedProjects.single;
      expect(server(p, 'spatial-1')['ip'], '10.0.1.135');
      expect(server(p, 'dc1')['ip'], '10.0.1.99');
      expect(
        (p['servers'] as List<dynamic>).cast<Json>().map((Json s) => s['name']),
        isNot(contains('new1')),
      );
      expect(
        (fake.sshConfBody!['servers'] as List<dynamic>).cast<Json>().map(
          (Json s) => s['name'],
        ),
        contains('spatial-1'),
      );
      final Json old =
          json.decode(File(out['backup'] as String).readAsStringSync()) as Json;
      expect(server(old, 'dc1')['ip'], isNot('10.0.1.99'));
    });
  });

  // The lademo rollback: unticking docker_compose went through
  // deleteCluster(), which also dropped every row pointing at a missing
  // cluster, on servers the change never touched.
  group('orphan deploy rows', () {
    setUp(() {
      fake.projects.removeWhere((Json p) => p['shortName'] == 'Moving');
      fake.projects.add(placementPortalWithOrphan());
    });

    bool keepsOrphan(Json p) => (p['serviceDeploys'] as List<dynamic>)
        .cast<Json>()
        .any((Json sd) => sd['clusterId'] == orphanCluster);

    Future<Json> saved(String tool, Map<String, Object?> args) async {
      final CallToolResult r = await call(tool, <String, Object?>{
        'project': 'Moving',
        ...args,
        'save': true,
        'confirm': true,
      });
      expect(r.isError, isNot(isTrue), reason: text(r));
      final Json out = json.decode(text(r)) as Json;
      expect(out, isNot(contains('collateralRemovals')));
      return out;
    }

    test('survive unassigning docker_compose', () async {
      await saved('la_set_placement', <String, Object?>{
        'changes': <Object?>[
          <String, Object?>{
            'op': 'unassign',
            'service': 'ala_hub',
            'from': 'dc2',
          },
          <String, Object?>{
            'op': 'unassign',
            'service': 'docker_compose',
            'from': 'dc2',
          },
        ],
      });
      expect(keepsOrphan(fake.updatedProjects.single), isTrue);
    });

    test('survive removing a server', () async {
      await saved('la_set_placement', <String, Object?>{
        'changes': <Object?>[
          <String, Object?>{
            'op': 'unassign',
            'service': 'ala_hub',
            'from': 'dc2',
          },
        ],
      });
      fake.projects
        ..removeWhere((Json p) => p['shortName'] == 'Moving')
        ..add(fake.updatedProjects.last);
      await saved('la_set_servers', <String, Object?>{
        'remove': <String>['dc2'],
      });
      expect(keepsOrphan(fake.updatedProjects.last), isTrue);
    });
  });

  // The lademo test: saves made through the tools, rows lost by a bug, and
  // the backup taken before the first save put back.
  group('la_restore_backup', () {
    setUp(() {
      fake.projects.removeWhere((Json p) => p['shortName'] == 'Moving');
      fake.projects.add(placementPortalWithOrphan());
      fake.applyUpdates = true;
    });

    Json moving() =>
        fake.projects.firstWhere((Json p) => p['shortName'] == 'Moving');
    List<Json> rows(Json p, String c) => (p[c] as List<dynamic>).cast<Json>();
    Future<Json> ok(String tool, Map<String, Object?> args) async {
      final CallToolResult r = await call(tool, <String, Object?>{
        'project': 'Moving',
        ...args,
      });
      expect(r.isError, isNot(isTrue), reason: text(r));
      return json.decode(text(r)) as Json;
    }

    test('lists, previews and puts a backup back', () async {
      expect(
        (await ok('la_restore_backup', <String, Object?>{}))['backups'],
        isEmpty,
      );
      final Json original = json.decode(json.encode(moving())) as Json;
      await ok('la_set_servers', <String, Object?>{
        'add': <Object?>[
          <String, Object?>{'name': 'test1', 'ip': '10.0.1.200'},
        ],
        'save': true,
        'confirm': true,
      });
      await ok('la_set_placement', <String, Object?>{
        'changes': <Object?>[
          <String, Object?>{
            'op': 'assign',
            'service': 'docker_compose',
            'to': 'test1',
          },
        ],
        'save': true,
        'confirm': true,
      });
      // What the old unassign did on top: the orphan row gone.
      rows(
        moving(),
        'serviceDeploys',
      ).removeWhere((Json sd) => sd['clusterId'] == orphanCluster);

      final List<dynamic> listed =
          (await ok('la_restore_backup', <String, Object?>{}))['backups']
              as List<dynamic>;
      expect(listed, hasLength(2));
      final String first = (listed.last as Json)['backup'] as String;
      expect((listed.last as Json)['servers'], isNot(contains('test1')));

      final int saves = fake.updatedProjects.length;
      final Json preview = await ok('la_restore_backup', <String, Object?>{
        'backup': first,
      });
      expect(preview['saved'], isFalse);
      final Json changes = preview['changes'] as Json;
      expect(
        (changes['servers'] as Json)['dropped'].single,
        startsWith('test1 ('),
      );
      expect(
        (changes['serviceDeploys'] as Json)['back'].single,
        startsWith('spatial_service on dc1 ('),
      );
      expect(
        (changes['serviceDeploys'] as Json)['dropped'].single,
        startsWith('docker_compose on test1 ('),
      );
      expect((changes['clusters'] as Json)['dropped'], hasLength(1));
      expect((preview['newerBackups'] as Json)['backups'], hasLength(1));
      expect(fake.updatedProjects, hasLength(saves));

      final Json out = await ok('la_restore_backup', <String, Object?>{
        'backup': first,
        'save': true,
        'confirm': true,
      });
      expect(out['saved'], isTrue);
      expect(out, isNot(contains('stillDifferent')));
      expect((out['rowsMatchTheBackup'] as Json).values, everyElement(isTrue));
      expect(File(out['backupOfWhatWasThere'] as String).existsSync(), isTrue);
      final Json body = fake.updatedProjects.last;
      expect(body.keys, isNot(contains('serversMap')));
      expect(body['genConf'], original['genConf']);
      for (final String c in <String>['servers', 'serviceDeploys']) {
        expect(
          rows(body, c).map((Json r) => r['id']),
          unorderedEquals(rows(original, c).map((Json r) => r['id'])),
        );
      }
      expect(
        (fake.sshConfBody!['servers'] as List<dynamic>).cast<Json>().map(
          (Json s) => s['name'],
        ),
        isNot(contains('test1')),
      );

      // Nothing left to restore.
      final CallToolResult again = await call(
        'la_restore_backup',
        <String, Object?>{
          'project': 'Moving',
          'backup': first,
          'save': true,
          'confirm': true,
        },
      );
      expect(again.isError, isTrue);
      expect(text(again), contains('already holds'));
    });

    test('takes only a backup of that project, and confirm', () async {
      await ok('la_set_servers', <String, Object?>{
        'add': <Object?>[
          <String, Object?>{'name': 'test1', 'ip': '10.0.1.200'},
        ],
        'save': true,
        'confirm': true,
      });
      final String name = backups.listSync().single.uri.pathSegments.last;
      final Json demo = fake.projects.firstWhere(
        (Json p) => p['shortName'] != 'Moving',
      );
      for (final (Map<String, Object?> args, String why)
          in <(Map<String, Object?>, String)>[
            (<String, Object?>{'backup': name, 'save': true}, 'confirm'),
            (<String, Object?>{'save': true, 'confirm': true}, 'Name the'),
            (<String, Object?>{'backup': '../$name'}, 'not a backup of'),
            (<String, Object?>{'backup': 7}, 'not of type'),
            (
              <String, Object?>{
                'backup': name.replaceFirst(
                  moving()['id'] as String,
                  '0123456789abcdef01234567',
                ),
              },
              'not a backup of',
            ),
            (
              <String, Object?>{
                'backup':
                    '${moving()['dirName']}-${moving()['id']}-2020-01-01T00-00-00Z.json',
              },
              'No backup',
            ),
          ]) {
        final CallToolResult r = await call(
          'la_restore_backup',
          <String, Object?>{'project': 'Moving', ...args},
        );
        expect(r.isError, isTrue, reason: why);
        expect(text(r), contains(why));
      }
      final CallToolResult other = await call(
        'la_restore_backup',
        <String, Object?>{'project': demo['dirName'], 'backup': name},
      );
      expect(other.isError, isTrue);
      expect(text(other), contains('not a backup of'));
    });
  });
}
