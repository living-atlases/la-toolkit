#!/usr/bin/env bash
# Checks a built la-toolkit image before it is pushed (Jenkinsfile), the way a
# first-time installer meets it:
#   1. the backend suite, inside the image (it has ttyd and assh), against a
#      throwaway mongo;
#   2. docker-compose.yml's checks of the fast deploy's docker client;
#   3. a cold start on an empty mongo:8 initialised by mongo-init.sh, as in
#      docker-compose.yml: the backend answers and reports EXPECTED_VERSION;
#   4. the image's docker client and the MCP server answer.
# Usage: docker/ci/smoke.sh IMAGE EXPECTED_VERSION
set -euo pipefail
cd "$(dirname "$0")/../.."

image="$1"
expected="$2"
run="la-toolkit-smoke-$$"
net="$run"
mongo_image="$(sed -n 's/^ *image: *\(mongo:.*\)$/\1/p' docker-compose.yml | head -1)"

pass() { printf '[PASS] %s\n' "$*"; }
fail() { printf '[FAIL] %s\n' "$*" >&2; exit 1; }
cleanup() {
  docker rm -f "$run-app" "$run-mongo" "$run-testdb" >/dev/null 2>&1 || true
  docker network rm "$net" >/dev/null 2>&1 || true
}
trap cleanup EXIT
docker network create "$net" >/dev/null

# 1. Backend suite.
docker run -d --name "$run-testdb" --network "$net" "$mongo_image" >/dev/null
# LA_TOOLKIT_TEST_PRECMD='': ttyd runs here directly, not in a la-toolkit container.
docker run --rm --network "$net" -e DATABASE_URL="mongodb://$run-testdb:27017/la_toolkit_test" \
  -e LA_TOOLKIT_TEST_PRECMD= --entrypoint /bin/bash "$image" \
  -lc 'cd /home/ubuntu/la-toolkit && npx ava --timeout=2m' ||
  fail "1: the backend suite fails in the image"
pass "the backend suite passes in the image"

# 2. Static checks of the image's docker client and the compose file.
docker run --rm -v "$PWD:/w:ro" -w /w --entrypoint /bin/bash "$image" -c 'bash docker/test-fast-deploy-docker.sh' ||
  fail "2: docker/test-fast-deploy-docker.sh"
pass "docker-compose.yml and the Dockerfile give the fast deploy a docker client"

# 3. Cold start, as docker-compose.yml wires it.
docker run -d --name "$run-mongo" --network "$net" \
  -e MONGO_INITDB_ROOT_USERNAME=admin -e MONGO_INITDB_ROOT_PASSWORD=smoke \
  -e MONGO_INITDB_DATABASE=la_toolkit -e LA_USER=la_toolkit_user -e LA_PASS=smoke \
  -v "$PWD/mongo-init.sh:/docker-entrypoint-initdb.d/mongo-init.sh:ro" "$mongo_image" >/dev/null
docker run -d --name "$run-app" --network "$net" -e NODE_ENV=production \
  -e DATABASE_URL="mongodb://la_toolkit_user:smoke@$run-mongo:27017/la_toolkit" "$image" >/dev/null
version=""
for _ in $(seq 1 60); do
  version="$(docker exec "$run-app" bash -c 'set -o pipefail;
    curl -fsS http://localhost:2010/api/v1/get-backend-version | jq -er .version' 2>/dev/null)" || version=""
  [ -n "$version" ] && break
  [ "$(docker inspect -f '{{.State.Running}}' "$run-app")" = true ] || break
  sleep 5
done
if [ -z "$version" ]; then
  docker logs --tail 60 "$run-app" >&2
  fail "3: the backend did not answer on a cold start"
fi
[ "$version" = "$expected" ] || fail "3: the backend reports $version, expected $expected"
if docker logs "$run-app" 2>&1 | grep -qi 'authentication failed'; then
  fail "3: authentication failed against the fresh mongo"
fi
pass "a cold start answers and reports $version"
docker exec "$run-app" curl -fsS http://localhost:2010/ | grep -qi '<html' ||
  fail "3: the backend does not serve the frontend"
pass "the backend serves the frontend"

# 4. The fast deploy's docker client and the MCP server.
docker exec "$run-app" docker --version >/dev/null || fail "4: no docker client in the image"
docker exec "$run-app" docker buildx version >/dev/null || fail "4: no docker buildx in the image"
pass "the image has docker and buildx"
printf '%s\n' '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"smoke","version":"0"}}}' |
  timeout 30 docker exec -i "$run-app" la_toolkit_mcp --backend http://localhost:2010 2>/dev/null |
  grep -q '"serverInfo":{"name":"la-toolkit"' || fail "4: la_toolkit_mcp did not answer initialize"
pass "la_toolkit_mcp answers an MCP initialize"
