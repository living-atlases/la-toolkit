import 'package:pub_semver/pub_semver.dart';

import 'projects.dart';

/// Servers that carry work: something assigned straight to them, or the
/// carrier host of a docker-compose cluster that has services. Projects keep
/// retired VMs around, and checking those would bury the real blockers.
List<Json> serversWithServices(Json p) {
  final Map<String, dynamic> ss =
      p['serverServices'] as Map<String, dynamic>? ?? const <String, dynamic>{};
  final Map<String, dynamic> cs =
      p['clusterServices'] as Map<String, dynamic>? ?? const <String, dynamic>{};
  final Set<String> ids = <String>{
    for (final MapEntry<String, dynamic> e in ss.entries)
      if ((e.value as List<dynamic>).isNotEmpty) e.key,
    for (final Json c in (p['clusters'] as List<dynamic>? ?? const <dynamic>[]).cast<Json>())
      if (c['serverId'] is String && ((cs[c['id']] as List<dynamic>?)?.isNotEmpty ?? false))
        c['serverId'] as String,
  };
  return (p['servers'] as List<dynamic>? ?? const <dynamic>[])
      .cast<Json>()
      .where((Json s) => ids.contains(s['id']))
      .toList();
}

final RegExp _hostname = RegExp(
  r'^(?=.{1,253}$)([A-Za-z0-9]([A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)+[A-Za-z]{2,}$',
);

/// The host names the portal must answer on, and how sure we are of them.
///
/// Docker-compose projects carry the exact list: the vhosts nginx serves,
/// per host, in `LA_nginx_docker_internal_aliases_by_host` (computed by the
/// generator, hubs included). Otherwise the best available is `LA_<svc>_url`
/// of every service in use, but that also names internal services with no
/// vhost (cassandra, spark, zookeeper...): telling them apart needs the
/// service catalogue of the Flutter models, so those are only [authoritative]
/// false and their failures are warnings.
({List<String> hosts, bool authoritative}) publicHostnames(Json p) {
  final Json g = p['genConf'] as Json? ?? const <String, dynamic>{};
  final Object? aliases = g['LA_nginx_docker_internal_aliases_by_host'];
  if (aliases is Map && aliases.isNotEmpty) {
    final Set<String> out = <String>{
      for (final Object? list in aliases.values)
        if (list is List)
          for (final Object? h in list)
            if (h is String && _hostname.hasMatch(h)) h.toLowerCase(),
    };
    return (hosts: out.toList()..sort(), authoritative: true);
  }
  final Set<String> out = <String>{};
  for (final String svc in servicesInUse(p)) {
    // The generator config names species_lists `lists`, like ansiblew.
    final String key = svc == 'species_lists' ? 'lists' : svc;
    final Object? url = g['LA_${key}_url'];
    // Sub-services served under a path can carry leftovers such as
    // "API keys.gbif.es".
    if (url is String && _hostname.hasMatch(url)) out.add(url.toLowerCase());
  }
  return (hosts: out.toList()..sort(), authoritative: false);
}

/// What la_check_preconditions found, split into what stops a deploy and
/// what only deserves a look.
class PreconditionReport {
  final List<String> blocking = <String>[];
  final List<String> warnings = <String>[];
  final Json details = <String, dynamic>{};

  bool get ready => blocking.isEmpty;

  Json toJson() => <String, dynamic>{
    'ready': ready,
    'blocking': blocking,
    'warnings': warnings,
    ...details,
  };
}

final Version _minUbuntu = Version(22, 4, 0);

Version? _ubuntuVersion(Object? v) {
  if (v is! String) return null;
  final RegExpMatch? m = RegExp(r'^(\d+)\.(\d+)').firstMatch(v);
  return m == null ? null : Version(int.parse(m[1]!), int.parse(m[2]!), 0);
}

/// [connectivity]: `test-connectivity` servers; [disk]: `disk-usage` servers;
/// [keys]: `ssh-key-scan` keys; [dns]: host name -> resolved addresses
/// (empty when it does not resolve).
PreconditionReport evaluatePreconditions({
  required Json project,
  required List<Json> servers,
  required List<Json> connectivity,
  required List<Json> disk,
  required List<Json> keys,
  required Map<String, List<String>> dns,
  bool dnsAuthoritative = true,
}) {
  final PreconditionReport r = PreconditionReport();

  // SSH keys: the toolkit must hold the private key each server uses.
  final Map<String, Json> byKey = <String, Json>{for (final Json k in keys) k['name'] as String: k};
  for (final Json s in servers) {
    final Json? key = s['sshKey'] as Json?;
    if (key == null) {
      r.blocking.add('${s['name']}: no ssh key assigned.');
    } else if (byKey[key['name']] == null || byKey[key['name']]!['missing'] == true) {
      r.blocking.add('${s['name']}: ssh key "${key['name']}" is not in the toolkit.');
    }
  }

  // Connectivity, as the toolkit sees it (through the configured gateways).
  for (final Json c in connectivity) {
    final String name = c['name'] as String;
    if (c['sshReachable'] != 'success') {
      r.blocking.add('$name: not reachable over ssh from the toolkit.');
    } else if (c['sudoEnabled'] != 'success') {
      r.blocking.add('$name: ssh works but sudo does not.');
    }
    final Version? v = _ubuntuVersion(c['osVersion']);
    // Unreachable servers report no OS; they are already blocking above.
    final Object? os = c['osName'];
    if (os is String && os.isNotEmpty && (os != 'Ubuntu' || (v != null && v < _minUbuntu))) {
      r.warnings.add('$name: ${c['osName']} ${c['osVersion']}; LA deploys expect Ubuntu 22.04 or newer.');
    }
  }
  r.details['servers'] = connectivity
      .map(
        (Json c) => <String, dynamic>{
          'name': c['name'],
          'ssh': c['sshReachable'],
          'sudo': c['sudoEnabled'],
          'os': '${c['osName'] ?? '?'} ${c['osVersion'] ?? ''}'.trim(),
        },
      )
      .toList();

  // Disk. Unreachable servers are already blocking above.
  for (final Json d in disk) {
    if (d['ok'] == true && d['low'] == true) {
      final String where = (d['filesystems'] as List<dynamic>)
          .cast<Json>()
          .where((Json f) => f['low'] == true)
          .map((Json f) => '${f['mount']} ${f['availableGB']} GB free (${f['usePct']}%)')
          .join(', ');
      r.blocking.add('${d['name']}: low disk space: $where.');
    }
  }
  r.details['disk'] = disk;

  // DNS, resolved from where this server runs (the toolkit host).
  final Set<String> serverIps = <String>{
    for (final Json s in servers)
      if (s['ip'] is String && (s['ip'] as String).isNotEmpty) s['ip'] as String,
  };
  final List<Json> dnsOut = <Json>[];
  dns.forEach((String host, List<String> ips) {
    if (ips.isEmpty) {
      (dnsAuthoritative ? r.blocking : r.warnings).add(
        dnsAuthoritative
            ? '$host does not resolve.'
            : '$host does not resolve (fine if that service has no public vhost).',
      );
    }
    dnsOut.add(<String, dynamic>{
      'host': host,
      'ips': ips,
      // Informative only: a portal behind a proxy or NAT resolves elsewhere.
      if (ips.isNotEmpty) 'pointsToAProjectServer': ips.any(serverIps.contains),
    });
  });
  r.details['dns'] = dnsOut;
  return r;
}
