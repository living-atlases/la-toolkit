import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/models/LAServiceConstants.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/laProjectStatus.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:la_toolkit/models/laServiceName.dart';
import 'package:la_toolkit/models/sshKey.dart';
import 'package:la_toolkit/routes.dart';
import 'package:pub_semver/pub_semver.dart';

import '../dependenciesManager.dart';
import '../models/laServer.dart';
import '../models/versionUtils.dart';
import 'alertCard.dart';
import 'lintErrorPanel.dart';

class LintProjectPanel extends StatefulWidget {
  final bool showLADeps;
  final bool showToolkitDeps;
  final bool showOthers;

  const LintProjectPanel(
      {Key? key,
      this.showLADeps = true,
      this.showToolkitDeps = true,
      this.showOthers = true})
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
      Map<String, String> selectedVersions = {};
      if (widget.showLADeps) {
        selectedVersions.addAll(project.getServiceDeployReleases());
      }
      // we need also the toolkit deps
      if ((widget.showToolkitDeps || widget.showLADeps) &&
          vm.backendVersion != null) {
        selectedVersions.addAll({
          toolkit: vm.backendVersion!,
          alaInstall: project.alaInstallRelease ?? vm.alaInstallReleases[0],
          generator: project.generatorRelease ?? vm.generatorReleases[0]
        });
      }
      List<Widget> lints = [
        LintErrorPanel(vm.backendVersion == null // AppUtils.isDemo()
            ? []
            : DependenciesManager.verifyLAReleases(
                project.getServicesNameListInUse() + laTools, selectedVersions))
      ];

      if (basicDefined && widget.showLADeps) {
        // Check java
        for (LAServer s in project.servers) {
          List<String> services = project.getServerServices(serverId: s.id);
          lints.add(LintErrorPanel(
              vm.backendVersion == null // AppUtils.isDemo()
                  ? []
                  : DependenciesManager.verifySw(
                      s, java, services, selectedVersions)));
        }
      }
      List<String> notAssigned = project.servicesNotAssigned();
      String notAssignedMessage = notAssigned.length < 5
          ? ' (' +
              notAssigned
                  .map((s) => LAServiceDesc.get(s).name)
                  .toList()
                  .join(', ') +
              ')'
          : '';
      if (widget.showOthers) {
        final bool? useOidc = project.getVariableValue("oidc_use") as bool;
        final String? userDetailsVersion =
            project.getSwVersionOfService(userdetails);
        // print('useOidc: $useOidc userDetails version: $userDetailsVersion');
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
            AlertCard(
                message:
                    "Some service is not assigned to a server$notAssignedMessage"),
          if (basicDefined &&
              project.servers.isNotEmpty &&
              project.getIncompatibilities().isNotEmpty)
            for (String i in project.getIncompatibilities())
              AlertCard(message: i),
          if (basicDefined && !project.allServersWithIPs())
            const AlertCard(
                message: "All servers should have configured their IP address"),
          if (basicDefined && !project.allServersWithSshKeys())
            const AlertCard(
                message: "All servers should have configured their SSH keys"),
          if (!project.servicesInDifferentServers(collectory, alaHub))
            const AlertCard(
                message:
                    "The collections and the occurrences front-end (biocache-hub) services are in the same server. This can cause start-up problems when caches are enabled"),
          if (!project.servicesInDifferentServers(ecodata, spatial))
            const AlertCard(
                message:
                    "The ecodata and spatial services are in the same server. This can cause deploy problems"),
          if (!project.servicesInDifferentServers(ecodataReporting, spatial))
            const AlertCard(
                message:
                    "The ecodata reporting and spatial services are in the same server. This can cause deploy problems"),
          if (!project.isHub &&
              !project.isPipelinesInUse &&
              !project.getServiceE(LAServiceName.biocache_backend).use)
            const AlertCard(
                message:
                    "You should use biocache-store or the new pipelines as backend"),
          if (!project.isHub &&
              project.getService(biocacheBackend).use &&
              !project.getService(solr).use)
            const AlertCard(
                message:
                    "You should use solr standalone for indexing biocache-store"),
          if (!project.isHub &&
              project.getService(bie).use &&
              !project.getService(solr).use)
            const AlertCard(
                message: "You should use solr standalone for indexing species"),
          if (!project.isHub &&
              project.getService(pipelines).use &&
              !project.getService(solrcloud).use)
            const AlertCard(
                message: "You should use solrcloud for indexing pipelines"),
          if (!project.isHub &&
              project.getService(events).use &&
              !project.getService(eventsElasticSearch).use)
            const AlertCard(message: "You should use elasticsearch for events"),
          if (!project.isHub &&
              project.getService(pipelines).use &&
              project.getService(solrcloud).use &&
              !project.getService(zookeeper).use)
            const AlertCard(
                message: "You should use zookeeper for solrcloud coordination"),
          if (basicDefined &&
              project.isPipelinesInUse &&
              project.getPipelinesMaster() == null)
            AlertCard(
                message: "You should select a master server for pipelines",
                actionText: "SOLVE",
                action: () => BeamerCond.of(context, LAProjectTuneLocation())),
          if (basicDefined &&
              project.isPipelinesInUse &&
              project.getHostnames(pipelines).length < 3)
            AlertCard(
                message: "A pipelines cluster should have at least 3 servers",
                actionText: "SOLVE",
                action: () => BeamerCond.of(context, LAProjectEditLocation())),
          if (basicDefined &&
              project.isPipelinesInUse &&
              project.getService(solrcloud).use &&
              project.getHostnames(solrcloud).isNotEmpty &&
              project.getHostnames(solrcloud).length.isEven)
            AlertCard(
                message:
                    "A solrcloud cluster should have a odd number of servers",
                actionText: "SOLVE",
                action: () => BeamerCond.of(context, LAProjectEditLocation())),
          if (basicDefined &&
              project.isPipelinesInUse &&
              project.getService(zookeeper).use &&
              project.getHostnames(zookeeper).isNotEmpty &&
              project.getHostnames(zookeeper).length.isEven)
            AlertCard(
                message:
                    "A zookeeper cluster should have a odd number of servers",
                actionText: "SOLVE",
                action: () => BeamerCond.of(context, LAProjectEditLocation())),
          if (project.isPipelinesInUse &&
              project.getHostnames(pipelines).isNotEmpty &&
              project.getHostnames(pipelines).join(" ").contains("_"))
            AlertCard(
                message:
                    "Pipelines server names should not contain underscores",
                actionText: "SOLVE",
                action: project.isCreated
                    ? () => BeamerCond.of(context, LAProjectEditLocation())
                    : null),
          if (!project.isHub &&
              project.getService(cas).use &&
              userDetailsVersion != null &&
              VersionConstraint.parse('< 3.0.1')
                  .allows(v(userDetailsVersion)) &&
              useOidc != null &&
              useOidc)
            const AlertCard(
                message: "OIDC can be used with userdetails >= 3.0.1"),
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
