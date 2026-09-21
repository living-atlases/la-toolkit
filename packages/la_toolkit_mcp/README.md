# la_toolkit_mcp

An [MCP](https://modelcontextprotocol.io) server that lets an AI agent (Claude Code,
Claude Desktop, or any MCP client) operate an LA Toolkit: list portals, run a dry run,
deploy, follow the run and explain why it failed.

It adds no logic of its own to the toolkit. Every tool is a thin composition of the
backend REST endpoints the Flutter app already calls and of the app's own models and
lint (`packages/la_toolkit_core`), with the same payloads, so the
backend cannot tell an agent-driven deploy from one started in the UI, and every run
shows up in the project history like any other.

## Tools

| Tool | What it does | Changes anything? |
|---|---|---|
| `la_list_projects` | Portals and hubs, with their deploy mode (docker-compose / vm / hybrid) | no |
| `la_get_project` | Servers, releases, which services run where, recent runs | no |
| `la_lint_project` | The warnings of the UI lint panel: placement, cluster sizes, services that need each other, releases the dependency matrix rejects. Never `clean` when the matrix could not be read | no |
| `la_create_project` | A new docker-compose portal on 1-3 hosts from domain, names, hosts and ssh key, built on a la-docker-compose topology its CI checks (`1host`, `2host`, `default-3host` by host count, or the one named). Previews by default (validation, lint, public names, the `skipServices` to deploy with); `save` + `confirm` store it | only with `save` + `confirm`: adds the project to the toolkit, touches no server |
| `la_list_runs` | Command history, newest first | no |
| `la_check_connectivity` | ping, ssh, sudo and OS of every server | read-only ssh on the servers; saves the results on the project, like the UI |
| `la_check_preconditions` | Blockers before a deploy, for the servers that carry services: ssh key in the toolkit, ssh and sudo, Ubuntu >= 22.04, disk space (`/`, `/data`, `/var/lib/docker`), portal host names resolve | read-only ssh; saves connectivity results like the UI |
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

### Preconditions

- Only servers with services assigned (directly, or as the carrier of a docker-compose
  cluster) are checked; projects often keep retired VMs.
- Disk needs the backend's `POST /api/v1/disk-usage` (la_toolkit_backend, added with this
  tool). An older backend only yields a warning. Below 10 GB free or at 90% use a
  filesystem blocks: pulling the compose images alone takes several GB.
- DNS is resolved from the toolkit host. For docker-compose projects the host names are
  the nginx vhosts the generator computed (`LA_nginx_docker_internal_aliases_by_host`),
  and a name that does not resolve blocks. Other projects fall back to the URL of every
  service in use, which also names internal services without a vhost, so there it is
  only a warning. An address that is not one of the project's servers is fine (proxy,
  NAT) and only reported.

### Not supported yet

- Hybrid projects (VM + docker-compose). The UI splits them into two legs; use it.
- A docker-compose hub on its own: it deploys as part of its portal's stack.
- Service health checks (`test-host-services`): the catalogue of ports and URLs is now
  in the core (`BasicService.tcp`, `ProdServiceDesc`,
  `LAProject.serverServicesToMonitor()`), the tool is not written yet.
- Creating hubs, and layouts no la-docker-compose topology covers.
- `validate-topology.yml` (it needs an ansible run the backend exposes no endpoint for);
  the core validation and lint run instead.

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
