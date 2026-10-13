#!/bin/bash
# Builds the backend-less demo and publishes it to toolkit-demo.l-a.site, as the
# Jenkins release builds do (Jenkinsfile, stage Demo): the demo target of
# docker/u22/Dockerfile is the web build with the demo env (DEMO=true), so the
# regular build is not affected. Needs docker, and ssh access to the demo host
# for publishing.
#   ./deploy-demo.sh               test, build and publish
#   ./deploy-demo.sh --no-publish  test and build into build/demo only
set -euo pipefail
cd "$(dirname "$0")"

docker build --target web-test -f docker/u22/Dockerfile .
rm -rf build/demo
docker build --target demo --output type=local,dest=build/demo -f docker/u22/Dockerfile .

if [ "${1:-}" = "--no-publish" ]; then
  echo "Demo built in build/demo (not published)"
  exit 0
fi
docker/ci/publish-demo.sh build/demo
