import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_mcp/server.dart';
import 'package:la_toolkit_core/dependencies_manager.dart';
import 'package:la_toolkit_core/models/la_project.dart';
import 'package:la_toolkit_core/models/la_releases.dart';
import 'package:la_toolkit_core/models/ssh_key.dart';
import 'package:la_toolkit_core/placement/placement_changes.dart';
import 'package:la_toolkit_core/placement/server_changes.dart';
import 'package:la_toolkit_core/releases/deps_versions.dart';
import 'package:la_toolkit_core/synth/synthesize_project.dart';

import 'backend_client.dart';
import 'deploy_outcome.dart';
import 'deploy_request.dart';
import 'lint.dart';
import 'placement.dart';
import 'preconditions.dart';
import 'projects.dart';
import 'releases.dart';

const String _instructions = '''
Drives an LA Toolkit (Living Atlas deployment tool) through its backend API.

Typical flow to update a portal:
1. la_list_projects, then la_get_project to see servers, placement and history.
   la_check_preconditions before a first or long-delayed deploy: it names
   what is missing (DNS, ssh key, ssh/sudo access, disk space) instead of
   letting a multi-hour deploy fail on it. la_lint_project gives the same
   warnings the toolkit UI shows for the project (placement, cluster sizes,
   release incompatibilities); report them to the user before deploying.

To set up a new portal (1-3 hosts): la_create_project previews it (it starts
from a la-docker-compose topology its CI proves); show the
preview, then la_create_project again with save: true and confirm: true once
the user agrees. Then la_check_preconditions and la_deploy (dry run first,
with the skipServices the preview recommends).
2. la_deploy with dryRun: true (the default). It prints the exact ansible
   command and changes nothing. Show it to the user. If it reports exit 127,
   the inventories were never generated: retry with prepare: true, which
   checks out the project's pinned releases in the toolkit (shared by all
   projects) and regenerates them; ask the user first.
3. Only if the user agrees, la_deploy with dryRun: false and confirm: true. It
   returns a runId immediately; deploys take from minutes to hours.
4. Poll la_deploy_status (every few minutes, not seconds). When the verdict is
   failed, la_deploy_failures gives the failed tasks without the full log.

Hybrid portals (services on VMs and on docker-compose) deploy one leg per
run: la_deploy with leg: "docker" (compose hosts only) or leg: "vm".
la_set_releases changes the releases a portal pins (preview, then save and
confirm); the next la_deploy with prepare: true applies them.
la_set_servers adds, changes or removes machines, and la_set_placement moves,
assigns or unassigns services on them (docker_compose included), both the same
way (preview, then save and confirm); a later deploy of the servers involved
applies it. A new compose host: la_set_servers add, then la_set_placement with
{op: assign, service: docker_compose, to: <server>} before moving services.

Never pass confirm: true without the user's explicit agreement for that run.''';

final Schema _projectArg = Schema.string(
  description: 'Project id, dirName or shortName (portals and hubs).',
);

final Schema _runIdArg = Schema.string(
  description:
      'Run id from la_deploy or la_list_runs. Defaults to the latest run.',
);

Schema _tokenList(String description) =>
    Schema.list(description: description, items: Schema.string());

/// The MCP server. Every tool is a thin composition of [BackendClient] calls
/// and the pure helpers in `projects.dart` / `deploy_*.dart`.
base class LaToolkitMcpServer extends MCPServer with ToolsSupport {
  LaToolkitMcpServer(
    super.channel, {
    required this.backend,
    this.dryRunWait,
    Future<List<String>> Function(String host)? resolve,
    Directory? backupDir,
  }) : resolve = resolve ?? _lookup,
       backupDir =
           backupDir ??
           Directory(
             '${Platform.environment['HOME'] ?? Directory.systemTemp.path}'
             '/.cache/la_toolkit_mcp/backups',
           ),
       super.fromStreamChannel(
         implementation: Implementation(name: 'la-toolkit', version: '0.1.0'),
         instructions: _instructions,
       ) {
    _register();
  }

  final BackendClient backend;

  /// Where la_set_releases and la_set_placement leave the project as it was
  /// before saving.
  final Directory backupDir;

  /// Resolves a host name to its addresses, empty when it does not resolve.
  final Future<List<String>> Function(String host) resolve;

  static Future<List<String>> _lookup(String host) async {
    try {
      final List<InternetAddress> a = await InternetAddress.lookup(
        host,
      ).timeout(const Duration(seconds: 5));
      return a.map((InternetAddress i) => i.address).toSet().toList();
    } on SocketException {
      return <String>[];
    } on TimeoutException {
      return <String>[];
    }
  }

  /// How long la_deploy waits for a dry run to finish so it can return the
  /// echoed command. Null means the default (30 s); tests shorten it.
  final Duration? dryRunWait;

  void _register() {
    _tool(
      'la_list_projects',
      'List the portals and hubs managed by this LA Toolkit.',
      Schema.object(),
      readOnly: true,
      (Map<String, Object?> a) async {
        final List<Json> portals = await backend.getProjects();
        return <Json>[
          for (final Json p in portals) ...<Json>[
            projectSummary(ProjectRef(p)),
            for (final Json h in (p['hubs'] as List<dynamic>).cast<Json>())
              projectSummary(ProjectRef(h, p)),
          ],
        ];
      },
    );

    _tool(
      'la_get_project',
      'Details of one project: servers and their last connectivity check, '
          'releases, which services run where, last service checks and recent runs.',
      Schema.object(
        properties: <String, Schema>{'project': _projectArg},
        required: <String>['project'],
      ),
      readOnly: true,
      (Map<String, Object?> a) async => projectDetails(await _resolve(a)),
    );

    _tool(
      'la_lint_project',
      'The warnings the toolkit UI shows for a project: services without a '
          'server, compose placement, cluster sizes, services that need each '
          'other, and releases that the dependency matrix marks incompatible. '
          'Touches no server. clean: true means nothing to report.',
      Schema.object(
        properties: <String, Schema>{'project': _projectArg},
        required: <String>['project'],
      ),
      readOnly: true,
      _lint,
    );

    _tool(
      'la_list_runs',
      'Command history of a project (deploys, dry runs, pre/post-deploy), newest first.',
      Schema.object(
        properties: <String, Schema>{
          'project': _projectArg,
          'limit': Schema.int(description: 'How many runs (default 10).'),
        },
        required: <String>['project'],
      ),
      readOnly: true,
      (Map<String, Object?> a) async =>
          runs((await _resolve(a)).project, limit: (a['limit'] as int?) ?? 10),
    );

    _tool(
      'la_check_connectivity',
      'Check every server of a project from the toolkit: ping, ssh, sudo and OS '
          'version. Runs read-only commands over ssh on the servers, and stores '
          'the results on the project, as the UI does.',
      Schema.object(
        properties: <String, Schema>{'project': _projectArg},
        required: <String>['project'],
      ),
      // Not read-only: check-connectivity.js saves the statuses and OS facts.
      openWorld: true,
      (Map<String, Object?> a) async {
        final ProjectRef ref = await _resolve(a);
        final List<dynamic> servers = ref.project['servers'] as List<dynamic>;
        if (servers.isEmpty) {
          throw InvalidRequest('"${ref.dirName}" has no servers of its own.');
        }
        final Json r = await backend.testConnectivity(servers);
        return (r['servers'] as List<dynamic>? ?? const <dynamic>[])
            .cast<Json>()
            .map(
              (Json s) => <String, dynamic>{
                'name': s['name'],
                'reachable': s['reachable'],
                'sshReachable': s['sshReachable'],
                'sudoEnabled': s['sudoEnabled'],
                'os': '${s['osName'] ?? '?'} ${s['osVersion'] ?? ''}'.trim(),
              },
            )
            .toList();
      },
    );

    _tool(
      'la_check_preconditions',
      'Everything a deploy needs before it starts, for the servers that carry '
          'services: the toolkit holds their ssh keys, ssh and sudo work, the OS '
          'is a supported Ubuntu, there is disk space, and the portal host names '
          'resolve. Answers ready: true or the list of blockers. Runs read-only '
          'commands over ssh; the connectivity results are saved on the project, '
          'as the UI does.',
      Schema.object(
        properties: <String, Schema>{
          'project': _projectArg,
          'servers': _tokenList(
            'Only these servers (by name; default: every server with services).',
          ),
          'leg': Schema.string(
            description:
                'Hybrid portals: "docker" checks only the hosts that carry a '
                'docker-compose cluster, "vm" only the others.',
          ),
        },
        required: <String>['project'],
      ),
      openWorld: true,
      _preconditions,
    );

    _tool(
      'la_create_project',
      'A new docker-compose portal on one to three hosts, from a few facts: '
          'domain, names, the hosts (name, IP) and the toolkit ssh key to reach '
          'them. It starts from a topology la-docker-compose checks in its CI '
          '(1host, 2host, default-3host by host count, or the one named), so '
          'the placement and the versions are known to work together; only the '
          'identity changes, hosts taken in order for the topology slots. By '
          'default it only previews (validation, lint, public names, the '
          'skipServices to deploy with) and stores nothing. save: true AND '
          'confirm: true store it in the toolkit, only after the user agreed; '
          'that touches no server.',
      Schema.object(
        properties: <String, Schema>{
          'domain': Schema.string(description: 'e.g. example.com'),
          'name': Schema.string(
            description: 'Long name, e.g. "Example Portal".',
          ),
          'shortName': Schema.string(description: 'e.g. "Example".'),
          'hosts': Schema.list(
            description: 'The machines, in topology slot order.',
            items: Schema.object(
              properties: <String, Schema>{
                'name': Schema.string(
                  description:
                      'Server name as ssh and ansible will know it (not a public name).',
                ),
                'ip': Schema.string(
                  description: 'IPv4 the toolkit reaches it at.',
                ),
              },
              required: <String>['name', 'ip'],
            ),
          ),
          'hostName': Schema.string(
            description: 'Single host shorthand for hosts: [{name, ip}].',
          ),
          'ip': Schema.string(description: 'With hostName.'),
          'topology': Schema.string(
            description:
                'la-docker-compose topology (default by host count: '
                '1host, 2host, default-3host). Others: 3host-alt, '
                'shared-hostname-2host, shared-hostname-3host.',
          ),
          'sshUser': Schema.string(description: 'Default ubuntu.'),
          'sshPort': Schema.int(description: 'Default 22.'),
          'sshKey': Schema.string(
            description: 'Name of a toolkit ssh key authorised on the hosts.',
          ),
          'ssl': Schema.bool(description: 'Default true.'),
          'disableServices': _tokenList(
            'Services to leave out entirely (service names, e.g. spatial, doi).',
          ),
          'dockerComposeRelease': Schema.string(
            description: 'la-docker-compose tag to pin (default: the newest).',
          ),
          'save': Schema.bool(
            description: 'Store the project (default false).',
          ),
          'confirm': Schema.bool(
            description:
                'Required with save: true. Set it only when the user agreed.',
          ),
        },
        required: <String>['domain', 'name', 'shortName', 'sshKey'],
      ),
      openWorld: true,
      _createProject,
    );

    _tool(
      'la_set_releases',
      'Change the generator / la-docker-compose / ala-install releases a '
          'portal pins, as the Tune page does. Previews by default: the '
          'releases before and after, the generator configuration keys that '
          'change, the hubs kept and the lint. save: true AND confirm: true '
          'store it (after writing a backup of the project as it was); only '
          'once the user agreed. Touches no server: the next la_deploy with '
          'prepare: true checks the new releases out and regenerates.',
      Schema.object(
        properties: <String, Schema>{
          'project': _projectArg,
          'generatorRelease': Schema.string(
            description: 'generator-living-atlas version, e.g. 1.9.11.',
          ),
          'dockerComposeRelease': Schema.string(
            description:
                'la-docker-compose tag, or "upstream" for its main branch.',
          ),
          'alaInstallRelease': Schema.string(
            description: 'ala-install tag, or "upstream".',
          ),
          'save': Schema.bool(description: 'Store it (default false).'),
          'confirm': Schema.bool(
            description:
                'Required with save: true. Set it only when the user agreed.',
          ),
        },
        required: <String>['project'],
      ),
      openWorld: true,
      _setReleases,
    );

    _tool(
      'la_set_placement',
      'Change where the services of a project run, as the servers page of '
          'the toolkit does, with an ordered list of changes: move a service '
          'off a server (or the docker-compose cluster it carries) onto '
          'another, assign it to one more place, or unassign it. Assigning '
          'docker_compose to a server makes it a compose host (its cluster '
          'comes with it); unassigning it deletes the cluster once empty. A '
          'service takes its sub-services along (spatial: spatial_service, '
          'geoserver) and a move keeps its versions. Previews by default: '
          'placement before and after, servers that gain and lose services, '
          'public names and extra_hosts that change host, generator keys, new '
          'integrity errors, lint delta and the hosts to deploy. save: true '
          'AND confirm: true store it (after a backup of the project); only '
          'once the user agreed. Touches no server.',
      Schema.object(
        properties: <String, Schema>{
          'project': _projectArg,
          'changes': Schema.list(
            description: 'Applied in order.',
            items: Schema.object(
              properties: <String, Schema>{
                'op': Schema.string(
                  description: '"move" (default), "assign" or "unassign".',
                ),
                'service': Schema.string(
                  description:
                      'Service name (spatial, ala_hub, docker_compose...) or '
                      'its inventory group / artifact when unambiguous '
                      '(spatial-hub).',
                ),
                'to': Schema.string(
                  description:
                      'Server name (exact; it must exist: la_set_servers adds '
                      'one). For move and assign.',
                ),
                'from': Schema.string(
                  description:
                      'Server it leaves. For unassign, and for a move when '
                      'it runs on several.',
                ),
                'fromLeg': Schema.string(
                  description:
                      '"docker" or "vm", when `from` runs it both ways.',
                ),
                'toLeg': Schema.string(
                  description:
                      '"docker" (the compose cluster `to` carries) or "vm". '
                      'Default: the leg it leaves.',
                ),
              },
              required: <String>['service'],
            ),
          ),
          'save': Schema.bool(description: 'Store it (default false).'),
          'confirm': Schema.bool(
            description:
                'Required with save: true. Set it only when the user agreed.',
          ),
        },
        required: <String>['project', 'changes'],
      ),
      openWorld: true,
      _setPlacement,
    );

    Schema serverItem({required bool isNew}) => Schema.object(
      properties: <String, Schema>{
        'name': Schema.string(
          description:
              'Server name as ssh and ansible know it (not a public name).',
        ),
        'ip': Schema.string(description: 'IP the toolkit reaches it at.'),
        'sshUser': Schema.string(
          description: 'Default: the project ansible_user.',
        ),
        'sshPort': Schema.int(description: 'Default 22.'),
        'sshKey': Schema.string(description: 'Name of a toolkit ssh key.'),
        'aliases': _tokenList('Other names of the machine.'),
        'gateways': _tokenList(
          'Servers of the project to jump through (ssh ProxyJump).',
        ),
      },
      required: <String>['name', if (isNew) 'ip'],
    );

    _tool(
      'la_set_servers',
      'Add, change or remove the servers (machines) of a project, as the '
          'servers page of the toolkit does. update changes only the fields '
          'given (ip, ssh user/port/key, aliases, gateways; not the name). '
          'remove only takes servers that run nothing: move their services '
          'off first with la_set_placement (an empty docker-compose cluster '
          'goes with its server). Previews by default: the servers, name '
          'clashes with other projects, what an IP change moves (extra_hosts, '
          'public names), integrity, lint and the hosts to deploy. save: true '
          'AND confirm: true store it (after a backup of the project); only '
          'once the user agreed. Touches no server.',
      Schema.object(
        properties: <String, Schema>{
          'project': _projectArg,
          'add': Schema.list(items: serverItem(isNew: true)),
          'update': Schema.list(items: serverItem(isNew: false)),
          'remove': _tokenList('Names of servers to remove.'),
          'save': Schema.bool(description: 'Store it (default false).'),
          'confirm': Schema.bool(
            description:
                'Required with save: true. Set it only when the user agreed.',
          ),
        },
        required: <String>['project'],
      ),
      destructive: true,
      openWorld: true,
      _setServers,
    );

    _tool(
      'la_deploy',
      'Deploy a project with ansible (docker-compose, VM, or one leg of a '
          'hybrid portal). '
          'dryRun defaults to true and only prints the command. A real deploy '
          'needs dryRun: false AND confirm: true, and must only be requested after '
          'the user explicitly agreed. Returns a runId at once; poll la_deploy_status.',
      Schema.object(
        properties: <String, Schema>{
          'project': _projectArg,
          'dryRun': Schema.bool(
            description: 'Only print the command (default true).',
          ),
          'confirm': Schema.bool(
            description:
                'Required with dryRun: false. Set it only when the user agreed to this deploy.',
          ),
          'leg': Schema.string(
            description:
                'Hybrid portals only, required there: "docker" runs '
                'la-docker-compose on the compose hosts only (never a VM; '
                'limitToServers defaults to them), "vm" runs ala-install on '
                'the VM services. Built as the UI builds each leg.',
          ),
          'services': _tokenList(
            'VM deploys: services to deploy (default all). Not allowed for docker-compose.',
          ),
          'skipServices': _tokenList(
            'Docker-compose deploys: inventory groups to leave out (e.g. spatial, images).',
          ),
          'tags': _tokenList('Only run these ansible tags.'),
          'skipTags': _tokenList('Skip these ansible tags.'),
          'limitToServers': _tokenList('Only these servers (by name).'),
          'onlyProperties': Schema.bool(
            description: 'Only regenerate service configuration.',
          ),
          'continueEvenIfFails': Schema.bool(),
          'debug': Schema.bool(description: 'Verbose ansible output.'),
          'prepare': Schema.bool(
            description:
                'Check out the pinned releases and regenerate inventories and '
                'ssh config first, like the UI does (default: true for real deploys, '
                'false for dry runs). Changes the toolkit checkouts shared by every '
                'project, never the servers.',
          ),
          'desc': Schema.string(description: 'Label for the run history.'),
        },
        required: <String>['project'],
      ),
      destructive: true,
      openWorld: true,
      _deploy,
    );

    _tool(
      'la_deploy_status',
      'Status of a run: running / success / failed / aborted / cancelled, per-host '
          'recap and, while running, the current task. Poll every few minutes.',
      Schema.object(
        properties: <String, Schema>{
          'project': _projectArg,
          'runId': _runIdArg,
        },
        required: <String>['project'],
      ),
      readOnly: true,
      (Map<String, Object?> a) async {
        final (Json entry, Json results) = await _runResults(a);
        return summarizeRun(entry, results);
      },
    );

    _tool(
      'la_deploy_failures',
      'Failed tasks of a run (task, host, error message), without the full log. '
          'When no task failed but the run did, returns the tail of the log.',
      Schema.object(
        properties: <String, Schema>{
          'project': _projectArg,
          'runId': _runIdArg,
          'max': Schema.int(
            description: 'Max failed tasks to return (default 8, latest ones).',
          ),
        },
        required: <String>['project'],
      ),
      readOnly: true,
      (Map<String, Object?> a) async {
        final (Json entry, Json results) = await _runResults(a);
        final List<Json> failed = failedTasks(
          results,
          max: (a['max'] as int?) ?? 8,
        );
        return <String, dynamic>{
          ...summarizeRun(entry, results),
          'failedTasks': failed,
          if (failed.isEmpty) 'logTail': logTail(results),
        };
      },
    );

    _tool(
      'la_deploy_cancel',
      'Stop a running deploy (SIGTERM, then SIGKILL). Needs confirm: true.',
      Schema.object(
        properties: <String, Schema>{
          'project': _projectArg,
          'runId': _runIdArg,
          'confirm': Schema.bool(
            description:
                'Must be true; set it only when the user asked to cancel.',
          ),
        },
        required: <String>['project', 'confirm'],
      ),
      destructive: true,
      (Map<String, Object?> a) async {
        if (a['confirm'] != true) {
          throw InvalidRequest(
            'Cancelling needs confirm: true, set only when the user asked for it.',
          );
        }
        final ProjectRef ref = await _resolve(a);
        final Json entry = _entry(ref, a['runId'] as String?);
        final bool killed = await backend.deployCancel(
          entry['logsPrefix'] as String,
          entry['logsSuffix'] as String,
        );
        return <String, dynamic>{'runId': entry['id'], 'killed': killed};
      },
    );
  }

  Future<Object?> _lint(Map<String, Object?> a) async {
    final ProjectRef ref = await _resolve(a);
    return _lintModel(
      projectModel(ref),
      hasSshKeys: (await backend.sshKeys()).isNotEmpty,
    );
  }

  /// [lintReport] with what the UI would feed it: the backend version, the
  /// matrix and, for releases the project does not pin, the newest ones.
  Future<Json> _lintModel(LAProject project, {required bool hasSshKeys}) async {
    String? version;
    try {
      version = (await backend.backendVersion())['version'] as String?;
    } on BackendException {
      version = null;
    }
    final bool matrix = await (_matrix ??= _loadMatrix());
    return lintReport(
      project,
      hasSshKeys: hasSshKeys,
      backendVersion: version,
      matrixLoaded: matrix,
      alaInstallReleases: project.alaInstallRelease == null
          ? await _orEmpty(_alaInstallReleases)
          : const <String>[],
      generatorReleases: project.generatorRelease == null
          ? await _orEmpty(backend.generatorVersions)
          : const <String>[],
    );
  }

  /// The dependency matrix is global state in the core: loaded once per
  /// server. A failed download is retried on the next call.
  Future<bool>? _matrix;

  Future<bool> _loadMatrix() async {
    try {
      DependenciesManager.setDeps(
        await backend.fetchText(Uri.parse(DependenciesManager.dependenciesUrl)),
      );
    } catch (_) {
      _matrix = null;
      return false;
    }
    try {
      DependenciesManager.setNextgenCompat(
        await backend.fetchText(
          Uri.parse(DependenciesManager.nextgenCompatUrl),
        ),
      );
    } catch (_) {
      // As in the app: the nextgen guard never blocks the main matrix.
    }
    return true;
  }

  Future<List<String>> _alaInstallReleases() async {
    final List<dynamic> l =
        json.decode(
              await backend.fetchText(
                Uri.https(
                  DependenciesManager.alaInstallReleasesHost,
                  DependenciesManager.alaInstallReleasesPath,
                ),
              ),
            )
            as List<dynamic>;
    return <String>[
      for (final dynamic r in l) (r as Json)['tag_name'] as String,
    ];
  }

  static Future<List<String>> _orEmpty(
    Future<List<String>> Function() f,
  ) async {
    try {
      return await f();
    } catch (_) {
      return <String>[];
    }
  }

  Future<Object?> _createProject(Map<String, Object?> a) async {
    final bool save = a['save'] == true;
    if (save && a['confirm'] != true) {
      throw InvalidRequest(
        'save: true stores a new project in the toolkit: pass confirm: true, '
        'and only once the user agreed to it.',
      );
    }
    if (a['hosts'] == null && (a['hostName'] == null || a['ip'] == null)) {
      throw InvalidRequest('Give hosts: [{name, ip}] (or hostName and ip).');
    }
    final ProjectIntent intent = ProjectIntent.fromJson(<String, dynamic>{
      ...a,
    });
    final String? topology =
        a['topology'] as String? ?? defaultTopologies[intent.hosts.length];
    if (topology == null) {
      throw InvalidRequest(
        'No default topology for ${intent.hosts.length} hosts; name one.',
      );
    }
    if (!RegExp(r'^[a-z0-9][a-z0-9-]*$').hasMatch(topology)) {
      throw InvalidRequest('"$topology" is not a topology name.');
    }
    final List<String> problems = intent.problems();
    if (problems.isNotEmpty) {
      throw InvalidRequest(problems.join(' '));
    }

    final String keyName = a['sshKey'] as String;
    final List<Json> keys = await backend.sshKeys();
    final Json? key = keys.cast<Json?>().firstWhere(
      (Json? k) => k!['name'] == keyName,
      orElse: () => null,
    );
    if (key == null || key['missing'] == true) {
      throw InvalidRequest(
        'The toolkit has no usable ssh key "$keyName". Known: '
        '${keys.where((Json k) => k['missing'] != true).map((Json k) => k['name']).join(', ')}.',
      );
    }

    final String release =
        a['dockerComposeRelease'] as String? ?? await _newestComposeRelease();
    final Json base;
    try {
      base =
          json.decode(
                await backend.fetchText(
                  laDockerComposeFileUrl(release, topologyYoRcPath(topology)),
                ),
              )
              as Json;
    } on BackendException catch (e) {
      if (e.statusCode == 404) {
        throw InvalidRequest(
          'la-docker-compose $release has no topology "$topology".',
        );
      }
      rethrow;
    }
    List<String> skip = <String>[];
    try {
      final Json placement =
          json.decode(
                await backend.fetchText(
                  laDockerComposeFileUrl(
                    release,
                    topologyPlacementPath(topology),
                  ),
                ),
              )
              as Json;
      skip = (placement['skip_services'] as List<dynamic>? ?? <dynamic>[])
          .cast<String>();
    } on BackendException {
      // An older release without the placement file: deploy everything.
    }
    final List<String> generators = await backend.generatorVersions();
    if (generators.isEmpty) {
      throw InvalidRequest(
        'The backend lists no generator-living-atlas release.',
      );
    }

    // As the UI's template import: services the base pins no version for
    // get the newest known one. Without it the dependency lint reports them.
    Map<String, LAReleases>? laReleases;
    String? releasesNote;
    try {
      final Map<String, String> query = depsVersionsQuery();
      laReleases = parseDepsVersions(await backend.depsVersions(query), query);
    } on Exception catch (e) {
      releasesNote =
          'Service releases unavailable ($e): unpinned services have no version.';
    }

    final List<Json> portals = await backend.getProjects();
    final LAProject p;
    try {
      p = synthesizeProject(
        base,
        intent,
        takenDirNames: <String>{
          for (final ProjectRef r in allProjects(portals))
            if (r.dirName.isNotEmpty) r.dirName,
        },
        dockerComposeRelease: release,
        generatorRelease: generators.first,
        sshKey: SshKey.fromJson(key),
        laReleases: laReleases,
      );
    } on SynthesisException catch (e) {
      throw InvalidRequest(e.message);
    }

    final bool valid = p.validateCreation(debug: false);
    final Json lint = await _lintModel(p, hasSshKeys: true);
    // The names nginx will answer for: the ones that must resolve to the host.
    final Map<String, dynamic> aliases =
        p.toGeneratorJson()['LA_nginx_docker_internal_aliases_by_host']
            as Map<String, dynamic>? ??
        const <String, dynamic>{};
    final Json preview = <String, dynamic>{
      'dirName': p.dirName,
      'domain': p.domain,
      'topology': topology,
      'hosts': <Json>[
        for (final IntentHost h in intent.hosts)
          <String, dynamic>{
            'name': h.name,
            'ip': h.ip,
            // What nginx on this host answers for.
            'publicNames': (aliases[h.name] as List<dynamic>? ?? <dynamic>[])
                .cast<String>(),
          },
      ],
      'sshUser': intent.sshUser,
      'sshKey': keyName,
      'dockerComposeRelease': release,
      'generatorRelease': p.generatorRelease,
      'services': p.getServicesNameListInUse()..sort(),
      'publicNames': <String>{
        for (final dynamic names in aliases.values)
          ...(names as List<dynamic>).cast<String>(),
      }.toList()..sort(),
      'deployWithSkipServices': skip,
      'valid': valid,
      'lint': lint,
      if (releasesNote != null) 'note': releasesNote,
    };
    if (!save) {
      return <String, dynamic>{...preview, 'saved': false};
    }
    if (!valid || (lint['findings'] as List<dynamic>).isNotEmpty) {
      throw InvalidRequest(
        'Not saved: the project is not valid or has lint findings. '
        '${json.encode(lint['findings'])}',
      );
    }
    await backend.addProjects(<Json>[p.toApiJson()]);
    await backend.genSshConf(
      name: p.shortName,
      id: p.id,
      servers: p.toJson()['servers'] as List<dynamic>,
      user: p.getVariableValue('ansible_user')?.toString() ?? intent.sshUser,
    );
    return <String, dynamic>{...preview, 'saved': true, 'id': p.id};
  }

  Future<String> _newestComposeRelease() async {
    final List<String> tags = await _composeReleases();
    if (tags.isEmpty) {
      throw InvalidRequest('la-docker-compose has no release tags.');
    }
    return tags.first;
  }

  /// la-docker-compose tags, newest first. GitHub lists tags by name, so
  /// v1.10.0 would come after v1.9.0: sort them as versions.
  Future<List<String>> _composeReleases() async {
    final List<dynamic> tags =
        json.decode(
              await backend.fetchText(
                Uri.https(
                  'api.github.com',
                  DependenciesManager.dockerComposeTagsPath,
                ),
              ),
            )
            as List<dynamic>;
    return sortReleases(<String>[
      for (final dynamic t in tags) (t as Json)['name'] as String,
    ]);
  }

  Future<Object?> _setReleases(Map<String, Object?> a) async {
    final bool save = a['save'] == true;
    if (save && a['confirm'] != true) {
      throw InvalidRequest(
        'save: true changes the releases the next deploy uses: pass '
        'confirm: true, and only once the user agreed to it.',
      );
    }
    final ProjectRef ref = await _resolve(a);
    if (ref.isHub) {
      throw InvalidRequest(
        '"${ref.dirName}" is a hub: its inventories are generated with its '
        'portal "${ref.parent!['dirName']}". Change the portal releases.',
      );
    }
    String? arg(String k) {
      final Object? v = a[k];
      if (v == null) return null;
      if (v is! String || !safeToken.hasMatch(v)) {
        throw InvalidRequest('`$k` "$v" is not a release name.');
      }
      return v;
    }

    final String? gen = arg('generatorRelease');
    final String? compose = arg('dockerComposeRelease');
    final String? alaInstall = arg('alaInstallRelease');
    if (gen == null && compose == null && alaInstall == null) {
      throw InvalidRequest(
        'Give at least one of generatorRelease, dockerComposeRelease, '
        'alaInstallRelease.',
      );
    }
    Future<void> check(
      String what,
      String? v,
      Future<List<String>> Function() known, {
      bool upstream = false,
    }) async {
      if (v == null || (upstream && v == 'upstream')) return;
      final List<String> list = await known();
      if (!list.contains(v)) {
        throw InvalidRequest(
          'Unknown $what release "$v". Newest: ${list.take(5).join(', ')}'
          '${upstream ? ', upstream' : ''}.',
        );
      }
    }

    await check('generator-living-atlas', gen, backend.generatorVersions);
    await check('la-docker-compose', compose, _composeReleases, upstream: true);
    await check('ala-install', alaInstall, _alaInstallReleases, upstream: true);

    final LAProject p = projectModel(ref);
    final Json before = <String, dynamic>{
      'generator': p.generatorRelease,
      'dockerCompose': p.dockerComposeRelease,
      'alaInstall': p.alaInstallRelease,
    };
    if (gen != null) p.generatorRelease = gen;
    if (compose != null) p.dockerComposeRelease = compose;
    if (alaInstall != null) p.alaInstallRelease = alaInstall;
    final Json body = p.toApiJson();
    final Json lint = await _lintModel(
      p,
      hasSshKeys: (await backend.sshKeys()).isNotEmpty,
    );
    final Json preview = <String, dynamic>{
      'project': ref.dirName,
      'before': before,
      'after': <String, dynamic>{
        'generator': p.generatorRelease,
        'dockerCompose': p.dockerComposeRelease,
        'alaInstall': p.alaInstallRelease,
      },
      'genConfChanges': genConfDiff(
        ref.project['genConf'] as Json? ?? const <String, dynamic>{},
        body['genConf'] as Json,
      ),
      'hubs': <String>[
        for (final LAProject h in p.hubs) h.dirName ?? h.shortName,
      ],
      'lint': lint,
    };
    if (!save) return <String, dynamic>{...preview, 'saved': false};

    final File backup = await _backup(ref);
    await backend.updateProject(body);
    return <String, dynamic>{
      ...preview,
      'saved': true,
      'backup': backup.path,
      'next':
          'la_deploy with prepare: true checks out these releases and '
          'regenerates the inventories.',
    };
  }

  /// The project as `get-conf` returned it, before a save changes it.
  Future<File> _backup(ProjectRef ref) async {
    await backupDir.create(recursive: true);
    final String stamp = DateTime.now().toUtc().toIso8601String().replaceAll(
      RegExp(r'[:.]'),
      '-',
    );
    final File backup = File(
      '${backupDir.path}/${ref.dirName}-${ref.id}-$stamp.json',
    );
    await backup.writeAsString(
      const JsonEncoder.withIndent('  ').convert(ref.project),
    );
    return backup;
  }

  Future<Object?> _setPlacement(Map<String, Object?> a) async {
    final bool save = _saveArgs(a, 'changes where services run');
    final List<ServiceMove> changes;
    try {
      changes = parseChanges(a['changes']);
    } on FormatException catch (e) {
      throw InvalidRequest(e.message);
    }
    final ProjectRef ref = await _resolve(a);
    // Two models from the same stored JSON: whatever fromJson normalises
    // shows up on both sides and is not reported as part of the change.
    final LAProject before = projectModel(ref);
    final LAProject p = projectModel(ref);
    Map<String, LAReleases>? laReleases;
    try {
      final Map<String, String> query = depsVersionsQuery();
      laReleases = parseDepsVersions(await backend.depsVersions(query), query);
    } on Exception {
      // Only seeds versions of rows that are new, not moved.
      laReleases = null;
    }
    final PlacementChange change;
    try {
      change = changePlacement(p, changes, laReleases: laReleases);
    } on PlacementException catch (e) {
      throw InvalidRequest(e.message);
    }
    final Json preview = await _previewChange(
      ref,
      before,
      p,
      head: <String, dynamic>{
        'changes': change.moves.map(moveJson).toList(),
        if (change.clustersCreated.isNotEmpty)
          'composeClustersCreatedOn': change.clustersCreated,
        if (change.clustersDeleted.isNotEmpty)
          'composeClustersDeletedOn': change.clustersDeleted,
      },
      touched: <String>[
        for (final MovedService m in change.moves)
          if (m.to != null) m.to!.server.name,
        for (final MovedService m in change.moves)
          if (m.from != null) m.from!.server.name,
      ],
      removesComposeServices: change.moves.any(
        (MovedService m) =>
            m.from?.leg == PlacementLeg.docker && m.service != 'docker_compose',
      ),
    );
    return save ? _saveChange(ref, p, preview) : preview;
  }

  Future<Object?> _setServers(Map<String, Object?> a) async {
    final bool save = _saveArgs(a, 'changes the servers of the project');
    final ProjectRef ref = await _resolve(a);
    final List<Json> keys = await backend.sshKeys();
    final ({List<ServerSpec> add, List<ServerSpec> update, List<String> remove})
    args;
    try {
      args = parseServerChanges(a, keys);
    } on FormatException catch (e) {
      throw InvalidRequest(e.message);
    }
    if (args.add.isEmpty && args.update.isEmpty && args.remove.isEmpty) {
      throw InvalidRequest('Give at least one of add, update, remove.');
    }
    final LAProject before = projectModel(ref);
    final LAProject p = projectModel(ref);
    final ServerChange change;
    try {
      change = changeServers(
        p,
        add: args.add,
        update: args.update,
        remove: args.remove,
      );
    } on ServerChangeException catch (e) {
      throw InvalidRequest(e.message);
    }
    final List<String> warnings = serverNameClashes(
      allProjects(await backend.getProjects()),
      ref,
      p,
      <String>[...change.added, ...change.updated.keys],
    );
    warnings.addAll(missingKeyWarnings(p, change.added));
    final Json preview = await _previewChange(
      ref,
      before,
      p,
      head: <String, dynamic>{
        if (change.added.isNotEmpty)
          'added': <Json>[
            for (final String n in change.added) serverJson(p, n),
          ],
        if (change.updated.isNotEmpty)
          'updated': <String, dynamic>{
            for (final MapEntry<String, List<String>> e
                in change.updated.entries)
              e.key: <String, dynamic>{
                'fields': e.value,
                'before': serverJson(before, e.key),
                'after': serverJson(p, e.key),
              },
          },
        if (change.removed.isNotEmpty) 'removed': change.removed,
        if (change.notes.isNotEmpty) 'notes': change.notes,
        if (warnings.isNotEmpty) 'warnings': warnings,
      },
      touched: change.updated.keys.toList(),
      removesComposeServices: false,
    );
    if (save && change.added.isNotEmpty) {
      preview['next'] =
          'la_check_connectivity or la_check_preconditions for the new '
          'servers, then la_set_placement to give them services.';
    }
    return save ? _saveChange(ref, p, preview) : preview;
  }

  /// `save` needs `confirm`; answers whether to save.
  bool _saveArgs(Map<String, Object?> a, String what) {
    final bool save = a['save'] == true;
    if (save && a['confirm'] != true) {
      throw InvalidRequest(
        'save: true $what: pass confirm: true, and only once the user agreed '
        'to it.',
      );
    }
    return save;
  }

  /// What a change of servers or placement does to the project: which
  /// servers gain and lose services, the names that change host, the
  /// generator keys, integrity and lint, and what to deploy afterwards.
  Future<Json> _previewChange(
    ProjectRef ref,
    LAProject before,
    LAProject p, {
    required Json head,
    required List<String> touched,
    required bool removesComposeServices,
  }) async {
    final Json beforeConf = before.toApiJson()['genConf'] as Json;
    final Json afterConf = p.toApiJson()['genConf'] as Json;
    final List<String> integrityBefore = before.validateDataIntegrity();
    final List<String> newErrors = p
        .validateDataIntegrity()
        .where((String e) => !integrityBefore.contains(e))
        .toList();
    final List<String> unassignedBefore = before.servicesNotAssigned();
    final List<String> newlyUnassigned = p
        .servicesNotAssigned()
        .where((String s) => !unassignedBefore.contains(s))
        .toList();
    final bool hasKeys = (await backend.sshKeys()).isNotEmpty;
    final Json lint = lintDelta(
      await _lintModel(before, hasSshKeys: hasKeys),
      await _lintModel(p, hasSshKeys: hasKeys),
    );
    final Json servers = serverChanges(
      servicesByServer(before),
      servicesByServer(p),
    );
    final Json genConfChanges = genConfDiff(beforeConf, afterConf);
    final List<String> genConf = <String>[
      for (final String k in <String>['added', 'removed', 'changed'])
        ...(genConfChanges[k] as List<String>),
    ];
    final Json extraHosts = extraHostChanges(beforeConf, afterConf);
    final List<String> toDeploy = <String>{
      ...touched,
      ...servers.keys,
      ...extraHosts.keys,
    }.where((String n) => p.getServerByName(n) != null).toList();
    return <String, dynamic>{
      'project': ref.dirName,
      ...head,
      'servers': servers,
      'placement': <String, dynamic>{
        'before': <String, dynamic>{
          for (final MapEntry<String, Map<String, List<String>>> e
              in servicesByServer(before).entries)
            if (servers.containsKey(e.key)) e.key: e.value,
        },
        'after': <String, dynamic>{
          for (final MapEntry<String, Map<String, List<String>>> e
              in servicesByServer(p).entries)
            if (servers.containsKey(e.key)) e.key: e.value,
        },
      },
      'publicNames': publicNameChanges(beforeConf, afterConf),
      'extraHosts': extraHosts,
      'genConfChanges': genConfChanges,
      'integrityErrors': newErrors,
      if (newlyUnassigned.isNotEmpty) 'newlyUnassigned': newlyUnassigned,
      'lint': lint,
      'deployNotes': <String>[
        if (toDeploy.isEmpty)
          'Nothing to deploy for this change.'
        else
          'Nothing changed on the servers yet. Deploy, new hosts first: '
              '${toDeploy.join(', ')}'
              '${p.isHybrid ? ' (hybrid portal: la_deploy with leg: "docker" for the compose hosts, limitToServers for these)' : ''}'
              ', with prepare: true, dry run first.',
        if (extraHosts.isNotEmpty)
          'Compose hosts listed in extraHosts resolve a changed name to its '
              'old address until they are deployed again.',
        if (genConf.contains('LA_hubs') ||
            genConf.any((String k) => k.endsWith('_hostname')))
          'Hosts outside the compose stack (VMs, VM hubs) get the new '
              'addresses in /etc/hosts only on their next deploy.',
        if (newlyUnassigned.isNotEmpty)
          'Services unassigned here keep running where they were until '
              'stopped by hand.',
        if (removesComposeServices)
          'A compose host that loses services stops its next deploy at '
              "la-docker-compose's safety gate (validate-service-consistency) "
              'until it is run with -e allow_service_removal=true, which '
              'la_deploy does not pass: until then the old containers keep '
              'running there.',
      ],
      'saved': false,
    };
  }

  /// What the app does on every save (_updateProject), after a backup:
  /// store, then regenerate the toolkit's ssh config for the servers.
  Future<Json> _saveChange(ProjectRef ref, LAProject p, Json preview) async {
    final List<dynamic> errors = preview['integrityErrors'] as List<dynamic>;
    if (errors.isNotEmpty) {
      throw InvalidRequest(
        'Not saved: the change breaks the project integrity: '
        '${errors.join(' ')}',
      );
    }
    final File backup = await _backup(ref);
    await backend.updateProject(p.toApiJson());
    if (p.servers.isNotEmpty) {
      await backend.genSshConf(
        name: p.shortName,
        id: p.id,
        servers: p.toJson()['servers'] as List<dynamic>,
        user: p.getVariableValue('ansible_user')?.toString() ?? 'ubuntu',
      );
    }
    return <String, dynamic>{...preview, 'saved': true, 'backup': backup.path};
  }

  Future<Object?> _preconditions(Map<String, Object?> a) async {
    final ProjectRef ref = await _resolve(a);
    // A hub without servers of its own runs on its portal's.
    final bool onParent =
        ref.isHub &&
        (ref.project['servers'] as List<dynamic>? ?? <dynamic>[]).isEmpty;
    final Json target = onParent ? ref.parent! : ref.project;
    final List<Json> withServices = serversWithServices(target);
    final Object? leg = a['leg'];
    if (leg != null && leg != 'docker' && leg != 'vm') {
      throw InvalidRequest('`leg` must be "docker" or "vm".');
    }
    final List<String> composeHosts = composeHostNames(target);
    final List<String> only = a['servers'] == null
        ? <String>[]
        : (a['servers']! as List<dynamic>).cast<String>();
    final List<String> unknown = only
        .where((String n) => !withServices.any((Json s) => s['name'] == n))
        .toList();
    if (unknown.isNotEmpty) {
      throw InvalidRequest(
        'No server with services named ${unknown.join(', ')} in '
        '"${target['dirName']}".',
      );
    }
    final List<Json> servers = withServices.where((Json s) {
      final String n = s['name'] as String;
      if (only.isNotEmpty && !only.contains(n)) return false;
      if (leg == 'docker') return composeHosts.contains(n);
      if (leg == 'vm') return !composeHosts.contains(n);
      return true;
    }).toList();
    if (servers.isEmpty) {
      throw InvalidRequest(
        '"${target['dirName']}" has no servers with services assigned'
        '${leg != null || only.isNotEmpty ? ' among the ones asked for' : ''}.',
      );
    }
    final List<String> names = servers
        .map((Json s) => s['name'] as String)
        .toList();
    final ({List<String> hosts, bool authoritative}) public = publicHostnames(
      ref.project,
    );
    final List<String> hosts = public.hosts;

    final (
      Json conn,
      List<Json> disk,
      List<Json> keys,
      List<List<String>> ips,
    ) = await (
      backend.testConnectivity(servers),
      // Backends older than the disk-usage endpoint answer 404: report the
      // rest rather than failing the whole check.
      backend
          .diskUsage(target['id'] as String, names: names)
          .catchError(
            (Object e) => <Json>[],
            test: (Object e) => e is BackendException && e.statusCode == 404,
          ),
      backend.sshKeys(),
      Future.wait(hosts.map(resolve)),
    ).wait;

    final PreconditionReport r = evaluatePreconditions(
      project: target,
      servers: servers,
      connectivity: (conn['servers'] as List<dynamic>? ?? const <dynamic>[])
          .cast<Json>(),
      disk: disk,
      keys: keys,
      dns: <String, List<String>>{
        for (int i = 0; i < hosts.length; i++) hosts[i]: ips[i],
      },
      dnsAuthoritative: public.authoritative,
    );
    if (disk.isEmpty) {
      r.warnings.add(
        'Disk space not checked: this backend has no disk-usage endpoint (update la_toolkit_backend).',
      );
    }
    final int ignored =
        (target['servers'] as List<dynamic>).length - servers.length;
    return <String, dynamic>{
      'project': ref.dirName,
      if (onParent)
        'checkedOn':
            'portal ${target['dirName']} (the hub has no servers of its own)',
      ...r.toJson(),
      if (ignored > 0)
        'ignoredServers':
            '$ignored server(s) without services were not checked',
      'note': 'DNS is resolved from the toolkit host.',
    };
  }

  Future<Object?> _deploy(Map<String, Object?> a) async {
    final ProjectRef ref = await _resolve(a);
    final DeployRequest req = buildDeployRequest(ref, a);
    final Json p = ref.project;

    if (req.prepare) {
      await _refuseIfSomethingRuns(ref);
      final Json? genConf = p['genConf'] as Json?;
      if (genConf == null || genConf.isEmpty) {
        throw InvalidRequest(
          '"${ref.dirName}" has no saved generator configuration; open and save it '
          'once in the LA Toolkit UI.',
        );
      }
      if (p['alaInstallRelease'] is String) {
        await backend.alaInstallSelect(p['alaInstallRelease'] as String);
      }
      if (p['dockerComposeRelease'] is String) {
        await backend.dockerComposeSelect(p['dockerComposeRelease'] as String);
      }
      if (p['generatorRelease'] is String) {
        await backend.generatorSelect(p['generatorRelease'] as String);
      }
      // A hub's inventories live inside its portal's directory, so the
      // generation is addressed to the portal (Api.regenerateInv).
      await backend.regenerateInventories(
        ref.isHub ? ref.parent!['id'] as String : ref.id,
        genConf,
      );
      final List<dynamic> servers =
          p['servers'] as List<dynamic>? ?? <dynamic>[];
      if (servers.isNotEmpty) {
        await backend.genSshConf(
          name: p['shortName'] as String,
          id: ref.id,
          servers: servers,
          user: (genConf['LA_variable_ansible_user'] as String?) ?? 'ubuntu',
        );
      }
    }

    final Json started = await backend.ansiblew(
      id: ref.id,
      desc: req.desc,
      cmd: req.cmd,
    );
    final Json entry = started['cmdEntry'] as Json;
    // ansiblew also starts a ttyd viewer tailing the log, which the UI kills
    // when its console dialog closes. Nobody here will ever look at it, and
    // each one holds a port of the 2011-2100 pool until killed.
    if (started['port'] is int && started['ttydPid'] is int) {
      try {
        await backend.termClose(
          started['port'] as int,
          started['ttydPid'] as int,
        );
      } catch (_) {
        // A leaked viewer is not worth failing a deploy that already started.
      }
    }
    final Json out = <String, dynamic>{
      'runId': entry['id'],
      'dryRun': req.dryRun,
      'prepared': req.prepare,
      'command': entry['rawCmd'],
    };
    if (!req.dryRun) {
      return <String, dynamic>{
        ...out,
        'next':
            'Running detached. Poll la_deploy_status with this runId every few minutes.',
      };
    }
    // A dry run only echoes the ansible-playbook line; wait for it so the agent
    // can show the user exactly what a real run would execute.
    final Json results = await _waitFinished(
      entry,
      dryRunWait ?? const Duration(seconds: 30),
    );
    final Json summary = summarizeRun(entry, results);
    return <String, dynamic>{
      ...out,
      'verdict': summary['verdict'],
      if (summary['exitCode'] != null) 'exitCode': summary['exitCode'],
      if (summary['hint'] != null) 'hint': summary['hint'],
      'output': logTail(results, lines: 20),
    };
  }

  /// Preparing checks out ala-install / la-docker-compose / the generator in
  /// place: they are shared by every project, so doing it under a running
  /// deploy swaps its roles and playbooks mid-run. The UI allows that; an
  /// agent should not.
  Future<void> _refuseIfSomethingRuns(ProjectRef target) async {
    for (final ProjectRef r in allProjects(await backend.getProjects())) {
      for (final Json e in unfinishedRuns(r.project)) {
        if (await backend.deployStatus(
          e['logsPrefix'] as String,
          e['logsSuffix'] as String,
        )) {
          throw InvalidRequest(
            'Run ${e['id']} ("${e['desc']}") of "${r.dirName}" is still running. '
            'Preparing "${target.dirName}" would check out the shared ala-install / '
            'la-docker-compose repos under it. Wait for it (la_deploy_status), or '
            'pass prepare: false to reuse the current checkouts and inventories.',
          );
        }
      }
    }
  }

  Future<Json> _waitFinished(Json entry, Duration max) async {
    final Stopwatch sw = Stopwatch()..start();
    while (true) {
      final Json r = await backend.cmdResults(
        cmdHistoryEntryId: entry['id'] as String,
        logsPrefix: entry['logsPrefix'] as String,
        logsSuffix: entry['logsSuffix'] as String,
      );
      if (r['running'] != true || sw.elapsed >= max) return r;
      await Future<void>.delayed(const Duration(seconds: 1));
    }
  }

  Future<ProjectRef> _resolve(Map<String, Object?> a) async {
    final Object? ref = a['project'];
    if (ref is! String || ref.trim().isEmpty) {
      throw InvalidRequest('`project` is required (id, dirName or shortName).');
    }
    final List<Json> portals = await backend.getProjects();
    final ProjectRef? found = findProject(portals, ref);
    if (found == null) {
      final List<String> names = <String>[
        for (final Json p in portals) ...<String>[
          p['dirName'] as String,
          for (final Json h in (p['hubs'] as List<dynamic>).cast<Json>())
            h['dirName'] as String,
        ],
      ];
      throw InvalidRequest('No project "$ref". Known: ${names.join(', ')}.');
    }
    return found;
  }

  Json _entry(ProjectRef ref, String? runId) {
    final Json? e = findRun(ref.project, runId);
    if (e == null) {
      throw InvalidRequest(
        runId == null
            ? '"${ref.dirName}" has no runs yet.'
            : 'No run "$runId" in "${ref.dirName}"; see la_list_runs.',
      );
    }
    return e;
  }

  Future<(Json, Json)> _runResults(Map<String, Object?> a) async {
    final ProjectRef ref = await _resolve(a);
    final Json entry = _entry(ref, a['runId'] as String?);
    final Json r = await backend.cmdResults(
      cmdHistoryEntryId: entry['id'] as String,
      logsPrefix: entry['logsPrefix'] as String,
      logsSuffix: entry['logsSuffix'] as String,
    );
    return (entry, r);
  }

  void _tool(
    String name,
    String description,
    ObjectSchema schema,
    FutureOr<Object?> Function(Map<String, Object?> args) body, {
    bool readOnly = false,
    bool destructive = false,
    bool openWorld = false,
  }) {
    registerTool(
      Tool(
        name: name,
        description: description,
        inputSchema: schema,
        annotations: ToolAnnotations(
          readOnlyHint: readOnly,
          destructiveHint: destructive,
          openWorldHint: openWorld,
        ),
      ),
      (CallToolRequest request) async {
        try {
          final Object? result = await body(
            request.arguments ?? <String, Object?>{},
          );
          return CallToolResult(
            content: <Content>[
              TextContent(
                text: const JsonEncoder.withIndent('  ').convert(result),
              ),
            ],
          );
        } on InvalidRequest catch (e) {
          return _error(e.message);
        } on BackendException catch (e) {
          return _error(e.toString());
        } on TimeoutException {
          return _error(
            'The LA Toolkit backend at ${backend.baseUri} did not answer in time.',
          );
        } catch (e) {
          return _error('${e.runtimeType}: $e');
        }
      },
    );
  }

  CallToolResult _error(String message) => CallToolResult(
    isError: true,
    content: <Content>[TextContent(text: message)],
  );
}
