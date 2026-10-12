#!/usr/bin/env bash
# Checks docker/ci/resolve.sh against a throwaway frontend clone and a local
# backend repo (no network):
#   1. no tag on HEAD: a dev build of the backend's master;
#   2. vX.Y.Z on HEAD, matching pubspec.yaml and the backend tag: a release;
#   3. the backend has no such tag: refused;
#   4. pubspec.yaml says another version: refused;
#   5. the backend's package.json at the tag says another version: refused.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

pass() { printf '[PASS] %s\n' "$*"; }
fail() { printf '[FAIL] %s\n' "$*" >&2; exit 1; }
g() { git -c user.name=t -c user.email=t@t -c commit.gpgsign=false -c tag.gpgsign=false "$@"; }

# Backend: master at 1.8.0-dev, tag v1.8.0 at 1.8.0, tag v1.9.0 at 1.8.9 (wrong).
mkdir -p "$tmp/backend" "$tmp/raw"
cd "$tmp/backend" && g init -q -b master .
commit_pkg() {
  printf '{"version":"%s"}\n' "$1" > package.json
  g add package.json && g commit -qm "$1"
  local sha; sha="$(git rev-parse HEAD)"
  mkdir -p "$tmp/raw/$sha" && cp package.json "$tmp/raw/$sha/"
}
commit_pkg 1.8.0 && g tag -a v1.8.0 -m v1.8.0
commit_pkg 1.8.9 && g tag v1.9.0
commit_pkg 1.8.0-dev
export BACKEND_REPO="$tmp/backend" BACKEND_RAW="file://$tmp/raw"

# Frontend: resolve.sh and a pubspec.yaml.
mkdir -p "$tmp/front/docker/ci"
cp "$here/resolve.sh" "$tmp/front/docker/ci/"
cd "$tmp/front" && g init -q -b master .
printf 'name: x\nversion: 1.8.0\n' > pubspec.yaml
g add . && g commit -qm one

out="$(docker/ci/resolve.sh)" || fail "1: refused a dev build"
grep -qx 'RELEASE_TAG=' <<<"$out" && grep -qx 'BACKEND_REF=master' <<<"$out" &&
  grep -qx "BACKEND_SHA=$(git -C "$tmp/backend" rev-parse master)" <<<"$out" &&
  grep -qx 'BACKEND_VERSION=1.8.0-dev' <<<"$out" || fail "1: $out"
pass "no tag: a dev build of the backend's master"

g tag -a v1.8.0 -m v1.8.0
out="$(docker/ci/resolve.sh)" || fail "2: refused a consistent release"
grep -qx 'RELEASE_TAG=v1.8.0' <<<"$out" && grep -qx 'BACKEND_REF=v1.8.0' <<<"$out" &&
  grep -qx "BACKEND_SHA=$(git -C "$tmp/backend" rev-parse 'v1.8.0^{}')" <<<"$out" &&
  grep -qx 'BACKEND_VERSION=1.8.0' <<<"$out" || fail "2: $out"
pass "vX.Y.Z everywhere: a release of the backend's tag (annotated, peeled)"

g tag -d v1.8.0 >/dev/null
printf 'name: x\nversion: 1.8.1\n' > pubspec.yaml && g commit -qam two && g tag v1.8.1
err="$(docker/ci/resolve.sh 2>&1)" && fail "3: accepted a tag the backend does not have"
grep -q 'has no tag v1.8.1' <<<"$err" || fail "3: $err"
pass "a tag the backend lacks is refused"

g tag -d v1.8.1 >/dev/null && g tag v1.8.0
err="$(docker/ci/resolve.sh 2>&1)" && fail "4: accepted a pubspec.yaml version that is not the tag's"
grep -q 'pubspec.yaml says 1.8.1' <<<"$err" || fail "4: $err"
pass "pubspec.yaml out of step with the tag is refused"

g tag -d v1.8.0 >/dev/null
printf 'name: x\nversion: 1.9.0\n' > pubspec.yaml && g commit -qam three && g tag v1.9.0
err="$(docker/ci/resolve.sh 2>&1)" && fail "5: accepted a backend package.json out of step"
grep -q 'package.json at v1.9.0 says 1.8.9' <<<"$err" || fail "5: $err"
pass "the backend's package.json out of step with the tag is refused"
