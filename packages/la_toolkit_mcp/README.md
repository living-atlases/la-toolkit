# la_toolkit_mcp

An [MCP](https://modelcontextprotocol.io) server that lets an AI agent (Claude Code,
Claude Desktop, or any MCP client) operate an LA Toolkit: list portals, run a dry run,
deploy, follow the run and explain why it failed.

It adds no logic of its own to the toolkit. Every tool is a thin composition of the
backend REST endpoints the Flutter app already calls, with the same payloads, so the
backend cannot tell an agent-driven deploy from one started in the UI, and every run
shows up in the project history like any other.

## Tools

| Tool | What it does | Changes anything? |
|---|---|---|
| `la_list_projects` | Portals and hubs, with their deploy mode (docker-compose / vm / hybrid) | no |
| `la_get_project` | Servers, releases, which services run where, recent runs | no |
| `la_list_runs` | Command history, newest first | no |
| `la_check_connectivity` | ping, ssh, sudo and OS of every server | read-only ssh on the servers; saves the results on the project, like the UI |
| `la_deploy` | Dry run (default) or real deploy | see below |
| `la_deploy_status` | running / success / failed / aborted / cancelled, per-host recap, current task | no |
| `la_deploy_failures` | Failed tasks with their error, never the full log | no |
| `la_deploy_cancel` | Stops a running deploy; needs `confirm: true` | yes |

### How `la_deploy` stays safe

- **Dry run by default.** `ansiblew` without `--nodryrun` only echoes the
  `ansible-playbook` line. The tool waits for it and returns that line, so the agent can
  show the user exactly what a real run would execute.
- **A real run needs `dryRun: false` and `confirm: true`.** The server refuses the first
  without the second. MCP gives a server no way to ask the user itself, so the contract
  is spelled out in the tool description and the server instructions: `confirm` is only
  set after the user agreed.
- **Every list argument is whitelisted** (`^[A-Za-z0-9][A-Za-z0-9._-]*$`). `ansiblew`
  runs its final line through `sh -c`, dry run included, and the backend pastes tags,
  services and hosts into it unquoted: a `;` would run on the toolkit host, and a
  service named `--nodryrun` would turn a dry run into a real one.
- **Preparing** (checking out the project's pinned ala-install / la-docker-compose /
  generator, regenerating inventories and ssh config) is on by default for real deploys
  only. The UI also does it before dry runs, but those checkouts are shared by every
  project (`git checkout -f`, `reset --hard`, `npm install -g`), so a dry run on a
  project pinning another release would move them for everybody. A dry run on a project
  whose inventories were never generated ends with exit 127 and a hint to retry with
  `prepare: true`. Either way the tool refuses to prepare while any run of the last 24 h
  is still going.
- The ttyd viewer the backend starts for every run is closed right away. The deploy is
  detached and does not depend on it; left open, each one would hold a port of the
  2011-2100 pool.

### Not supported yet

- Hybrid projects (VM + docker-compose). The UI splits them into two legs; use it.
- A docker-compose hub on its own: it deploys as part of its portal's stack.
- Service health checks (`test-host-services`): which ports and URLs to probe on each
  server comes from the service catalogue in the Flutter models (`BasicService.tcp`,
  `ProdServiceDesc`, `LAProject.serverServicesToMonitor()`); rebuilding it here would
  duplicate that catalogue. It comes with the shared core package.
- Creating projects. Same reason: project validation lives in the Flutter app today.

## Setup

The backend API has **no authentication**, so run this server on the same machine as the
toolkit and talk to it over stdio. Do not put it behind a public HTTP endpoint.

```bash
cd packages/la_toolkit_mcp
dart pub get
dart compile exe bin/la_toolkit_mcp.dart -o la_toolkit_mcp
```

Register it in Claude Code (use `http://localhost:1337` for a backend running natively
in development; the production image listens on 2010):

```bash
claude mcp add la-toolkit -- /path/to/la_toolkit_mcp --backend http://localhost:2010
```

Or point any MCP client at the command, with the backend in `LA_TOOLKIT_BACKEND`.

## Development

```bash
dart analyze
dart test
```

`test/server_test.dart` drives the server over the MCP protocol against a fake backend;
the other suites cover the pure helpers (argument validation, project lookup, failure
extraction from the ansible JSON callback and from the log).
