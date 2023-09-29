import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/serverStatusCard.dart';
import 'package:la_toolkit/components/termDialog.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/laServer.dart';

import '../models/deploymentType.dart';

class ServersStatusPanel extends StatefulWidget {
  final bool extendedStatus;
  final Map<String, dynamic> results;

  const ServersStatusPanel(
      {Key? key, required this.extendedStatus, required this.results})
      : super(key: key);

  @override
  State<ServersStatusPanel> createState() => _ServersStatusPanelState();
}

class _ServersStatusPanelState extends State<ServersStatusPanel> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ServersStatusPanelViewModel>(
        distinct: true,
        converter: (store) {
          return _ServersStatusPanelViewModel(
            project: store.state.currentProject,
            openTerm: (project, server) =>
                TermDialog.openTerm(context, false, project.id, server.name),
          );
        },
        builder: (BuildContext context, _ServersStatusPanelViewModel vm) {
          return Wrap(children: [
            for (var server in vm.project.serversWithServices())
              ServerStatusCard(
                server: server,
                services: vm.project.getServerServicesFull(
                    id: server.id, type: DeploymentType.vm),
                alaInstallVersion: vm.project.alaInstallRelease!,
                extendedStatus: widget.extendedStatus,
                status: widget.results.isNotEmpty &&
                        widget.results[server.id] != null
                    ? widget.results[server.id]
                    : [],
                onTerm: () => vm.openTerm(vm.project, server),
              )
          ]);
        });
  }
}

class _ServersStatusPanelViewModel {
  final LAProject project;
  final void Function(LAProject, LAServer) openTerm;

  _ServersStatusPanelViewModel({required this.project, required this.openTerm});
}
