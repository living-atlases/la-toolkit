import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class ListUtils {
  static bool notNull(Object o) => o != null;

// What is the best way to optionally include a widget in a list of children
// https://github.com/flutter/flutter/issues/3783

  static List<Widget> listWithoutNulls(List<Widget> children) =>
      children.where(notNull).toList();
}

class AppUtils {
  static bool isDev() {
    return !kReleaseMode;
  }
}
