import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laServer.dart';
import 'package:la_toolkit/models/la_project.dart';
import 'package:la_toolkit/redux/actions.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'serverSelector.dart';

class GatewaySelector extends StatelessWidget {
  final bool firstServer;
  final LAServer exclude;

  const GatewaySelector(
      {Key? key, required this.firstServer, required this.exclude})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _GatewaySelectorViewModel>(
        distinct: false,
        converter: (store) {
          return _GatewaySelectorViewModel(
              project: store.state.currentProject,
              server: exclude,
              onSaveProject: (project) =>
                  store.dispatch(SaveCurrentProject(project)));
        },
        builder: (BuildContext context, _GatewaySelectorViewModel vm) {
          List<String> initialValue = vm.project.servers
              .where((s) => vm.server.gateways.contains(s.id))
              .map((s) => s.name)
              .toList();
          // print("Building gateway selector for ${vm.server.name}");
          return ServerSelector(
            selectorKey: GlobalKey<FormFieldState<dynamic>>(),
            exclude: vm.server,
            initialValue: initialValue,
            hosts: vm.project.getServersNameList(),
            title: "SSH Gateway",
            icon: MdiIcons.doorClosedLock,
            modalTitle:
                "Select the server (or servers) that is used as gateway to access to this server:",
            placeHolder: "Direct connection",
            /* choiceEmptyPanel: ChoiceEmptyPanel(
                title: "This server doesn't have a ssh gateway associated",
                body:
                    "If you access to this server using another server as a ssh gateway, you should add the gateway also as a server and select later here.",
                footer: "For more info see our ssh documentation in our wiki"), */
            onChange: (List<String> gatewaysNames) {
              print(
                  "Gateway name-------------------------------------: $gatewaysNames");
              List<String> gatewaysIds = vm.project.servers
                  .where((s) => gatewaysNames.contains(s.name))
                  .map((s) => s.id)
                  .toList();
              print("Gateway ids: $gatewaysIds");
              if (firstServer) {
                UiUtils.showAlertDialog(context, () {
                  for (LAServer s in vm.project.servers) {
                    if (!gatewaysIds.contains(s.id)) {
                      print("Setting gateways for ${s.name}");
                      s.gateways = gatewaysIds;
                      vm.project.upsertServer(s);
                    }
                  }
                }, () {
                  vm.server.gateways = gatewaysIds;
                  vm.project.upsertServer(vm.server);
                },
                    title: "Use this gateway always",
                    subtitle:
                        "Do you want to use the same gateway for all your servers?",
                    confirmBtn: "YES",
                    cancelBtn: "NO");
              } else {
                vm.server.gateways = gatewaysIds;
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
