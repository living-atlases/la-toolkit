#!/bin/bash
# Builds the backend-less demo and publishes it to toolkit-demo.l-a.site.
# It is a normal web build whose bundled env is swapped for the demo one
# (DEMO=true), so the regular build is not affected.
set -euo pipefail
cd "$(dirname "$0")"

(cd packages/la_toolkit_core && dart test)
flutter test
flutter build web

# main.dart loads 'env.production.txt' in release builds; the 'assets/' copy is
# swapped too so both bundled envs agree.
cp assets/env.production-demo.txt build/web/assets/env.production.txt
cp assets/env.production-demo.txt build/web/assets/assets/env.production.txt
grep -q '^DEMO=true' build/web/assets/env.production.txt || {
  echo "Refusing to publish: the bundled env is not a demo one" >&2
  exit 1
}

if [ "${1:-}" = "--no-publish" ]; then
  echo "Demo built in build/web (not published)"
  exit 0
fi
rsync --info=progress2 -a build/web/ root@l-a.site:/srv/toolkit-demo.l-a.site/www/
# release
#flutter test && flutter build web --release --no-sound-null-safety --source-maps && tar czfv flutter-web-$(cat pubspec.yaml| egrep "^version" | cut -d":" -f 2 | sed 's/ //g').tgz build/web
