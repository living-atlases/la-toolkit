import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/models/Dependencies.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/laProjectStatus.dart';
import 'package:la_toolkit/models/sshKey.dart';
import 'package:la_toolkit/routes.dart';

import 'alertCard.dart';

class LintProjectPanel extends StatefulWidget {
  LintProjectPanel({Key? key}) : super(key: key);

  @override
  _LintProjectPanelState createState() => _LintProjectPanelState();
}

class _LintProjectPanelState extends State<LintProjectPanel> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _LintProjectPanelViewModel>(
        distinct: true,
        converter: (store) {
          return _LintProjectPanelViewModel(
              project: store.state.currentProject,
              backendVersion: store.state.backendVersion,
              sshKeys: store.state.sshKeys,
              status: store.state.currentProject.status);
        },
        builder: (BuildContext context, _LintProjectPanelViewModel vm) {
          LAProject project = vm.project;
          final bool basicDefined =
              vm.status.value >= LAProjectStatus.basicDefined.value;
          List<String>? lintVersionErrors =
              vm.backendVersion == null // AppUtils.isDemo()
                  ? []
                  : Dependencies.check(
                      toolkitV: vm.backendVersion,
                      alaInstallV: project.alaInstallRelease,
                      generatorV: project.generatorRelease);
          return Column(
            children: [
              if (lintVersionErrors != null) LintErrorPanel(lintVersionErrors),
              if (vm.sshKeys.isEmpty)
                AlertCard(
                    message: "You don't have any SSH key",
                    actionText: "SOLVE",
                    action: () => BeamerCond.of(context, SshKeysLocation())),
              if (project.allServersWithServicesReady() &&
                  !project.allServersWithOs('Ubuntu', '18.04'))
                AlertCard(
                    message:
                        "The current supported OS version in Ubuntu 18.04"),
              if (basicDefined && !project.allServicesAssignedToServers())
                AlertCard(message: "Some service is not assigned to a server"),
              if (basicDefined && !project.allServersWithIPs())
                AlertCard(
                    message:
                        "All servers should have configured their IP address"),
              if (basicDefined && !project.allServersWithSshKeys())
                AlertCard(
                    message:
                        "All servers should have configured their SSH keys"),
              if (!project.collectoryAndBiocacheDifferentServers())
                AlertCard(
                    message:
                        "The collections and the occurrences front-end (bioache-hub) services are in the same server. This can cause start-up problems when caches are enabled")
            ],
          );
        });
  }
}

class LintErrorPanel extends StatelessWidget {
  final List<String> errors;

  LintErrorPanel(this.errors);
  @override
  Widget build(BuildContext context) {
    return Column(children: errors.map((e) => AlertCard(message: e)).toList());
  }
}

class _LintProjectPanelViewModel {
  final LAProject project;
  final String? backendVersion;
  final List<SshKey> sshKeys;
  final LAProjectStatus status;
  _LintProjectPanelViewModel(
      {required this.project,
      required this.sshKeys,
      required this.status,
      required this.backendVersion});
}
