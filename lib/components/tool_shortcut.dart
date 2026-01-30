import 'package:flutter/material.dart';

import '../la_theme.dart';
import '../utils/utils.dart';
import 'tool.dart';

class ToolShortcut extends StatelessWidget {
  const ToolShortcut({super.key, required this.tool});

  final Tool tool;

  @override
  Widget build(BuildContext context) {
    // https://api.flutter.dev/flutter/material/Colors/grey-constant.html
    final Color color = tool.enabled
        ? LAColorTheme.laPalette
        : Colors.grey[500]!;
    final Color backgroundColor = tool.enabled
        ? Colors.white
        : Colors.grey[200]!;
    final double elevation = tool.enabled ? 4 : 0;
    final Widget btn = ElevatedButton(
      style: TextButton.styleFrom(
        // ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        elevation: elevation,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        shadowColor: LAColorTheme.laPalette,
        // primary: Colors.white,
        padding: const EdgeInsets.all(8.0),
      ),
      // disabledColor: Colors.grey[200],
      // disabledElevation: 0.2,
      // disabledTextColor: Colors.grey[100],
      onPressed: !tool.enabled
          ? null
          : () {
              if (tool.askConfirmation) {
                UiUtils.showAlertDialog(context, () => tool.action(), () {});
              } else {
                tool.action();
              }
            },

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: IconTheme.merge(
              data: IconThemeData(color: color),
              child: tool.icon,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Text(
              tool.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                // fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    if (tool.tooltip != null) {
      return Tooltip(
        waitDuration: const Duration(seconds: 1),
        padding: const EdgeInsets.all(10),
        message: tool.tooltip,
        child: btn,
      );
    }
    return btn;
  }
}
