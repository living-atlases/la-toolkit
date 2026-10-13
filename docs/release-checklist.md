# Releasing la-toolkit

Jenkins builds, checks and publishes the image (`Jenkinsfile`, job `la-toolkit`, polling
every 15 minutes):

| Pushed               | Image                                         |
|----------------------|-----------------------------------------------|
| a commit on master   | `livingatlases/la-toolkit:dev`                |
| a `vX.Y.Z` tag       | `livingatlases/la-toolkit:X.Y.Z` and `:vX.Y.Z` |

Every build runs the core, MCP and Flutter suites (the `mcp-test` and `web-test` targets
of `docker/u22/Dockerfile`), builds the image with the frontend and the MCP server from
the checkout and the backend from its own repo, and then `docker/ci/smoke.sh`: the
backend suite inside the image, a cold start on an empty `mongo:8` initialised as
`docker-compose.yml` does, the version the backend reports, the docker client of the fast
deploy and an MCP `initialize`. Nothing is pushed unless all of it passes, and the tags of
one build are checked to be the same digest.

## 1. Prepare, on master

- Release notes: rename `docs/release-notes/next.md` to `docs/release-notes/vX.Y.Z.md`.
- `version:` in `pubspec.yaml` to `X.Y.Z`.
- `version` in `la-toolkit-backend/package.json` to `X.Y.Z`.
- The `image:` of the `la-toolkit` service in `docker-compose.yml` to `X.Y.Z`. That is
  what a first-time installer gets, whatever `latest` points at.
- Push both repos and wait for the `dev` build to go green: it is the same build the tag
  will run.

## 2. Tag both repos

Tag the backend first, then the frontend, on the commits just pushed:

```bash
git -C ../la_toolkit_backend tag -a vX.Y.Z -m vX.Y.Z && git -C ../la_toolkit_backend push origin vX.Y.Z
git tag -a vX.Y.Z -m vX.Y.Z && git push origin vX.Y.Z
```

The release build stops in its first stage (`docker/ci/resolve.sh`) unless the tag,
`pubspec.yaml` and the backend's `package.json` at its own `vX.Y.Z` tag all say `X.Y.Z`,
and it builds the image from that backend tag. This is not bookkeeping: the frontend asks
the backend for its version (`GET /api/v1/get-backend-version`, which returns
`package.json`) and compares it with the newest GitHub release. 1.7.1 shipped a backend
still saying `1.7.0`, so every 1.7.1 install was told to upgrade to the version it was
already running. The same number picks the `la-toolkit:` bucket of the backend's
`assets/dependencies.yaml`, so a stale one also recommends the wrong generator.

## 3. GitHub release and changelog

After pushing the images, the release build creates the GitHub release of the tag with
`docs/release-notes/vX.Y.Z.md` as its body (`docker/ci/github-release.sh`, credential
`github-la-toolkit-release`: a token with Contents read and write on this repo), or
updates it on a rebuild. A tag without that file fails in the first stage. The release
matters: the upgrade banner compares against the newest GitHub release, not Docker Hub.

Then regenerate the changelog (it needs the backend checkout next to this one) and push:

```bash
scripts/gen-changelog.py > CHANGELOG.md
bash scripts/test-gen-changelog.sh
```

## 4. Decide about `latest`, never on autopilot

`docker-compose.yml` ships a `watchtower` container that polls hourly and updates images
by itself. Moving `latest` therefore upgrades every unpinned installation in the wild
within the hour, without anyone deciding to.

For a release that only changes the toolkit, that is fine. For one that changes
something underneath it, it is not: 1.7.0 also moved MongoDB from 4 to 8, and MongoDB 8
refuses to start on MongoDB 4 data files. `latest` was deliberately left on 1.6.9 for
that release rather than pushing every existing installation into an unattended
migration.

So CI never moves it by itself. To move it, run the job with `PROMOTE_VERSION=X.Y.Z`: it
only points `latest` at that published release, the same digest, and checks they match;
nothing is rebuilt. Before that, try the upgrade an unpinned installation will get: the
oldest compose file still around (1.6.9, with `mongo:4`) recreated with the new image and
its volumes must start, keep its projects and save a change. If the release needs the
operator to do anything by hand, leave `latest` where it is and say so in the release
notes.

## 5. Check from the outside

The build log ends with the digest every pushed tag resolves to. From any machine:

```bash
docker buildx imagetools inspect livingatlases/la-toolkit:X.Y.Z  --format '{{json .Manifest.Digest}}'
docker buildx imagetools inspect livingatlases/la-toolkit:vX.Y.Z --format '{{json .Manifest.Digest}}'   # same
docker buildx imagetools inspect livingatlases/la-toolkit:latest --format '{{json .Manifest.Digest}}'   # is this what you intended?
```

The image's labels say what it was built from: `org.opencontainers.image.revision` (this
repo) and `la-toolkit.backend.revision` (the backend).
