import 'package:flutter/material.dart';
import 'package:smart_select/smart_select.dart';

class SelectUtils {
  static Center modalConfirmBuild(S2MultiState<String> state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
        child: OutlinedButton(
            child: const Text('CONFIRM'),
            style: TextButton.styleFrom(
//              disabledColor: Colors.grey,
              // primary: LAColorTheme.laPalette,
              primary: Colors.white,
            ),
            onPressed: !state.changes.valid
                ? null
                : () => state.closeModal(confirmed: true)),
      ),
    );
  }
}
