import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:la_toolkit/redux/project_bases.dart';
import 'package:la_toolkit_core/models/la_project.dart';
import 'package:la_toolkit_core/models/la_server.dart';
import 'package:la_toolkit_core/models/project_patch.dart';

// The copies a save diffs against: taken from every backend list, except
// for the project open with possibly unsaved changes, whose base only moves
// when the user saves or reloads.

Json copy(Object? j) => jsonDecode(jsonEncode(j)) as Json;

/// A project as get-conf would list it.
Json stored(LAProject p) => copy(p.toJson())..['genConf'] = <String, dynamic>{};

void main() {
  late LAProject portal;
  late LAProject hub;

  setUp(() {
    portal = LAProject(
      longName: 'Portal',
      shortName: 'portal',
      domain: 'p.org',
    );
    portal.upsertServer(LAServer(name: 'vm1', projectId: portal.id));
    hub = LAProject(
      longName: 'Hub',
      shortName: 'hub',
      isHub: true,
      parent: portal,
    );
  });

  List<dynamic> listWith({String portalName = 'Portal', String? vmIp}) {
    final Json p = stored(portal)..['longName'] = portalName;
    if (vmIp != null) {
      ((p['servers'] as List<dynamic>).first as Json)['ip'] = vmIp;
    }
    p['hubs'] = <dynamic>[stored(hub)];
    return <dynamic>[p];
  }

  test('a save diffs only what was edited since the copy read', () {
    final ProjectBases bases = ProjectBases()..recordAll(listWith());
    final LAProject edited = LAProject.fromJson(listWith().first as Json)
      ..longName = 'Renamed';
    final Json patch = ProjectPatch.diff(
      bases.clientBase(portal.id)!,
      edited.toApiJson(),
    );
    expect((patch['project'] as Json).keys, <String>['longName']);
    expect((patch['rows'] as Json)['servers'] as Json?, isNull);
  });

  test('the open project keeps its base; the others follow the backend', () {
    final ProjectBases bases = ProjectBases()..recordAll(listWith());
    bases.recordAll(
      listWith(portalName: 'Changed by the MCP'),
      keepBase: <String>{portal.id},
    );
    expect(bases.baseRaw(portal.id)!['longName'], 'Portal');
    expect(bases.latestRaw(portal.id)!['longName'], 'Changed by the MCP');
    expect(bases.changedSinceBase(portal.id), isTrue);
    expect(bases.changedSinceBase(hub.id), isFalse);

    bases.adoptLatest(portal.id);
    expect(bases.baseRaw(portal.id)!['longName'], 'Changed by the MCP');
    expect(bases.changedSinceBase(portal.id), isFalse);
  });

  test(
    'check results and progress flags do not count as changed elsewhere',
    () {
      final ProjectBases bases = ProjectBases()..recordAll(listWith());
      final List<dynamic> checked = listWith();
      final Json p = checked.first as Json;
      p['status'] = 'firstDeploy';
      ((p['servers'] as List<dynamic>).first as Json)['reachable'] = 'success';
      bases.recordAll(checked, keepBase: <String>{portal.id});
      expect(bases.changedSinceBase(portal.id), isFalse);

      bases.recordAll(
        listWith(vmIp: '10.9.9.9'),
        keepBase: <String>{portal.id},
      );
      expect(bases.changedSinceBase(portal.id), isTrue);
    },
  );

  test('a hub is diffed against its own row, parsed inside its portal', () {
    final ProjectBases bases = ProjectBases()..recordAll(listWith());
    final Json base = bases.clientBase(hub.id)!;
    expect(base['id'], hub.id);
    expect(base['isHub'], isTrue);
    expect(bases.parseLatest(hub.id)!.parent!.id, portal.id);
  });

  test(
    'saves of one project run one after another, a failure included',
    () async {
      final SaveQueue queue = SaveQueue();
      final List<String> log = <String>[];
      final Completer<void> first = Completer<void>();
      final Future<void> a = queue.run('p', () async {
        log.add('a start');
        await first.future;
        log.add('a end');
        throw Exception('a failed');
      });
      final Future<void> b = queue.run('p', () async => log.add('b'));
      final Future<void> other = queue.run('q', () async => log.add('q'));
      await other;
      expect(log, <String>['a start', 'q']);
      first.complete();
      await expectLater(a, throwsException);
      await b;
      expect(log, <String>['a start', 'q', 'a end', 'b']);
    },
  );
}
