import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/serverStatusCard.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';

class ServersStatusPanel extends StatefulWidget {
  final bool extendedStatus;
  ServersStatusPanel({Key? key, required this.extendedStatus})
      : super(key: key);

  @override
  _ServersStatusPanelState createState() => _ServersStatusPanelState();
}

class _ServersStatusPanelState extends State<ServersStatusPanel> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ServersStatusPanelViewModel>(
        distinct: true,
        converter: (store) {
          return _ServersStatusPanelViewModel(
            project: store.state.currentProject,
          );
        },
        builder: (BuildContext context, _ServersStatusPanelViewModel vm) {
          return Wrap(children: [
            for (var server in vm.project.serversWithServices())
              ServerStatusCard(
                  server,
                  vm.project.getServerServices(serverUuid: server.uuid),
                  widget.extendedStatus)
          ]);
        });
  }
}

class _ServersStatusPanelViewModel {
  final LAProject project;

  _ServersStatusPanelViewModel({required this.project});
}
