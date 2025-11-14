import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import '../models/app_state.dart';
import '../models/deployment_type.dart';
import '../models/la_server.dart';
import '../models/la_project.dart';
import '../redux/app_actions.dart';
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
            refreshServer: (LAProject project, String serverId) {
              store.dispatch(
                  TestServicesSingleServer(project, serverId, () {}, () {}));
            },
          );
        },
        builder: (BuildContext context, _ServersStatusPanelViewModel vm) {
          final Map<String, dynamic> results = widget.results;
          return Wrap(children: <Widget>[
            for (final LAServer server in vm.project.serversWithServices())
              () {
                // Check if monitoring tools are installed for this server
                final monitoringKey = '_monitoring_${server.id}';
                final hasMonitoring = !results.containsKey(monitoringKey);
                final monitoringError = hasMonitoring
                    ? ''
                    : (results[monitoringKey]?['error'] as String? ??
                        'Monitoring tools not installed. Run pre-deploy step.');

                return ServerStatusCard(
                  server: server,
                  services: vm.project.getServerServicesFull(
                      id: server.id, type: DeploymentType.vm),
                  alaInstallVersion: vm.project.alaInstallRelease!,
                  extendedStatus: widget.extendedStatus,
                  status: results.isNotEmpty && results[server.id] != null
                      ? results[server.id]! as List<dynamic>
                      : <dynamic>[],
                  hasMonitoringTools: hasMonitoring,
                  monitoringError: monitoringError,
                  onTerm: () => vm.openTerm(vm.project, server),
                  onRefresh: () => vm.refreshServer(vm.project, server.id),
                );
              }()
          ]);
        });
  }
}

class _ServersStatusPanelViewModel {
  _ServersStatusPanelViewModel(
      {required this.project,
      required this.openTerm,
      required this.refreshServer});

  final LAProject project;
  final void Function(LAProject, LAServer) openTerm;
  final void Function(LAProject, String) refreshServer;
}
