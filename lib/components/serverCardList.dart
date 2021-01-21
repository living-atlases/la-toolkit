import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/redux/actions.dart';

class ServersCardList extends StatelessWidget {
  ServersCardList({Key key}) : super(key: key);

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
                    elevation: 1,
                    child: Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                        child: ListTile(
                          contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          title: Text(_project.servers[index].name),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _project.delete(_project.servers[index]);
                              vm.onSaveCurrentProject(_project);
                            },
                          ),
                        )));
              });
        });
  }
}

class _ServersCardListViewModel {
  final LAProject currentProject;
  final void Function(LAProject project) onSaveCurrentProject;

  _ServersCardListViewModel({this.currentProject, this.onSaveCurrentProject});
}
