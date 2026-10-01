/// Field-level changes of a project, for saving it while other sessions (a
/// browser, the MCP) change it too.
///
/// [ProjectPatch.diff] turns "the copy I read" and "the copy I have now" into
/// what changed: field `{from, to}` pairs, created rows and removed ids. The
/// backend's `patch-project` merges that into what is stored now and answers
/// 409, writing nothing, only when the same field changed on both sides, a
/// row was edited here and deleted there, or a reference points to a row that
/// is gone. Rows nobody mentions are never deleted.
///
/// [ProjectPatch.merge] and [ProjectPatch.applyWrites] are the same rules as
/// the backend's `api/libs/project-patch.js` (a client rebasing its unsaved
/// changes on a pushed project must agree with the server); both run the
/// fixtures in `test/fixtures/patch_merge`.
///
/// Everything works on the JSON of a project ([LAProject.toJson] /
/// `toApiJson`), as the backend stores it.
library;

import 'dart:convert';

typedef Json = Map<String, dynamic>;

class MergeResult {
  MergeResult(this.conflicts, this.writes);

  /// `project.<field>`, `<collection>/<id>` or `<collection>/<id>.<field>`.
  final List<String> conflicts;

  /// `{project: {field: value}, rows: {collection: {create, update, remove}}}`.
  final Json writes;

  bool get hasConflicts => conflicts.isNotEmpty;
}

class ProjectPatch {
  ProjectPatch._();

  static const List<String> projectFields = <String>[
    'longName',
    'shortName',
    'dirName',
    'domain',
    'useSSL',
    'isHub',
    'theme',
    'mapZoom',
    'mapBoundsFstPoint',
    'mapBoundsSndPoint',
    'additionalVariables',
    'alaInstallRelease',
    'generatorRelease',
    'dockerComposeRelease',
    'status',
    'isCreated',
    'fstDeployed',
    'advancedEdit',
    'advancedTune',
    'clientMigration',
  ];

  /// Progress flags any session may move forward: last write wins.
  static const List<String> projectSoft = <String>[
    'status',
    'isCreated',
    'fstDeployed',
    'clientMigration',
  ];

  /// Recomputed by every client from the whole project: last write wins.
  static const List<String> derived = <String>['genConf'];

  static const List<String> collections = <String>[
    'servers',
    'clusters',
    'services',
    'serviceDeploys',
    'variables',
  ];

  static const List<String> rowMeta = <String>[
    'id',
    'projectId',
    'createdAt',
    'updatedAt',
  ];

  /// Written by checks (connectivity, service status), not by people.
  static const Map<String, List<String>> rowSoft = <String, List<String>>{
    'servers': <String>[
      'reachable',
      'sshReachable',
      'sudoEnabled',
      'osName',
      'osVersion',
    ],
    'clusters': <String>[],
    'services': <String>['status'],
    'serviceDeploys': <String>['status', 'checkedAt'],
    'variables': <String>[],
  };

  /// Two sessions creating "the same" row give it different ids.
  static const Map<String, List<String>> naturalKeys = <String, List<String>>{
    'servers': <String>['name'],
    'clusters': <String>[],
    'services': <String>['nameInt'],
    'serviceDeploys': <String>['serviceId', 'serverId', 'clusterId'],
    'variables': <String>['nameInt'],
  };

  static const Map<String, Map<String, String>> refs =
      <String, Map<String, String>>{
        'clusters': <String, String>{'serverId': 'servers'},
        'serviceDeploys': <String, String>{
          'serviceId': 'services',
          'serverId': 'servers',
          'clusterId': 'clusters',
        },
      };

  /// Deep equality where a missing key and null are the same.
  static bool eq(Object? a, Object? b) {
    if (a == null || b == null) {
      return a == null && b == null;
    }
    if (a is List || b is List) {
      if (a is! List || b is! List || a.length != b.length) {
        return false;
      }
      for (int i = 0; i < a.length; i++) {
        if (!eq(a[i], b[i])) {
          return false;
        }
      }
      return true;
    }
    if (a is Map || b is Map) {
      if (a is! Map || b is! Map) {
        return false;
      }
      for (final Object? k in <Object?>{...a.keys, ...b.keys}) {
        if (!eq(a[k], b[k])) {
          return false;
        }
      }
      return true;
    }
    return a == b;
  }

  /// Whether what is stored still is the `from` the client saw. A key the
  /// stored object lacks, and stored sub-keys the client does not know (an
  /// sshKey saved with an old `fingerprint`), are not changes made by anyone:
  /// they would make every edit of that field conflict on old rows.
  static bool matchesFrom(Object? stored, bool present, Object? from) {
    if (!present) {
      return true;
    }
    if (stored is Map && from is Map) {
      return from.keys.every(
        (Object? k) => matchesFrom(stored[k], stored.containsKey(k), from[k]),
      );
    }
    return eq(stored, from);
  }

  static String _id(Object? v) => v.toString();

  static List<Json> _rows(Json p, String c, String projectId) =>
      ((p[c] as List<dynamic>?) ?? <dynamic>[])
          .cast<Json>()
          .where(
            (Json r) =>
                r['projectId'] == null || _id(r['projectId']) == projectId,
          )
          .toList();

  /// What changed from [base] (the copy last read from the backend) to
  /// [next] (the copy edited since). Rows of another project (a hub carrying
  /// its portal's clusters) are left out.
  static Json diff(Json base, Json next) {
    final String projectId = _id(next['id']);
    final Json project = <String, dynamic>{};
    for (final String f in projectFields) {
      if (!eq(base[f], next[f])) {
        project[f] = <String, dynamic>{'from': base[f], 'to': next[f]};
      }
    }
    final Json derivedChanges = <String, dynamic>{};
    for (final String f in derived) {
      if (next.containsKey(f) && !eq(base[f], next[f])) {
        derivedChanges[f] = next[f];
      }
    }
    final Json rows = <String, dynamic>{};
    for (final String c in collections) {
      final Map<String, Json> before = <String, Json>{
        for (final Json r in _rows(base, c, projectId)) _id(r['id']): r,
      };
      final Map<String, Json> after = <String, Json>{
        for (final Json r in _rows(next, c, projectId)) _id(r['id']): r,
      };
      final List<Json> create = <Json>[];
      final List<Json> update = <Json>[];
      for (final MapEntry<String, Json> e in after.entries) {
        final Json? old = before[e.key];
        if (old == null) {
          create.add(e.value);
          continue;
        }
        final Json set = <String, dynamic>{};
        for (final String k in <String>{...old.keys, ...e.value.keys}) {
          if (!rowMeta.contains(k) && !eq(old[k], e.value[k])) {
            set[k] = <String, dynamic>{'from': old[k], 'to': e.value[k]};
          }
        }
        if (set.isNotEmpty) {
          update.add(<String, dynamic>{'id': e.value['id'], 'set': set});
        }
      }
      final List<Object?> remove = before.entries
          .where((MapEntry<String, Json> e) => !after.containsKey(e.key))
          .map((MapEntry<String, Json> e) => e.value['id'])
          .toList();
      if (create.isNotEmpty || update.isNotEmpty || remove.isNotEmpty) {
        rows[c] = <String, dynamic>{
          'create': create,
          'update': update,
          'remove': remove,
        };
      }
    }
    return <String, dynamic>{
      'projectId': next['id'],
      'project': project,
      if (derivedChanges.isNotEmpty) 'derived': derivedChanges,
      'rows': rows,
      // The rows that point to others which this client had read: removing
      // what one of them points to while keeping it is this client's call
      // (orphans the MCP keeps for a restore), not a conflict.
      if (rows.isNotEmpty)
        'seen': <String, dynamic>{
          for (final String c in refs.keys)
            c: _rows(base, c, projectId).map((Json r) => r['id']).toList(),
        },
    };
  }

  /// Whether [patch] changes nothing.
  static bool isEmpty(Json patch) =>
      (patch['project'] as Map<dynamic, dynamic>? ?? <dynamic, dynamic>{})
          .isEmpty &&
      (patch['derived'] as Map<dynamic, dynamic>? ?? <dynamic, dynamic>{})
          .isEmpty &&
      (patch['rows'] as Map<dynamic, dynamic>? ?? <dynamic, dynamic>{}).isEmpty;

  static Json _content(String c, Json row) => <String, dynamic>{
    for (final MapEntry<String, dynamic> e in row.entries)
      if (!rowMeta.contains(e.key) && !rowSoft[c]!.contains(e.key))
        e.key: e.value,
  };

  // Only the creating client's own fields count: a stored row also carries
  // model defaults the client never sends.
  static bool _sameRow(String c, Json stored, Json created) => _content(
    c,
    created,
  ).entries.every((MapEntry<String, dynamic> e) => eq(stored[e.key], e.value));

  /// [patch] merged into [current] (the project as stored now). [foreignIds]
  /// are the ids of rows a hub may point to in its portal.
  static MergeResult merge(
    Json current,
    Json patch, {
    Iterable<String> foreignIds = const <String>[],
  }) {
    final Set<String> foreign = foreignIds.map(_id).toSet();
    final List<String> conflicts = <String>[];
    final Json writesProject = <String, dynamic>{};
    final Json writesRows = <String, dynamic>{};
    final String pid = _id(current['id']);

    final Json projectChanges =
        (patch['project'] as Json?) ?? <String, dynamic>{};
    for (final MapEntry<String, dynamic> e in projectChanges.entries) {
      if (!projectFields.contains(e.key)) {
        continue;
      }
      final Json change = e.value as Json;
      final Object? cur = current[e.key];
      if (eq(cur, change['to'])) {
        continue;
      }
      if (projectSoft.contains(e.key) ||
          matchesFrom(cur, current.containsKey(e.key), change['from'])) {
        writesProject[e.key] = change['to'];
      } else {
        conflicts.add('project.${e.key}');
      }
    }
    final Json derivedChanges =
        (patch['derived'] as Json?) ?? <String, dynamic>{};
    for (final String f in derived) {
      if (derivedChanges.containsKey(f) && !eq(current[f], derivedChanges[f])) {
        writesProject[f] = derivedChanges[f];
      }
    }

    final Json rowOps = (patch['rows'] as Json?) ?? <String, dynamic>{};
    Json opsOf(String c) => (rowOps[c] as Json?) ?? <String, dynamic>{};
    List<Json> currentRows(String c) =>
        ((current[c] as List<dynamic>?) ?? <dynamic>[]).cast<Json>();

    final Map<String, Map<String, Json>> byId = <String, Map<String, Json>>{};
    final Map<String, Set<String>> removed = <String, Set<String>>{};
    for (final String c in collections) {
      byId[c] = <String, Json>{
        for (final Json r in currentRows(c)) _id(r['id']): r,
      };
      removed[c] = ((opsOf(c)['remove'] as List<dynamic>?) ?? <dynamic>[])
          .map(_id)
          .where((String id) => byId[c]!.containsKey(id))
          .toSet();
    }

    final List<(String, Json)> touched = <(String, Json)>[];
    for (final String c in collections) {
      final Json ops = opsOf(c);
      final List<Json> create = <Json>[];
      final List<Json> update = <Json>[];

      for (final Json row
          in ((ops['create'] as List<dynamic>?) ?? <dynamic>[]).cast<Json>()) {
        final String id = _id(row['id']);
        if (row['projectId'] != null && _id(row['projectId']) != pid) {
          continue; // another project's row
        }
        final Json? existing = byId[c]![id];
        if (existing != null) {
          if (!_sameRow(c, existing, row)) {
            conflicts.add('$c/$id');
          }
          continue;
        }
        final List<String> keys = naturalKeys[c]!;
        Json? twin;
        if (keys.isNotEmpty) {
          for (final Json r in currentRows(c)) {
            if (!removed[c]!.contains(_id(r['id'])) &&
                keys.every((String k) => eq(r[k], row[k]))) {
              twin = r;
              break;
            }
          }
        }
        if (twin != null) {
          if (!_sameRow(c, twin, row)) {
            conflicts.add('$c/$id');
          }
          continue;
        }
        create.add(row);
        touched.add((c, row));
      }

      for (final Json u
          in ((ops['update'] as List<dynamic>?) ?? <dynamic>[]).cast<Json>()) {
        final String id = _id(u['id']);
        final Json existingSet = (u['set'] as Json?) ?? <String, dynamic>{};
        final List<String> fields = existingSet.keys
            .where((String f) => !rowMeta.contains(f))
            .toList();
        final Json? existing = byId[c]![id];
        if (existing == null || removed[c]!.contains(id)) {
          if (fields.any((String f) => !rowSoft[c]!.contains(f))) {
            conflicts.add('$c/$id'); // edited here, deleted elsewhere
          }
          continue;
        }
        final Json set = <String, dynamic>{};
        for (final String f in fields) {
          final Json change = existingSet[f] as Json;
          final Object? cur = existing[f];
          if (eq(cur, change['to'])) {
            continue;
          }
          if (rowSoft[c]!.contains(f) ||
              matchesFrom(cur, existing.containsKey(f), change['from'])) {
            set[f] = change['to'];
          } else {
            conflicts.add('$c/$id.$f');
          }
        }
        if (set.isNotEmpty) {
          update.add(<String, dynamic>{'id': u['id'], 'set': set});
          touched.add((c, <String, dynamic>{...existing, ...set}));
        }
      }

      if (create.isNotEmpty || update.isNotEmpty || removed[c]!.isNotEmpty) {
        writesRows[c] = <String, dynamic>{
          'create': create,
          'update': update,
          'remove': removed[c]!.toList(),
        };
      }
    }

    // References: what this patch writes must point to rows that still
    // exist, and what it deletes must not be pointed to by a row that stays.
    final Map<String, Set<String>> finalIds = <String, Set<String>>{};
    for (final String c in collections) {
      finalIds[c] = byId[c]!.keys
          .where((String id) => !removed[c]!.contains(id))
          .toSet();
      final Json? w = writesRows[c] as Json?;
      for (final Json r
          in ((w?['create'] as List<dynamic>?) ?? <dynamic>[]).cast<Json>()) {
        finalIds[c]!.add(_id(r['id']));
      }
    }
    bool dangling(String target, Object? v) =>
        v != null &&
        !finalIds[target]!.contains(_id(v)) &&
        !foreign.contains(_id(v));
    for (final (String c, Json row) in touched) {
      for (final MapEntry<String, String> r
          in (refs[c] ?? <String, String>{}).entries) {
        if (dangling(r.value, row[r.key])) {
          conflicts.add('$c/${row['id']}.${r.key}');
        }
      }
    }
    for (final MapEntry<String, Map<String, String>> cr in refs.entries) {
      final String c = cr.key;
      final Json? w = writesRows[c] as Json?;
      final Map<String, Json> updates = <String, Json>{
        for (final Json u
            in ((w?['update'] as List<dynamic>?) ?? <dynamic>[]).cast<Json>())
          _id(u['id']): u['set'] as Json,
      };
      final Set<String> seen =
          ((((patch['seen'] as Json?) ?? <String, dynamic>{})[c]
                      as List<dynamic>?) ??
                  <dynamic>[])
              .map(_id)
              .toSet();
      for (final Json row in currentRows(c)) {
        if (removed[c]!.contains(_id(row['id'])) ||
            seen.contains(_id(row['id']))) {
          continue;
        }
        final Json merged = <String, dynamic>{
          ...row,
          ...?updates[_id(row['id'])],
        };
        for (final MapEntry<String, String> r in cr.value.entries) {
          final Object? v = merged[r.key];
          if (v != null && removed[r.value]!.contains(_id(v))) {
            conflicts.add('${r.value}/${_id(v)}'); // still used here
          }
        }
      }
    }

    final List<String> sorted = conflicts.toSet().toList()..sort();
    return MergeResult(sorted, <String, dynamic>{
      'project': writesProject,
      'rows': writesRows,
    });
  }

  /// The project as it is after [writes] (a [MergeResult.writes]).
  static Json applyWrites(Json current, Json writes) {
    final Json next = jsonDecode(jsonEncode(current)) as Json;
    next.addAll((writes['project'] as Json?) ?? <String, dynamic>{});
    final Json rows = (writes['rows'] as Json?) ?? <String, dynamic>{};
    for (final MapEntry<String, dynamic> e in rows.entries) {
      final Json w = e.value as Json;
      final Set<String> remove =
          ((w['remove'] as List<dynamic>?) ?? <dynamic>[]).map(_id).toSet();
      final Map<String, Json> updates = <String, Json>{
        for (final Json u
            in ((w['update'] as List<dynamic>?) ?? <dynamic>[]).cast<Json>())
          _id(u['id']): u['set'] as Json,
      };
      final List<Json> list = ((next[e.key] as List<dynamic>?) ?? <dynamic>[])
          .cast<Json>()
          .where((Json r) => !remove.contains(_id(r['id'])))
          .map(
            (Json r) => updates.containsKey(_id(r['id']))
                ? <String, dynamic>{...r, ...updates[_id(r['id'])]!}
                : r,
          )
          .toList();
      list.addAll(
        ((w['create'] as List<dynamic>?) ?? <dynamic>[]).cast<Json>().map(
          (Json r) => jsonDecode(jsonEncode(r)) as Json,
        ),
      );
      next[e.key] = list;
    }
    return next;
  }
}
