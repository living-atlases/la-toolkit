import 'dart:convert';

import 'package:la_toolkit_core/models/la_project.dart';
import 'package:la_toolkit_core/models/project_patch.dart';

/// The copy of each project this browser last took from the backend, kept
/// as JSON snapshots: a save sends what changed since that copy
/// ([ProjectPatch.diff]), not the whole project, so it never undoes what
/// another session (a browser, the MCP) changed meanwhile.
///
/// Snapshots, never [LAProject]s: reducers mutate the current project in
/// place, and a base sharing its objects would make every diff empty.
class ProjectBases {
  /// What the backend sent last, for every project (hubs included).
  final Map<String, Json> _latest = <String, Json>{};

  /// The copy a save diffs against. Lags behind [_latest] for a project
  /// whose newer copy was not taken (open with unsaved changes).
  final Map<String, Json> _base = <String, Json>{};

  /// Hub id -> portal id: a hub is parsed inside its portal.
  final Map<String, String> _portalOf = <String, String>{};

  static Json _copy(Object? j) => jsonDecode(jsonEncode(j)) as Json;

  /// Records a full project list from the backend. The base of the ids in
  /// [keepBase] is left as it was.
  void recordAll(
    List<dynamic> projectsJson, {
    Set<String> keepBase = const <String>{},
  }) {
    final Map<String, Json> latest = <String, Json>{};
    _portalOf.clear();
    for (final dynamic p in projectsJson) {
      final Json portal = p as Json;
      latest[portal['id'].toString()] = portal;
      for (final dynamic h
          in (portal['hubs'] as List<dynamic>?) ?? <dynamic>[]) {
        final Json hub = h as Json;
        latest[hub['id'].toString()] = hub;
        _portalOf[hub['id'].toString()] = portal['id'].toString();
      }
    }
    _latest
      ..clear()
      ..addAll(
        latest.map((String k, Json v) => MapEntry<String, Json>(k, _copy(v))),
      );
    final Map<String, Json> kept = <String, Json>{
      for (final String id in keepBase)
        if (_base.containsKey(id)) id: _base[id]!,
    };
    _base
      ..clear()
      ..addAll(
        _latest.map((String k, Json v) => MapEntry<String, Json>(k, _copy(v))),
      )
      ..addAll(kept);
  }

  /// Takes the latest copy of [id] as its base (the user reloaded it).
  void adoptLatest(String id) {
    final Json? l = _latest[id];
    if (l != null) {
      _base[id] = _copy(l);
    }
  }

  bool hasBase(String id) => _base.containsKey(id);

  Json? latestRaw(String id) => _latest[id];

  Json? baseRaw(String id) => _base[id];

  /// Whether the latest copy of [id] differs from its base in anything a
  /// person edits: genConf, history, check results and progress flags
  /// aside.
  bool changedSinceBase(String id) {
    final Json? b = _base[id];
    final Json? l = _latest[id];
    if (b == null || l == null) {
      return b != l;
    }
    final Json p = ProjectPatch.diff(b, l);
    if ((p['project'] as Json).keys.any(
      (String f) => !ProjectPatch.projectSoft.contains(f),
    )) {
      return true;
    }
    for (final MapEntry<String, dynamic> e in (p['rows'] as Json).entries) {
      final Json ops = e.value as Json;
      if ((ops['create'] as List<dynamic>).isNotEmpty ||
          (ops['remove'] as List<dynamic>).isNotEmpty) {
        return true;
      }
      for (final dynamic u in ops['update'] as List<dynamic>) {
        if (((u as Json)['set'] as Json).keys.any(
          (String f) => !ProjectPatch.rowSoft[e.key]!.contains(f),
        )) {
          return true;
        }
      }
    }
    return false;
  }

  /// [raw] (a snapshot of [id] or of its portal) parsed as the app parses
  /// it, hubs linked to their portal.
  LAProject? _parse(String id, Map<String, Json> from) {
    final String? portalId = _portalOf[id];
    final Json? raw = from[portalId ?? id];
    if (raw == null) {
      return null;
    }
    final Json json = _copy(raw);
    if (portalId != null) {
      // The base of a hub may lag behind its portal's: parse that one.
      final Json? hubRaw = from[id];
      json['hubs'] = <dynamic>[
        for (final dynamic h in (json['hubs'] as List<dynamic>?) ?? <dynamic>[])
          if ((h as Json)['id'].toString() == id && hubRaw != null)
            _copy(hubRaw)
          else
            h,
      ];
    }
    final LAProject p = LAProject.fromJson(json);
    if (portalId == null) {
      return p;
    }
    for (final LAProject hub in p.hubs) {
      if (hub.id == id) {
        return hub;
      }
    }
    return null;
  }

  /// The base of [id] in the shape [LAProject.toApiJson] has, so that a
  /// diff against it only holds what was edited.
  Json? clientBase(String id) {
    final LAProject? p = _parse(id, _base);
    if (p == null) {
      return null;
    }
    return _copy(p.toJson())..['genConf'] = _base[id]!['genConf'];
  }

  /// The latest copy of [id], parsed (to recompute its genConf).
  LAProject? parseLatest(String id) => _parse(id, _latest);
}

/// Runs the saves of one project one after another: each diff is computed
/// when its turn comes, against the base the previous save left.
class SaveQueue {
  final Map<String, Future<void>> _tails = <String, Future<void>>{};

  Future<void> run(String projectId, Future<void> Function() save) {
    final Future<void> previous = _tails[projectId] ?? Future<void>.value();
    final Future<void> mine = previous.catchError((_) {}).then((_) => save());
    _tails[projectId] = mine;
    return mine.whenComplete(() {
      if (identical(_tails[projectId], mine)) {
        _tails.remove(projectId);
      }
    });
  }
}
