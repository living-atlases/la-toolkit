import 'package:la_toolkit_core/placement/move_services.dart';
import 'package:la_toolkit_mcp/la_toolkit_mcp.dart';
import 'package:la_toolkit_mcp/src/placement.dart';
import 'package:test/test.dart';

void main() {
  group('parseMoves', () {
    test('reads names and legs', () {
      final ServiceMove m = parseMoves(<Object?>[
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
          <String, dynamic>{'service': 'spatial'},
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
        expect(() => parseMoves(bad), throwsFormatException, reason: '$bad');
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
}
