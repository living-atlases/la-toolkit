# Connect your AI agent to the toolkit and the knowledge base

Do this once, before giving your agent the
[portal setup prompt](agent-portal-setup.md). The agent needs two
[MCP](https://modelcontextprotocol.io) servers:

| Server | What it gives the agent | Where it runs |
|---|---|---|
| `la-toolkit` | Tools to operate the LA Toolkit: projects, placement, deploys | Next to your toolkit, over stdio |
| `living-atlas-kb` | Search over Living Atlas documentation, source code, issues and release notes | Public service at `https://kb.l-a.site/mcp`, no account needed |

The commands below are for Claude Code. Other clients are covered in
[Other MCP clients](#other-mcp-clients).

## 1. Install the toolkit

It can run on a small server or a laptop, as long as it reaches the portal machines over ssh.

```bash
mkdir -p /data/la-toolkit/config/ /data/la-toolkit/logs/ /data/la-toolkit/ssh/ /data/la-toolkit/mongo /data/la-toolkit/backups
```

```bash
git clone https://github.com/living-atlases/la-toolkit.git
```

Read the comments in `la-toolkit/docker-compose.yml` and **change the default passwords before
the first start**. Then, from that directory:

```bash
docker compose up -d
```

The interface is at http://localhost:2010/. The
[toolkit README](https://github.com/living-atlases/la-toolkit#readme) has the details.

## 2. Register the toolkit MCP server

From 1.8.0 the toolkit image ships the server, so there is nothing to build. On the machine that
runs the toolkit:

```bash
claude mcp add --scope user la-toolkit -- docker exec -i la-toolkit la_toolkit_mcp
```

If the agent runs on another machine, go through ssh. That user needs access to docker there:

```bash
claude mcp add --scope user la-toolkit -- ssh toolkit-host docker exec -i la-toolkit la_toolkit_mcp
```

- Use `-i`, never `-t`: a terminal corrupts the protocol stream.
- The server speaks stdio only. The backend API has no authentication, so **never expose the
  toolkit or its MCP server over public HTTP**.
- Keep the toolkit up to date, so the MCP server and the backend come from the same release. An
  older backend ignores some options, such as `allowServiceRemoval`.

## 3. Register the knowledge base

```bash
claude mcp add --scope user --transport http living-atlas-kb https://kb.l-a.site/mcp
```

It is a public remote service: whatever the agent asks it leaves your network. The prompt tells
the agent to keep hostnames, IPs, logs and secrets out of its questions.

## 4. Check the connection

```bash
claude mcp list
```

Both servers must say `Connected`. Then start a new session, so the tools load.

## 5. Permissions

Allow the tools that only read, so the agent can follow a long deploy without being blocked, and
search without asking each time. In `~/.claude/settings.json`:

```json
{
  "permissions": {
    "allow": [
      "mcp__la-toolkit__la_list_projects",
      "mcp__la-toolkit__la_get_project",
      "mcp__la-toolkit__la_lint_project",
      "mcp__la-toolkit__la_list_runs",
      "mcp__la-toolkit__la_deploy_status",
      "mcp__la-toolkit__la_deploy_failures",
      "mcp__living-atlas-kb__query_ala_kb",
      "mcp__living-atlas-kb__answer_ala_kb",
      "mcp__living-atlas-kb__list_ala_kb_collections",
      "mcp__living-atlas-kb__get_ala_component_versions",
      "mcp__living-atlas-kb__get_ala_test_coverage"
    ]
  }
}
```

Leave the other `la_*` tools out, so each of them still asks. The prefix is
`mcp__<name>__`, with the name the server was registered under.

## Other MCP clients

Most clients take a JSON configuration like this one. For the ssh variant, change `command` and
`args` to match the command in step 2.

```json
{
  "mcpServers": {
    "la-toolkit": {
      "command": "docker",
      "args": ["exec", "-i", "la-toolkit", "la_toolkit_mcp"]
    },
    "living-atlas-kb": {
      "type": "http",
      "url": "https://kb.l-a.site/mcp"
    }
  }
}
```

The formats differ a little between clients. The
[kb README](https://github.com/living-atlases/kb#readme) shows them for the knowledge base.

## More

- Every tool of the toolkit server, and how it stays safe:
  [la_toolkit_mcp README](../packages/la_toolkit_mcp/README.md).
- If the agent still has no `la_*` tools, run `docker ps` and check that `la-toolkit` is up.
