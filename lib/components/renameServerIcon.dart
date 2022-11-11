import 'package:flutter/material.dart';
import 'package:la_toolkit/laTheme.dart';
import 'package:la_toolkit/models/laServer.dart';
import 'package:la_toolkit/utils/regexp.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'genericTextFormField.dart';

class RenameServerIcon extends StatelessWidget {
  final Function(String) onRename;
  final Function() onEditing;
  final LAServer server;

  const RenameServerIcon(this.server, this.onEditing, this.onRename, {Key? key})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Tooltip(
        message: "Rename the server",
        child: IconButton(
            icon: const Icon(Icons.edit, size: 18, color: Colors.grey),
            color: LAColorTheme.inactive,
            onPressed: () {
              onEditing();
              _generateRenameDialog(
                  context: context,
                  onRename: (String newName) => onRename(newName),
                  server: server);
            }));
  }

  _generateRenameDialog(
      {required BuildContext context,
      required Function(String) onRename,
      required LAServer server}) {
    String? name;
    Alert(
        context: context,
        closeIcon: const Icon(Icons.close),
        image: const Icon(Icons.dns, size: 60, color: LAColorTheme.inactive),
        title: "Server rename",
        style: const AlertStyle(
            constraints: BoxConstraints.expand(height: 600, width: 600)),
        content: Column(
          children: <Widget>[
            // TODO: Add a subsection for this help
            Text(
              "Type a new name for server '${server.name}':",
            ),
            GenericTextFormField(
                initialValue: server.name,
                regexp: LARegExp.hostnameRegexp,
                error: "This is not a valid server name",
                onChanged: (value) {
                  name = value;
                }),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
        buttons: [
          DialogButton(
            width: 500,
            onPressed: () {
              if (name != null) {
                if (LARegExp.hostnameRegexp.hasMatch(name!)) {
                  onRename(name!);
                  Navigator.pop(context);
                }
              }
            },
            child: const Text(
              "RENAME",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }
}
