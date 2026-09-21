// The project lint: what the LA Toolkit warns about a project before it is
// deployed. It used to live inside the LintProjectPanel widget; it is here so
// the app, the CLI and the MCP server all judge a project the same way.
import 'package:meta/meta.dart';
import 'package:pub_semver/pub_semver.dart';

import '../dependencies_manager.dart';
import '../models/la_project.dart';
import '../models/la_project_status.dart';
import '../models/la_server.dart';
import '../models/la_service_constants.dart';
import '../models/la_service_desc.dart';
import '../models/la_service_name.dart';
import '../models/version_utils.dart';

/// Where the user goes to fix a finding. The app maps each one to a screen;
/// other clients can just show the message.
enum LintFix {
  /// Add or generate an ssh key.
  sshKeys,

  /// The project's "tune" settings (e.g. the pipelines master).
  tuneProject,

  /// The project's servers and services.
  editProject,

  /// The portal a hub belongs to.
  openParent,
}

@immutable
class LintFinding {
  const LintFinding(this.message, {this.fix});

  final String message;
  final LintFix? fix;

  @override
  String toString() => message;

  @override
  bool operator ==(Object other) =>
      other is LintFinding && other.message == message && other.fix == fix;

  @override
  int get hashCode => message.hashCode ^ fix.hashCode;
}

/// The versions the dependency checks compare: the software of each service
/// deploy ([laDeps]) and the toolkit itself, ala-install, the generator and
/// la-docker-compose ([toolkitDeps] or [laDeps]).
///
/// [backendVersion] is the running toolkit; without it no toolkit version is
/// added (the app is in demo mode or the backend is unreachable).
/// [alaInstallReleases] / [generatorReleases] are the known releases, newest
/// first, used when the project does not pin one.
Map<String, String> lintSelectedVersions(
  LAProject project, {
  required String? backendVersion,
  required List<String> alaInstallReleases,
  required List<String> generatorReleases,
  bool laDeps = true,
  bool toolkitDeps = true,
}) {
  final Map<String, String> selectedVersions = <String, String>{};
  if (laDeps) {
    selectedVersions.addAll(project.getServiceDeployReleases());
  }
  // we need also the toolkit deps
  if ((toolkitDeps || laDeps) && backendVersion != null) {
    selectedVersions.addAll(<String, String>{
      toolkit: backendVersion,
      alaInstall:
          project.alaInstallRelease ??
          (alaInstallReleases.isNotEmpty ? alaInstallReleases[0] : '2.1.14'),
      generator:
          project.generatorRelease ??
          (generatorReleases.isNotEmpty ? generatorReleases[0] : '1.4.3'),
      // getServiceDeployReleases() does not carry this one: the
      // la-docker-compose release is a project field, not a per-deploy
      // software version. Without it here the docker-compose entries in
      // the dependency matrix are never evaluated. The 'v' of the git tag
      // and the 'upstream' sentinel are both handled downstream, by
      // StringUtils.semantize and by verifyLAReleases respectively.
      if (project.dockerComposeRelease != null)
        dockerCompose: project.dockerComposeRelease!,
    });
  }
  return selectedVersions;
}

/// Dependency-matrix errors, one group per check: releases, nextgen
/// compatibility, then the java of each server (the latter only with
/// [laDeps] once the project is basically defined).
///
/// Needs the matrix loaded (`DependenciesManager.setDeps` /
/// `setNextgenCompat`). With no [backendVersion] every group is empty, as the
/// selected versions would be incomplete.
List<List<String>> lintDependencies(
  LAProject project,
  Map<String, String> selectedVersions, {
  required String? backendVersion,
  bool laDeps = true,
}) {
  final bool known = backendVersion != null;
  final bool basicDefined =
      project.status.value >= LAProjectStatus.basicDefined.value;
  return <List<String>>[
    if (known)
      DependenciesManager.verifyLAReleases(
        project.getServicesNameListInUse() + laTools,
        selectedVersions,
      )
    else
      <String>[],
    if (known)
      DependenciesManager.verifyNextgen(selectedVersions)
    else
      <String>[],
    if (basicDefined && laDeps)
      for (final LAServer s in project.servers)
        known
            ? DependenciesManager.verifySw(
                s,
                java,
                project.getServerServices(serverId: s.id),
                selectedVersions,
              )
            : <String>[],
  ];
}

/// Everything else the toolkit warns about a project: placement, missing
/// data, services that need each other, cluster sizes, deprecated auth...
/// [hasSshKeys]: whether the toolkit holds any ssh key at all.
List<LintFinding> lintProject(LAProject project, {required bool hasSshKeys}) {
  final bool basicDefined =
      project.status.value >= LAProjectStatus.basicDefined.value;
  final List<String> notAssigned = project.servicesNotAssigned();
  final String notAssignedMessage = notAssigned.length < 5
      ? ' (${notAssigned.map((String s) => LAServiceDesc.get(s).name).toList().join(', ')})'
      : '';
  final List<String> strandedServices = project.servicesWithNowhereToRun();
  final String strandedMessage = strandedServices
      .map((String s) => LAServiceDesc.get(s).name)
      .join(', ');
  final String? userDetailsVersion = project.getSwVersionOfService(userdetails);

  return <LintFinding>[
    if (!hasSshKeys)
      const LintFinding("You don't have any SSH key", fix: LintFix.sshKeys),
    // A hub inherits its deployment mode and its machines from the
    // portal; the carrier constraint is the portal's to satisfy. The
    // old rule tested the docker_compose service's deploy rows, which
    // a hub never has, so it fired on every compose hub.
    if (basicDefined &&
        !project.isHub &&
        project.isDockerComposeEnabled &&
        !project.hasComposeCarrierHost())
      const LintFinding(
        'Docker Compose is enabled but no VM carries the compose stack. '
        'Tick "docker compose" on one of your servers: the compose cluster needs a machine to run on.',
      ),
    for (final String error in project.hubComposePlacementErrors())
      LintFinding(error),
    // A hub with no server of its own has nothing to run its own
    // Deploy against: validateCreation() requires servers.isNotEmpty
    // unconditionally, so its Deploy/Test Connectivity cards never
    // enable. Its containers are rendered as part of the parent's
    // docker-compose stack (LA_hubs), so the parent is what to deploy.
    if (project.isHub &&
        project.parent != null &&
        project.servers.isEmpty &&
        project.isDockerComposeEnabled)
      LintFinding(
        '${project.shortName} has no server of its own: it deploys as part of '
        "${project.parent!.shortName}'s docker-compose stack. Deploy "
        '${project.parent!.shortName} to bring ${project.shortName} online.',
        fix: LintFix.openParent,
      ),
    if (project.allServersWithServicesReady() &&
        !project.allServersWithSupportedOs('Ubuntu', '22.04'))
      const LintFinding(
        'The current supported OS version are Ubuntu 22.04 and 24.04 (under testing)',
      ),
    if (basicDefined &&
        project.servers.isNotEmpty &&
        !project.allServicesAssigned())
      LintFinding(
        'Some services is not assigned to a server$notAssignedMessage',
      ),
    if (basicDefined && strandedServices.isNotEmpty)
      LintFinding(
        'These services cannot run on a Docker Compose deployment and should be disabled: $strandedMessage. '
        'They are the legacy biocache-store path; this stack indexes with pipelines and solrcloud instead.',
      ),
    if (basicDefined &&
        project.servers.isNotEmpty &&
        project.getIncompatibilities().isNotEmpty)
      for (final String i in project.getIncompatibilities()) LintFinding(i),
    if (basicDefined && !project.allServersWithIPs())
      const LintFinding('All servers should have configured their IP address'),
    if (basicDefined && !project.allServersWithSshKeys())
      const LintFinding('All servers should have configured their SSH keys'),
    for (final String warning in project.getDockerComposeVMWarnings())
      LintFinding(warning),
    if (!project.servicesInDifferentServers(collectory, alaHub) &&
        !project.hasAnyServerWithDockerCompose())
      const LintFinding(
        'The collections and the occurrences front-end (biocache-hub) services are in the same server. This can cause start-up problems when caches are enabled',
      ),
    if (!project.servicesInDifferentServers(ecodata, spatial))
      const LintFinding(
        'The ecodata and spatial services are in the same server. This can cause deploy problems',
      ),
    if (!project.servicesInDifferentServers(ecodataReporting, spatial))
      const LintFinding(
        'The ecodata reporting and spatial services are in the same server. This can cause deploy problems',
      ),
    if (!project.isHub &&
        !project.isPipelinesInUse &&
        !project.getServiceE(LAServiceName.biocache_backend).use)
      const LintFinding(
        'You should use biocache-store or the new pipelines as backend',
      ),
    if (!project.isHub &&
        project.getService(biocacheBackend).use &&
        !project.getService(solr).use &&
        !project.hasAnyServerWithDockerCompose())
      const LintFinding(
        'You should use solr standalone for indexing biocache-store',
      ),
    if (!project.isHub &&
        project.getService(bie).use &&
        !project.getService(solr).use &&
        !project.hasAnyServerWithDockerCompose())
      const LintFinding('You should use solr standalone for indexing species'),
    if (!project.isHub &&
        project.getService(pipelines).use &&
        !project.getService(solrcloud).use)
      const LintFinding('You should use solrcloud for indexing pipelines'),
    if (!project.isHub &&
        project.getService(events).use &&
        !project.getService(eventsElasticSearch).use)
      const LintFinding('You should use elasticsearch for events'),
    if (!project.isHub &&
        project.getService(pipelines).use &&
        project.getService(solrcloud).use &&
        !project.getService(zookeeper).use)
      const LintFinding('You should use zookeeper for solrcloud coordination'),
    if (basicDefined &&
        project.isPipelinesInUse &&
        !project.isPipelinesOnlyInClusters &&
        project.getPipelinesMaster() == null)
      const LintFinding(
        'You should select a master server for pipelines',
        fix: LintFix.tuneProject,
      ),
    if (basicDefined &&
        project.isPipelinesInUse &&
        !project.isPipelinesOnlyInClusters &&
        project.getHostnames(pipelines).length < 3)
      LintFinding(
        'A pipelines cluster should have at least 3 servers (it have ${project.getHostnames(pipelines).length})',
        fix: LintFix.editProject,
      ),
    if (basicDefined &&
        project.isPipelinesInUse &&
        !project.isPipelinesOnlyInClusters &&
        project.getService(solrcloud).use &&
        project.getHostnames(solrcloud).isNotEmpty &&
        project.getHostnames(solrcloud).length.isEven)
      LintFinding(
        'A solrcloud cluster should have a odd number of servers (it have ${project.getHostnames(solrcloud).length})',
        fix: LintFix.editProject,
      ),
    if (basicDefined &&
        project.isPipelinesInUse &&
        !project.isPipelinesOnlyInClusters &&
        project.getService(zookeeper).use &&
        project.getHostnames(zookeeper).isNotEmpty &&
        project.getHostnames(zookeeper).length.isEven)
      LintFinding(
        'A zookeeper cluster should have a odd number of servers (it have ${project.getHostnames(zookeeper).length})',
        fix: LintFix.editProject,
      ),
    if (project.isPipelinesInUse &&
        !project.isPipelinesOnlyInClusters &&
        project.getHostnames(pipelines).isNotEmpty &&
        project.getHostnames(pipelines).join(' ').contains('_'))
      LintFinding(
        'Pipelines server names should not contain underscores',
        // Nothing to edit before the project exists.
        fix: project.isCreated ? LintFix.editProject : null,
      ),
    if (!project.isHub &&
        project.getService(cas).use &&
        userDetailsVersion != null &&
        VersionConstraint.parse('< 3.0.1').allows(v(userDetailsVersion)))
      const LintFinding(
        'OIDC is now required (CAS auth is deprecated) and needs '
        'userdetails >= 3.0.1. Please upgrade the userdetails service.',
      ),
  ];
}
