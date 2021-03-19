import 'dart:async';

import 'package:flutter/foundation.dart';

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer.def() : milliseconds = 1000;

  Debouncer({required this.milliseconds});

  run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }

    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
