import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../models/laServer.dart';
import '../models/sshKey.dart';
import '../utils/cardConstants.dart';
import '../utils/regexp.dart';
import 'gatewaySelector.dart';
import 'genericTextFormField.dart';
import 'help_icon.dart';
import 'renameServerIcon.dart';
import 'serverSshKeySelector.dart';

class ServerDetailsCard extends StatelessWidget {
  const ServerDetailsCard(
      {super.key,
      required this.server,
      required this.onSave,
      required this.onAllSameSshKey,
      required this.advancedEdit,
      required this.isFirst,
      required this.sshKeys,
      required this.ansibleUser});
  final LAServer server;

  final Function(LAServer) onSave;
  final Function(SshKey?) onAllSameSshKey;
  final bool advancedEdit;
  final bool isFirst;
  final List<SshKey> sshKeys;
  final String ansibleUser;

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: CardConstants.defaultSeparation,
        elevation: CardConstants.defaultElevation,
        shape: CardConstants.defaultShape,
        child: Column(
            mainAxisSize: MainAxisSize.min,
            // margin: EdgeInsets.fromLTRB(30, 12, 20, 30),
            children: <Widget>[
              ListTile(
                leading: Icon(MdiIcons.server),
                // tileColor: Colors.black12,
                title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(server.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 16)),
                      RenameServerIcon(server, () {}, (String newName) {
                        server.name = newName;
                        onSave(server);
                      }),
                      const SizedBox(width: 40),
                      ServerSshKeySelector(
                          key: ValueKey(
                              server.name + server.sshKey.hashCode.toString()),
                          server: server,
                          currentSshKey: server.sshKey,
                          isFirst: isFirst,
                          sshKeys: sshKeys,
                          onSave: onSave,
                          onAllSameSshKey: onAllSameSshKey),
                      const SizedBox(width: 10),
                      HelpIcon(wikipage: 'SSH-for-Beginners#ssh-keys'),
                      const SizedBox(width: 10),
                      Flexible(
                        child: GenericTextFormField(
                            // IP
                            label: 'IP Address',
                            hint: "ex: '10.0.0.1' or '84.120.10.4'",
                            error: 'Wrong IP address.',
                            initialValue: server.ip,
                            isDense: true,
                            /* isCollapsed: true, */
                            regexp: LARegExp.ip,
                            allowEmpty: true,
                            onChanged: (String value) {
                              server.ip = value;
                              onSave(server);
                            }),
                      )
                    ]),
                trailing: HelpIcon(
                    wikipage:
                        'SSH-for-Beginners#public-and-private-ip-addresses'),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child:
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  /* SizedBox(height: 10),
                                    Text("Advanced optional settings:",
                                        style: TextStyle(fontSize: 16)),*/
                  // SizedBox(height: 10),
                  if (advancedEdit)
                    Flexible(
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Flexible(
                              child: GatewaySelector(
                                  key: ValueKey(server.name +
                                      server.gateways.hashCode.toString()),
                                  firstServer: isFirst,
                                  exclude: server),
                            ),
                            HelpIcon(wikipage: 'SSH-For-Beginners#Gateways'),
                            const SizedBox(width: 20),
                            Flexible(
                              child: GenericTextFormField(
                                  // SSH Port
                                  label: 'SSH alternative Port',
                                  hint: 'Only if this is different than 22',
                                  error: 'Invalid port',
                                  initialValue: server.sshPort != 22
                                      ? server.sshPort.toString()
                                      : null,
                                  allowEmpty: true,
                                  isDense: true,
                                  regexp: LARegExp.portNumber,
                                  onChanged: (String value) {
                                    server.sshPort = value.isNotEmpty
                                        ? int.parse(value)
                                        : 22;
                                    onSave(server);
                                  }),
                            ),
                            HelpIcon(wikipage: 'SSH-For-Beginners#ssh-ports'),
                            const SizedBox(width: 20),
                            Flexible(
                              child: GenericTextFormField(
                                  // SSH User
                                  label: 'SSH alternative username',
                                  hint:
                                      "Only if it's different than '$ansibleUser' in this server",
                                  error: 'Invalid username',
                                  initialValue: server.sshUser ?? '',
                                  isDense: true,
                                  regexp: LARegExp.username,
                                  allowEmpty: true,
                                  onChanged: (String value) {
                                    server.sshUser = value;
                                    onSave(server);
                                  }),
                            )
                          ]),
                    ),
                  if (advancedEdit)
                    Flexible(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Flexible(
                            child: GenericTextFormField(
                                // ALIASES
                                label:
                                    'Aliases (other names you give to this server separated by spaces)',
                                /* hint:
                                                    'e.g. \'${_project.getService('collectory')?.url(_project.domain)} ${_project.getService('ala_hub')?.url(_project.domain)} ${_project.getService('ala_bie')?.suburl}\' ', */
                                error: 'Wrong aliases.',
                                initialValue: server.aliases.join(' '),
                                isDense: true,
                                /* isCollapsed: true, */
                                regexp: LARegExp.aliasesRegexp,
                                onChanged: (String value) {
                                  server.aliases = value.split(' ');
                                  onSave(server);
                                }),
                          ),
                        ],
                      ),
                    ),
                ]),
              )
            ]));
  }
}
