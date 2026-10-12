#!/usr/bin/env bash
# Decides what the Jenkinsfile builds, and prints it as KEY=VALUE lines:
#   RELEASE_TAG       the vX.Y.Z tag on HEAD, or empty for a dev build
#   BACKEND_REF       that same tag in la-toolkit-backend, or its master
#   BACKEND_SHA       the commit BACKEND_REF resolves to
#   BACKEND_VERSION   package.json's version at BACKEND_SHA, which the image reports
# A release build fails here unless the tag, pubspec.yaml and the backend's
# package.json at the same tag all say the same version: 1.7.1 shipped a
# backend still saying 1.7.0, and every install was told to upgrade to itself.
# Usage: docker/ci/resolve.sh   (needs git, curl and node)
set -euo pipefail
cd "$(dirname "$0")/../.."

backend_repo="${BACKEND_REPO:-https://github.com/living-atlases/la-toolkit-backend.git}"
backend_raw="${BACKEND_RAW:-https://raw.githubusercontent.com/living-atlases/la-toolkit-backend}"

fail() { printf 'resolve: %s\n' "$*" >&2; exit 1; }

tag="$(git tag --points-at HEAD | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -1 || true)"
app_version="$(sed -n 's/^version: *//p' pubspec.yaml | head -1)"

if [ -n "$tag" ]; then
  ref="$tag"
  # An annotated tag lists its peeled commit as ^{}; a lightweight one only itself.
  sha="$(git ls-remote "$backend_repo" "refs/tags/$tag^{}" | cut -f1)"
  [ -n "$sha" ] || sha="$(git ls-remote "$backend_repo" "refs/tags/$tag" | cut -f1)"
  [ -n "$sha" ] || fail "la-toolkit-backend has no tag $tag: tag it on the commit to release"
else
  ref=master
  sha="$(git ls-remote "$backend_repo" refs/heads/master | cut -f1)"
  [ -n "$sha" ] || fail "cannot resolve la-toolkit-backend master"
fi

backend_version="$(curl -fsSL "$backend_raw/$sha/package.json" |
  node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>console.log(JSON.parse(s).version))')"
[ -n "$backend_version" ] || fail "cannot read la-toolkit-backend package.json at $sha"

if [ -n "$tag" ]; then
  [ "v$app_version" = "$tag" ] || fail "tag $tag but pubspec.yaml says $app_version"
  [ "v$backend_version" = "$tag" ] || fail "tag $tag but la-toolkit-backend package.json at $tag says $backend_version"
fi

printf 'RELEASE_TAG=%s\nBACKEND_REF=%s\nBACKEND_SHA=%s\nBACKEND_VERSION=%s\n' \
  "$tag" "$ref" "$sha" "$backend_version"
