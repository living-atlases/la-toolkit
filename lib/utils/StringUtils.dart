class StringUtils {
  static String capitalize(String s) {
    if (s.isEmpty) return s;
    return s.substring(0, 1).toUpperCase() + s.substring(1);
  }

  static String suggestDirName(
      {required String shortName, required String id}) {
    final String dirName = shortName
        .toLowerCase()
        .replaceAll(RegExp(r'[^\d.-\w]'), '')
        .replaceAll('.', '-');
    return dirName.length <= 1 ? 'la_${id.substring(0, 8)}' : dirName;
  }

  static String removeLastSlash(String url) {
    return url.replaceAll(RegExp(r'[/]+$'), '');
  }

  // This convert a non semantic version to a semantic version similar one
  static String semantize(String version) {
    // replace 1.0 with 1.0.0
    version = version.replaceAllMapped(
        RegExp(r'^([\^>=< ]+|)([0-9]+\.[0-9]+)$'),
        (Match m) => "${m[1]}${m[2]}.0");
    // replace 1.0-SNAPSHOT with 1.0.0-SNAPSHOT
    version = version.replaceAllMapped(RegExp(r'^([0-9]+\.[0-9]+)(-[A-Z]+)$'),
        (Match m) => '${m[1]}.0${m[2]}');
    // replace 1.0.SNAPSHOT with 1.0.0-SNAPSHOT
    version = version.replaceAllMapped(RegExp(r'^([0-9]+\.[0-9]+)\.([A-Z]+)$'),
        (Match m) => '${m[1]}.0-${m[2]}');
    // replace v1.0.0 with 1.0.0
    version = version.replaceAllMapped(
        RegExp(r'^v([0-9]+\.[0-9]+\.[0-9]+)$'), (Match m) => '${m[1]}');
    // replace 1.0.0.1 with 1.0.0-1
    version = version.replaceAllMapped(
        RegExp(r'^([0-9]+\.[0-9]+\.[0-9]+)\.([0-9]+)$'),
        (Match m) => '${m[1]}-${m[2]}');
    // replace 1 with 1.0.0
    version = version.replaceAllMapped(
        RegExp(r'^([\^>=< ]+|)([0-9]+)$'), (Match m) => "${m[1]}${m[2]}.0.0");
    return version;
  }
}

// https://stackoverflow.com/a/21134081
extension BoolParsing on String {
  bool parseBool() {
    return toLowerCase() == 'true';
  }
}
