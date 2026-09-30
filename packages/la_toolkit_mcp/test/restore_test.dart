import 'package:la_toolkit_mcp/src/projects.dart';
import 'package:la_toolkit_mcp/src/restore.dart';
import 'package:test/test.dart';

void main() {
  // get-conf returns more than the app sends (maps, timestamps, lastCmdEntryId)
  // and less (dockerComposeRelease): the body takes the app's keys.
  test('restoreBody sends the backup in the shape the app sends', () {
    final Json api = <String, dynamic>{
      'id': 'p1',
      'shortName': 'now',
      'dockerComposeRelease': 'v1.5.1',
      'genConf': <String, dynamic>{'LA_x': 'now'},
      'servers': <Json>[
        <String, dynamic>{'id': 's1', 'name': 'a', 'ip': '10.0.0.1'},
      ],
      'serviceDeploys': <Json>[],
    };
    final Json backup = <String, dynamic>{
      'id': 'p1',
      'shortName': 'then',
      'updatedAt': 1,
      'serversMap': <String, dynamic>{},
      'lastCmdEntryId': 'c1',
      'genConf': <String, dynamic>{'LA_x': 'then'},
      'servers': <Json>[
        <String, dynamic>{
          'id': 's0',
          'name': 'b',
          'ip': '10.0.0.2',
          'createdAt': 1,
          'projectId': 'p1',
        },
      ],
      'serviceDeploys': <Json>[
        <String, dynamic>{'id': 'd1', 'createdAt': 1, 'updatedAt': 2, 'x': 1},
      ],
    };
    expect(restoreBody(backup, api), <String, dynamic>{
      'id': 'p1',
      'shortName': 'then',
      'dockerComposeRelease': 'v1.5.1',
      'genConf': <String, dynamic>{'LA_x': 'then'},
      'servers': <Json>[
        <String, dynamic>{'id': 's0', 'name': 'b', 'ip': '10.0.0.2'},
      ],
      'serviceDeploys': <Json>[
        <String, dynamic>{'id': 'd1', 'x': 1},
      ],
    });
  });

  test('restoreDiff ignores timestamps; restoreCheck compares ids', () {
    final Json a = <String, dynamic>{
      'servers': <Json>[
        <String, dynamic>{'id': 's1', 'name': 'a', 'updatedAt': 1},
      ],
    };
    final Json b = <String, dynamic>{
      'servers': <Json>[
        <String, dynamic>{'id': 's1', 'name': 'a', 'updatedAt': 2},
      ],
    };
    expect(restoreDiff(a, b), isEmpty);
    expect((restoreCheck(a, b))['servers'], isTrue);
    final Json c = <String, dynamic>{
      'servers': <Json>[
        <String, dynamic>{'id': 's1', 'name': 'renamed'},
        <String, dynamic>{'id': 's2', 'name': 'b'},
      ],
    };
    expect(restoreDiff(a, c)['servers'], <String, dynamic>{
      'back': <String>['b (s2)'],
      'changed': <String>['renamed (s1)'],
    });
    expect((restoreCheck(a, c))['servers'], isFalse);
  });
}
