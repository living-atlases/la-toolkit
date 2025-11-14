#!/bin/bash
flutter test && flutter build web && cp assets/.env.production-demo build/web/assets/env.production.txt && rsync --progress=info2 -a build/web/ root@l-a.site:/srv/toolkit-demo.l-a.site/www/
# release
#flutter test && flutter build web --release --no-sound-null-safety --source-maps && tar czfv flutter-web-$(cat pubspec.yaml| egrep "^version" | cut -d":" -f 2 | sed 's/ //g').tgz build/web
