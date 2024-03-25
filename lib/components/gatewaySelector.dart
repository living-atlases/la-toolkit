import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:redux/redux.dart';
import '../models/appState.dart';
import '../models/laServer.dart';
import '../models/la_project.dart';
import '../redux/actions.dart';
import '../utils/utils.dart';
import 'serverSelector.dart';

class GatewaySelector extends StatelessWidget {
  const GatewaySelector(
      {super.key, required this.firstServer, required this.exclude});

  final bool firstServer;
  final LAServer exclude;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _GatewaySelectorViewModel>(
        converter: (Store<AppState> store) {
      return _GatewaySelectorViewModel(
          project: store.state.currentProject,
          server: exclude,
          onSaveProject: (LAProject project) =>
              store.dispatch(SaveCurrentProject(project)));
    }, builder: (BuildContext context, _GatewaySelectorViewModel vm) {
      final List<String> initialValue = vm.project.servers
          .where((LAServer s) => vm.server.gateways.contains(s.id))
          .map((LAServer s) => s.name)
          .toList();
      // debugPrint("Building gateway selector for ${vm.server.name}");
      return ServerSelector(
        selectorKey: GlobalKey<FormFieldState<dynamic>>(),
        exclude: vm.server,
        initialValue: initialValue,
        hosts: vm.project.getServersNameList(),
        title: 'SSH Gateway',
        icon: MdiIcons.doorClosedLock,
        modalTitle:
            'Select the server (or servers) that is used as gateway to access to this server:',
        placeHolder: 'Direct connection',
        /* choiceEmptyPanel: ChoiceEmptyPanel(
                title: "This server doesn't have a ssh gateway associated",
                body:
                    "If you access to this server using another server as a ssh gateway, you should add the gateway also as a server and select later here.",
                footer: "For more info see our ssh documentation in our wiki"), */
        onChange: (List<String> gatewaysNames) {
          debugPrint(
              'Gateway name-------------------------------------: $gatewaysNames');
          final List<String> gatewaysIds = vm.project.servers
              .where((LAServer s) => gatewaysNames.contains(s.name))
              .map((LAServer s) => s.id)
              .toList();
          debugPrint('Gateway ids: $gatewaysIds');
          if (firstServer) {
            UiUtils.showAlertDialog(context, () {
              for (final LAServer s in vm.project.servers) {
                if (!gatewaysIds.contains(s.id)) {
                  debugPrint('Setting gateways for ${s.name}');
                  s.gateways = gatewaysIds;
                  vm.project.upsertServer(s);
                }
              }
            }, () {
              vm.server.gateways = gatewaysIds;
              vm.project.upsertServer(vm.server);
            },
                title: 'Use this gateway always',
                subtitle:
                    'Do you want to use the same gateway for all your servers?',
                confirmBtn: 'YES',
                cancelBtn: 'NO');
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
  _GatewaySelectorViewModel(
      {required this.project,
      required this.server,
      required this.onSaveProject});

  final LAProject project;
  final LAServer server;
  final void Function(LAProject project) onSaveProject;
}
