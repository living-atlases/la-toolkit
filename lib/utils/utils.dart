import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:la_toolkit/utils/StringUtils.dart';

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

  static bool isDemo() {
    return env['DEMO'].parseBool();
  }

  static String proxyImg(imgUrl) {
    return "${env['BACKEND']}api/v1/image-proxy/${Uri.encodeFull(imgUrl)}";
  }
}
