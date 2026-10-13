#!/usr/bin/env bash
# Checks docker/ci/github-release.sh against a local mock of the GitHub API:
#   1. no release for the tag: POST, with the token, the tag and the notes as body;
#   2. a release already there (a rebuild): PATCH that one, no second release;
#   3. no notes file for the tag: refused before calling the API;
#   4. the API refuses: the script fails and shows the answer.
# Needs python3, curl and node.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
tmp="$(mktemp -d)"
pid=""
trap '[ -n "$pid" ] && kill "$pid" 2>/dev/null; rm -rf "$tmp"' EXIT

pass() { printf '[PASS] %s\n' "$*"; }
fail() { printf '[FAIL] %s\n' "$*" >&2; exit 1; }

mkdir -p "$tmp/repo/docker/ci" "$tmp/repo/docs/release-notes"
cp "$here/github-release.sh" "$tmp/repo/docker/ci/"
printf '## Notes of v9.0.0\n\nSome "quoted" text.\n' > "$tmp/repo/docs/release-notes/v9.0.0.md"

cat > "$tmp/mock.py" <<'EOF'
import http.server, json, os, sys
log = sys.argv[2]
class H(http.server.BaseHTTPRequestHandler):
    def log_message(self, *a): pass
    def answer(self, code, obj):
        self.send_response(code); self.send_header('Content-Type', 'application/json'); self.end_headers()
        self.wfile.write(json.dumps(obj).encode())
    def record(self):
        n = int(self.headers.get('Content-Length') or 0)
        body = json.loads(self.rfile.read(n)) if n else None
        with open(log, 'a') as f:
            f.write(json.dumps({'m': self.command, 'p': self.path, 'auth': self.headers.get('Authorization'), 'body': body}) + '\n')
    def do_GET(self):
        self.record()
        if os.path.exists(log + '.exists'): self.answer(200, {'id': 42})
        else: self.answer(404, {'message': 'Not Found'})
    def do_POST(self):
        self.record()
        if os.path.exists(log + '.refuse'): self.answer(422, {'message': 'Validation Failed'})
        else: self.answer(201, {'id': 43})
    def do_PATCH(self):
        self.record(); self.answer(200, {'id': 42})
s = http.server.HTTPServer(('127.0.0.1', 0), H)
open(sys.argv[1], 'w').write(str(s.server_port))
s.serve_forever()
EOF
python3 "$tmp/mock.py" "$tmp/port" "$tmp/log" & pid=$!
for _ in $(seq 1 50); do [ -s "$tmp/port" ] && break; sleep 0.1; done
export GITHUB_API="http://127.0.0.1:$(cat "$tmp/port")" GITHUB_REPO=o/r GH_TOKEN=secret
cd "$tmp/repo"
calls() { node -e 'require("fs").readFileSync(process.argv[1],"utf8").trim().split("\n").forEach(l=>{const c=JSON.parse(l);console.log(c.m+" "+c.p+" "+c.auth+" "+(c.body?c.body.tag_name+"|"+c.body.body.length+"|"+c.body.make_latest:"-"))})' "$tmp/log"; }

out="$(docker/ci/github-release.sh v9.0.0)" || fail "1: $out"
[ "$(calls)" = "GET /repos/o/r/releases/tags/v9.0.0 Bearer secret -
POST /repos/o/r/releases Bearer secret v9.0.0|$(wc -c < docs/release-notes/v9.0.0.md)|true" ] || fail "1: $(calls)"
grep -qx 'github-release: created v9.0.0' <<<"$out" || fail "1: $out"
pass "no release yet: created, with the token, the tag and the notes"

: > "$tmp/log"; touch "$tmp/log.exists"
out="$(docker/ci/github-release.sh v9.0.0)" || fail "2: $out"
calls | grep -q '^PATCH /repos/o/r/releases/42 ' || fail "2: $(calls)"
calls | grep -q '^POST' && fail "2: created a second release"
pass "a rebuild updates the release it finds"

: > "$tmp/log"
err="$(docker/ci/github-release.sh v9.9.9 2>&1)" && fail "3: accepted a tag without notes"
grep -q 'no docs/release-notes/v9.9.9.md' <<<"$err" && [ ! -s "$tmp/log" ] || fail "3: $err"
pass "no notes for the tag: refused without calling the API"

rm -f "$tmp/log.exists"; touch "$tmp/log.refuse"
err="$(docker/ci/github-release.sh v9.0.0 2>&1)" && fail "4: ignored a refusal"
grep -q 'answered 422' <<<"$err" && grep -q 'Validation Failed' <<<"$err" || fail "4: $err"
pass "a refusal fails the build and shows GitHub's answer"
