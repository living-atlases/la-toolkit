# Releasing la-toolkit

The release is manual — there is no CI for it. That is workable, but it means every
step below is a step that can be forgotten, and one of them has been: 1.7.0 shipped
with `latest` still resolving to the 1.6.9 image, so every fresh install got a 1.7.0
`docker-compose.yml` (mongo:8) driving a 1.6.x backend that still vendored
`mongodb-core`. It restart-looped on
`Unsupported OP_QUERY command: listCollections`, and it took an external report to
find out.

Order matters: the image build downloads the frontend from the GitHub release, so
the release has to exist before the image can be built.

## 1. Frontend

- Bump `version:` in `pubspec.yaml`.
- `./build.sh` — runs the tests, builds Flutter web, and writes
  `flutter-web-<version>.tgz`.

## 2. GitHub release

- Tag `vX.Y.Z` and create the release.
- Upload `flutter-web-X.Y.Z.tgz` as a release asset.

The `curl` in the Dockerfile uses `-f`, so if the asset is missing the build fails
instead of unpacking GitHub's error page into the assets directory. Do not remove it.

## 3. Image

In `docker/u22/Dockerfile`:

- Bump the cache buster above the backend clone (`RUN echo "X.Y.Z-dN"`). This is
  load-bearing, not decoration: the clone is `--depth 1` from the backend's default
  branch and is not pinned to a tag, so without a bump Docker reuses the cached layer
  and ships the *previous* backend.
- Point the frontend `curl` at the release asset you just uploaded.

Then build and push. Push **both** tag spellings — every release up to 1.6.9 used the
`v` form, 1.7.0 was first published without it, and the pinning advice in
`docs/mongodb-4-to-8-upgrade.md` leads people to write `:vX.Y.Z`:

```bash
docker build . -f ./docker/u22/Dockerfile -t livingatlases/la-toolkit:X.Y.Z
docker tag livingatlases/la-toolkit:X.Y.Z livingatlases/la-toolkit:vX.Y.Z
docker push livingatlases/la-toolkit:X.Y.Z
docker push livingatlases/la-toolkit:vX.Y.Z
```

## 4. Decide about `latest` — do not do it on autopilot

`docker-compose.yml` ships with a `watchtower` container that polls hourly and
updates images by itself. Moving `latest` therefore upgrades every unpinned
installation in the wild within the hour, without anyone deciding to.

For a release that only changes the toolkit, that is fine. For one that changes
something underneath it, it is not: 1.7.0 also moved MongoDB from 4 to 8, and
MongoDB 8 refuses to start on MongoDB 4 data files. `latest` was deliberately left on
1.6.9 for that release rather than pushing every existing installation into an
unattended migration.

So: if the release needs the operator to do anything by hand, leave `latest` where it
is and say so in the release notes.

## 5. Pin the compose file

Bump the `image:` tag in `docker-compose.yml` to the new version. This is what a
first-time installer gets, and it is what keeps the compose file and the image in
step regardless of what `latest` points at.

## 6. Verify, from the outside

Digests, not tag names:

```bash
docker manifest inspect livingatlases/la-toolkit:X.Y.Z  | sha256sum
docker manifest inspect livingatlases/la-toolkit:vX.Y.Z | sha256sum   # must match
docker manifest inspect livingatlases/la-toolkit:latest | sha256sum   # is this what you intended?
```

Then a genuine cold start, on an empty data directory, which is the case that broke:

```bash
docker compose down && sudo rm -rf /data/la-toolkit/mongo/* && docker compose up -d
docker compose ps                      # mongo healthy, la-toolkit up and not restarting
docker compose logs la-toolkit | grep -i 'authentication failed'    # empty
```

Not a running installation of your own — those have an initialized database and will
hide exactly the class of failure that first-time users hit.

### Do not read the backend's package.json as a version

`la-toolkit-backend` never bumps its own version, so the backend inside the image
reports whatever it last happened to be set to — it read `1.7.0` in the 1.7.1 image
and will keep reading `1.7.0` in the ones after it. That discrepancy looks exactly
like a stale cached layer, and it is not.

What the file does tell you is that the clone is *fresh*, since a cached layer would
carry an older tree. For "what does this running image actually contain", the commit
is the honest answer — the `--depth 1` clone keeps enough history for it:

```bash
docker run --rm --entrypoint /bin/bash livingatlases/la-toolkit:X.Y.Z \
  -c 'cd /home/ubuntu/la-toolkit && git log -1 --format="%H %cd %s"'
```
