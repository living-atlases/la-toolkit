import 'dart:convert';

import 'package:la_toolkit_mcp/la_toolkit_mcp.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

String b64(String s) => base64.encode(utf8.encode(s));

// Shaped like a real toolkit log: colour codes with their ESC stripped, an
// ignored failure, and the run printed twice (ansible's log + the tee).
const String _once = '''
PLAY [docker_compose] **********************************************************

TASK [la-compose : Render compose files] ***************************************
[0;32mok: [la-1.docker_compose]

TASK [la-compose : Run biocache dependency validation] *************************
[0;31mfatal: [la-1.docker_compose]: FAILED! => {"changed": false, "msg": "deps check failed"}
[0;36m...ignoring

TASK [la-compose : SSL Certificates: Fail with the reason nginx did not start] ***
[0;31mfatal: [la-1.docker_compose]: FAILED! => {"changed": false, "msg": "la_nginx is not running after 60s.", "stderr": "cert missing"}

PLAY RECAP *********************************************************************
[0;31mla-1.docker_compose : [0;32mok=10 [0;31mfailed=1
''';

void main() {
  group('failedTasksFromLog', () {
    final List<Json> f = failedTasksFromLog(stripAnsi(_once + _once));

    test('keeps real failures with their task, host and message', () {
      expect(f, hasLength(1));
      expect(
        f.single['task'],
        'la-compose : SSL Certificates: Fail with the reason nginx did not start',
      );
      expect(f.single['host'], 'la-1.docker_compose');
      expect(
        f.single['detail'],
        'la_nginx is not running after 60s.\ncert missing',
      );
    });

    test('lastTask reports the task in progress', () {
      expect(
        lastTask(stripAnsi(_once)),
        'la-compose : SSL Certificates: Fail with the reason nginx did not start',
      );
    });
  });

  test('prefers the JSON callback results when present', () {
    final Json results = <String, dynamic>{
      'code': 2,
      'running': false,
      'logs': b64(_once),
      'results': <dynamic>[
        <String, dynamic>{
          'stats': <String, dynamic>{
            'la-1': <String, dynamic>{
              'ok': 10,
              'failures': 1,
              'unreachable': 0,
            },
          },
          'plays': <dynamic>[
            <String, dynamic>{
              'tasks': <dynamic>[
                <String, dynamic>{
                  'task': <String, dynamic>{'name': 'role : ok task'},
                  'hosts': <String, dynamic>{
                    'la-1': <String, dynamic>{'failed': false},
                  },
                },
                <String, dynamic>{
                  'task': <String, dynamic>{'name': 'role : broken'},
                  'hosts': <String, dynamic>{
                    'la-1': <String, dynamic>{
                      'failed': true,
                      'msg': 'boom',
                      'stderr': 'trace',
                    },
                  },
                },
              ],
            },
          ],
        },
      ],
    };
    expect(failedTasks(results), <Json>[
      <String, dynamic>{
        'task': 'role : broken',
        'host': 'la-1',
        'detail': 'boom\ntrace',
      },
    ]);
    final Json s = summarizeRun(run('r1', 1), results);
    expect(s['verdict'], 'failed');
    expect(s['exitCode'], 2);
    expect((s['recap'] as Json)['la-1'], containsPair('failures', 1));
    expect(s.containsKey('currentTask'), isFalse);
  });

  test(
    'drops ignored failures from the JSON too, and digs stdout for commands',
    () {
      Json task(String name, Json r) => <String, dynamic>{
        'task': <String, dynamic>{'name': name},
        'hosts': <String, dynamic>{'la-1.docker_compose': r},
      };
      final Json results = <String, dynamic>{
        'logs': b64(_once),
        'results': <dynamic>[
          <String, dynamic>{
            'stats': <String, dynamic>{},
            'plays': <dynamic>[
              <String, dynamic>{
                'tasks': <dynamic>[
                  task(
                    'la-compose : Run biocache dependency validation',
                    <String, dynamic>{'failed': true, 'msg': 'x'},
                  ),
                  task('la-compose : Run health check', <String, dynamic>{
                    'failed': true,
                    'rc': 1,
                    'msg': 'non-zero return code',
                    'stderr': '',
                    'stdout': 'checking...\nla_nginx: unhealthy',
                  }),
                ],
              },
            ],
          },
        ],
      };
      expect(failedTasks(results), <Json>[
        <String, dynamic>{
          'task': 'la-compose : Run health check',
          'host': 'la-1.docker_compose',
          'rc': 1,
          'detail': 'non-zero return code\nchecking...\nla_nginx: unhealthy',
        },
      ]);
    },
  );

  test('caps the number and size of failures', () {
    final String many = List<String>.generate(
      20,
      (int i) =>
          'TASK [t$i] ***\nfatal: [h]: FAILED! => {"msg": "${'x' * 3000}"}\n',
    ).join();
    final List<Json> f = failedTasks(
      <String, dynamic>{'logs': b64(many)},
      max: 3,
      maxChars: 100,
    );
    expect(f.map((Json e) => e['task']), <String>['t17', 't18', 't19']);
    expect((f.first['detail'] as String).length, lessThan(150));
  });

  group('verdict mirrors the backend cmdResultFor', () {
    test('success / failed / aborted / unknown', () {
      expect(verdict(code: 0, running: false, failures: 0), 'success');
      expect(verdict(code: 2, running: false, failures: 1), 'failed');
      expect(
        verdict(code: unknownExitCode, running: false, failures: 0),
        'aborted',
      );
      expect(verdict(code: 4, running: false, failures: 0), 'unknown');
    });

    test('plus running and cancelled', () {
      expect(
        verdict(code: unknownExitCode, running: true, failures: 0),
        'running',
      );
      expect(
        verdict(code: cancelledExitCode, running: false, failures: 0),
        'cancelled',
      );
    });
  });

  test('running runs report the current task and no exit code', () {
    final Json s = summarizeRun(run('r1', 1), <String, dynamic>{
      'code': 100,
      'running': true,
      'logs': b64(_once),
    });
    expect(s['verdict'], 'running');
    expect(s.containsKey('exitCode'), isFalse);
    expect(s['currentTask'], isNotNull);
  });
}
