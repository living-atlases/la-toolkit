import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/laTheme.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/laServer.dart';
import 'package:la_toolkit/models/sshKey.dart';
import 'package:la_toolkit/redux/actions.dart';
import 'package:la_toolkit/utils/cardContants.dart';
import 'package:la_toolkit/utils/regexp.dart';
import 'package:mdi/mdi.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'gatewaySelector.dart';
import 'genericTextFormField.dart';
import 'helpIcon.dart';

class ServersDetailsCardList extends StatelessWidget {
  final FocusNode focusNode;
  ServersDetailsCardList(this.focusNode, {Key? key}) : super(key: key);

  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ServersCardListViewModel>(
        distinct: false,
        converter: (store) {
          return _ServersCardListViewModel(
              state: store.state,
              onSaveCurrentProject: (project) {
                store.dispatch(SaveCurrentProject(project));
              });
        },
        builder: (BuildContext context, _ServersCardListViewModel vm) {
          final _project = vm.state.currentProject;

          return ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: _project.numServers(),
              // itemCount: appStateProv.appState.projects.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                    margin: CardConstants.defaultSeparation,
                    elevation: CardConstants.defaultElevation,
                    shape: CardConstants.defaultShape,
                    child: Column(mainAxisSize: MainAxisSize.min,
                        // margin: EdgeInsets.fromLTRB(30, 12, 20, 30),
                        children: [
                          ListTile(
                            leading: Icon(Mdi.server),
                            // tileColor: Colors.black12,
                            title: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(_project.servers[index].name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16)),
                                  Tooltip(
                                      message: "Rename the server",
                                      child: IconButton(
                                        icon: const Icon(Icons.edit, size: 18),
                                        color: LAColorTheme.inactive,
                                        onPressed: () => _generateRenameDialog(
                                            context: context,
                                            vm: vm,
                                            server: _project.servers[index],
                                            project: _project),
                                      )),
                                  SizedBox(width: 40),
                                  DropdownButton(
                                    isDense: false,
                                    // isExpanded: true,
                                    underline: Container(),

                                    disabledHint: Text("No ssh keys available"),
                                    hint: Row(
                                      children: [
                                        if (_project.servers[index].sshKey !=
                                            null)
                                          Container(
                                              child: Icon(Mdi.key,
                                                  color:
                                                      LAColorTheme.laPalette)),
                                        if (_project.servers[index].sshKey !=
                                            null)
                                          SizedBox(width: 5),
                                        Container(
                                          child: Text(
                                              _project.servers[index].sshKey !=
                                                      null
                                                  ? _project.servers[index]
                                                      .sshKey!.name
                                                  : "No SSH key selected"),
                                        ),
                                      ],
                                    ),
                                    items: vm.state.sshKeys
                                        // For now we only support keys with no passphrase
                                        .where((k) => k.encrypted != true)
                                        .toList()
                                        .map((SshKey sshKey) {
                                      return DropdownMenuItem(
                                        value: sshKey,
                                        child: Row(
                                          children: [
                                            Icon(Mdi.key),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              sshKey.name,
                                              // style: TextStyle(color: Colors.red),
                                            ),
                                            SizedBox(
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
                                        _project.servers[index].sshKey = value;
                                        vm.onSaveCurrentProject(_project);
                                      }
                                      /* setState(() {
                                    value;
                                  }); */
                                    },
                                  ),
                                  SizedBox(width: 10),
                                  HelpIcon(
                                      wikipage: "SSH-for-Beginners#ssh-keys"),
                                  Flexible(
                                    child: GenericTextFormField(
                                        // IP
                                        label: "IP Address",
                                        hint: "ex: '10.0.0.1' or '84.120.10.4'",
                                        error: 'Wrong IP address.',
                                        initialValue:
                                            _project.servers[index].ip,
                                        isDense: true,
                                        /* isCollapsed: true, */
                                        regexp: LARegExp.ip,
                                        allowEmpty: true,
                                        focusNode: null,
                                        onChanged: (value) {
                                          _project.servers.map((current) {
                                            if (_project.servers[index].uuid ==
                                                current.uuid) {
                                              current.ip = value;
                                              _project.upsertByName(current);
                                            }
                                            return current;
                                          }).toList();
                                          vm.onSaveCurrentProject(_project);
                                        }),
                                  )
                                ]),
                            trailing: HelpIcon(
                                wikipage:
                                    "SSH-for-Beginners#public-and-private-ip-addresses"),
                          ),
                          Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Container(
                                height: _project.advancedEdit ? 180 : 0,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      /* SizedBox(height: 10),
                                      Text("Advanced optional settings:",
                                          style: TextStyle(fontSize: 16)),*/
                                      SizedBox(height: 10),
                                      if (_project.advancedEdit)
                                        Flexible(
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Flexible(
                                                  child: GatewaySelector(
                                                      exclude: _project
                                                          .servers[index]),
                                                ),
                                                HelpIcon(
                                                    wikipage:
                                                        "SSH-For-Beginners#Gateways"),
                                                SizedBox(width: 20),
                                                Flexible(
                                                  child: GenericTextFormField(
                                                      // SSH Port
                                                      label:
                                                          "SSH alternative Port",
                                                      hint:
                                                          'Only if this is different than 22',
                                                      error: 'Invalid port',
                                                      initialValue: _project
                                                                  .servers[
                                                                      index]
                                                                  .sshPort !=
                                                              22
                                                          ? _project
                                                              .servers[index]
                                                              .sshPort
                                                              .toString()
                                                          : null,
                                                      allowEmpty: true,
                                                      isDense: true,
                                                      regexp:
                                                          LARegExp.portNumber,
                                                      onChanged: (value) {
                                                        _project.servers[index]
                                                            .sshPort = value
                                                                    .length >
                                                                0
                                                            ? int.parse(value)
                                                            : 22;
                                                        vm.onSaveCurrentProject(
                                                            _project);
                                                      }),
                                                ),
                                                HelpIcon(
                                                    wikipage:
                                                        "SSH-For-Beginners#ssh-ports"),
                                                SizedBox(width: 20),
                                                Flexible(
                                                  child: GenericTextFormField(
                                                      // SSH User
                                                      label:
                                                          "SSH alternative username",
                                                      hint:
                                                          'Only if it\'s different than \'${_project.getVariable("ansible_user").value}\' in this server',
                                                      error: 'Invalid username',
                                                      initialValue: _project
                                                              .servers[index]
                                                              .sshUser ??
                                                          '',
                                                      isDense: true,
                                                      regexp: LARegExp.username,
                                                      allowEmpty: true,
                                                      onChanged: (value) {
                                                        _project.servers[index]
                                                            .sshUser = value;
                                                        vm.onSaveCurrentProject(
                                                            _project);
                                                      }),
                                                )
                                              ]),
                                        ),
                                      if (_project.advancedEdit)
                                        Flexible(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Flexible(
                                                child: GenericTextFormField(
                                                    // ALIASES
                                                    label:
                                                        "Aliases (other names you give to this server separated by spaces)",
                                                    /* hint:
                                                      'e.g. \'${_project.getService('collectory')?.url(_project.domain)} ${_project.getService('ala_hub')?.url(_project.domain)} ${_project.getService('ala_bie')?.suburl}\' ', */
                                                    error: 'Wrong aliases.',
                                                    initialValue: _project
                                                        .servers[index].aliases
                                                        .join(' '),
                                                    isDense: true,
                                                    /* isCollapsed: true, */
                                                    regexp:
                                                        LARegExp.aliasesRegexp,
                                                    onChanged: (value) {
                                                      _project.servers[index]
                                                              .aliases =
                                                          value.split(' ');
                                                      vm.onSaveCurrentProject(
                                                          _project);
                                                    }),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ]),
                              ))
                        ]));
                /*

                    Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                        child: ListTile(
                          contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          title: Text(_project.servers[index].name),
                        )));*/
              });
        });
  }

  _generateRenameDialog(
      {required BuildContext context,
      required _ServersCardListViewModel vm,
      required LAServer server,
      required LAProject project}) {
    var name;
    Alert(
        context: context,
        closeIcon: Icon(Icons.close),
        image: Icon(Mdi.key, size: 60, color: LAColorTheme.inactive),
        title: "Server rename",
        style: AlertStyle(
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
            SizedBox(
              height: 20,
            ),
          ],
        ),
        buttons: [
          DialogButton(
            width: 500,
            onPressed: () {
              if (LARegExp.hostnameRegexp.hasMatch(name)) {
                server.name = name;
                project.upsertById(server);
                vm.onSaveCurrentProject(project);
                Navigator.pop(context);
              }
            },
            child: Text(
              "RENAME",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }
}

class _ServersCardListViewModel {
  final AppState state;
  final void Function(LAProject project) onSaveCurrentProject;

  _ServersCardListViewModel(
      {required this.state, required this.onSaveCurrentProject});
}
