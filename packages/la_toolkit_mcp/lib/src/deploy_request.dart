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

/// Builds the backend command for [ref] from the tool arguments.
///
/// Refuses what the app would never send: hybrid projects (the UI splits them
/// into a docker leg and a VM leg, `resolveDeployCmd` in `deploy_page.dart`),
/// a compose hub on its own (it deploys as part of its portal's stack) and a
/// real run without `confirm: true`.
DeployRequest buildDeployRequest(ProjectRef ref, Map<String, Object?> args) {
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
  if (mode == DeployMode.hybrid) {
    throw InvalidRequest(
      '"${ref.dirName}" is hybrid (services both on VMs and on docker-compose). '
      'Deploying it from here is not supported yet; use the LA Toolkit UI, '
      'which splits it into a docker leg and a VM leg.',
    );
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
  final bool dockerCompose = mode == DeployMode.dockerCompose;

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

  final List<String> servers = _tokens(args, 'limitToServers');
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

  final String desc =
      (args['desc'] is String && (args['desc']! as String).trim().isNotEmpty)
      ? (args['desc']! as String).trim()
      : '${dryRun ? 'Dry run' : 'Agent'} ${dockerCompose ? 'docker-compose ' : ''}deploy';

  return DeployRequest(
    desc: desc,
    dryRun: dryRun,
    prepare: _flag(args, 'prepare', def: !dryRun),
    cmd: <String, dynamic>{
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
    },
  );
}
