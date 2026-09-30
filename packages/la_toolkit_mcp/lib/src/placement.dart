/// Arguments and preview of la_set_placement and la_set_servers. The changes
/// themselves are the core's (`changePlacement`, `changeServers`); this only
/// parses and compares.
library;

import 'package:collection/collection.dart';
import 'package:la_toolkit_core/models/la_project.dart';
import 'package:la_toolkit_core/models/la_cluster.dart';
import 'package:la_toolkit_core/models/la_server.dart';
import 'package:la_toolkit_core/models/la_service.dart';
import 'package:la_toolkit_core/models/la_service_deploy.dart';
import 'package:la_toolkit_core/models/ssh_key.dart';
import 'package:la_toolkit_core/placement/placement_changes.dart';
import 'package:la_toolkit_core/placement/server_changes.dart';

import 'deploy_request.dart';
import 'projects.dart';

String? _name(Json m, String k, {bool required = false, String? what}) {
  final Object? v = m[k];
  if (v == null) {
    if (required) throw FormatException('Each ${what ?? 'item'} needs `$k`.');
    return null;
  }
  if (v is! String || !safeToken.hasMatch(v)) {
    throw FormatException('`$k` "$v" is not a valid name.');
  }
  return v;
}

List<String>? _names(Json m, String k) {
  final Object? v = m[k];
  if (v == null) return null;
  if (v is! List) throw FormatException('`$k` is a list of names.');
  return <String>[
    for (final Object? x in v)
      if (x is String && safeToken.hasMatch(x))
        x
      else
        throw FormatException('`$k`: "$x" is not a valid name.'),
  ];
}

T? _oneOf<T extends Enum>(Json m, String k, List<T> values) {
  final Object? v = m[k];
  if (v == null) return null;
  for (final T x in values) {
    if (x.name == v) return x;
  }
  throw FormatException(
    '`$k` must be ${values.map((T x) => '"${x.name}"').join(' or ')}.',
  );
}

/// The `changes` argument of la_set_placement, every name whitelisted like
/// the deploy arguments.
List<ServiceMove> parseChanges(Object? raw) {
  if (raw is! List || raw.isEmpty) {
    throw const FormatException(
      'Give changes: [{op?, service, to?, from?, fromLeg?, toLeg?}].',
    );
  }
  return <ServiceMove>[
    for (final Object? m in raw)
      if (m is Map<String, dynamic>)
        ServiceMove(
          op:
              _oneOf<PlacementOp>(m, 'op', PlacementOp.values) ??
              PlacementOp.move,
          service: _name(m, 'service', required: true, what: 'change')!,
          to: _name(m, 'to'),
          from: _name(m, 'from'),
          fromLeg: _oneOf<PlacementLeg>(m, 'fromLeg', PlacementLeg.values),
          toLeg: _oneOf<PlacementLeg>(m, 'toLeg', PlacementLeg.values),
        )
      else
        throw const FormatException('Each change is an object.'),
  ];
}

/// The `add` / `update` / `remove` arguments of la_set_servers. Names are
/// whitelisted here; ips, users and ports are checked by the core. An ssh
/// key is named and must be one the toolkit has.
({List<ServerSpec> add, List<ServerSpec> update, List<String> remove})
parseServerChanges(Map<String, Object?> a, List<Json> keys) {
  List<ServerSpec> specs(String k) {
    final Object? raw = a[k];
    if (raw == null) return <ServerSpec>[];
    if (raw is! List) throw FormatException('`$k` is a list of servers.');
    return <ServerSpec>[
      for (final Object? m in raw)
        if (m is Map<String, dynamic>)
          _spec(m, keys)
        else
          throw FormatException('Each server in `$k` is an object.'),
    ];
  }

  return (
    add: specs('add'),
    update: specs('update'),
    remove:
        _names(<String, dynamic>{'remove': a['remove']}, 'remove') ??
        <String>[],
  );
}

ServerSpec _spec(Json m, List<Json> keys) {
  final Object? ip = m['ip'];
  if (ip != null && ip is! String) {
    throw const FormatException('`ip` is text.');
  }
  final Object? port = m['sshPort'];
  if (port != null && port is! int) {
    throw const FormatException('`sshPort` is a number.');
  }
  final String? keyName = _name(m, 'sshKey');
  SshKey? key;
  if (keyName != null) {
    final Json? k = keys.firstWhereOrNull((Json k) => k['name'] == keyName);
    if (k == null || k['missing'] == true) {
      throw FormatException(
        'The toolkit has no usable ssh key "$keyName". Known: '
        '${keys.where((Json k) => k['missing'] != true).map((Json k) => k['name']).join(', ')}.',
      );
    }
    key = SshKey.fromJson(k);
  }
  return ServerSpec(
    name: _name(m, 'name', required: true, what: 'server')!,
    ip: ip as String?,
    sshUser: _name(m, 'sshUser'),
    sshPort: port as int?,
    sshKey: key,
    aliases: _names(m, 'aliases'),
    gateways: _names(m, 'gateways'),
  );
}

/// A server as the preview shows it; never the key material.
Json serverJson(LAProject p, String name) {
  final LAServer? s = p.getServerByName(name);
  if (s == null) return <String, dynamic>{'name': name};
  return <String, dynamic>{
    'name': s.name,
    'ip': s.ip,
    'sshUser': s.sshUser,
    'sshPort': s.sshPort,
    'sshKey': s.sshKey?.name,
    'aliases': s.aliases,
    'gateways': <String>[
      for (final String id in s.gateways) p.getServerById(id)?.name ?? id,
    ],
  };
}

/// Server names are global ssh host aliases in the toolkit: the same name in
/// another project with another IP makes `ssh <name>` ambiguous. Existing
/// installations have such pairs, so this only warns.
List<String> serverNameClashes(
  List<ProjectRef> all,
  ProjectRef self,
  LAProject p,
  List<String> names,
) => <String>[
  for (final String n in names)
    for (final ProjectRef r in all)
      if (r.id != self.id)
        for (final Json s
            in (r.project['servers'] as List<dynamic>? ?? const <dynamic>[])
                .cast<Json>())
          if (s['name'] == n && s['ip'] != p.getServerByName(n)?.ip)
            'Project ${r.dirName} also has a server "$n", at ${s['ip']}: '
                'ssh to that name may reach either.',
];

/// Added servers without an ssh key: the toolkit cannot reach them. Names
/// the keys the other servers use.
List<String> missingKeyWarnings(LAProject p, List<String> added) {
  final List<String> used = <String>{
    for (final LAServer s in p.servers)
      if (s.sshKey != null) s.sshKey!.name,
  }.toList()..sort();
  return <String>[
    for (final String n in added)
      if (p.getServerByName(n)?.sshKey == null)
        '$n has no ssh key: the toolkit cannot reach it until one is set '
            '(sshKey)${used.isEmpty ? '' : '; the other servers use ${used.join(', ')}'}.',
  ];
}

Json moveJson(MovedService m) => <String, dynamic>{
  'op': m.op.name,
  'service': m.service,
  if (m.carried.isNotEmpty) 'carries': m.carried,
  if (m.from != null) 'from': m.from.toString(),
  if (m.to != null) 'to': m.to.toString(),
  if (m.versions.isNotEmpty) 'versions': m.versions,
};

/// Per server, the services it gains and loses, as `name (docker|vm)`.
/// Servers without changes left out.
Json serverChanges(
  Map<String, Map<String, List<String>>> before,
  Map<String, Map<String, List<String>>> after,
) {
  Set<String> flat(Map<String, List<String>>? legs) => <String>{
    for (final MapEntry<String, List<String>> e
        in (legs ?? const <String, List<String>>{}).entries)
      for (final String s in e.value) '$s (${e.key})',
  };
  final Json out = <String, dynamic>{};
  for (final String server in <String>{...before.keys, ...after.keys}) {
    final Set<String> b = flat(before[server]);
    final Set<String> a = flat(after[server]);
    final List<String> gains = a.difference(b).toList()..sort();
    final List<String> loses = b.difference(a).toList()..sort();
    if (gains.isEmpty && loses.isEmpty) continue;
    out[server] = <String, dynamic>{
      if (gains.isNotEmpty) 'gains': gains,
      if (loses.isNotEmpty) 'loses': loses,
    };
  }
  return out;
}

/// The public names each compose host's nginx answers for that change: the
/// DNS the user has to move.
Json publicNameChanges(Json beforeGenConf, Json afterGenConf) {
  Map<String, Set<String>> byHost(Json g) => <String, Set<String>>{
    for (final MapEntry<String, dynamic> e
        in (g['LA_nginx_docker_internal_aliases_by_host']
                    as Map<String, dynamic>? ??
                const <String, dynamic>{})
            .entries)
      e.key: (e.value as List<dynamic>).cast<String>().toSet(),
  };
  final Map<String, Set<String>> b = byHost(beforeGenConf);
  final Map<String, Set<String>> a = byHost(afterGenConf);
  final Json out = <String, dynamic>{};
  for (final String host in <String>{...b.keys, ...a.keys}) {
    final Set<String> was = b[host] ?? <String>{};
    final Set<String> now = a[host] ?? <String>{};
    final List<String> gains = now.difference(was).toList()..sort();
    final List<String> loses = was.difference(now).toList()..sort();
    if (gains.isEmpty && loses.isEmpty) continue;
    out[host] = <String, dynamic>{
      if (gains.isNotEmpty) 'gains': gains,
      if (loses.isNotEmpty) 'loses': loses,
    };
  }
  return out;
}

/// Per compose host, the names its containers resolve through `extra_hosts`
/// that now point elsewhere (`{name: {before, after}}`, null when absent).
/// Hosts that did not move a service can show up here: they need a deploy
/// too, or their containers keep calling the old address.
Json extraHostChanges(Json beforeGenConf, Json afterGenConf) {
  Map<String, Map<String, String>> byHost(
    Json g,
  ) => <String, Map<String, String>>{
    for (final MapEntry<String, dynamic> e
        in (g['LA_docker_extra_hosts_by_host'] as Map<String, dynamic>? ??
                const <String, dynamic>{})
            .entries)
      e.key: <String, String>{
        for (final String entry in (e.value as List<dynamic>).cast<String>())
          if (entry.lastIndexOf(':') > 0)
            entry.substring(0, entry.lastIndexOf(':')): entry.substring(
              entry.lastIndexOf(':') + 1,
            ),
      },
  };
  final Map<String, Map<String, String>> b = byHost(beforeGenConf);
  final Map<String, Map<String, String>> a = byHost(afterGenConf);
  final Json out = <String, dynamic>{};
  for (final String host in <String>{...b.keys, ...a.keys}) {
    final Map<String, String> was = b[host] ?? const <String, String>{};
    final Map<String, String> now = a[host] ?? const <String, String>{};
    final Json changed = <String, dynamic>{
      for (final String name in <String>{
        ...was.keys,
        ...now.keys,
      }.toList()..sort())
        if (was[name] != now[name])
          name: <String, dynamic>{'before': was[name], 'after': now[name]},
    };
    if (changed.isNotEmpty) out[host] = changed;
  }
  return out;
}

/// What a change adds to and removes from a lint report. A portal is rarely
/// clean, so only the difference says something about the move.
Json lintDelta(Json before, Json after) {
  List<String> messages(Json r) => <String>[
    for (final dynamic f in r['findings'] as List<dynamic>)
      (f as Json)['message'] as String,
  ];
  List<String> deps(Json r) =>
      (r['dependencyErrors'] as List<dynamic>).cast<String>();
  List<String> minus(List<String> a, List<String> b) =>
      a.where((String x) => !b.contains(x)).toList();
  final List<String> fb = messages(before);
  final List<String> fa = messages(after);
  return <String, dynamic>{
    'new': <Json>[
      for (final dynamic f in after['findings'] as List<dynamic>)
        if (!fb.contains((f as Json)['message'])) f,
    ],
    'resolved': minus(fb, fa),
    'newDependencyErrors': minus(deps(after), deps(before)),
    'resolvedDependencyErrors': minus(deps(before), deps(after)),
    'unchanged': fa.where(fb.contains).length,
    'unchangedDependencyErrors': deps(
      after,
    ).where(deps(before).contains).length,
    if (after['dependenciesNotChecked'] != null)
      'dependenciesNotChecked': after['dependenciesNotChecked'],
  };
}

/// Deploy rows [after] lost that belong to no server in [touched]: a
/// change of one server must not drop rows elsewhere. Rows pointing at a
/// cluster that no longer exists (older projects have them, and they still
/// decide where names resolve) are the usual victims.
List<Json> collateralRemovals(
  LAProject before,
  LAProject after,
  List<String> touched,
) {
  final Set<String> kept = <String>{
    for (final LAServiceDeploy sd in after.serviceDeploys) sd.id,
  };
  String? host(LAServiceDeploy sd) {
    final String? serverId =
        sd.serverId ??
        before.clusters
            .firstWhereOrNull((LACluster c) => c.id == sd.clusterId)
            ?.serverId;
    return serverId == null ? null : before.getServerById(serverId)?.name;
  }

  return <Json>[
    for (final LAServiceDeploy sd in before.serviceDeploys)
      if (!kept.contains(sd.id) && !touched.contains(host(sd)))
        <String, dynamic>{
          'service':
              before.services
                  .firstWhereOrNull((LAService s) => s.id == sd.serviceId)
                  ?.nameInt ??
              sd.serviceId,
          'server': host(sd) ?? sd.serverId,
          if (sd.clusterId != null) 'cluster': sd.clusterId,
          if (sd.clusterId != null &&
              !before.clusters.any((LACluster c) => c.id == sd.clusterId))
            'clusterMissing': true,
        },
  ];
}
