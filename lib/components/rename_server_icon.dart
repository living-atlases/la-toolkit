import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';


import '../la_theme.dart';
import '../models/la_server.dart';
import '../utils/regexp.dart';
import 'generic_text_form_field.dart';

class RenameServerIcon extends StatelessWidget {
  const RenameServerIcon(this.server, this.onEditing, this.onRename,
      {super.key});

  final Function(String) onRename;
  final Function() onEditing;
  final LAServer server;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
        message: 'Rename the server',
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

  void _generateRenameDialog(
      {required BuildContext context,
      required Function(String) onRename,
      required LAServer server}) {
    String? name;
    Alert(
        context: context,
        closeIcon: const Icon(Icons.close),
        image: const Icon(Icons.dns, size: 60, color: LAColorTheme.inactive),
        title: 'Server rename',
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
                error: 'This is not a valid server name',
                onChanged: (String value) {
                  name = value.trim().toLowerCase();
                }),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
        buttons: <DialogButton>[
          DialogButton(
            width: 450,
            onPressed: () {
              if (name != null) {
                if (LARegExp.hostnameRegexp.hasMatch(name!)) {
                  Navigator.pop(context);
                  onRename(name!.trim().toLowerCase());
                }
              }
            },
            child: const Text(
              'RENAME',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }
}
