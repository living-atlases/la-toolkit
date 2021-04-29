import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/laServer.dart';
import 'package:la_toolkit/redux/actions.dart';
import 'package:mdi/mdi.dart';

import 'hostsSelector.dart';

class GatewaySelector extends StatefulWidget {
  final LAServer exclude;
  GatewaySelector({Key? key, required this.exclude}) : super(key: key);

  @override
  _GatewaySelectorState createState() => _GatewaySelectorState();
}

class _GatewaySelectorState extends State<GatewaySelector> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _GatewaySelectorViewModel>(
        distinct: true,
        converter: (store) {
          return _GatewaySelectorViewModel(
              project: store.state.currentProject,
              onSaveProject: (project) =>
                  store.dispatch(SaveCurrentProject(project)));
        },
        builder: (BuildContext context, _GatewaySelectorViewModel vm) {
          return HostsSelector(
            selectorKey: GlobalKey<FormFieldState>(),
            exclude: widget.exclude,
            initialValue: widget.exclude.gateways,
            hosts: vm.project.getServersNameList(),
            title: "SSH Gateway",
            icon: Mdi.doorClosedLock,
            modalTitle:
                "Select the server (or servers) that is used as gateway to access to this server:",
            placeHolder: "Direct connection",
            /* choiceEmptyPanel: ChoiceEmptyPanel(
                title: "This server doesn't have a ssh gateway associated",
                body:
                    "If you access to this server using another server as a ssh gateway, you should add the gateway also as a server and select later here.",
                footer: "For more info see our ssh documentation in our wiki"), */
            onChange: (gateways) {
              widget.exclude.gateways = gateways;
              vm.project.upsertByName(widget.exclude);
              vm.onSaveProject(vm.project);
            },
          );
        });
  }
}

class _GatewaySelectorViewModel {
  final LAProject project;
  final void Function(LAProject project) onSaveProject;

  _GatewaySelectorViewModel(
      {required this.project, required this.onSaveProject});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _GatewaySelectorViewModel &&
          runtimeType == other.runtimeType &&
          project == other.project;

  @override
  int get hashCode => project.hashCode;
}
