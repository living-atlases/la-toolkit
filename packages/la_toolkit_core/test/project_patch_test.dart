import 'dart:convert';
import 'dart:io';

import 'package:la_toolkit_core/models/la_project.dart';
import 'package:la_toolkit_core/models/la_server.dart';
import 'package:la_toolkit_core/models/project_patch.dart';
import 'package:test/test.dart';

// The merge rules are shared with the backend (api/libs/project-patch.js,
// tests/fixtures/patch_merge there is a copy of this directory): the client
// rebase and the server must agree on every case.

Json copy(Json j) => jsonDecode(jsonEncode(j)) as Json;

void main() {
  group('merge fixtures', () {
    final List<File> files =
        Directory('test/fixtures/patch_merge')
            .listSync()
            .whereType<File>()
            .where((File f) => f.path.endsWith('.json'))
            .toList()
          ..sort((File a, File b) => a.path.compareTo(b.path));

    test('there are fixtures', () => expect(files, isNotEmpty));

    for (final File f in files) {
      final Json c = jsonDecode(f.readAsStringSync()) as Json;
      test('${f.uri.pathSegments.last}: ${c['description']}', () {
        final MergeResult r = ProjectPatch.merge(
          c['current'] as Json,
          c['patch'] as Json,
          foreignIds: ((c['foreignIds'] as List<dynamic>?) ?? <dynamic>[])
              .cast<String>(),
        );
        final List<String> expected =
            (c['conflicts'] as List<dynamic>).cast<String>().toList()..sort();
        expect(r.conflicts, expected);
        if (c['result'] != null) {
          final Json result = ProjectPatch.applyWrites(
            c['current'] as Json,
            r.writes,
          );
          expect(
            ProjectPatch.eq(result, c['result']),
            isTrue,
            reason: jsonEncode(result),
          );
        }
      });
    }
  });

  group('diff', () {
    late LAProject project;
    late Json base;

    setUp(() {
      project = LAProject(longName: 'Portal', shortName: 'p', domain: 'p.org');
      project.upsertServer(LAServer(name: 'vm1', projectId: project.id));
      base = copy(project.toJson());
    });

    test('an untouched project is an empty patch', () {
      expect(ProjectPatch.isEmpty(ProjectPatch.diff(base, base)), isTrue);
    });

    test('only what changed travels', () {
      final Json next = copy(base);
      next['longName'] = 'Renamed';
      (next['servers'] as List<dynamic>).add(
        LAServer(name: 'vm2', projectId: project.id).toJson(),
      );
      final Json p = ProjectPatch.diff(base, next);
      expect(p['project'], <String, dynamic>{
        'longName': <String, dynamic>{'from': 'Portal', 'to': 'Renamed'},
      });
      final Json servers = (p['rows'] as Json)['servers'] as Json;
      expect(
        ((servers['create'] as List<dynamic>).single as Json)['name'],
        'vm2',
      );
      expect(servers['update'], isEmpty);
      expect(servers['remove'], isEmpty);
      expect((p['rows'] as Json).keys, <String>['servers']);
    });

    test('a removed row is a removal, an edited row only its fields', () {
      final Json next = copy(base);
      final Json vm1 = (next['servers'] as List<dynamic>).single as Json;
      vm1['ip'] = '10.0.0.7';
      Json p = ProjectPatch.diff(base, next);
      final Json u =
          ((((p['rows'] as Json)['servers'] as Json)['update'])
                      as List<dynamic>)
                  .single
              as Json;
      expect(u['id'], vm1['id']);
      expect((u['set'] as Json).keys, <String>['ip']);

      (next['servers'] as List<dynamic>).clear();
      p = ProjectPatch.diff(base, next);
      expect(((p['rows'] as Json)['servers'] as Json)['remove'], <Object?>[
        vm1['id'],
      ]);
    });

    test(
      'rows of another project (a hub carrying its portal) are left out',
      () {
        final Json next = copy(base);
        (next['clusters'] as List<dynamic>).add(<String, dynamic>{
          'id': 'c-portal',
          'name': 'compose',
          'projectId': 'the-portal',
        });
        expect(ProjectPatch.isEmpty(ProjectPatch.diff(base, next)), isTrue);
      },
    );

    test('a diff merged into its own base gives the edited copy', () {
      final Json next = copy(base);
      next['domain'] = 'q.org';
      (next['servers'] as List<dynamic>).add(
        LAServer(name: 'vm2', projectId: project.id).toJson(),
      );
      ((next['servers'] as List<dynamic>).first as Json)['ip'] = '10.0.0.8';
      final MergeResult r = ProjectPatch.merge(
        base,
        ProjectPatch.diff(base, next),
      );
      expect(r.conflicts, isEmpty);
      expect(
        ProjectPatch.eq(ProjectPatch.applyWrites(base, r.writes), next),
        isTrue,
      );
    });

    test('genConf travels as derived, last wins', () {
      final Json next = copy(base)
        ..['genConf'] = <String, dynamic>{'LA_domain': 'p.org'};
      final Json p = ProjectPatch.diff(base, next);
      expect(p['derived'], <String, dynamic>{
        'genConf': <String, dynamic>{'LA_domain': 'p.org'},
      });
      expect(p['project'], isEmpty);
    });
  });
}
