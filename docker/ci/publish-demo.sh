#!/usr/bin/env bash
# Publishes the backend-less demo built by the `demo` target of
# docker/u22/Dockerfile to toolkit-demo.l-a.site, then checks that the site
# serves that version with the demo env.
#   docker build --target demo --output type=local,dest=build/demo -f docker/u22/Dockerfile .
#   docker/ci/publish-demo.sh build/demo
# DEMO_DEST and DEMO_URL point it somewhere else (tests).
set -euo pipefail
cd "$(dirname "$0")/../.."

dir="${1:?usage: publish-demo.sh <demo build dir>}"
dest="${DEMO_DEST:-root@l-a.site:/srv/toolkit-demo.l-a.site/www/}"
url="${DEMO_URL:-https://toolkit-demo.l-a.site}"
version="$(sed -n 's/^version: *//p' pubspec.yaml | head -1)"

fail() { printf 'publish-demo: %s\n' "$*" >&2; exit 1; }

for env in "$dir/assets/env.production.txt" "$dir/assets/assets/env.production.txt"; do
  grep -q '^DEMO=true' "$env" 2>/dev/null || fail "refusing to publish: $env is not a demo env"
done
grep -q "\"version\":\"$version\"" "$dir/version.json" ||
  fail "the build is not $version: $(cat "$dir/version.json" 2>/dev/null)"

# The web root belongs to ubuntu on the server; DEMO_CHOWN= keeps the owner.
# --chmod: docker's local export makes the top directory 0700, and -a would
# carry that to the web root, which the web server then cannot read (403).
chown_to="${DEMO_CHOWN-ubuntu:ubuntu}"
rsync -a --chmod=D755,F644 ${chown_to:+--chown="$chown_to"} -e 'ssh -o BatchMode=yes' "$dir/" "$dest"

# The site, not the copy: what a visitor gets.
served="$(curl -fsS "$url/version.json?$(date +%s)")" || fail "$url/version.json does not answer"
grep -q "\"version\":\"$version\"" <<<"$served" || fail "$url serves $served, expected $version"
curl -fsS "$url/assets/assets/env.production.txt?$(date +%s)" | grep -q '^DEMO=true' ||
  fail "$url does not serve the demo env"
echo "publish-demo: $url serves $version"
