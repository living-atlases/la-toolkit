import 'package:flutter/material.dart';

import 'StringUtils.dart';

/*
class ResultsColors {
  static final basicGraphPalette = const <Color>[
    Color.fromRGBO(75, 135, 185, 1),
    Color.fromRGBO(192, 108, 132, 1),
    Color.fromRGBO(246, 114, 128, 1),
    Color.fromRGBO(248, 177, 149, 1),
    Color.fromRGBO(116, 180, 155, 1),
    Color.fromRGBO(0, 168, 181, 1),
    Color.fromRGBO(73, 76, 162, 1),
    Color.fromRGBO(255, 205, 96, 1),
    Color.fromRGBO(255, 240, 219, 1),
    Color.fromRGBO(238, 238, 238, 1)
  ];

  static final Color ok = Colors.green;
  static final Color failure =
      Color.fromRGBO(246, 114, 128, 1); // Colors.redAccent
  static final Color skipped = Colors.grey;
  static final Color changed = Colors.brown;
  static final Color ignored = Colors.grey;
  static final Color rescued = Colors.blueGrey;
} */

enum ResultType {
  changed,
  failures,
  ignored,
  ok,
  rescued,
  skipped,
  unreachable
}

extension ParseToString on ResultType {
  String toS() {
    return toString().split('.').last;
  }

  String title() {
    String toS = this.toS();
    return StringUtils.capitalize(toS == "ok" ? "success" : toS);
  }

  Color get color {
    switch (this) {
      case ResultType.changed:
        return Colors.brown;
      case ResultType.failures:
        return Colors.redAccent;
      case ResultType.ignored:
        return Colors.grey;
      case ResultType.ok:
        return Colors.green;
      case ResultType.rescued:
        return Colors.blueGrey;
      case ResultType.skipped:
        return Colors.grey;
      case ResultType.unreachable:
        return Colors.deepOrange;
    }
  }

  Color get textColor {
    switch (this) {
      case ResultType.changed:
        return Colors.white;
      case ResultType.failures:
        return Colors.black;
      case ResultType.ignored:
        return Colors.black;
      case ResultType.ok:
        return Colors.white;
      case ResultType.rescued:
        return Colors.white;
      case ResultType.skipped:
        return Colors.black;
      case ResultType.unreachable:
        return Colors.black;
    }
  }
}

class ResultTypes {
  static List<String>? _list;

  static List<String> get list {
    _list ??= ResultType.values.map((ResultType v) => v.toS()).toList();
    return _list!;
  }
}
