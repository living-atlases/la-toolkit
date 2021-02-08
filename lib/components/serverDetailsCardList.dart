import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/redux/actions.dart';
import 'package:la_toolkit/utils/cardContants.dart';
import 'package:la_toolkit/utils/regexp.dart';
import 'package:mdi/mdi.dart';

import 'genericTextFormField.dart';
import 'helpIcon.dart';
import 'hostSelector.dart';

class ServersDetailsCardList extends StatelessWidget {
  final FocusNode focusNode;
  ServersDetailsCardList(this.focusNode, {Key key}) : super(key: key);

  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ServersCardListViewModel>(
        distinct: false,
        converter: (store) {
          return _ServersCardListViewModel(
              currentProject: store.state.currentProject,
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
                            leading: Icon(Mdi.server),
                            // tileColor: Colors.black12,
                            title: Row(children: [
                              Text(_project.servers[index].name,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16)),
                              SizedBox(width: 20),
                              Flexible(
                                child: GenericTextFormField(
                                    // IP
                                    label: "IP Address",
                                    hint: "ex: '10.0.0.1' or '84.120.10.4'",
                                    error: 'Wrong IP address.',
                                    initialValue: _project.servers[index].ip,
                                    isDense: true,
                                    /* isCollapsed: true, */
                                    regexp: LARegExp.ip,
                                    allowEmpty: true,
                                    focusNode: null,
                                    onChanged: (value) {
                                      _project.servers.map((current) {
                                        if (_project.servers[index].name ==
                                            current.name) {
                                          current.ip = value;
                                          _project.upsert(current);
                                        }
                                        return current;
                                      }).toList();
                                      vm.onSaveCurrentProject(_project);
                                    }),
                              )
                            ]),
                            trailing: HelpIcon(wikipage: "SSH-for-Beginners"),
                          ),
                          Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Container(
                                height: 200,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 10),
                                      Text("Advanced optional settings:",
                                          style: TextStyle(fontSize: 16)),
                                      SizedBox(height: 10),
                                      Flexible(
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Flexible(
                                                child: HostSelector(
                                                    server: _project
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
                                                                .servers[index]
                                                                .sshPort !=
                                                            22
                                                        ? _project
                                                            .servers[index]
                                                            .sshPort
                                                        : '',
                                                    isDense: true,
                                                    regexp: LARegExp.portNumber,
                                                    onChanged: (value) {
                                                      _project.servers
                                                          .map((current) {
                                                        if (_project
                                                                .servers[index]
                                                                .name ==
                                                            current.name) {
                                                          current.sshPort =
                                                              int.parse(value);
                                                          _project
                                                              .upsert(current);
                                                        }
                                                        return current;
                                                      });
                                                      vm.onSaveCurrentProject(
                                                          _project);
                                                    }),
                                              ),
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
                                                    onChanged: (value) {
                                                      _project.servers
                                                          .map((current) {
                                                        if (_project
                                                                .servers[index]
                                                                .name ==
                                                            current.name) {
                                                          current.sshUser =
                                                              value;
                                                          _project
                                                              .upsert(current);
                                                        }
                                                        return current;
                                                      });
                                                      vm.onSaveCurrentProject(
                                                          _project);
                                                    }),
                                              )
                                            ]),
                                      ),
                                      Flexible(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Flexible(
                                              child: GenericTextFormField(
                                                  // ALIASES
                                                  label:
                                                      "Aliases (other names you give to this server)",
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
                                                    _project.servers
                                                        .map((current) {
                                                      if (_project
                                                              .servers[index]
                                                              .name ==
                                                          current.name) {
                                                        current.aliases =
                                                            value.split(' ');
                                                        _project
                                                            .upsert(current);
                                                      }
                                                      return current;
                                                    });

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
}

class _ServersCardListViewModel {
  final LAProject currentProject;
  final void Function(LAProject project) onSaveCurrentProject;

  _ServersCardListViewModel({this.currentProject, this.onSaveCurrentProject});
}
