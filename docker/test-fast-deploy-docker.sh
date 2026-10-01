#!/usr/bin/env bash
# The la-toolkit image and docker-compose.yml give the fast deploy (TASK-31) a docker client:
#   1. the Dockerfile installs docker-ce-cli and docker-buildx-plugin from Docker's apt repo;
#   2. docker-compose.yml mounts /var/run/docker.sock and adds DOCKER_GID to la-toolkit and
#      la-toolkit-dev, and nothing else gains the socket;
#   3. with --install (needs docker): that Dockerfile RUN, run as is in ubuntu:22.04, leaves a
#      working `docker` and `docker buildx` (the apt repo line and package names are right).
# Usage: docker/test-fast-deploy-docker.sh [--install]
set -eu
cd "$(dirname "$0")/.."

pass() { printf '[PASS] %s\n' "$*"; }
fail() { printf '[FAIL] %s\n' "$*" >&2; exit 1; }

df=docker/u22/Dockerfile
grep -q 'download.docker.com/linux/ubuntu jammy stable' "$df" || fail "1: no Docker apt repo for jammy"
grep -q 'apt-get install --no-install-recommends -y docker-ce-cli docker-buildx-plugin' "$df" ||
  fail "1: docker-ce-cli / docker-buildx-plugin not installed"
pass "the image installs the docker CLI and buildx"

python3 - <<'PY' || fail "2: docker-compose.yml"
import sys, yaml
c = yaml.safe_load(open("docker-compose.yml"))
sock = "/var/run/docker.sock:/var/run/docker.sock:rw"
for name in ("la-toolkit", "la-toolkit-dev"):
    s = c["services"][name]
    assert sock in s.get("volumes", []), f"{name}: no docker.sock"
    assert "${DOCKER_GID:-999}" in [str(g) for g in s.get("group_add", [])], f"{name}: no group_add DOCKER_GID"
others = [n for n, s in c["services"].items()
          if n not in ("la-toolkit", "la-toolkit-dev", "watchtower") and sock in (s.get("volumes") or [])]
assert not others, f"socket also in {others}"
PY
pass "la-toolkit and la-toolkit-dev get the socket and DOCKER_GID, nothing else does"

if [ "${1:-}" = --install ]; then
  run=$(python3 - "$df" <<'PY'
import re, sys
s = open(sys.argv[1]).read()
m = re.search(r"\nRUN (install -m 0755 -d /etc/apt/keyrings.*?)\n\n", s, re.S)
print(m.group(1).replace("\\\n", " "))
PY
)
  docker run --rm ubuntu:22.04 bash -euc "apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -qq -y curl ca-certificates >/dev/null && $run >/dev/null && docker --version && docker buildx version" \
    >/tmp/fast-deploy-docker-install.log 2>&1 || { tail -20 /tmp/fast-deploy-docker-install.log >&2; fail "3: the install RUN failed"; }
  grep -q '^Docker version' /tmp/fast-deploy-docker-install.log && grep -q 'buildx' /tmp/fast-deploy-docker-install.log ||
    fail "3: no docker or buildx after the RUN"
  pass "the Dockerfile RUN installs a working docker CLI and buildx in ubuntu:22.04"
fi
