import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';


import '../la_theme.dart';
import '../models/laServer.dart';
import '../models/sshKey.dart';
import '../utils/utils.dart';

class ServerSshKeySelector extends StatefulWidget {

  const ServerSshKeySelector(
      {super.key,
      required this.server,
      this.currentSshKey,
      required this.sshKeys,
      required this.isFirst,
      required this.onSave,
      required this.onAllSameSshKey});
  final LAServer server;
  final SshKey? currentSshKey;
  final List<SshKey> sshKeys;
  final bool isFirst;
  final Function(LAServer) onSave;
  final Function(SshKey?) onAllSameSshKey;

  @override
  State<ServerSshKeySelector> createState() => _ServerSshKeySelectorState();
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
      // isExpanded: true,
      underline: Container(),

      disabledHint: const Text('No ssh keys available'),
      hint: Row(
        children: <Widget>[
          if (_sshKey != null)
            Icon(MdiIcons.key, color: LAColorTheme.laPalette),
          if (_sshKey != null) const SizedBox(width: 5),
          Text(_sshKey != null ? _sshKey!.name : 'No SSH key selected'),
        ],
      ),
      items: widget.sshKeys
          // For now we only support keys with no passphrase
          .where((SshKey k) => k.encrypted != true)
          .toList()
          .map((SshKey sshKey) {
        return DropdownMenuItem(
          value: sshKey,
          child: Row(
            children: <Widget>[
              Icon(MdiIcons.key),
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
              widget.onAllSameSshKey(value);
            }, () {
              widget.server.sshKey = value;
            },
                title: 'Use this ssh key always',
                subtitle:
                    'Do you want to use this ssh key in all your servers?',
                confirmBtn: 'YES',
                cancelBtn: 'NO');
          } else {
            widget.server.sshKey = value;
          }
          widget.onSave(widget.server);
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
