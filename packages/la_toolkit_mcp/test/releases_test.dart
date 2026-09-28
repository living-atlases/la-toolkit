import 'package:la_toolkit_mcp/la_toolkit_mcp.dart';
import 'package:test/test.dart';

void main() {
  test('releases sort as versions, not as names', () {
    expect(
      sortReleases(<String>['v1.9.0', 'v1.10.0', 'upstream', 'v1.8.2']),
      <String>['v1.10.0', 'v1.9.0', 'v1.8.2', 'upstream'],
    );
    expect(sortReleases(<String>['1.9.7', '1.9.11']), <String>[
      '1.9.11',
      '1.9.7',
    ]);
  });

  test('genConf diff names keys only, deep-comparing values', () {
    final Json d = genConfDiff(
      <String, dynamic>{
        'a': 1,
        'gone': 'x',
        'nested': <String, dynamic>{
          'h': <String>['n1'],
        },
        'same': <String>['x'],
      },
      <String, dynamic>{
        'a': 2,
        'new': 'y',
        'nested': <String, dynamic>{
          'h': <String>['n1', 'n2'],
        },
        'same': <String>['x'],
      },
    );
    expect(d['added'], <String>['new']);
    expect(d['removed'], <String>['gone']);
    expect(d['changed'], <String>['a', 'nested']);
  });
}
