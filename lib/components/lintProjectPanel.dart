import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/models/LAServiceConstants.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/dependencies.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/laProjectStatus.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:la_toolkit/models/sshKey.dart';
import 'package:la_toolkit/routes.dart';

import 'alertCard.dart';
import 'lintErrorPanel.dart';

class LintProjectPanel extends StatefulWidget {
  final bool onlySoftware;

  const LintProjectPanel({Key? key, this.onlySoftware = false})
      : super(key: key);

  @override
  _LintProjectPanelState createState() => _LintProjectPanelState();
}

class _LintProjectPanelState extends State<LintProjectPanel> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _LintProjectPanelViewModel>(
        // distinct: true,
        converter: (store) {
      return _LintProjectPanelViewModel(
          project: store.state.currentProject,
          alaInstallReleases: store.state.alaInstallReleases,
          generatorReleases: store.state.generatorReleases,
          backendVersion: store.state.backendVersion,
          sshKeys: store.state.sshKeys,
          status: store.state.currentProject.status);
    }, builder: (BuildContext context, _LintProjectPanelViewModel vm) {
      LAProject project = vm.project;
      final bool basicDefined =
          vm.status.value >= LAProjectStatus.basicDefined.value;
      List<Widget> lints = [
        LintErrorPanel(vm.backendVersion == null // AppUtils.isDemo()
            ? []
            : Dependencies.verifyLAReleases(
                project.getServicesNameListInUse() + Dependencies.laTools,
                {}
                  ..addAll(project.getServiceDeployReleases())
                  ..addAll({
                    toolkit: vm.backendVersion!,
                    alaInstall:
                        project.alaInstallRelease ?? vm.alaInstallReleases[0],
                    generator:
                        project.generatorRelease ?? vm.generatorReleases[0]
                  })))
      ];
      if (!widget.onlySoftware) {
        lints.addAll([
          if (vm.sshKeys.isEmpty)
            AlertCard(
                message: "You don't have any SSH key",
                actionText: "SOLVE",
                action: () => BeamerCond.of(context, SshKeysLocation())),
          if (project.allServersWithServicesReady() &&
              !project.allServersWithOs('Ubuntu', '18.04'))
            const AlertCard(
                message: "The current supported OS version in Ubuntu 18.04"),
          if (basicDefined &&
              project.servers.isNotEmpty &&
              !project.allServicesAssignedToServers())
            const AlertCard(
                message: "Some service is not assigned to a server"),
          if (basicDefined && !project.allServersWithIPs())
            const AlertCard(
                message: "All servers should have configured their IP address"),
          if (basicDefined && !project.allServersWithSshKeys())
            const AlertCard(
                message: "All servers should have configured their SSH keys"),
          if (!project.collectoryAndBiocacheDifferentServers())
            const AlertCard(
                message:
                    "The collections and the occurrences front-end (biocache-hub) services are in the same server. This can cause start-up problems when caches are enabled"),
          if (!project.getServiceE(LAServiceName.pipelines).use &&
              !project.getServiceE(LAServiceName.biocache_backend).use)
            const AlertCard(
                message:
                    "You should use biocache-store or the new pipelines as backend")
        ]);
      }
      return Column(children: lints);
    });
  }
}

class _LintProjectPanelViewModel {
  final LAProject project;
  final String? backendVersion;
  final List<SshKey> sshKeys;
  final List<String> alaInstallReleases;
  final List<String> generatorReleases;
  final LAProjectStatus status;
  _LintProjectPanelViewModel(
      {required this.project,
      required this.sshKeys,
      required this.status,
      required this.alaInstallReleases,
      required this.generatorReleases,
      required this.backendVersion});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _LintProjectPanelViewModel &&
          runtimeType == other.runtimeType &&
          project == other.project &&
          backendVersion == other.backendVersion &&
          sshKeys == other.sshKeys &&
          const ListEquality()
              .equals(generatorReleases, other.generatorReleases) &&
          const ListEquality()
              .equals(alaInstallReleases, other.alaInstallReleases) &&
          status == other.status;

  @override
  int get hashCode =>
      project.hashCode ^
      backendVersion.hashCode ^
      sshKeys.hashCode ^
      const ListEquality().hash(generatorReleases) ^
      const ListEquality().hash(alaInstallReleases) ^
      status.hashCode;
}
