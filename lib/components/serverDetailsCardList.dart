import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/serverDetailsCard.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/la_project.dart';
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
          final project = vm.currentProject;
          return ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: project.numServers(),
              // itemCount: appStateProv.appState.projects.length,
              itemBuilder: (BuildContext context, int index) {
                return ServerDetailsCard(
                    server: project.servers[index],
                    index: index,
                    onSave: (server) {
                      project.upsertServer(server);
                      vm.onSaveCurrentProject(project);
                    },
                    onAllSameSshKey: (sshKey) {
                      for (int i = 0; i < project.servers.length; i++) {
                        project.servers[i].sshKey = sshKey;
                      }
                    },
                    advancedEdit: project.advancedEdit,
                    isFirst: _isFirstServer(index, project.servers.length),
                    sshKeys: vm.sshKeys,
                    ansibleUser:
                        project.getVariableValue("ansible_user").toString());
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
