import 'package:la_toolkit_mcp/la_toolkit_mcp.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  final Json hub = project(id: 'h1', dirName: 'myhub', compose: false, isHub: true);
  final List<Json> portals = <Json>[
    project(hubs: <Json>[hub]),
    project(id: 'p2', dirName: 'other', compose: false, vm: true),
  ];

  test('finds portals and hubs by id, dirName or shortName', () {
    expect(findProject(portals, 'DEMO')!.id, 'p1');
    expect(findProject(portals, 'p2')!.dirName, 'other');
    final ProjectRef h = findProject(portals, 'myhub')!;
    expect(h.isHub, isTrue);
    expect(h.parent!['id'], 'p1');
    expect(findProject(portals, 'missing'), isNull);
  });

  test('dirName wins over another project\'s shortName', () {
    final Json docker = project(id: 'd', dirName: 'lademo-docker')..['shortName'] = 'LADemo';
    final Json plain = project(id: 'l', dirName: 'lademo')..['shortName'] = 'LA Demo';
    expect(findProject(<Json>[docker, plain], 'lademo')!.id, 'l');
    expect(findProject(<Json>[docker, plain], 'ladEMO')!.id, 'l');
  });

  test('derives the deploy mode from placement', () {
    expect(deployMode(project()), DeployMode.dockerCompose);
    expect(deployMode(project(compose: false, vm: true)), DeployMode.vm);
    expect(deployMode(project(vm: true)), DeployMode.hybrid);
    expect(deployMode(project(compose: false)), DeployMode.none);
  });

  test('runs are newest first and findRun defaults to the latest', () {
    final Json p = project(history: <Json>[run('a', 1), run('c', 3), run('b', 2)]);
    expect(runs(p).map((Json r) => r['runId']), <String>['c', 'b', 'a']);
    expect(findRun(p, null)!['id'], 'c');
    expect(findRun(p, 'a')!['id'], 'a');
    expect(findRun(p, 'zzz'), isNull);
  });

  test('only recent unrecorded runs count as possibly running', () {
    final DateTime now = DateTime.fromMillisecondsSinceEpoch(100 * 3600 * 1000);
    final Json p = project(history: <Json>[
      run('old', 10 * 3600 * 1000),
      run('recent', 90 * 3600 * 1000),
      run('done', 99 * 3600 * 1000)..['result'] = 'success',
    ]);
    expect(unfinishedRuns(p, now: now).map((Json e) => e['id']), <String>['recent']);
  });

  test('details name services and servers instead of ids', () {
    final Json d = projectDetails(ProjectRef(project()));
    expect(d['servicesInUse'], <String>['collectory']);
    expect((d['placement'] as Json).keys, contains('cluster Docker Compose on la-1'));
  });
}
