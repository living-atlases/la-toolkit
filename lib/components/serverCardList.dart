import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/renameServerIcon.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/laService.dart';
import 'package:la_toolkit/redux/actions.dart';
import 'package:la_toolkit/utils/cardConstants.dart';
import 'package:la_toolkit/utils/utils.dart';

class ServersCardList extends StatelessWidget {
  ServersCardList({Key? key}) : super(key: key);

  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ServersCardListViewModel>(
        distinct: true,
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
                return IntrinsicWidth(
                    child: Card(
                        margin: CardConstants.defaultSeparation,
                        elevation: CardConstants.defaultElevation,
                        shape: CardConstants.defaultShape,
                        child: Container(
                            margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                            child: ListTile(
                                contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                title: Text(_project.servers[index].name),
                                subtitle: Text(LAService.servicesForHumans(
                                    _project.getServerServicesFull(
                                        serverId: _project.servers[index].id))),
                                trailing:
                                    Wrap(spacing: 12, // space between two icons
                                        children: <Widget>[
                                      RenameServerIcon(
                                          _project,
                                          _project.servers[index],
                                          (LAProject project) =>
                                              vm.onSaveCurrentProject(project)),
                                      Tooltip(
                                          message: "Delete this server",
                                          child: IconButton(
                                              icon: const Icon(Icons.delete),
                                              onPressed: () =>
                                                  UiUtils.showAlertDialog(
                                                      context, () {
                                                    _project.delete(_project
                                                        .servers[index]);
                                                    _project.validateCreation();
                                                    vm.onSaveCurrentProject(
                                                        _project);
                                                  }, () => {},
                                                      title:
                                                          "Deleting the server '${_project.servers[index].name}'"))),
                                    ])))));
              });
        });
  }
}

class _ServersCardListViewModel {
  final LAProject currentProject;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ServersCardListViewModel &&
          runtimeType == other.runtimeType &&
          currentProject == other.currentProject;

  @override
  int get hashCode => currentProject.hashCode;
  final void Function(LAProject project) onSaveCurrentProject;

  _ServersCardListViewModel(
      {required this.currentProject, required this.onSaveCurrentProject});
}
