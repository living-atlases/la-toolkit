import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/serverDetailsCard.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/sshKey.dart';
import 'package:la_toolkit/redux/actions.dart';

class ServersDetailsCardList extends StatelessWidget {
  final FocusNode focusNode;

  const ServersDetailsCardList(this.focusNode, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ServersCardListViewModel>(
        distinct: false,
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
                return ServerDetailsCard(
                    server: _project.servers[index],
                    index: index,
                    onSave: (server) {
                      _project.upsertServer(server);
                      vm.onSaveCurrentProject(_project);
                    },
                    onAllSameSshKey: (sshKey) {
                      for (int i = 0; i < _project.servers.length; i++) {
                        _project.servers[i].sshKey = sshKey;
                      }
                    },
                    advancedEdit: _project.advancedEdit,
                    isFirst: _isFirstServer(index, _project.servers.length),
                    sshKeys: vm.sshKeys,
                    ansibleUser:
                        _project.getVariableValue("ansible_user").toString());
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
