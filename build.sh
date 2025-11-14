flutter test && flutter build web --no-tree-shake-icons --release --source-maps && tar czfv flutter-web-$(cat pubspec.yaml| egrep "^version" | cut -d":" -f 2 | sed 's/ //g').tgz build/web
