import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:redux/redux.dart';

import '../dependencies_manager.dart';
import '../models/app_state.dart';
import '../models/la_project.dart';
import '../models/la_project_status.dart';
import '../models/la_server.dart';
import '../models/la_service_constants.dart';
import '../models/la_service_desc.dart';
import '../models/la_service_name.dart';
import '../models/ssh_key.dart';
import '../models/version_utils.dart';
import '../routes.dart';
import 'alert_card.dart';
import 'lint_error_panel.dart';

class LintProjectPanel extends StatefulWidget {
  const LintProjectPanel({
    super.key,
    this.showLADeps = true,
    this.showToolkitDeps = true,
    this.showOthers = true,
  });

  final bool showLADeps;
  final bool showToolkitDeps;
  final bool showOthers;

  @override
  State<LintProjectPanel> createState() => _LintProjectPanelState();
}

class _LintProjectPanelState extends State<LintProjectPanel> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _LintProjectPanelViewModel>(
      // distinct: true,
      converter: (Store<AppState> store) {
        return _LintProjectPanelViewModel(
          project: store.state.currentProject,
          alaInstallReleases: store.state.alaInstallReleases,
          generatorReleases: store.state.generatorReleases,
          backendVersion: store.state.backendVersion,
          sshKeys: store.state.sshKeys,
          status: store.state.currentProject.status,
        );
      },
      builder: (BuildContext context, _LintProjectPanelViewModel vm) {
        final LAProject project = vm.project;
        final bool basicDefined =
            vm.status.value >= LAProjectStatus.basicDefined.value;
        final Map<String, String> selectedVersions = <String, String>{};
        if (widget.showLADeps) {
          selectedVersions.addAll(project.getServiceDeployReleases());
        }
        // we need also the toolkit deps
        if ((widget.showToolkitDeps || widget.showLADeps) &&
            vm.backendVersion != null) {
          selectedVersions.addAll(<String, String>{
            toolkit: vm.backendVersion!,
            alaInstall:
                project.alaInstallRelease ??
                (vm.alaInstallReleases.isNotEmpty
                    ? vm.alaInstallReleases[0]
                    : '2.1.14'),
            generator:
                project.generatorRelease ??
                (vm.generatorReleases.isNotEmpty
                    ? vm.generatorReleases[0]
                    : '1.4.3'),
          });
        }
        final List<Widget> lints = <Widget>[
          LintErrorPanel(
            vm.backendVersion ==
                    null // AppUtils.isDemo()
                ? <String>[]
                : DependenciesManager.verifyLAReleases(
                    project.getServicesNameListInUse() + laTools,
                    selectedVersions,
                  ),
          ),
        ];

        if (basicDefined && widget.showLADeps) {
          // Check java
          for (final LAServer s in project.servers) {
            final List<String> services = project.getServerServices(
              serverId: s.id,
            );
            lints.add(
              LintErrorPanel(
                vm.backendVersion ==
                        null // AppUtils.isDemo()
                    ? <String>[]
                    : DependenciesManager.verifySw(
                        s,
                        java,
                        services,
                        selectedVersions,
                      ),
              ),
            );
          }
        }
        final List<String> notAssigned = project.servicesNotAssigned();
        final String notAssignedMessage = notAssigned.length < 5
            ? ' (${notAssigned.map((String s) => LAServiceDesc.get(s).name).toList().join(', ')})'
            : '';
        if (widget.showOthers) {
          final bool useOidc =
              project.getVariableValue('oidc_use') as bool? ?? false;
          final String? userDetailsVersion = project.getSwVersionOfService(
            userdetails,
          );
          final String? generatorVersion = project.generatorRelease;
          final String? alaInstallVersion = project.alaInstallRelease;
          debugPrint(
            'ala-install $alaInstallVersion, generator: $generatorVersion',
          );
          // debugPrint('useOidc: $useOidc userDetails version: $userDetailsVersion');
          lints.insertAll(0, <Widget>[
            if (vm.sshKeys.isEmpty)
              AlertCard(
                message: "You don't have any SSH key",
                actionText: 'SOLVE',
                action: () => BeamerCond.of(context, SshKeysLocation()),
              ),
            if (basicDefined &&
                project.servers.isNotEmpty &&
                project.hasDockerSupportedServicesInUse() &&
                !project.hasAnyServerWithDockerCompose())
              const AlertCard(
                message:
                    'You have Docker compose enabled. You should include at least one VM with docker-compose configured to use it',
              ),
            if (project.allServersWithServicesReady() &&
                !project.allServersWithSupportedOs('Ubuntu', '22.04'))
              const AlertCard(
                message:
                    'The current supported OS version are Ubuntu 22.04 and 24.04 (under testing)',
              ),
            if (basicDefined &&
                project.servers.isNotEmpty &&
                !project.allServicesAssigned())
              AlertCard(
                message:
                    'Some service is not assigned to a server$notAssignedMessage',
              ),
            if (basicDefined &&
                project.servers.isNotEmpty &&
                project.getIncompatibilities().isNotEmpty)
              for (final String i in project.getIncompatibilities())
                AlertCard(message: i),
            if (basicDefined && !project.allServersWithIPs())
              const AlertCard(
                message: 'All servers should have configured their IP address',
              ),
            if (basicDefined && !project.allServersWithSshKeys())
              const AlertCard(
                message: 'All servers should have configured their SSH keys',
              ),
            if (!project.servicesInDifferentServers(collectory, alaHub))
              const AlertCard(
                message:
                    'The collections and the occurrences front-end (biocache-hub) services are in the same server. This can cause start-up problems when caches are enabled',
              ),
            if (!project.servicesInDifferentServers(ecodata, spatial))
              const AlertCard(
                message:
                    'The ecodata and spatial services are in the same server. This can cause deploy problems',
              ),
            if (!project.servicesInDifferentServers(ecodataReporting, spatial))
              const AlertCard(
                message:
                    'The ecodata reporting and spatial services are in the same server. This can cause deploy problems',
              ),
            if (!project.isHub &&
                !project.isPipelinesInUse &&
                !project.getServiceE(LAServiceName.biocache_backend).use)
              const AlertCard(
                message:
                    'You should use biocache-store or the new pipelines as backend',
              ),
            if (!project.isHub &&
                project.getService(biocacheBackend).use &&
                !project.getService(solr).use)
              const AlertCard(
                message:
                    'You should use solr standalone for indexing biocache-store',
              ),
            if (!project.isHub &&
                project.getService(bie).use &&
                !project.getService(solr).use)
              const AlertCard(
                message: 'You should use solr standalone for indexing species',
              ),
            if (!project.isHub &&
                project.getService(pipelines).use &&
                !project.getService(solrcloud).use)
              const AlertCard(
                message: 'You should use solrcloud for indexing pipelines',
              ),
            if (!project.isHub &&
                project.getService(events).use &&
                !project.getService(eventsElasticSearch).use)
              const AlertCard(
                message: 'You should use elasticsearch for events',
              ),
            if (!project.isHub &&
                project.getService(pipelines).use &&
                project.getService(solrcloud).use &&
                !project.getService(zookeeper).use)
              const AlertCard(
                message: 'You should use zookeeper for solrcloud coordination',
              ),
            if (basicDefined &&
                project.isPipelinesInUse &&
                project.getPipelinesMaster() == null)
              AlertCard(
                message: 'You should select a master server for pipelines',
                actionText: 'SOLVE',
                action: () => BeamerCond.of(context, LAProjectTuneLocation()),
              ),
            if (basicDefined &&
                project.isPipelinesInUse &&
                project.getHostnames(pipelines).length < 3)
              AlertCard(
                message:
                    'A pipelines cluster should have at least 3 servers (it have ${project.getHostnames(pipelines).length})',
                actionText: 'SOLVE',
                action: () => BeamerCond.of(context, LAProjectEditLocation()),
              ),
            if (basicDefined &&
                project.isPipelinesInUse &&
                project.getService(solrcloud).use &&
                project.getHostnames(solrcloud).isNotEmpty &&
                project.getHostnames(solrcloud).length.isEven)
              AlertCard(
                message:
                    'A solrcloud cluster should have a odd number of servers (it have ${project.getHostnames(solrcloud).length})',
                actionText: 'SOLVE',
                action: () => BeamerCond.of(context, LAProjectEditLocation()),
              ),
            if (basicDefined &&
                project.isPipelinesInUse &&
                project.getService(zookeeper).use &&
                project.getHostnames(zookeeper).isNotEmpty &&
                project.getHostnames(zookeeper).length.isEven)
              AlertCard(
                message:
                    'A zookeeper cluster should have a odd number of servers (it have ${project.getHostnames(zookeeper).length})',
                actionText: 'SOLVE',
                action: () => BeamerCond.of(context, LAProjectEditLocation()),
              ),
            if (project.isPipelinesInUse &&
                project.getHostnames(pipelines).isNotEmpty &&
                project.getHostnames(pipelines).join(' ').contains('_'))
              AlertCard(
                message:
                    'Pipelines server names should not contain underscores',
                actionText: 'SOLVE',
                action: project.isCreated
                    ? () => BeamerCond.of(context, LAProjectEditLocation())
                    : null,
              ),
            if (!project.isHub &&
                project.getService(cas).use &&
                userDetailsVersion != null &&
                VersionConstraint.parse(
                  '< 3.0.1',
                ).allows(v(userDetailsVersion)) &&
                // useOidc != null &&
                useOidc)
              const AlertCard(
                message: 'OIDC can be used with userdetails >= 3.0.1',
              ),
          ]);
        }
        return Column(children: lints);
      },
    );
  }
}

@immutable
class _LintProjectPanelViewModel {
  const _LintProjectPanelViewModel({
    required this.project,
    required this.sshKeys,
    required this.status,
    required this.alaInstallReleases,
    required this.generatorReleases,
    required this.backendVersion,
  });

  final LAProject project;
  final String? backendVersion;
  final List<SshKey> sshKeys;
  final List<String> alaInstallReleases;
  final List<String> generatorReleases;
  final LAProjectStatus status;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _LintProjectPanelViewModel &&
          runtimeType == other.runtimeType &&
          project == other.project &&
          backendVersion == other.backendVersion &&
          sshKeys == other.sshKeys &&
          const ListEquality<String>().equals(
            generatorReleases,
            other.generatorReleases,
          ) &&
          const ListEquality<String>().equals(
            alaInstallReleases,
            other.alaInstallReleases,
          ) &&
          status == other.status;

  @override
  int get hashCode =>
      project.hashCode ^
      backendVersion.hashCode ^
      sshKeys.hashCode ^
      const ListEquality<String>().hash(generatorReleases) ^
      const ListEquality<String>().hash(alaInstallReleases) ^
      status.hashCode;
}
