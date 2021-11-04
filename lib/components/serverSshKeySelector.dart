import 'package:flutter/material.dart';
import 'package:la_toolkit/laTheme.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/laServer.dart';
import 'package:la_toolkit/models/sshKey.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:mdi/mdi.dart';

class ServerSshKeySelector extends StatefulWidget {
  final LAServer server;
  final SshKey? currentSshKey;
  final List<SshKey> sshKeys;
  final bool isFirst;
  final LAProject project;
  final Function(LAProject) onSave;
  const ServerSshKeySelector(
      {Key? key,
      required this.project,
      required this.server,
      this.currentSshKey,
      required this.sshKeys,
      required this.isFirst,
      required this.onSave})
      : super(key: key);

  @override
  _ServerSshKeySelectorState createState() => _ServerSshKeySelectorState();
}

class _ServerSshKeySelectorState extends State<ServerSshKeySelector> {
  SshKey? _sshKey;
  @override
  void initState() {
    _sshKey = widget.currentSshKey;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      isDense: false,
      // isExpanded: true,
      underline: Container(),

      disabledHint: const Text("No ssh keys available"),
      hint: Row(
        children: [
          if (_sshKey != null)
            const Icon(Mdi.key, color: LAColorTheme.laPalette),
          if (_sshKey != null) const SizedBox(width: 5),
          Text(_sshKey != null ? _sshKey!.name : "No SSH key selected"),
        ],
      ),
      items: widget.sshKeys
          // For now we only support keys with no passphrase
          .where((k) => k.encrypted != true)
          .toList()
          .map((SshKey sshKey) {
        return DropdownMenuItem(
          value: sshKey,
          child: Row(
            children: [
              const Icon(Mdi.key),
              const SizedBox(
                width: 10,
              ),
              Text(
                sshKey.name,
                // style: TextStyle(color: Colors.red),
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                sshKey.desc,
                // style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (SshKey? value) {
        if (value != null) {
          if (widget.isFirst) {
            UiUtils.showAlertDialog(context, () {
              for (int i = 0; i < widget.project.servers.length; i++) {
                widget.project.servers[i].sshKey = value;
              }
            }, () {
              widget.server.sshKey = value;
            },
                title: "Use this ssh key always",
                subtitle:
                    "Do you want to use this ssh key in all your servers?",
                confirmBtn: "YES",
                cancelBtn: "NO");
          } else {
            widget.server.sshKey = value;
          }
          widget.project.upsertServer(widget.server);
          widget.onSave(widget.project);
          if (mounted) {
            setState(() {
              _sshKey = value;
            });
          }
        }
      },
    );
  }
}
