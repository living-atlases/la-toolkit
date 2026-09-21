// A new portal from a small intent ("a test node for example.com on these
// hosts"), built on a known-good configuration instead of being assembled
// service by service. The base is one of the `.yo-rc.json` that
// la-docker-compose generates for its topologies and checks in CI
// (inventories/testing/topologies/<topology>/), so the placement, the service
// set and the software versions are the ones that repo already proves work
// together. Only the identity changes: names, domain, hosts.
import 'dart:convert';

import '../models/la_project.dart';
import '../models/la_releases.dart';
import '../models/la_server.dart';
import '../models/la_service_desc.dart';
import '../models/la_variable.dart';
import '../models/la_variable_desc.dart';
import '../models/ssh_key.dart';
import '../utils/regexp.dart';
import '../utils/string_utils.dart';

/// The generated configuration of [topology] inside a la-docker-compose
/// release.
String topologyYoRcPath(String topology) =>
    'inventories/testing/topologies/$topology/.yo-rc.json';

/// The placement of [topology] (its runtime skip list), same release.
String topologyPlacementPath(String topology) =>
    'topologies/$topology.placement.json';

/// The topology used when the intent names none, by number of hosts.
const Map<int, String> defaultTopologies = <int, String>{
  1: '1host',
  2: '2host',
  3: 'default-3host',
};

/// One machine of the intent. Hosts map onto the base's hosts in order.
class IntentHost {
  const IntentHost({required this.name, required this.ip});

  factory IntentHost.fromJson(Map<String, dynamic> j) =>
      IntentHost(name: j['name'] as String, ip: j['ip'] as String);

  /// The server name (inventory host), not a public name.
  final String name;
  final String ip;
}

/// [path] of la-docker-compose at [release] (a tag, or 'upstream' for the
/// default branch, as the release selector offers it).
Uri laDockerComposeFileUrl(String release, String path) => Uri.https(
  'raw.githubusercontent.com',
  '/living-atlases/la-docker-compose/${release == 'upstream' ? 'main' : release}/$path',
);

class ProjectIntent {
  const ProjectIntent({
    required this.domain,
    required this.longName,
    required this.shortName,
    required this.hosts,
    this.sshUser = 'ubuntu',
    this.sshPort = 22,
    this.useSSL = true,
    this.disableServices = const <String>[],
  });

  factory ProjectIntent.fromJson(Map<String, dynamic> j) => ProjectIntent(
    domain: j['domain'] as String,
    longName: j['name'] as String,
    shortName: j['shortName'] as String,
    // A single host may also be given flat, as hostName + ip.
    hosts: j['hosts'] != null
        ? <IntentHost>[
            for (final dynamic h in j['hosts'] as List<dynamic>)
              IntentHost.fromJson(h as Map<String, dynamic>),
          ]
        : <IntentHost>[
            IntentHost(name: j['hostName'] as String, ip: j['ip'] as String),
          ],
    sshUser: j['sshUser'] as String? ?? 'ubuntu',
    sshPort: j['sshPort'] as int? ?? 22,
    useSSL: j['ssl'] as bool? ?? true,
    disableServices:
        (j['disableServices'] as List<dynamic>? ?? const <dynamic>[])
            .cast<String>(),
  );

  final String domain;
  final String longName;
  final String shortName;

  final List<IntentHost> hosts;
  final String sshUser;
  final int sshPort;
  final bool useSSL;

  /// Service names (`nameInt`, e.g. `spatial`) to turn off entirely.
  final List<String> disableServices;

  /// What is wrong with the intent itself, before touching any model.
  List<String> problems() => <String>[
    if (!LARegExp.domainRegexp.hasMatch(domain))
      '"$domain" is not a domain name (no scheme, no www).',
    if (!LARegExp.projectNameRegexp.hasMatch(longName))
      '"$longName" is not a valid project name.',
    if (!LARegExp.shortNameRegexp.hasMatch(shortName))
      '"$shortName" is not a valid short name.',
    if (hosts.isEmpty) 'At least one host is needed.',
    for (final IntentHost h in hosts) ...<String>[
      if (!LARegExp.hostnameRegexp.hasMatch(h.name))
        '"${h.name}" is not a valid server name.',
      if (!LARegExp.ip.hasMatch(h.ip)) '"${h.ip}" is not an IPv4 address.',
    ],
    if (hosts.map((IntentHost h) => h.name).toSet().length != hosts.length)
      'Host names must be different.',
    for (final String s in disableServices)
      if (!LAServiceDesc.listS(false).contains(s))
        '"$s" is not a service name.'
      else if (!LAServiceDesc.get(s).optional)
        '"$s" cannot be disabled.',
  ];
}

/// Thrown when the intent is invalid or does not fit the base.
class SynthesisException implements Exception {
  SynthesisException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Builds the portal of [intent] from [baseYoRc] (a generated `.yo-rc.json`,
/// the whole file). The base's data hubs are left out.
///
/// [takenDirNames]: the directories of the projects the toolkit already has,
/// so the new inventory never lands on top of one of them.
/// [laReleases]: as for template imports, the versions to give services the
/// base does not pin.
LAProject synthesizeProject(
  Map<String, dynamic> baseYoRc,
  ProjectIntent intent, {
  required Set<String> takenDirNames,
  required String dockerComposeRelease,
  required String generatorRelease,
  SshKey? sshKey,
  Map<String, LAReleases>? laReleases,
}) {
  final List<String> problems = intent.problems();
  if (problems.isNotEmpty) {
    throw SynthesisException(problems.join(' '));
  }
  // Deep copy: the base may be reused for several intents.
  final Map<String, dynamic> copy =
      json.decode(json.encode(baseYoRc)) as Map<String, dynamic>;
  final Map<String, dynamic> pv = copy.containsKey('generator-living-atlas')
      ? (copy['generator-living-atlas'] as Map<String, dynamic>)['promptValues']
            as Map<String, dynamic>
      : copy;

  final List<String> baseHosts = (pv['LA_hostnames'] as String? ?? '')
      .split(RegExp(r'[, ]+'))
      .where((String h) => h.isNotEmpty)
      .toList();
  if (baseHosts.length != intent.hosts.length) {
    throw SynthesisException(
      'The base configuration has ${baseHosts.length} hosts '
      '(${baseHosts.join(', ')}) and the intent ${intent.hosts.length}.',
    );
  }
  final String baseDomain = pv['LA_domain'] as String;

  // Base host -> intent host, matched as whole tokens only ("la-mh-1" must
  // not touch "la-mh-10").
  final Map<String, String> hostMap = <String, String>{
    for (int i = 0; i < baseHosts.length; i++)
      baseHosts[i]: intent.hosts[i].name,
  };
  final RegExp hostToken = RegExp(
    '(?<![\\w.-])(${baseHosts.map(RegExp.escape).join('|')})(?![\\w.-])',
  );
  Object? renameHosts(Object? v) => switch (v) {
    final String s => s.replaceAllMapped(
      hostToken,
      (Match m) => hostMap[m.group(1)]!,
    ),
    final List<dynamic> l => l.map(renameHosts).toList(),
    _ => v,
  };

  // The derived maps (aliases, extra hosts, /etc/hosts) are dropped:
  // toGeneratorJson() recomputes them.
  pv
    ..['LA_id'] = null
    ..remove('LA_hubs')
    ..remove('LA_etc_hosts')
    ..remove('LA_nginx_docker_internal_aliases_by_host')
    ..remove('LA_docker_extra_hosts_by_host');
  for (final String key in pv.keys.toList()) {
    pv[key] = renameHosts(pv[key]);
  }

  final LAProject p = LAProject.fromObject(pv, laReleases: laReleases);
  // A variable the base holds at its default (e.g. branding_source
  // "../lademo-branding", derived from the directory) must follow the new
  // identity, not keep the base's: clear it so the default is recomputed.
  final String? basePkg = pv['LA_pkg_name'] as String?;
  if (basePkg != null && basePkg.isNotEmpty) {
    p.dirName = basePkg;
  }
  for (final LAVariable v in p.variables) {
    if (v.value != null && v.value == p.variableDefault(v.nameInt)) {
      v.value = null;
    }
  }
  // Service urls are kept as sub-urls of the project domain, so changing it
  // moves every service with it.
  p
    ..domain = intent.domain
    ..longName = intent.longName
    ..shortName = intent.shortName
    ..useSSL = intent.useSSL
    ..dockerComposeRelease = dockerComposeRelease
    ..generatorRelease = generatorRelease;
  p.dirName = StringUtils.uniqueDirName(
    candidate: p.suggestDirName(),
    taken: takenDirNames,
  );

  // Variables that spell the base domain out (emails, the dev mail catcher).
  for (final LAVariable v in p.variables) {
    final Object? value = v.value;
    if (value is String && value.contains(baseDomain)) {
      v.value = value.replaceAll(baseDomain, intent.domain);
    }
  }
  p.additionalVariables = p.additionalVariables.replaceAll(
    baseDomain,
    intent.domain,
  );
  // The shared l-a.site certificates only cover l-a.site.
  if (intent.domain != baseDomain) {
    for (final LAVariable v in p.variables) {
      if (v.nameInt == 'use_la_site_certs') {
        v.value = false;
      }
    }
  }

  // Ansible logs in as the ssh user the intent names.
  p.setVariable(LAVariableDesc.get('ansible_user'), intent.sshUser);

  for (final IntentHost h in intent.hosts) {
    final LAServer server = p.servers.firstWhere(
      (LAServer s) => s.name == h.name,
    );
    server
      ..ip = h.ip
      ..sshUser = intent.sshUser
      ..sshPort = intent.sshPort
      ..sshKey = sshKey;
    p.upsertServer(server);
  }

  for (final String s in intent.disableServices) {
    p.serviceInUse(s, false);
  }
  p.validateCreation(debug: false);
  return p;
}
