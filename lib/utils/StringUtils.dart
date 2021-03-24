class StringUtils {
  static String capitalize(String s) {
    if (s.length == 0) return s;
    return s.substring(0, 1).toUpperCase() + s.substring(1);
  }

  static String suggestDirName(
      {required String shortName, required String uuid}) {
    String dirName = shortName
        .toLowerCase()
        .replaceAll(RegExp(r'[^\d.-\w]'), '')
        .replaceAll('.', '-');
    return dirName.length <= 1 ? "la-${uuid.substring(0, 8)}" : dirName;
  }
}

// https://stackoverflow.com/a/21134081
extension BoolParsing on String {
  bool parseBool() {
    return this.toLowerCase() == 'true';
  }
}
