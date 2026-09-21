import 'dart:async';
import 'dart:convert';

import 'package:dart_mcp/server.dart';

import 'backend_client.dart';
import 'deploy_outcome.dart';
import 'deploy_request.dart';
import 'projects.dart';

const String _instructions = '''
Drives an LA Toolkit (Living Atlas deployment tool) through its backend API.

Typical flow to update a portal:
1. la_list_projects, then la_get_project to see servers, placement and history.
2. la_deploy with dryRun: true (the default). It prints the exact ansible
   command and changes nothing. Show it to the user. If it reports exit 127,
   the inventories were never generated: retry with prepare: true, which
   checks out the project's pinned releases in the toolkit (shared by all
   projects) and regenerates them; ask the user first.
3. Only if the user agrees, la_deploy with dryRun: false and confirm: true. It
   returns a runId immediately; deploys take from minutes to hours.
4. Poll la_deploy_status (every few minutes, not seconds). When the verdict is
   failed, la_deploy_failures gives the failed tasks without the full log.

Never pass confirm: true without the user's explicit agreement for that run.''';

final Schema _projectArg = Schema.string(
  description: 'Project id, dirName or shortName (portals and hubs).',
);

final Schema _runIdArg = Schema.string(
  description: 'Run id from la_deploy or la_list_runs. Defaults to the latest run.',
);

Schema _tokenList(String description) =>
    Schema.list(description: description, items: Schema.string());

/// The MCP server. Every tool is a thin composition of [BackendClient] calls
/// and the pure helpers in `projects.dart` / `deploy_*.dart`.
base class LaToolkitMcpServer extends MCPServer with ToolsSupport {
  LaToolkitMcpServer(super.channel, {required this.backend, this.dryRunWait})
    : super.fromStreamChannel(
        implementation: Implementation(name: 'la-toolkit', version: '0.1.0'),
        instructions: _instructions,
      ) {
    _register();
  }

  final BackendClient backend;

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
      Schema.object(properties: <String, Schema>{'project': _projectArg}, required: <String>['project']),
      readOnly: true,
      (Map<String, Object?> a) async => projectDetails(await _resolve(a)),
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
      Schema.object(properties: <String, Schema>{'project': _projectArg}, required: <String>['project']),
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
      'la_deploy',
      'Deploy a project with ansible (docker-compose or VM, not hybrid). '
          'dryRun defaults to true and only prints the command. A real deploy '
          'needs dryRun: false AND confirm: true, and must only be requested after '
          'the user explicitly agreed. Returns a runId at once; poll la_deploy_status.',
      Schema.object(
        properties: <String, Schema>{
          'project': _projectArg,
          'dryRun': Schema.bool(description: 'Only print the command (default true).'),
          'confirm': Schema.bool(
            description: 'Required with dryRun: false. Set it only when the user agreed to this deploy.',
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
          'onlyProperties': Schema.bool(description: 'Only regenerate service configuration.'),
          'continueEvenIfFails': Schema.bool(),
          'debug': Schema.bool(description: 'Verbose ansible output.'),
          'prepare': Schema.bool(
            description: 'Check out the pinned releases and regenerate inventories and '
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
        properties: <String, Schema>{'project': _projectArg, 'runId': _runIdArg},
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
          'max': Schema.int(description: 'Max failed tasks to return (default 8, latest ones).'),
        },
        required: <String>['project'],
      ),
      readOnly: true,
      (Map<String, Object?> a) async {
        final (Json entry, Json results) = await _runResults(a);
        final List<Json> failed = failedTasks(results, max: (a['max'] as int?) ?? 8);
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
          'confirm': Schema.bool(description: 'Must be true; set it only when the user asked to cancel.'),
        },
        required: <String>['project', 'confirm'],
      ),
      destructive: true,
      (Map<String, Object?> a) async {
        if (a['confirm'] != true) {
          throw InvalidRequest('Cancelling needs confirm: true, set only when the user asked for it.');
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
      await backend.regenerateInventories(ref.isHub ? ref.parent!['id'] as String : ref.id, genConf);
      final List<dynamic> servers = p['servers'] as List<dynamic>? ?? <dynamic>[];
      if (servers.isNotEmpty) {
        await backend.genSshConf(
          name: p['shortName'] as String,
          id: ref.id,
          servers: servers,
          user: (genConf['LA_variable_ansible_user'] as String?) ?? 'ubuntu',
        );
      }
    }

    final Json started = await backend.ansiblew(id: ref.id, desc: req.desc, cmd: req.cmd);
    final Json entry = started['cmdEntry'] as Json;
    // ansiblew also starts a ttyd viewer tailing the log, which the UI kills
    // when its console dialog closes. Nobody here will ever look at it, and
    // each one holds a port of the 2011-2100 pool until killed.
    if (started['port'] is int && started['ttydPid'] is int) {
      try {
        await backend.termClose(started['port'] as int, started['ttydPid'] as int);
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
        'next': 'Running detached. Poll la_deploy_status with this runId every few minutes.',
      };
    }
    // A dry run only echoes the ansible-playbook line; wait for it so the agent
    // can show the user exactly what a real run would execute.
    final Json results = await _waitFinished(entry, dryRunWait ?? const Duration(seconds: 30));
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
        if (await backend.deployStatus(e['logsPrefix'] as String, e['logsSuffix'] as String)) {
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
          for (final Json h in (p['hubs'] as List<dynamic>).cast<Json>()) h['dirName'] as String,
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
          final Object? result = await body(request.arguments ?? <String, Object?>{});
          return CallToolResult(
            content: <Content>[
              TextContent(text: const JsonEncoder.withIndent('  ').convert(result)),
            ],
          );
        } on InvalidRequest catch (e) {
          return _error(e.message);
        } on BackendException catch (e) {
          return _error(e.toString());
        } on TimeoutException {
          return _error('The LA Toolkit backend at ${backend.baseUri} did not answer in time.');
        } catch (e) {
          return _error('${e.runtimeType}: $e');
        }
      },
    );
  }

  CallToolResult _error(String message) =>
      CallToolResult(isError: true, content: <Content>[TextContent(text: message)]);
}
