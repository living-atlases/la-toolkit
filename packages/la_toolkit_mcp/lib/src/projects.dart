/// Read-only views over the project JSON that `get-conf` returns.
///
/// Everything here works on the persisted shape (`toJson()` plus the maps
/// `populate-project.js` rebuilds), never on the Flutter models, so the MCP
/// server needs nothing from `lib/`.
library;

typedef Json = Map<String, dynamic>;

/// Services that describe *where* things run, not a workload. Mirrors the
/// exclusions of `LAProject._vmAssignedServices`.
const Set<String> placementServices = <String>{
  'docker_compose',
  'docker_swarm',
  'docker_common',
};

/// A project plus, for a hub, the portal it hangs from. `get-conf` nests hubs
/// under their portal and leaves the hub's own `parent` empty.
class ProjectRef {
  ProjectRef(this.project, [this.parent]);

  final Json project;
  final Json? parent;

  bool get isHub => project['isHub'] == true;
  String get id => project['id'] as String;
  String get dirName => project['dirName'] as String? ?? '';
}

/// Finds a portal or hub by id, then dirName, then shortName
/// (case-insensitive). The order matters: shortNames are free text and can
/// collide with another project's dirName ("LADemo" vs dir "lademo").
ProjectRef? findProject(List<Json> portals, String ref) {
  final String needle = ref.trim().toLowerCase();
  final List<ProjectRef> all = allProjects(portals);
  for (final String key in <String>['id', 'dirName', 'shortName']) {
    for (final ProjectRef r in all) {
      final Object? v = r.project[key];
      if (v is String && v.toLowerCase() == needle) return r;
    }
  }
  return null;
}

/// Every portal and hub, flattened.
List<ProjectRef> allProjects(List<Json> portals) => <ProjectRef>[
  for (final Json portal in portals) ...<ProjectRef>[
    ProjectRef(portal),
    for (final Json hub in _hubs(portal)) ProjectRef(hub, portal),
  ],
];

List<Json> _hubs(Json p) =>
    (p['hubs'] as List<dynamic>? ?? const <dynamic>[]).cast<Json>();

List<Json> _list(Json p, String key) =>
    (p[key] as List<dynamic>? ?? const <dynamic>[]).cast<Json>();

List<String> servicesInUse(Json p) =>
    _list(p, 'services')
        .where((Json s) => s['use'] == true)
        .map((Json s) => s['nameInt'] as String)
        .where((String n) => !placementServices.contains(n))
        .toList()
      ..sort();

bool hasComposeCluster(Json p) =>
    _list(p, 'clusters').any((Json c) => c['type'] == 'dockerCompose');

/// Whether any workload is assigned straight to a server (the VM leg).
bool hasVmServices(Json p) {
  final Map<String, dynamic> ss =
      p['serverServices'] as Map<String, dynamic>? ?? const <String, dynamic>{};
  return ss.values.any(
    (dynamic v) =>
        (v as List<dynamic>).any((dynamic s) => !placementServices.contains(s)),
  );
}

bool hasComposeServices(Json p) {
  final Map<String, dynamic> cs =
      p['clusterServices'] as Map<String, dynamic>? ??
      const <String, dynamic>{};
  return hasComposeCluster(p) &&
      cs.values.any((dynamic v) => (v as List<dynamic>).isNotEmpty);
}

enum DeployMode { dockerCompose, vm, hybrid, none }

DeployMode deployMode(Json p) {
  final bool compose = hasComposeServices(p);
  final bool vm = hasVmServices(p);
  if (compose && vm) return DeployMode.hybrid;
  if (compose) return DeployMode.dockerCompose;
  if (vm) return DeployMode.vm;
  return DeployMode.none;
}

Json projectSummary(ProjectRef ref) {
  final Json p = ref.project;
  return <String, dynamic>{
    'id': p['id'],
    'name': p['longName'],
    'shortName': p['shortName'],
    'dirName': p['dirName'],
    'domain': p['domain'],
    'status': p['status'],
    'isHub': ref.isHub,
    if (ref.parent != null) 'parent': ref.parent!['dirName'],
    'deployMode': deployMode(p).name,
    'servers': _list(p, 'servers').map((Json s) => s['name']).toList(),
    if (!ref.isHub) 'hubs': _hubs(p).map((Json h) => h['dirName']).toList(),
  };
}

Json projectDetails(ProjectRef ref) {
  final Json p = ref.project;
  final Map<String, String> clusterNames = <String, String>{
    for (final Json c in _list(p, 'clusters'))
      c['id'] as String: c['name'] as String,
  };
  final Map<String, String> serverNames = <String, String>{
    for (final Json s in _list(p, 'servers'))
      s['id'] as String: s['name'] as String,
  };
  final Map<String, String> serviceNames = <String, String>{
    for (final Json s in _list(p, 'services'))
      s['id'] as String: s['nameInt'] as String,
  };
  final Map<String, dynamic> cs =
      p['clusterServices'] as Map<String, dynamic>? ??
      const <String, dynamic>{};
  final Map<String, dynamic> ss =
      p['serverServices'] as Map<String, dynamic>? ?? const <String, dynamic>{};

  return <String, dynamic>{
    ...projectSummary(ref),
    'useSSL': p['useSSL'],
    'releases': <String, dynamic>{
      'generator': p['generatorRelease'],
      'alaInstall': p['alaInstallRelease'],
      'dockerCompose': p['dockerComposeRelease'],
    },
    'servers': _list(p, 'servers')
        .map(
          (Json s) => <String, dynamic>{
            'name': s['name'],
            'ip': s['ip'],
            'os': '${s['osName'] ?? '?'} ${s['osVersion'] ?? ''}'.trim(),
            'reachable': s['reachable'],
            'sshReachable': s['sshReachable'],
            'sudoEnabled': s['sudoEnabled'],
          },
        )
        .toList(),
    'servicesInUse': servicesInUse(p),
    if (_composeStages(p, serverNames).isNotEmpty)
      'composeStages': _composeStages(p, serverNames),
    'placement': <String, dynamic>{
      for (final MapEntry<String, dynamic> e in ss.entries)
        if ((e.value as List<dynamic>).isNotEmpty)
          'server ${serverNames[e.key] ?? e.key}': e.value,
      for (final MapEntry<String, dynamic> e in cs.entries)
        if ((e.value as List<dynamic>).isNotEmpty)
          'cluster ${clusterNames[e.key] ?? e.key}': e.value,
    },
    'lastServiceChecks': _list(p, 'serviceDeploys')
        .where((Json d) => d['checkedAt'] != null)
        .map(
          (Json d) => <String, dynamic>{
            'service': serviceNames[d['serviceId']] ?? d['serviceId'],
            'status': d['status'],
            'checkedAt': d['checkedAt'],
          },
        )
        .toList(),
    'recentRuns': runs(p, limit: 5),
  };
}

/// Stage of each compose host (`{server: production|staging}`), only once a
/// portal uses stages: without one every host is production.
Map<String, String> _composeStages(Json p, Map<String, String> serverNames) {
  final Map<String, String> out = <String, String>{
    for (final Json c in _list(p, 'clusters'))
      if (c['type'] == 'dockerCompose' && c['serverId'] != null)
        serverNames[c['serverId']] ?? c['serverId'] as String:
            c['stage'] as String? ?? 'production',
  };
  return out.containsValue('staging') ? out : <String, String>{};
}

/// What a docker run reaching production should tell the user when the portal
/// has a staging host: placement and la-docker-compose changes go there first.
/// [limit] is the run's `--limit`, `<server>.docker_compose` or a bare server.
/// Null when the run touches no production host, or the portal has no staging.
String? stagingWarning(Json p, List<String> limit) {
  final Map<String, String> names = <String, String>{
    for (final Json s in _list(p, 'servers'))
      s['id'] as String: s['name'] as String,
  };
  final Map<String, String> stages = _composeStages(p, names);
  final List<String> hosts = limit
      .map((String h) => h.replaceFirst(RegExp(r'\.docker_compose$'), ''))
      .toList();
  final List<String> staging = stages.keys
      .where((String h) => stages[h] == 'staging')
      .toList();
  if (!hosts.any((String h) => stages[h] == 'production')) return null;
  final List<Json> tried = List<Json>.of(_list(p, 'cmdHistoryEntries'))
    ..retainWhere((Json e) {
      final String cmd = e['rawCmd'] as String? ?? '';
      return cmd.contains('--nodryrun') && staging.any(cmd.contains);
    })
    ..sort(
      (Json a, Json b) => ((b['createdAt'] as num?) ?? 0).compareTo(
        (a['createdAt'] as num?) ?? 0,
      ),
    );
  return 'This run reaches production. New placements and la-docker-compose '
      'changes go to staging (${staging.join(', ')}) first; '
      '${tried.isEmpty ? 'no run there yet' : 'last run there: ${tried.first['logsSuffix']}, "${tried.first['desc']}"'}. '
      'Tell the user before a real run.';
}

/// Command history, newest first.
List<Json> runs(Json p, {int limit = 10}) {
  final List<Json> entries = List<Json>.of(_list(p, 'cmdHistoryEntries'))
    ..sort(
      (Json a, Json b) => ((b['createdAt'] as num?) ?? 0).compareTo(
        (a['createdAt'] as num?) ?? 0,
      ),
    );
  return entries.take(limit).map(runSummary).toList();
}

/// One history entry as `la_list_runs` shows it.
Json runSummary(Json e) => <String, dynamic>{
  'runId': e['id'],
  'desc': e['desc'],
  'started': e['logsSuffix'],
  'result': e['result'],
  if (e['duration'] is num)
    'durationMin': ((e['duration'] as num) / 60000).round(),
  'cmd': e['rawCmd'],
};

/// One page of a portal's history from the backend's `cmd-history`:
/// `{entries, total}`, newest first. Null when the backend cannot page (an
/// older build without the route, or an answer that is not JSON).
typedef HistoryPage = Future<Json?> Function(int skip, int limit);

/// Up to [limit] history entries, newest first, paged from the backend.
/// Null when the backend cannot page, so the caller can use the five entries
/// that get-conf embeds.
Future<List<Json>?> pagedRuns(
  HistoryPage page, {
  required int limit,
  int pageSize = 100,
}) async {
  final List<Json> out = <Json>[];
  while (out.length < limit) {
    final int want = limit - out.length;
    final Json? r = await page(out.length, want < pageSize ? want : pageSize);
    if (r == null) return null;
    final List<Json> entries = _entriesOf(r);
    out.addAll(entries);
    if (entries.isEmpty || out.length >= _totalOf(r)) break;
  }
  return out;
}

/// The history entry with [runId] somewhere in the backend's history, paging
/// through it. Null when there is none, or when the backend cannot page.
Future<Json?> findRunPaged(
  String runId,
  HistoryPage page, {
  int pageSize = 100,
}) async {
  int skip = 0;
  while (true) {
    final Json? r = await page(skip, pageSize);
    if (r == null) return null;
    final List<Json> entries = _entriesOf(r);
    for (final Json e in entries) {
      if (e['id'] == runId) return e;
    }
    skip += entries.length;
    if (entries.isEmpty || skip >= _totalOf(r)) return null;
  }
}

List<Json> _entriesOf(Json page) =>
    (page['entries'] as List<dynamic>? ?? const <dynamic>[]).cast<Json>();

int _totalOf(Json page) => (page['total'] as num?)?.toInt() ?? 0;

/// The history entry for [runId], or the newest one when it is null.
Json? findRun(Json p, String? runId) {
  final List<Json> entries = _list(p, 'cmdHistoryEntries');
  if (entries.isEmpty) return null;
  if (runId != null) {
    for (final Json e in entries) {
      if (e['id'] == runId) return e;
    }
    return null;
  }
  return entries.reduce(
    (Json a, Json b) =>
        ((a['createdAt'] as num?) ?? 0) >= ((b['createdAt'] as num?) ?? 0)
        ? a
        : b,
  );
}

/// Recent history entries whose outcome nobody recorded yet: the only ones
/// that can still be running. Old `unknown` entries are left alone: the
/// backend checks liveness by pid, and a years-old pid may belong to anything.
List<Json> unfinishedRuns(
  Json p, {
  DateTime? now,
  Duration within = const Duration(hours: 24),
}) {
  final int since = (now ?? DateTime.now())
      .subtract(within)
      .millisecondsSinceEpoch;
  return _list(p, 'cmdHistoryEntries')
      .where(
        (Json e) =>
            e['result'] == 'unknown' &&
            ((e['createdAt'] as num?) ?? 0) >= since,
      )
      .toList();
}
