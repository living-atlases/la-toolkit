import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/renameServerIcon.dart';
import 'package:la_toolkit/components/serverSshKeySelector.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/sshKey.dart';
import 'package:la_toolkit/redux/actions.dart';
import 'package:la_toolkit/utils/cardConstants.dart';
import 'package:la_toolkit/utils/regexp.dart';
import 'package:mdi/mdi.dart';

import 'gatewaySelector.dart';
import 'genericTextFormField.dart';
import 'helpIcon.dart';

class ServersDetailsCardList extends StatelessWidget {
  final FocusNode focusNode;

  const ServersDetailsCardList(this.focusNode, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ServersCardListViewModel>(
        distinct: true,
        converter: (store) {
          return _ServersCardListViewModel(
              currentProject: store.state.currentProject,
              sshKeys: store.state.sshKeys,
              onSaveCurrentProject: (project) {
                store.dispatch(SaveCurrentProject(project));
              });
        },
        builder: (BuildContext context, _ServersCardListViewModel vm) {
          final _project = vm.currentProject;

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
                            leading: const Icon(Mdi.server),
                            // tileColor: Colors.black12,
                            title: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(_project.servers[index].name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16)),
                                  RenameServerIcon(
                                      _project,
                                      _project.servers[index],
                                      (LAProject project) =>
                                          vm.onSaveCurrentProject(project)),
                                  const SizedBox(width: 40),
                                  ServerSshKeySelector(
                                      key: ValueKey(
                                          _project.servers[index].name +
                                              _project.servers[index].sshKey
                                                  .hashCode
                                                  .toString()),
                                      project: _project,
                                      server: _project.servers[index],
                                      currentSshKey:
                                          _project.servers[index].sshKey,
                                      isFirst: _isFirstServer(
                                          index, _project.servers.length),
                                      sshKeys: vm.sshKeys,
                                      onSave: (LAProject project) =>
                                          vm.onSaveCurrentProject(project)),
                                  const SizedBox(width: 10),
                                  HelpIcon(
                                      wikipage: "SSH-for-Beginners#ssh-keys"),
                                  const SizedBox(width: 10),
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
                                            if (_project.servers[index].id ==
                                                current.id) {
                                              current.ip = value;
                                              _project.upsertServer(current);
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
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  /* SizedBox(height: 10),
                                      Text("Advanced optional settings:",
                                          style: TextStyle(fontSize: 16)),*/
                                  // SizedBox(height: 10),
                                  if (_project.advancedEdit)
                                    Flexible(
                                      child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Flexible(
                                              child: GatewaySelector(
                                                  key: ValueKey(_project
                                                          .servers[index].name +
                                                      _project.servers[index]
                                                          .gateways.hashCode
                                                          .toString()),
                                                  firstServer: _isFirstServer(
                                                      index,
                                                      _project.servers.length),
                                                  exclude:
                                                      _project.servers[index]),
                                            ),
                                            HelpIcon(
                                                wikipage:
                                                    "SSH-For-Beginners#Gateways"),
                                            const SizedBox(width: 20),
                                            Flexible(
                                              child: GenericTextFormField(
                                                  // SSH Port
                                                  label: "SSH alternative Port",
                                                  hint:
                                                      'Only if this is different than 22',
                                                  error: 'Invalid port',
                                                  initialValue: _project
                                                              .servers[index]
                                                              .sshPort !=
                                                          22
                                                      ? _project.servers[index]
                                                          .sshPort
                                                          .toString()
                                                      : null,
                                                  allowEmpty: true,
                                                  isDense: true,
                                                  regexp: LARegExp.portNumber,
                                                  onChanged: (value) {
                                                    _project.servers[index]
                                                            .sshPort =
                                                        value.isNotEmpty
                                                            ? int.parse(value)
                                                            : 22;
                                                    vm.onSaveCurrentProject(
                                                        _project);
                                                  }),
                                            ),
                                            HelpIcon(
                                                wikipage:
                                                    "SSH-For-Beginners#ssh-ports"),
                                            const SizedBox(width: 20),
                                            Flexible(
                                              child: GenericTextFormField(
                                                  // SSH User
                                                  label:
                                                      "SSH alternative username",
                                                  hint:
                                                      'Only if it\'s different than \'${_project.getVariableValue("ansible_user")}\' in this server',
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
                                                regexp: LARegExp.aliasesRegexp,
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
                          )
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

  bool _isFirstServer(int index, int length) {
    return index == 0 && length > 1;
  }
}

class _ServersCardListViewModel {
  final List<SshKey> sshKeys;
  final LAProject currentProject;
  final void Function(LAProject project) onSaveCurrentProject;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ServersCardListViewModel &&
          runtimeType == other.runtimeType &&
          sshKeys == other.sshKeys &&
          currentProject == other.currentProject;

  @override
  int get hashCode => sshKeys.hashCode ^ currentProject.hashCode;

  _ServersCardListViewModel(
      {required this.currentProject,
      required this.sshKeys,
      required this.onSaveCurrentProject});
}
