#!/usr/bin/env bash
# Checks docker/ci/publish-demo.sh with a local directory as the server and a
# local HTTP server as the site:
#   1. a demo build of this version is copied, readable by the web server, and
#      checked on the site;
#   2. a build whose bundled env is not the demo one is refused, nothing copied;
#   3. a build of another version is refused;
#   4. a site that still serves another version fails the publish.
# Needs python3, rsync and curl.
set -euo pipefail
cd "$(dirname "$0")/../.."
tmp="$(mktemp -d)"
pid=""
trap '[ -n "$pid" ] && kill "$pid" 2>/dev/null; rm -rf "$tmp"' EXIT

pass() { printf '[PASS] %s\n' "$*"; }
fail() { printf '[FAIL] %s\n' "$*" >&2; exit 1; }

version="$(sed -n 's/^version: *//p' pubspec.yaml | head -1)"
build() { # dir version demo
  mkdir -p "$1/assets/assets"
  printf '{"app_name":"la_toolkit","version":"%s","package_name":"la_toolkit"}' "$2" > "$1/version.json"
  printf 'X=1\nDEMO=%s\n' "$3" | tee "$1/assets/env.production.txt" > "$1/assets/assets/env.production.txt"
  echo "<html>$2</html>" > "$1/index.html"
}

mkdir -p "$tmp/www"
python3 -u -m http.server --bind 127.0.0.1 0 --directory "$tmp/www" > "$tmp/http.log" 2>&1 & pid=$!
port=""
for _ in $(seq 1 50); do
  port="$(sed -n 's/.*port \([0-9]*\).*/\1/p' "$tmp/http.log" | head -1)"
  [ -n "$port" ] && break
  sleep 0.1
done
[ -n "$port" ] || fail "no local http server"
export DEMO_DEST="$tmp/www/" DEMO_URL="http://127.0.0.1:$port" DEMO_CHOWN=

build "$tmp/ok" "$version" true
chmod 700 "$tmp/ok"; chmod 600 "$tmp/ok/index.html"   # as docker's local export leaves it
out="$(docker/ci/publish-demo.sh "$tmp/ok" 2>&1)" || fail "1: $out"
grep -q "serves $version" <<<"$out" && grep -q "<html>$version" "$tmp/www/index.html" || fail "1: $out"
[ "$(stat -c %a "$tmp/www")" = 755 ] && [ "$(stat -c %a "$tmp/www/index.html")" = 644 ] ||
  fail "1: the web root is $(stat -c %a "$tmp/www"), index.html $(stat -c %a "$tmp/www/index.html"): the web server could not read them"
pass "a demo build of $version is copied readable and the site serves it"

rm -rf "$tmp/www"/*
build "$tmp/notdemo" "$version" false
err="$(docker/ci/publish-demo.sh "$tmp/notdemo" 2>&1)" && fail "2: published a non-demo env"
grep -q 'not a demo env' <<<"$err" && [ ! -e "$tmp/www/index.html" ] || fail "2: $err"
pass "a build with the regular env is refused before copying"

build "$tmp/old" 0.0.1 true
err="$(docker/ci/publish-demo.sh "$tmp/old" 2>&1)" && fail "3: published another version"
grep -q "the build is not $version" <<<"$err" || fail "3: $err"
pass "a build of another version is refused"

# The site lags behind the copy (another web root, a cache).
export DEMO_DEST="$tmp/elsewhere/"
mkdir -p "$tmp/elsewhere"
build "$tmp/www" 0.0.1 true
err="$(docker/ci/publish-demo.sh "$tmp/ok" 2>&1)" && fail "4: did not notice the site serves another version"
grep -q 'expected '"$version" <<<"$err" || fail "4: $err"
pass "a site still serving another version fails the publish"
