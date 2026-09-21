// A new portal from a small intent ("a test node for example.com on this
// host"), built on a known-good single-host configuration instead of being
// assembled service by service. The base is the `.yo-rc.json` that
// la-docker-compose generates and deploys in its CI for its `1host` topology
// (inventories/testing/topologies/1host/), so the placement, the service set
// and the software versions are the ones that repo already proves work
// together on one VM. Only the identity changes: names, domain, host.
import 'dart:convert';

import '../models/la_project.dart';
import '../models/la_releases.dart';
import '../models/la_server.dart';
import '../models/la_service_desc.dart';
import '../models/la_variable.dart';
import '../models/ssh_key.dart';
import '../utils/regexp.dart';
import '../utils/string_utils.dart';

/// Where the base lives inside a la-docker-compose release.
const String oneHostYoRcPath =
    'inventories/testing/topologies/1host/.yo-rc.json';

/// The runtime skip list of that topology, in the same release.
const String oneHostPlacementPath = 'topologies/1host.placement.json';

class ProjectIntent {
  const ProjectIntent({
    required this.domain,
    required this.longName,
    required this.shortName,
    required this.hostName,
    required this.ip,
    this.sshUser = 'ubuntu',
    this.sshPort = 22,
    this.useSSL = true,
    this.disableServices = const <String>[],
  });

  factory ProjectIntent.fromJson(Map<String, dynamic> j) => ProjectIntent(
    domain: j['domain'] as String,
    longName: j['name'] as String,
    shortName: j['shortName'] as String,
    hostName: j['hostName'] as String,
    ip: j['ip'] as String,
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

  /// The server name (inventory host), not a public name.
  final String hostName;
  final String ip;
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
    if (!LARegExp.hostnameRegexp.hasMatch(hostName))
      '"$hostName" is not a valid server name.',
    if (!LARegExp.ip.hasMatch(ip)) '"$ip" is not an IPv4 address.',
    for (final String s in disableServices)
      if (!LAServiceDesc.listS(false).contains(s))
        '"$s" is not a service name.'
      else if (!LAServiceDesc.get(s).optional)
        '"$s" cannot be disabled.',
  ];
}

/// Thrown when the base is not a single-host configuration.
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
  if (baseHosts.length != 1) {
    throw SynthesisException(
      'The base configuration has ${baseHosts.length} hosts (${baseHosts.join(', ')}); '
      'synthesis only starts from a single-host one.',
    );
  }
  final String baseHost = baseHosts.single;
  final String baseDomain = pv['LA_domain'] as String;

  // Every place the base names its host. The derived maps (aliases, extra
  // hosts, /etc/hosts) are dropped: toGeneratorJson() recomputes them.
  pv
    ..['LA_id'] = null
    ..remove('LA_hubs')
    ..remove('LA_etc_hosts')
    ..remove('LA_nginx_docker_internal_aliases_by_host')
    ..remove('LA_docker_extra_hosts_by_host');
  for (final String key in pv.keys.toList()) {
    final Object? v = pv[key];
    if (key.endsWith('_hostname') || key == 'LA_hostnames') {
      if (v is String && v.isNotEmpty) {
        pv[key] = v.replaceAll(baseHost, intent.hostName);
      }
    } else if (key == 'LA_docker_solr_hosts' && v is List<dynamic>) {
      pv[key] = <String>[
        for (final dynamic h in v)
          h == baseHost ? intent.hostName : h as String,
      ];
    }
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

  final LAServer server = p.servers.single;
  server
    ..ip = intent.ip
    ..sshUser = intent.sshUser
    ..sshPort = intent.sshPort
    ..sshKey = sshKey;
  p.upsertServer(server);

  for (final String s in intent.disableServices) {
    p.serviceInUse(s, false);
  }
  p.validateCreation(debug: false);
  return p;
}
