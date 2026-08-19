class StringUtils {
  static String capitalize(String s) {
    if (s.isEmpty) {
      return s;
    }
    return s.substring(0, 1).toUpperCase() + s.substring(1);
  }

  static String suggestDirName({
    required String shortName,
    required String id,
  }) {
    final String dirName = shortName
        .toLowerCase()
        .replaceAll(RegExp(r'[^\d.-\w]'), '')
        .replaceAll('.', '-');
    return dirName.length <= 1 ? 'la_${id.substring(0, 8)}' : dirName;
  }

  /// [candidate] itself when no project owns it, otherwise the first free
  /// `candidate-1`, `candidate-2`, ... The `-N` shape matches what the backend
  /// hands out in check-dir-name, so both ends agree on the same names.
  static String uniqueDirName({
    required String candidate,
    required Set<String> taken,
  }) {
    if (!taken.contains(candidate)) {
      return candidate;
    }
    int num = 1;
    while (taken.contains('$candidate-$num')) {
      num++;
    }
    return '$candidate-$num';
  }

  static String removeLastSlash(String url) {
    return url.replaceAll(RegExp(r'[/]+$'), '');
  }

  // This convert a non semantic version to a semantic version similar one
  static String semantize(String version) {
    // Handle compound constraints like '>= 2.0 < 4.1'
    final RegExpMatch? compoundMatch = RegExp(
      r'^([><]=?)\s*([0-9.]+)\s+([><]=?)\s*([0-9.]+)$',
    ).firstMatch(version);
    if (compoundMatch != null) {
      final String op1 = compoundMatch[1]!;
      final String ver1 = compoundMatch[2]!;
      final String op2 = compoundMatch[3]!;
      final String ver2 = compoundMatch[4]!;
      // Recursively semantize each version part
      final String semantized1 = semantize('$op1 $ver1').replaceAll(' ', '');
      final String semantized2 = semantize('$op2 $ver2').replaceAll(' ', '');
      return '$semantized1 $semantized2';
    }

    // strip leading 'v' from git-tag versions (v2.0, v1.2.3) so pub_semver parses them
    version = version.replaceFirst(RegExp(r'^v(?=[0-9])'), '');
    // replace 1.0 with 1.0.0
    version = version.replaceAllMapped(
      RegExp(r'^([\^>=< ]+|)([0-9]+\.[0-9]+)$'),
      (Match m) => '${m[1]}${m[2]}.0',
    );
    // replace 1.0-SNAPSHOT with 1.0.0-SNAPSHOT
    version = version.replaceAllMapped(
      RegExp(r'^([0-9]+\.[0-9]+)(-[A-Z]+)$'),
      (Match m) => '${m[1]}.0${m[2]}',
    );
    // replace 1.0.SNAPSHOT with 1.0.0-SNAPSHOT
    version = version.replaceAllMapped(
      RegExp(r'^([0-9]+\.[0-9]+)\.([A-Z]+)$'),
      (Match m) => '${m[1]}.0-${m[2]}',
    );
    // replace 1.0.0.1 with 1.0.0-1
    version = version.replaceAllMapped(
      RegExp(r'^([0-9]+\.[0-9]+\.[0-9]+)\.([0-9]+)$'),
      (Match m) => '${m[1]}-${m[2]}',
    );
    // replace 1 with 1.0.0
    version = version.replaceAllMapped(
      RegExp(r'^([\^>=< ]+|)([0-9]+)$'),
      (Match m) => '${m[1]}${m[2]}.0.0',
    );
    return version;
  }
}

// https://stackoverflow.com/a/21134081
extension BoolParsing on String {
  bool parseBool() {
    return toLowerCase() == 'true';
  }
}
