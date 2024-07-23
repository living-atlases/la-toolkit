import 'package:flutter/material.dart';

import 'laTheme.dart';
import 'project_edit_page.dart';
import 'utils/regexp.dart';

class ServerTextField extends StatelessWidget {
  const ServerTextField(
      {super.key,
      required this.controller,
      required this.focusNode,
      required this.formKey,
      required this.onAddServer});

  final TextEditingController controller;
  final FocusNode focusNode;

  final GlobalKey<FormState> formKey;
  final Function(String) onAddServer;
  static const String serverHint =
      "Something typically like 'vm1', 'vm2', 'vm3' or 'aws-ip-12-34-56-78', 'aws-ip-12-34-56-79', 'aws-ip-12-34-56-80'";

  @override
  Widget build(BuildContext context) {
    return Form(
        key: formKey,
        child: Column(children: <Widget>[
          // Add TextFormFields and ElevatedButton here.
          TextFormField(
            controller: controller,
            showCursor: true,
            cursorColor: Colors.orange,
            style: LAColorTheme.unDeployedTextStyle,
            onFieldSubmitted: (String value) {
              addServer(value.toLowerCase());
            },
            focusNode: focusNode,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (String? value) {
              return value != null &&
                      (LARegExp.hostnameRegexp.hasMatch(value) ||
                          LARegExp.multiHostnameRegexp.hasMatch(value) ||
                          value.isEmpty)
                  ? null
                  : 'Invalid server name.';
            },
            decoration: InputDecoration(
                suffixIcon: IconButton(
                    icon: const Icon(Icons.add_circle),
                    onPressed: () {
                      debugPrint('Trying to add server/s ${controller.text}');
                      if (formKey.currentState != null &&
                          formKey.currentState!.validate()) {
                        controller.text = controller.text.toLowerCase();
                        addServer(controller.text);
                      }
                    },
                    color: LAColorTheme.inactive),
                hintText: serverHint,
                labelText:
                    "Type the name of your servers, comma or space separated (Press 'enter' to add it)"),
          )
        ]));
  }

  void addServer(String value) {
    LAProjectEditPage.serversNameSplit(value).forEach((String server) {
      onAddServer(server.trim());
      controller.clear();
    });
  }
}
