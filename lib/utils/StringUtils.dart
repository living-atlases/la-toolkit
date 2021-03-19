class StringUtils {
  static String capitalize(String s) {
    if (s.length == 0) return s;
    return s.substring(0, 1).toUpperCase() + s.substring(1);
  }
}

// https://stackoverflow.com/a/21134081
extension BoolParsing on String {
  bool parseBool() {
    return this.toLowerCase() == 'true';
  }
}
