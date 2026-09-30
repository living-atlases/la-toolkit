/// Arguments and preview of la_set_placement. The moves themselves are the
/// core's (`moveServices`); this only parses and compares.
library;

import 'package:la_toolkit_core/placement/move_services.dart';

import 'deploy_request.dart';
import 'projects.dart';

/// The `moves` argument, every name whitelisted like the deploy arguments.
List<ServiceMove> parseMoves(Object? raw) {
  if (raw is! List || raw.isEmpty) {
    throw const FormatException(
      'Give moves: [{service, to, from?, fromLeg?, toLeg?}].',
    );
  }
  String? name(Json m, String k, {bool required = false}) {
    final Object? v = m[k];
    if (v == null) {
      if (required) throw FormatException('Each move needs `$k`.');
      return null;
    }
    if (v is! String || !safeToken.hasMatch(v)) {
      throw FormatException('`$k` "$v" is not a service or server name.');
    }
    return v;
  }

  PlacementLeg? leg(Json m, String k) {
    final Object? v = m[k];
    if (v == null) return null;
    for (final PlacementLeg l in PlacementLeg.values) {
      if (l.name == v) return l;
    }
    throw FormatException('`$k` must be "docker" or "vm".');
  }

  return <ServiceMove>[
    for (final Object? m in raw)
      if (m is Map<String, dynamic>)
        ServiceMove(
          service: name(m, 'service', required: true)!,
          to: name(m, 'to', required: true)!,
          from: name(m, 'from'),
          fromLeg: leg(m, 'fromLeg'),
          toLeg: leg(m, 'toLeg'),
        )
      else
        throw const FormatException('Each move is an object.'),
  ];
}

Json moveJson(MovedService m) => <String, dynamic>{
  'service': m.service,
  if (m.carried.isNotEmpty) 'carries': m.carried,
  'from': m.from?.toString(),
  'to': m.to.toString(),
  'versions': m.versions,
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
