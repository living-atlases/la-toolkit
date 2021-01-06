import 'package:flutter/material.dart';
import 'package:la_toolkit/laTheme.dart';

import 'tool.dart';

class ToolShortcut extends StatelessWidget {
  final Tool tool;

  ToolShortcut({this.tool});

  @override
  Widget build(BuildContext context) {
    // https://api.flutter.dev/flutter/material/Colors/grey-constant.html
    Color color = tool.enabled ? LAColorTheme.laPalette : Colors.grey[500];
    Widget result = RaisedButton(
      elevation: 3,
      color: Colors.white,
      disabledColor: Colors.grey[200],
      disabledElevation: 0.2,
      // disabledTextColor: Colors.grey[100],
      onPressed: !tool.enabled
          ? null
          : () {
              if (tool.askConfirmation)
                showAlertDialog(context, () => tool.action());
              else
                tool.action();
            },
      padding: EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: IconTheme.merge(
              data: IconThemeData(
                  //  size: iconSize,
                  color: color),
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
      result = Tooltip(
        message: tool.tooltip,
        child: result,
      );
    }
    return result;
  }

  showAlertDialog(BuildContext context, VoidCallback onConfirm) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("CANCEL"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    Widget continueButton = FlatButton(
        child: Text("CONFIRM"),
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
          onConfirm();
        });
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Please Confirm"),
      content: Text("Are you sure?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
