#!/usr/bin/env bash
# Creates the GitHub release of TAG with docs/release-notes/TAG.md as its body,
# or updates it when it already exists (a rebuild of the tag, e.g. to promote
# :latest). The app's upgrade banner compares the backend's version with the
# newest GitHub release, so a release without it never reaches anyone.
# Usage: GH_TOKEN=... docker/ci/github-release.sh vX.Y.Z   (needs curl and node)
set -euo pipefail
cd "$(dirname "$0")/../.."

tag="$1"
api="${GITHUB_API:-https://api.github.com}/repos/${GITHUB_REPO:-living-atlases/la-toolkit}"
notes="docs/release-notes/$tag.md"

resp="$(mktemp)"
trap 'rm -f "$resp"' EXIT
fail() { printf 'github-release: %s\n' "$*" >&2; [ -s "$resp" ] && head -c 2000 "$resp" >&2; exit 1; }
[ -n "${GH_TOKEN:-}" ] || fail "no GH_TOKEN"
[ -f "$notes" ] || fail "no $notes"

gh_api() {
  local method="$1" url="$2" data="${3:-}"
  local args=(-sS -o "$resp" -w '%{http_code}' -X "$method"
    -H "Authorization: Bearer $GH_TOKEN" -H 'Accept: application/vnd.github+json'
    -H 'X-GitHub-Api-Version: 2022-11-28')
  [ -n "$data" ] && args+=(-H 'Content-Type: application/json' --data-binary "$data")
  curl "${args[@]}" "$url"
}

body="$(TAG="$tag" NOTES="$notes" node -e '
  const fs = require("fs");
  console.log(JSON.stringify({
    tag_name: process.env.TAG,
    name: process.env.TAG,
    body: fs.readFileSync(process.env.NOTES, "utf8"),
    draft: false,
    prerelease: false,
    make_latest: "true",
  }));')"

existing="$(curl -sS -H "Authorization: Bearer $GH_TOKEN" -H 'Accept: application/vnd.github+json' \
  "$api/releases/tags/$tag" | node -e '
  let s = ""; process.stdin.on("data", (d) => (s += d)).on("end", () => {
    try { const r = JSON.parse(s); if (r.id) console.log(r.id); } catch (e) {}
  });')"

if [ -n "$existing" ]; then
  code="$(gh_api PATCH "$api/releases/$existing" "$body")"
  [ "$code" = 200 ] || fail "updating release $tag answered $code"
  echo "github-release: updated $tag"
else
  code="$(gh_api POST "$api/releases" "$body")"
  [ "$code" = 201 ] || fail "creating release $tag answered $code"
  echo "github-release: created $tag"
fi
