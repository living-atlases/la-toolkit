import 'package:flutter/material.dart';
import 'package:smart_select/smart_select.dart';

import '../laTheme.dart';

class SelectUtils {
  static Center modalConfirmBuild(S2MultiState<String> state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
        child: FlatButton(
            child: const Text('CONFIRM'),
            disabledColor: Colors.grey,
            textColor: LAColorTheme.laPalette,
            color: Colors.white,
            onPressed: !state.changes.valid
                ? null
                : () => state.closeModal(confirmed: true)),
      ),
    );
  }
}
