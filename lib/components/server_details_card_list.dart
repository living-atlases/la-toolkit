import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import '../models/app_state.dart';
import '../models/la_server.dart';
import '../models/la_project.dart';
import '../models/ssh_key.dart';
import '../redux/actions.dart';
import 'server_details_card.dart';

class ServersDetailsCardList extends StatelessWidget {
  const ServersDetailsCardList(this.focusNode, {super.key});

  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ServersCardListViewModel>(
        converter: (Store<AppState> store) {
      return _ServersCardListViewModel(
          currentProject: store.state.currentProject,
          sshKeys: store.state.sshKeys,
          onSaveCurrentProject: (LAProject project) {
            store.dispatch(SaveCurrentProject(project));
          });
    }, builder: (BuildContext context, _ServersCardListViewModel vm) {
      final LAProject project = vm.currentProject;
      return ListView.builder(
          shrinkWrap: true,
          itemCount: project.numServers(),
          // itemCount: appStateProv.appState.projects.length,
          itemBuilder: (BuildContext context, int index) {
            return ServerDetailsCard(
                server: project.servers[index],
                onSave: (LAServer server) {
                  project.upsertServer(server);
                  vm.onSaveCurrentProject(project);
                },
                onAllSameSshKey: (SshKey? sshKey) {
                  for (int i = 0; i < project.servers.length; i++) {
                    project.servers[i].sshKey = sshKey;
                  }
                },
                advancedEdit: project.advancedEdit,
                isFirst: _isFirstServer(index, project.servers.length),
                sshKeys: vm.sshKeys,
                ansibleUser:
                    project.getVariableValue('ansible_user').toString());
          });
    });
  }

  bool _isFirstServer(int index, int length) {
    return index == 0 && length > 1;
  }
}

class _ServersCardListViewModel {
  _ServersCardListViewModel(
      {required this.currentProject,
      required this.sshKeys,
      required this.onSaveCurrentProject});

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
}
