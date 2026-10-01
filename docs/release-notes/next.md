Two people (or a person and an AI agent) can now work on the same project at the same time without undoing each other, the toolkit can be driven by an AI agent through an MCP server that ships in the image, and data hubs can live on their portal's docker-compose stack.

## Action needed: backups

**Your toolkit has probably not been backing up its database since 2026-09-09.** The backup sidecar in `docker-compose.yml` used `tiredofit/db-backup:latest`; that project moved to `nfrastack/db-backup` and its `:latest` became an image that only prints a deprecation notice. `watchtower` pulled it, and the container kept showing as running while writing nothing. It also never deleted an old backup: the cleanup setting was misspelled and ignored.

`docker-compose.yml` is a file from this repository, not part of the image, so **pulling the new image does not fix this**. Copy the `mongo-db-backup` service from the current `docker-compose.yml` (pinned to `nfrastack/db-backup:4.9.2`, 30 days of retention) into yours. Its first run deletes every backup older than 30 days, years of them on an old installation, so move aside any you want to keep first. [Upgrading](https://github.com/living-atlases/la-toolkit/blob/master/docs/upgrading.md#every-installation-backups-stopped-on-2026-09-09) has the commands to check, move and restore.

## `:latest` is still 1.6.9

Unchanged from 1.7.x: `:latest` stays on 1.6.9 so that `watchtower` does not move an unpinned MongoDB 4 installation onto MongoDB 8 by itself. Pin the version you want; both `X.Y.Z` and `vX.Y.Z` are published.

## Working on a project together

Until now a save sent the whole project, so a browser holding an older copy deleted the servers and services another session had added meanwhile, and nobody saw other people's changes without reloading the page.

- **Live updates.** The open project refreshes by itself when another browser or the MCP saves it, and so do deploy, check and history results.
- **Saves send only what changed.** Changes to different settings, servers or services are merged on the server, so both are kept.
- **Real conflicts are refused, never overwritten.** If someone else changed the same setting, nothing is written and a banner offers *Reload* to see their version.
- **Presence.** A bar shows when the project is also open in another browser, and whether it is being edited, tuned or deployed there.

After upgrading, reload any browser tab that was open on the old version: an old tab still saves the whole project.

## An MCP server in the image

`la_toolkit_mcp` (at `/usr/local/bin/la_toolkit_mcp` in the image) lets an AI agent (Claude Code, or any MCP client) list and inspect projects, check preconditions (DNS, ssh key, ssh and sudo access, disk space), lint, create a portal from a la-docker-compose topology, add or change servers, move services between them, change releases, and run, follow and cancel deploys. Every change is a preview first and needs an explicit confirmation to save; each save keeps a backup that `la_restore_backup` can put back. See [the MCP README](https://github.com/living-atlases/la-toolkit/blob/master/packages/la_toolkit_mcp/README.md).

## docker-compose portals and data hubs

- A data hub can be placed on its portal's docker-compose clusters, by reference: the hub no longer copies the portal's servers, which used to take the cluster away from the portal. Hubs that only run on the portal's stack hide the tools that assume servers of their own.
- The lint now checks the la-docker-compose release against the dependency matrix (la-docker-compose 1.4.0 and later need la-generator 1.9.7).
- A docker cluster left without a server under it is reported at validation, not at deploy time.
- A public name served by the compose stack is no longer mapped to a VM in another compose host's `/etc/hosts`.
- The sample project is the docker-compose topology the la-docker-compose CI deploys.

## Fixes

- **Terminals did not work on a fresh install** (`read_cb: EIO`): `~/.ssh/config` was only built after a connectivity check.
- **Long deploys could hang forever** when an idle ssh connection was dropped by a NAT or firewall during a quiet task (a docker pull). ssh now sends keepalives.
- **A version dropdown left untouched deployed a different version** than the one it showed.
- **New data hubs failed at Finish** with "Would violate uniqueness constraint".
- **The backend reported the previous version**, so every 1.7.1 install was told to upgrade to the version it was running.
- The ala-namematching-server version list was empty, which made the pipelines dependency lint fire on every project.
- The default branding path lost the project name (`../-branding`).
- The biocache-service 2.x constraint no longer pulls biocache-cli for 3.x.
- The CARTO basemaps API key can be set in the Tune page.
- The backend-less demo builds and saves again.
