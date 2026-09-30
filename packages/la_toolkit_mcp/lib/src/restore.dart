/// la_restore_backup: the backups every save writes, listed, compared with
/// the stored project, and turned back into an update-project body.
library;

import 'dart:convert';
import 'dart:io';

import 'projects.dart';
import 'releases.dart';

/// The row collections update-project takes as complete lists: a row the
/// body lacks is deleted, one it carries is created with its id or updated.
const List<String> restoredCollections = <String>[
  'servers',
  'clusters',
  'services',
  'serviceDeploys',
  'variables',
];

/// The backups of [ref] in [dir], newest first.
List<File> backupsOf(Directory dir, ProjectRef ref) {
  if (!dir.existsSync()) return <File>[];
  final String prefix = '${ref.dirName}-${ref.id}-';
  return dir.listSync().whereType<File>().where((File f) {
    final String n = f.uri.pathSegments.last;
    return n.startsWith(prefix) && n.endsWith('.json');
  }).toList()..sort(
    (File a, File b) =>
        b.uri.pathSegments.last.compareTo(a.uri.pathSegments.last),
  );
}

/// The backup named [name] among [ref]'s, read. Only a bare file name of
/// that project is taken: no paths, no other project's backups.
Json readBackup(Directory dir, ProjectRef ref, String name) {
  final RegExp shape = RegExp(
    '^${RegExp.escape(ref.dirName)}-${ref.id}-[0-9TZ-]+\\.json\$',
  );
  if (!shape.hasMatch(name)) {
    throw FormatException('"$name" is not a backup of ${ref.dirName}.');
  }
  final File f = File('${dir.path}/$name');
  if (!f.existsSync()) {
    throw FormatException('No backup "$name" in ${dir.path}.');
  }
  final Object? j = json.decode(f.readAsStringSync());
  if (j is! Map<String, dynamic> || j['id'] != ref.id) {
    throw FormatException('"$name" does not hold project ${ref.id}.');
  }
  return j;
}

/// A line per backup: when, and the rows it holds.
Json backupSummary(File f) {
  final Json p = json.decode(f.readAsStringSync()) as Json;
  return <String, dynamic>{
    'backup': f.uri.pathSegments.last,
    'servers': <String>[
      for (final Json s in _rows(p, 'servers')) s['name'] as String,
    ],
    'rows': <String, int>{
      for (final String c in restoredCollections) c: _rows(p, c).length,
    },
  };
}

List<Json> _rows(Json p, String collection) =>
    (p[collection] as List<dynamic>? ?? const <dynamic>[]).cast<Json>();

/// The update-project body that stores [backup] again, in the shape the
/// app sends ([api], the current project's toApiJson()): its keys, with the
/// backup's values, rows and genConf verbatim. Keys the backup lacks (what
/// get-conf does not return) keep their current value, and null ones stay
/// out.
Json restoreBody(Json backup, Json api) {
  Json only(Json row, Set<String>? keys) => keys == null
      ? <String, dynamic>{
          for (final MapEntry<String, dynamic> e in row.entries)
            if (e.key != 'createdAt' && e.key != 'updatedAt') e.key: e.value,
        }
      : <String, dynamic>{
          for (final String k in keys)
            if (row.containsKey(k)) k: row[k],
        };

  final Json body = <String, dynamic>{};
  for (final String k in api.keys) {
    if (restoredCollections.contains(k)) {
      final List<Json> current = _rows(api, k);
      final Set<String>? keys = current.isEmpty
          ? null
          : <String>{for (final Json r in current) ...r.keys};
      body[k] = <Json>[for (final Json r in _rows(backup, k)) only(r, keys)];
    } else if (backup.containsKey(k)) {
      body[k] = backup[k];
    } else if (api[k] != null) {
      // A null here would store the key where the backup had none.
      body[k] = api[k];
    }
  }
  return body;
}

/// What storing [backup] over [stored] changes: per collection the rows it
/// brings back, drops and changes, by name; and the genConf keys.
Json restoreDiff(Json stored, Json backup) {
  String label(Json p, String collection, Json row) {
    String? name(String c, Object? id) => _rows(p, c)
        .where((Json r) => r['id'] == id)
        .map((Json r) => (r['name'] ?? r['nameInt']) as String?)
        .firstOrNull;
    switch (collection) {
      case 'serviceDeploys':
        final String service =
            name('services', row['serviceId']) ?? '${row['serviceId']}';
        final String where =
            name('servers', row['serverId']) ??
            name('clusters', row['clusterId']) ??
            '${row['clusterId'] ?? row['serverId']}';
        return '$service on $where (${row['id']})';
      case 'variables':
        return '${row['nameInt']} (${row['id']})';
      default:
        return '${row['name'] ?? row['nameInt']} (${row['id']})';
    }
  }

  bool same(Json a, Json b) {
    Json strip(Json r) => <String, dynamic>{
      for (final MapEntry<String, dynamic> e in r.entries)
        if (e.key != 'createdAt' && e.key != 'updatedAt') e.key: e.value,
    };
    return json.encode(strip(a)) == json.encode(strip(b));
  }

  final Json out = <String, dynamic>{};
  for (final String c in restoredCollections) {
    final Map<Object?, Json> now = <Object?, Json>{
      for (final Json r in _rows(stored, c)) r['id']: r,
    };
    final Map<Object?, Json> then = <Object?, Json>{
      for (final Json r in _rows(backup, c)) r['id']: r,
    };
    final List<String> back = <String>[
      for (final MapEntry<Object?, Json> e in then.entries)
        if (!now.containsKey(e.key)) label(backup, c, e.value),
    ];
    final List<String> dropped = <String>[
      for (final MapEntry<Object?, Json> e in now.entries)
        if (!then.containsKey(e.key)) label(stored, c, e.value),
    ];
    final List<String> changed = <String>[
      for (final MapEntry<Object?, Json> e in then.entries)
        if (now.containsKey(e.key) && !same(now[e.key]!, e.value))
          label(backup, c, e.value),
    ];
    if (back.isEmpty && dropped.isEmpty && changed.isEmpty) continue;
    out[c] = <String, dynamic>{
      if (back.isNotEmpty) 'back': back,
      if (dropped.isNotEmpty) 'dropped': dropped,
      if (changed.isNotEmpty) 'changed': changed,
    };
  }
  final Json conf = genConfDiff(
    stored['genConf'] as Json? ?? const <String, dynamic>{},
    backup['genConf'] as Json? ?? const <String, dynamic>{},
  );
  final List<String> confKeys = <String>[
    for (final String k in <String>['added', 'removed', 'changed'])
      ...(conf[k] as List<String>),
  ];
  if (confKeys.isNotEmpty) out['genConf'] = conf;
  return out;
}

/// Whether [stored] holds exactly the rows (by id) of [backup].
Json restoreCheck(Json stored, Json backup) => <String, dynamic>{
  for (final String c in restoredCollections)
    c:
        _rows(stored, c)
            .map((Json r) => r['id'])
            .toSet()
            .containsAll(_rows(backup, c).map((Json r) => r['id'])) &&
        _rows(stored, c).length == _rows(backup, c).length,
};
