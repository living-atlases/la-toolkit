import 'package:la_toolkit_mcp/la_toolkit_mcp.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

/// A backend's cmd-history over [all] (newest first), recording each request.
class _Pages {
  _Pages(this.all, {this.cannotPage = false});

  final List<Json> all;
  final bool cannotPage;
  final List<(int, int)> requests = <(int, int)>[];

  Future<Json?> call(int skip, int limit) async {
    requests.add((skip, limit));
    if (cannotPage) return null;
    return <String, dynamic>{
      'entries': all.skip(skip).take(limit).toList(),
      'total': all.length,
    };
  }
}

void main() {
  final List<Json> seven = <Json>[
    for (int i = 6; i >= 0; i--) run('r$i', 1000 + i),
  ];

  test('pagedRuns walks the pages until the limit or the total', () async {
    final _Pages p = _Pages(seven);
    final List<Json>? out = await pagedRuns(p.call, limit: 10, pageSize: 3);
    expect(out!.map((Json e) => e['id']), <String>[
      for (int i = 6; i >= 0; i--) 'r$i',
    ]);
    expect(p.requests, <(int, int)>[(0, 3), (3, 3), (6, 3)]);
  });

  test('pagedRuns asks only for what is still missing', () async {
    final _Pages p = _Pages(seven);
    final List<Json>? out = await pagedRuns(p.call, limit: 4, pageSize: 3);
    expect(out, hasLength(4));
    expect(p.requests, <(int, int)>[(0, 3), (3, 1)]);
  });

  test('pagedRuns is null when the backend cannot page', () async {
    expect(
      await pagedRuns(_Pages(seven, cannotPage: true).call, limit: 5),
      isNull,
    );
  });

  test('findRunPaged finds an id on a later page', () async {
    final _Pages p = _Pages(seven);
    final Json? e = await findRunPaged('r1', p.call, pageSize: 3);
    expect(e!['id'], 'r1');
    expect(p.requests, <(int, int)>[(0, 3), (3, 3)]);
  });

  test('findRunPaged is null for an id that is not in the history', () async {
    expect(await findRunPaged('nope', _Pages(seven).call, pageSize: 3), isNull);
  });

  test('findRunPaged is null when the backend cannot page', () async {
    expect(
      await findRunPaged('r1', _Pages(seven, cannotPage: true).call),
      isNull,
    );
  });
}
