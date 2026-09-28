import 'package:la_toolkit_core/models/deploy_cmd.dart';
import 'package:la_toolkit_core/models/la_project.dart';

import 'lint.dart';
import 'projects.dart';

/// A tool argument the server refuses. The message is what the agent sees, so
/// it says how to fix the call, not just that it is wrong.
class InvalidRequest implements Exception {
  InvalidRequest(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Service names, tags and host names that may reach the command line.
///
/// This is a security boundary, not tidiness: `ansiblew` runs the final
/// `ansible-playbook` line through `sh -c 'exec …'` (its `execCmd`), and the
/// backend pastes these lists into that line unquoted. A `;` or `$(…)` in a
/// tag would run on the toolkit host, dry run or not, because the dry run only
/// prefixes the line with `echo`. The leading character must not be `-`
/// either: a "service" called `--nodryrun` would turn a dry run into a real one.
final RegExp safeToken = RegExp(r'^[A-Za-z0-9][A-Za-z0-9._-]*$');

List<String> _tokens(Map<String, Object?> args, String key) {
  final Object? raw = args[key];
  if (raw == null) return <String>[];
  if (raw is! List) {
    throw InvalidRequest('`$key` must be a list of strings.');
  }
  final List<String> out = <String>[];
  for (final Object? v in raw) {
    if (v is! String || !safeToken.hasMatch(v)) {
      throw InvalidRequest(
        '`$key` entry ${v is String ? '"$v"' : v} is not allowed: only letters, '
        'digits, ".", "_" and "-" (no spaces or shell characters).',
      );
    }
    out.add(v);
  }
  return out;
}

bool _flag(Map<String, Object?> args, String key, {bool def = false}) {
  final Object? v = args[key];
  if (v == null) return def;
  if (v is bool) return v;
  throw InvalidRequest('`$key` must be true or false.');
}

/// A validated deploy: the `DeployCmd` JSON the backend expects plus the
/// decisions taken on the way.
class DeployRequest {
  DeployRequest({
    required this.cmd,
    required this.desc,
    required this.dryRun,
    required this.prepare,
  });

  /// Same shape as `DeployCmd.toJson()` in `lib/models/deploy_cmd.dart`.
  final Map<String, dynamic> cmd;
  final String desc;
  final bool dryRun;

  /// Whether to check out the pinned releases and regenerate the inventories
  /// and ssh config first, as `PrepareDeployProject` does in the app before
  /// every run.
  ///
  /// Off by default for dry runs, unlike the UI: the checkouts are shared by
  /// every project (`git checkout -f` / `reset --hard`, `npm install -g` of
  /// the generator), so a project pinning another release would move them for
  /// everybody, and the default call must change nothing.
  final bool prepare;
}

/// The inventory group site.yml plays, and the suffix of its host aliases.
const String dockerComposeGroup = 'docker_compose';

/// The hosts that carry a docker-compose cluster with services: the only ones
/// a docker leg may reach.
List<String> composeHostNames(Json p) {
  final Map<String, dynamic> cs =
      p['clusterServices'] as Map<String, dynamic>? ??
      const <String, dynamic>{};
  final Set<String> ids = <String>{
    for (final Json c
        in (p['clusters'] as List<dynamic>? ?? const <dynamic>[]).cast<Json>())
      if (c['type'] == 'dockerCompose' &&
          c['serverId'] is String &&
          ((cs[c['id']] as List<dynamic>?)?.isNotEmpty ?? false))
        c['serverId'] as String,
  };
  return <String>[
    for (final Json s
        in (p['servers'] as List<dynamic>? ?? const <dynamic>[]).cast<Json>())
      if (ids.contains(s['id'])) s['name'] as String,
  ];
}

/// Builds the backend command for [ref] from the tool arguments.
///
/// Refuses what the app would never send: a hybrid project without a `leg`
/// (the UI makes the user pick the docker leg or the VM leg,
/// `resolveDeployCmd` in `deploy_page.dart`), a docker leg reaching a server
/// that carries no compose cluster, a compose hub on its own (it deploys as
/// part of its portal's stack) and a real run without `confirm: true`.
///
/// Hybrid legs are built by the core, as in the UI
/// ([LAProject.buildDockerLegDeployCmd] / [LAProject.buildVmLegDeployCmd]);
/// [model] builds the project model and defaults to [projectModel].
DeployRequest buildDeployRequest(
  ProjectRef ref,
  Map<String, Object?> args, {
  LAProject Function()? model,
}) {
  final bool dryRun = _flag(args, 'dryRun', def: true);
  final bool confirm = _flag(args, 'confirm');
  if (!dryRun && !confirm) {
    throw InvalidRequest(
      'A real deploy (dryRun: false) changes the servers of "${ref.dirName}" and '
      'cannot be undone. Show the user what will run (a dryRun: true call prints '
      'the exact command), and only after they agree call again with '
      'confirm: true.',
    );
  }

  final Json checked = ref.isHub ? ref.parent! : ref.project;
  final DeployMode mode = deployMode(ref.project);
  final DeployMode parentMode = deployMode(checked);
  final Object? leg = args['leg'];
  if (leg != null && leg != 'docker' && leg != 'vm') {
    throw InvalidRequest('`leg` must be "docker" or "vm".');
  }
  final bool hybrid = mode == DeployMode.hybrid;
  if (hybrid && leg == null) {
    throw InvalidRequest(
      '"${ref.dirName}" is hybrid (services both on VMs and on docker-compose): '
      'it deploys in two separate runs, as in the UI. Pass leg: "docker" '
      '(la-docker-compose on the compose hosts only) or leg: "vm" '
      '(ala-install on the VMs).',
    );
  }
  if (!hybrid && leg != null) {
    final bool matches =
        (leg == 'docker' && mode == DeployMode.dockerCompose) ||
        (leg == 'vm' && mode == DeployMode.vm);
    if (!matches) {
      throw InvalidRequest(
        '"${ref.dirName}" is not hybrid (${mode.name}); leg: "$leg" does not apply.',
      );
    }
  }
  if (ref.isHub &&
      mode == DeployMode.none &&
      parentMode == DeployMode.dockerCompose) {
    throw InvalidRequest(
      'Hub "${ref.dirName}" has no servers of its own: it deploys as part of the '
      'docker-compose stack of its portal "${checked['dirName']}". Deploy the portal.',
    );
  }
  if (mode == DeployMode.none) {
    throw InvalidRequest(
      '"${ref.dirName}" has no services assigned to any server or cluster; '
      'there is nothing to deploy.',
    );
  }
  final bool dockerCompose = hybrid
      ? leg == 'docker'
      : mode == DeployMode.dockerCompose;

  List<String> services = _tokens(args, 'services');
  if (services.isEmpty) services = <String>['all'];
  // ansiblew knows species-lists as `lists` (Api.ansiblew does the same).
  services = services
      .map((String s) => s == 'species-lists' ? 'lists' : s)
      .toList();
  final List<String> skipServices = _tokens(args, 'skipServices');
  if (skipServices.isNotEmpty && !dockerCompose) {
    throw InvalidRequest(
      '`skipServices` only applies to docker-compose deploys; for a VM deploy '
      'list the services to deploy in `services` instead.',
    );
  }
  if (dockerCompose && !(services.length == 1 && services.first == 'all')) {
    throw InvalidRequest(
      'Docker-compose deploys are monolithic (site.yml over the whole stack). '
      'Leave `services` empty and exclude what you do not want with '
      '`skipServices`.',
    );
  }

  List<String> servers = _tokens(args, 'limitToServers');
  final Set<String> known = <String>{
    for (final Json s
        in (checked['servers'] as List<dynamic>? ?? <dynamic>[]).cast<Json>())
      s['name'] as String,
    for (final Json s
        in (ref.project['servers'] as List<dynamic>? ?? <dynamic>[])
            .cast<Json>())
      s['name'] as String,
  };
  final List<String> unknown = servers
      .where((String s) => !known.contains(s))
      .toList();
  if (unknown.isNotEmpty) {
    throw InvalidRequest(
      'Unknown servers in `limitToServers`: ${unknown.join(', ')}. '
      'Known: ${known.join(', ')}.',
    );
  }

  if (hybrid && dockerCompose) {
    // A docker leg never reaches a VM: on a hybrid portal those are the ones
    // serving, and site.yml has no business there.
    final List<String> composeHosts = composeHostNames(checked);
    final List<String> outside = servers
        .where((String s) => !composeHosts.contains(s))
        .toList();
    if (outside.isNotEmpty) {
      throw InvalidRequest(
        'The docker leg only runs on the compose hosts '
        '(${composeHosts.join(', ')}); not on ${outside.join(', ')}.',
      );
    }
    // The inventory lists each service as its own host alias,
    // `<server>.<group>` (ansible_host=<server>), and site.yml plays the
    // `docker_compose` group: a bare server name matches no host at all and
    // ansible would skip everything with exit 0.
    servers = <String>[
      for (final String s in servers.isEmpty ? composeHosts : servers)
        '$s.$dockerComposeGroup',
    ];
  }

  final String desc =
      (args['desc'] is String && (args['desc']! as String).trim().isNotEmpty)
      ? (args['desc']! as String).trim()
      : '${dryRun ? 'Dry run' : 'Agent'} ${dockerCompose ? 'docker-compose ' : ''}'
            '${hybrid ? '(${leg!} leg) ' : ''}deploy';

  final Map<String, dynamic> cmd = <String, dynamic>{
    'deployServices': services,
    'limitToServers': servers,
    'skipTags': _tokens(args, 'skipTags'),
    'tags': _tokens(args, 'tags'),
    'skipServices': skipServices,
    'advanced': true,
    'onlyProperties': _flag(args, 'onlyProperties'),
    'continueEvenIfFails': _flag(args, 'continueEvenIfFails'),
    'debug': _flag(args, 'debug'),
    'dryRun': dryRun,
    'dockerCompose': dockerCompose,
  };
  return DeployRequest(
    desc: desc,
    dryRun: dryRun,
    prepare: _flag(args, 'prepare', def: !dryRun),
    cmd: hybrid ? _hybridLeg(ref, cmd, dockerCompose, model) : cmd,
  );
}

Map<String, dynamic> _hybridLeg(
  ProjectRef ref,
  Map<String, dynamic> cmd,
  bool docker,
  LAProject Function()? model,
) {
  final LAProject p = (model ?? () => projectModel(ref))();
  final DeployCmd user = DeployCmd.fromJson(cmd);
  final DeployCmd leg = docker
      ? p.buildDockerLegDeployCmd(user)
      : p.buildVmLegDeployCmd(user);
  // The core only narrows what the whitelist already checked (the VM leg drops
  // docker services) or adds service names of its own (docker leg skips).
  if (!docker && leg.deployServices.isEmpty) {
    throw InvalidRequest(
      'None of ${user.deployServices.join(', ')} runs on a VM of '
      '"${ref.dirName}"; the VM leg would deploy nothing.',
    );
  }
  return leg.toJson();
}
