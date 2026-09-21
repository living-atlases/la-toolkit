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
    (dynamic v) => (v as List<dynamic>).any(
      (dynamic s) => !placementServices.contains(s),
    ),
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
    if (!ref.isHub)
      'hubs': _hubs(p).map((Json h) => h['dirName']).toList(),
  };
}

Json projectDetails(ProjectRef ref) {
  final Json p = ref.project;
  final Map<String, String> clusterNames = <String, String>{
    for (final Json c in _list(p, 'clusters')) c['id'] as String: c['name'] as String,
  };
  final Map<String, String> serverNames = <String, String>{
    for (final Json s in _list(p, 'servers')) s['id'] as String: s['name'] as String,
  };
  final Map<String, String> serviceNames = <String, String>{
    for (final Json s in _list(p, 'services')) s['id'] as String: s['nameInt'] as String,
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

/// Command history, newest first.
List<Json> runs(Json p, {int limit = 10}) {
  final List<Json> entries = List<Json>.of(_list(p, 'cmdHistoryEntries'))
    ..sort(
      (Json a, Json b) =>
          ((b['createdAt'] as num?) ?? 0).compareTo((a['createdAt'] as num?) ?? 0),
    );
  return entries
      .take(limit)
      .map(
        (Json e) => <String, dynamic>{
          'runId': e['id'],
          'desc': e['desc'],
          'started': e['logsSuffix'],
          'result': e['result'],
          if (e['duration'] is num)
            'durationMin': ((e['duration'] as num) / 60000).round(),
          'cmd': e['rawCmd'],
        },
      )
      .toList();
}

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
        ((a['createdAt'] as num?) ?? 0) >= ((b['createdAt'] as num?) ?? 0) ? a : b,
  );
}

/// Recent history entries whose outcome nobody recorded yet: the only ones
/// that can still be running. Old `unknown` entries are left alone: the
/// backend checks liveness by pid, and a years-old pid may belong to anything.
List<Json> unfinishedRuns(Json p, {DateTime? now, Duration within = const Duration(hours: 24)}) {
  final int since = (now ?? DateTime.now()).subtract(within).millisecondsSinceEpoch;
  return _list(p, 'cmdHistoryEntries')
      .where((Json e) => e['result'] == 'unknown' && ((e['createdAt'] as num?) ?? 0) >= since)
      .toList();
}
