import 'package:pub_semver/pub_semver.dart';

import 'projects.dart';

/// Release names, newest first, compared as versions (a leading `v` is
/// ignored). Names that are not versions go last, in their original order.
List<String> sortReleases(List<String> names) {
  Version? parse(String n) {
    try {
      return Version.parse(n.startsWith('v') ? n.substring(1) : n);
    } on FormatException {
      return null;
    }
  }

  final List<String> versions =
      names.where((String n) => parse(n) != null).toList()
        ..sort((String a, String b) => parse(b)!.compareTo(parse(a)!));
  return <String>[...versions, ...names.where((String n) => parse(n) == null)];
}

/// Which generator configuration keys a save would add, drop or change.
/// Only the key names: values can carry passwords and keys.
Json genConfDiff(Json stored, Json next) {
  final List<String> added =
      next.keys.where((String k) => !stored.containsKey(k)).toList()..sort();
  final List<String> removed =
      stored.keys.where((String k) => !next.containsKey(k)).toList()..sort();
  final List<String> changed =
      next.keys
          .where(
            (String k) => stored.containsKey(k) && !_same(stored[k], next[k]),
          )
          .toList()
        ..sort();
  return <String, dynamic>{
    'added': added,
    'removed': removed,
    'changed': changed,
  };
}

bool _same(Object? a, Object? b) {
  if (a is Map && b is Map) {
    return a.length == b.length &&
        a.keys.every((Object? k) => b.containsKey(k) && _same(a[k], b[k]));
  }
  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (!_same(a[i], b[i])) return false;
    }
    return true;
  }
  return a == b;
}
