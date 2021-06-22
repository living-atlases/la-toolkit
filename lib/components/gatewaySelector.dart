import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/laServer.dart';
import 'package:la_toolkit/redux/actions.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:mdi/mdi.dart';

import 'serverSelector.dart';

class GatewaySelector extends StatefulWidget {
  final bool firstServer;
  final LAServer exclude;
  const GatewaySelector(
      {Key? key, required this.firstServer, required this.exclude})
      : super(key: key);

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
              server: store.state.currentProject.servers
                  .firstWhere((s) => s.id == widget.exclude.id,
                      // workaround for delete servers
                      orElse: () => widget.exclude),
              onSaveProject: (project) =>
                  store.dispatch(SaveCurrentProject(project)));
        },
        builder: (BuildContext context, _GatewaySelectorViewModel vm) {
          return ServerSelector(
            selectorKey: GlobalKey<FormFieldState>(),
            exclude: vm.server,
            initialValue: vm.server.gateways,
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
            onChange: (List<String> gateways) {
              if (widget.firstServer) {
                UiUtils.showAlertDialog(context, () {
                  for (int i = 0; i < vm.project.servers.length; i++) {
                    LAServer s = vm.project.servers[i];
                    if (!gateways.contains(s.name)) {
                      print("Setting gateways for ${s.name}");
                      s.gateways = gateways;
                      vm.project.upsertServer(s);
                    }
                  }
                }, () {
                  vm.server.gateways = gateways;
                  vm.project.upsertServer(vm.server);
                },
                    title: "Use this gateway always",
                    subtitle:
                        "Do you want to use the same gateway for all your servers?",
                    confirmBtn: "YES",
                    cancelBtn: "NO");
              } else {
                vm.server.gateways = gateways;
                vm.project.upsertServer(vm.server);
              }
              vm.onSaveProject(vm.project);
            },
          );
        });
  }
}

class _GatewaySelectorViewModel {
  final LAProject project;
  final LAServer server;
  final void Function(LAProject project) onSaveProject;

  _GatewaySelectorViewModel(
      {required this.project,
      required this.server,
      required this.onSaveProject});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _GatewaySelectorViewModel &&
          runtimeType == other.runtimeType &&
          server == other.server &&
          project == other.project;

  @override
  int get hashCode => project.hashCode ^ server.hashCode;
}
