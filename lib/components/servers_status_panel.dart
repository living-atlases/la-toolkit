import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../models/appState.dart';
import '../models/deploymentType.dart';
import '../models/laServer.dart';
import '../models/la_project.dart';
import 'server_status_card.dart';
import 'term_dialog.dart';

class ServersStatusPanel extends StatefulWidget {
  const ServersStatusPanel(
      {super.key, required this.extendedStatus, required this.results});

  final bool extendedStatus;
  final Map<String, dynamic> results;

  @override
  State<ServersStatusPanel> createState() => _ServersStatusPanelState();
}

class _ServersStatusPanelState extends State<ServersStatusPanel> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ServersStatusPanelViewModel>(
        distinct: true,
        converter: (Store<AppState> store) {
          return _ServersStatusPanelViewModel(
            project: store.state.currentProject,
            openTerm: (LAProject project, LAServer server) =>
                TermDialog.openTerm(context, false, project.id, server.name),
          );
        },
        builder: (BuildContext context, _ServersStatusPanelViewModel vm) {
          final Map<String, dynamic> results = widget.results;
          return Wrap(children: <Widget>[
            for (final LAServer server in vm.project.serversWithServices())
              ServerStatusCard(
                server: server,
                services: vm.project.getServerServicesFull(
                    id: server.id, type: DeploymentType.vm),
                alaInstallVersion: vm.project.alaInstallRelease!,
                extendedStatus: widget.extendedStatus,
                status: results.isNotEmpty && results[server.id] != null
                    ? results[server.id]! as List<dynamic>
                    : <dynamic>[],
                onTerm: () => vm.openTerm(vm.project, server),
              )
          ]);
        });
  }
}

class _ServersStatusPanelViewModel {
  _ServersStatusPanelViewModel({required this.project, required this.openTerm});

  final LAProject project;
  final void Function(LAProject, LAServer) openTerm;
}
