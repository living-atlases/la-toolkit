import 'package:flutter/material.dart';
import 'package:la_toolkit/laTheme.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/laServer.dart';
import 'package:la_toolkit/utils/regexp.dart';
import 'package:mdi/mdi.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'genericTextFormField.dart';

class RenameServerIcon extends StatelessWidget {
  final LAProject project;
  final Function(LAProject) onRename;
  final LAServer server;

  const RenameServerIcon(this.project, this.server, this.onRename, {Key? key})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Tooltip(
        message: "Rename the server",
        child: IconButton(
          icon: const Icon(Icons.edit, size: 18),
          color: LAColorTheme.inactive,
          onPressed: () => _generateRenameDialog(
              context: context,
              onRename: (LAProject project) => onRename(project),
              server: server,
              project: project),
        ));
  }

  _generateRenameDialog(
      {required BuildContext context,
      required Function(LAProject) onRename,
      required LAServer server,
      required LAProject project}) {
    String? name;
    Alert(
        context: context,
        closeIcon: const Icon(Icons.close),
        image: const Icon(Mdi.key, size: 60, color: LAColorTheme.inactive),
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
                  server.name = name!;
                  project.upsertById(server);
                  onRename(project);
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
