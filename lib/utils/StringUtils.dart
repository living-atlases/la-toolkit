class StringUtils {
  static String capitalize(String s) {
    if (s == null || s.length == 0) return s;
    return s.substring(0, 1).toUpperCase() + s.substring(1);
  }
}
