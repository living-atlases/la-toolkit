import 'dart:convert';

import 'package:la_toolkit_core/models/deployment_type.dart';
import 'package:la_toolkit_core/models/la_cluster.dart';
import 'package:la_toolkit_core/models/la_project.dart';
import 'package:la_toolkit_core/models/la_server.dart';
import 'package:la_toolkit_core/placement/placement_changes.dart';
import 'package:la_toolkit_core/placement/server_changes.dart';
import 'package:la_toolkit_mcp/la_toolkit_mcp.dart';
import 'package:la_toolkit_mcp/src/placement.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  group('parseChanges', () {
    test('reads names and legs', () {
      final ServiceMove m = parseChanges(<Object?>[
        <String, dynamic>{
          'service': 'spatial',
          'to': 'dc2',
          'from': 'dc1',
          'fromLeg': 'docker',
          'toLeg': 'vm',
        },
      ]).single;
      expect(m.service, 'spatial');
      expect(m.to, 'dc2');
      expect(m.from, 'dc1');
      expect(m.fromLeg, PlacementLeg.docker);
      expect(m.toLeg, PlacementLeg.vm);
      expect(m.op, PlacementOp.move);
      expect(
        parseChanges(<Object?>[
          <String, dynamic>{
            'op': 'unassign',
            'service': 'docker_compose',
            'from': 'dc2',
          },
        ]).single.op,
        PlacementOp.unassign,
      );
    });

    test('refuses anything else', () {
      for (final Object? bad in <Object?>[
        null,
        'spatial',
        <Object?>[],
        <Object?>['spatial'],
        <Object?>[
          <String, dynamic>{'to': 'dc2'},
        ],
        <Object?>[
          <String, dynamic>{'service': 'spatial', 'op': 'copy'},
        ],
        <Object?>[
          <String, dynamic>{'service': 'spatial; id', 'to': 'dc2'},
        ],
        <Object?>[
          <String, dynamic>{'service': 'spatial', 'to': '-dc2'},
        ],
        <Object?>[
          <String, dynamic>{'service': 'spatial', 'to': 'dc2', 'from': 3},
        ],
        <Object?>[
          <String, dynamic>{
            'service': 'spatial',
            'to': 'dc2',
            'toLeg': 'swarm',
          },
        ],
      ]) {
        expect(() => parseChanges(bad), throwsFormatException, reason: '$bad');
      }
    });
  });

  test('serverChanges: only servers that change, a leg change both ways', () {
    final Json c = serverChanges(
      <String, Map<String, List<String>>>{
        'dc1': <String, List<String>>{
          'docker': <String>['ala_hub', 'spatial'],
        },
        'vm1': <String, List<String>>{
          'vm': <String>['collectory'],
        },
        'dc2': <String, List<String>>{
          'vm': <String>['images'],
        },
      },
      <String, Map<String, List<String>>>{
        'dc1': <String, List<String>>{
          'docker': <String>['ala_hub'],
        },
        'vm1': <String, List<String>>{
          'vm': <String>['collectory'],
        },
        'dc2': <String, List<String>>{
          'docker': <String>['images', 'spatial'],
        },
      },
    );
    expect(c.keys, unorderedEquals(<String>['dc1', 'dc2']));
    expect(c['dc1'], <String, dynamic>{
      'loses': <String>['spatial (docker)'],
    });
    expect(c['dc2'], <String, dynamic>{
      'gains': <String>['images (docker)', 'spatial (docker)'],
      'loses': <String>['images (vm)'],
    });
  });

  test('publicNameChanges: names moving between hosts, new hosts', () {
    Json conf(Map<String, List<String>> m) => <String, dynamic>{
      'LA_nginx_docker_internal_aliases_by_host': m,
    };
    final Json c = publicNameChanges(
      conf(<String, List<String>>{
        'dc1': <String>['records.example.org', 'spatial.example.org'],
      }),
      conf(<String, List<String>>{
        'dc1': <String>['records.example.org'],
        'new1': <String>['spatial.example.org'],
      }),
    );
    expect(c, <String, dynamic>{
      'dc1': <String, dynamic>{
        'loses': <String>['spatial.example.org'],
      },
      'new1': <String, dynamic>{
        'gains': <String>['spatial.example.org'],
      },
    });
    expect(
      publicNameChanges(<String, dynamic>{}, <String, dynamic>{}),
      isEmpty,
    );
  });

  test('extraHostChanges: per host, the names that point elsewhere', () {
    Json conf(Map<String, List<String>> m) => <String, dynamic>{
      'LA_docker_extra_hosts_by_host': m,
    };
    final Json c = extraHostChanges(
      conf(<String, List<String>>{
        'dc1': <String>['spatial.example.org:10.0.0.3', 'auth:10.0.0.9'],
        'dc2': <String>['auth:10.0.0.9'],
      }),
      conf(<String, List<String>>{
        'dc1': <String>['spatial.example.org:10.0.0.4', 'auth:10.0.0.9'],
        'dc2': <String>['auth:10.0.0.9', 'spatial.example.org:10.0.0.4'],
      }),
    );
    expect(c, <String, dynamic>{
      'dc1': <String, dynamic>{
        'spatial.example.org': <String, dynamic>{
          'before': '10.0.0.3',
          'after': '10.0.0.4',
        },
      },
      'dc2': <String, dynamic>{
        'spatial.example.org': <String, dynamic>{
          'before': null,
          'after': '10.0.0.4',
        },
      },
    });
  });

  test('lintDelta: only what the change adds or removes', () {
    Json report(List<String> findings, List<String> deps) => <String, dynamic>{
      'findings': <Json>[
        for (final String f in findings) <String, dynamic>{'message': f},
      ],
      'dependencyErrors': deps,
    };
    final Json same = lintDelta(
      report(<String>['a', 'b'], <String>['java']),
      report(<String>['a', 'b'], <String>['java']),
    );
    expect(same['new'], isEmpty);
    expect(same['resolved'], isEmpty);
    expect(same['unchanged'], 2);
    expect(same['unchangedDependencyErrors'], 1);

    final Json d = lintDelta(
      report(<String>['a', 'b'], <String>['java']),
      report(<String>['b', 'c'], <String>['java', 'solr']),
    );
    expect(d['new'], <Json>[
      <String, dynamic>{'message': 'c'},
    ]);
    expect(d['resolved'], <String>['a']);
    expect(d['newDependencyErrors'], <String>['solr']);
    expect(d['unchanged'], 1);
  });

  group('la_set_servers arguments', () {
    final List<Json> keys = <Json>[
      <String, dynamic>{
        'name': 'k1',
        'missing': false,
        'desc': 'k1',
        'encrypted': false,
      },
      <String, dynamic>{
        'name': 'gone',
        'missing': true,
        'desc': 'gone',
        'encrypted': false,
      },
    ];

    test('reads servers and resolves the ssh key', () {
      final ({
        List<ServerSpec> add,
        List<ServerSpec> update,
        List<String> remove,
      })
      c = parseServerChanges(<String, Object?>{
        'add': <Object?>[
          <String, dynamic>{
            'name': 'a',
            'ip': '10.0.0.1',
            'sshPort': 2222,
            'sshKey': 'k1',
            'aliases': <String>['a.example.org'],
          },
        ],
        'remove': <String>['b'],
      }, keys);
      expect(c.add.single.sshKey!.name, 'k1');
      expect(c.add.single.sshPort, 2222);
      expect(c.add.single.aliases, <String>['a.example.org']);
      expect(c.update, isEmpty);
      expect(c.remove, <String>['b']);
    });

    test('refuses anything else', () {
      for (final Map<String, Object?> bad in <Map<String, Object?>>[
        <String, Object?>{'add': 'a'},
        <String, Object?>{
          'add': <Object?>['a'],
        },
        <String, Object?>{
          'add': <Object?>[
            <String, dynamic>{'ip': '10.0.0.1'},
          ],
        },
        <String, Object?>{
          'add': <Object?>[
            <String, dynamic>{'name': 'a', 'sshKey': 'gone'},
          ],
        },
        <String, Object?>{
          'add': <Object?>[
            <String, dynamic>{'name': 'a', 'sshPort': '22'},
          ],
        },
        <String, Object?>{
          'add': <Object?>[
            <String, dynamic>{
              'name': 'a',
              'aliases': <String>['x y'],
            },
          ],
        },
        <String, Object?>{'remove': 'a'},
        <String, Object?>{
          'remove': <String>['-a'],
        },
      ]) {
        expect(
          () => parseServerChanges(bad, keys),
          throwsFormatException,
          reason: '$bad',
        );
      }
    });

    test('serverNameClashes: same name elsewhere, other IP', () {
      final LAProject p = LAProject(
        longName: 'P',
        shortName: 'P',
        domain: 'example.org',
      );
      p.upsertServer(LAServer(name: 'h1', ip: '10.0.0.1', projectId: p.id));
      p.upsertServer(LAServer(name: 'h2', ip: '10.0.0.2', projectId: p.id));
      final ProjectRef self = ProjectRef(<String, dynamic>{
        'id': p.id,
        'dirName': 'p',
      });
      final List<ProjectRef> all = <ProjectRef>[
        self,
        ProjectRef(<String, dynamic>{
          'id': 'o',
          'dirName': 'other',
          'servers': <Json>[
            <String, dynamic>{'name': 'h1', 'ip': '10.0.0.1'},
            <String, dynamic>{'name': 'h2', 'ip': '10.9.9.9'},
          ],
        }),
      ];
      expect(serverNameClashes(all, self, p, <String>['h1', 'h2']), <String>[
        'Project other also has a server "h2", at 10.9.9.9: ssh to that name '
            'may reach either.',
      ]);
      expect(serverJson(p, 'h1')['ip'], '10.0.0.1');
    });
  });

  test('collateralRemovals names rows dropped off untouched servers', () {
    final Json portal = placementPortalWithOrphan();
    final LAProject before = LAProject.fromJson(portal);
    final LAProject after = LAProject.fromJson(portal);
    final LAServer dc2 = after.getServerByName('dc2')!;
    // What the UI cluster delete does: dc2's rows go, and the orphan too.
    after.deleteCluster(
      after.clusters.firstWhere((LACluster c) => c.serverId == dc2.id),
    );
    final List<Json> rows = collateralRemovals(before, after, <String>['dc2']);
    expect(rows, <Json>[
      <String, dynamic>{
        'service': 'spatial_service',
        'server': 'dc1',
        'cluster': orphanCluster,
        'clusterMissing': true,
      },
    ]);
    expect(collateralRemovals(before, before, <String>[]), isEmpty);
  });

  test('collateralRemovals sees a hub move as its own', () {
    final LAProject portal = LAProject.fromJson(placementPortal());
    final LAProject hub = LAProject(
      longName: 'Hub',
      shortName: 'hub',
      domain: 'hub.example.net',
      alaInstallRelease: 'v2.4.2',
      generatorRelease: '1.8.32',
      isHub: true,
      parent: portal,
    );
    hub.serviceInUse('ala_hub', true);
    portal.hubs.add(hub);
    hub.assignByType(
      portal.clusters
          .firstWhere(
            (LACluster c) => c.serverId == portal.getServerByName('dc1')!.id,
          )
          .id,
      DeploymentType.dockerCompose,
      <String>['ala_hub'],
    );
    final Json stored = json.decode(json.encode(portal.toApiJson())) as Json;
    LAProject hubOf(Json j) => LAProject.fromJson(j).hubs.single;
    final LAProject before = hubOf(stored);
    final LAProject after = hubOf(stored);
    changePlacement(after, const <ServiceMove>[
      ServiceMove(service: 'ala_hub', to: 'dc2'),
    ]);
    expect(
      after.serviceDeploys.length,
      before.serviceDeploys.length,
      reason: 'a move replaces rows',
    );
    expect(collateralRemovals(before, after, <String>['dc1', 'dc2']), isEmpty);
    // Named by the portal's server, not left unresolved.
    expect(
      collateralRemovals(before, after, <String>['dc2']),
      allOf(isNotEmpty, everyElement(containsPair('server', 'dc1'))),
    );
  });
}
