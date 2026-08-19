# Releasing la-toolkit

The release is manual — there is no CI for it. That is workable, but it means every
step below is a step that can be forgotten, and one of them has been: 1.7.0 shipped
with `latest` still resolving to the 1.6.9 image, so every fresh install got a 1.7.0
`docker-compose.yml` (mongo:8) driving a 1.6.x backend that still vendored
`mongodb-core`. It restart-looped on
`Unsupported OP_QUERY command: listCollections`, and it took an external report to
find out.

Order matters, in both directions: the image build downloads the frontend from the
GitHub release, so the release has to exist first, and it clones the backend from
master, so the backend's version bump has to be pushed first too.

## 1. Frontend

- Bump `version:` in `pubspec.yaml`.
- `./build.sh` — runs the tests, builds Flutter web, and writes
  `flutter-web-<version>.tgz`.

## 2. GitHub release

- Tag `vX.Y.Z` and create the release.
- Upload `flutter-web-X.Y.Z.tgz` as a release asset.

The `curl` in the Dockerfile uses `-f`, so if the asset is missing the build fails
instead of unpacking GitHub's error page into the assets directory. Do not remove it.

## 3. Backend version

Bump `version` in `la-toolkit-backend/package.json` to the same `X.Y.Z` and push it to
master **before** building the image.

This is a real check, not bookkeeping. The frontend asks the backend for its version
(`GET /api/v1/get-backend-version`, which just returns `package.json`) and compares it
against the newest GitHub release; when the backend reports something older it shows
*"There is a new version the LA-Toolkit available"* to every user, forever. That is
exactly what 1.7.1 shipped: the backend still said `1.7.0`, so every 1.7.1 install was
told to upgrade to the version it was already running.

The same number decides which `la-toolkit:` bucket of `assets/dependencies.yaml` the
lint applies, so a stale one also recommends the wrong `la-generator` floor.

Push first: the image clones the backend `--depth 1` from its default branch, so a
commit that is not on master yet simply is not in the image.

## 4. Image

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

## 5. Decide about `latest` — do not do it on autopilot

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

## 6. Pin the compose file

Bump the `image:` tag in `docker-compose.yml` to the new version. This is what a
first-time installer gets, and it is what keeps the compose file and the image in
step regardless of what `latest` points at.

## 7. Verify, from the outside

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

### Check the version the image reports

The backend's `package.json` is what the upgrade banner compares against (see step 3),
so it is worth confirming on the built image rather than assuming the bump made it in:

```bash
docker run --rm --entrypoint /bin/bash livingatlases/la-toolkit:X.Y.Z \
  -c 'cd /home/ubuntu/la-toolkit && npm pkg get version'
```

If it reports the previous release, the cache buster in the Dockerfile did not do its
job or the backend commit was not on master when the image was built. The commit itself
tells you which of the two it was, and the `--depth 1` clone keeps enough history to ask:

```bash
docker run --rm --entrypoint /bin/bash livingatlases/la-toolkit:X.Y.Z \
  -c 'cd /home/ubuntu/la-toolkit && git log -1 --format="%H %cd %s"'
```
