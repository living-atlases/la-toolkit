import 'package:collection/collection.dart';

import 'deployment_type.dart';
import 'la_cluster.dart';
import 'la_project.dart';
import 'la_server.dart';

/// Where a service of [project] resolves to.
///
/// Infrastructure (servers, clusters) is OWNED by the portal; a data hub only
/// PLACES its services on it, or on VMs of its own. Every
/// "clusterId -> cluster -> serverId -> server" resolution goes through here,
/// so a hub deploy that references one of the portal's compose clusters finds
/// its carrier host. Ownership questions (ssh config, connectivity checks,
/// deploy targets, lints about the machines) keep reading `project.servers`
/// and `project.clusters` directly and never reach the parent: that is what
/// keeps a hub from claiming the portal's machines as its own.
class LAPlacement {
  const LAPlacement(this.project);

  final LAProject project;

  List<LACluster> get clusters => project.isHub
      ? <LACluster>[...project.clusters, ...?project.parent?.clusters]
      : project.clusters;

  List<LAServer> get servers => project.isHub
      ? <LAServer>[...project.servers, ...?project.parent?.servers]
      : project.servers;

  LACluster? clusterById(String? id) =>
      id == null ? null : clusters.firstWhereOrNull((LACluster c) => c.id == id);

  LAServer? serverById(String? id) =>
      id == null ? null : servers.firstWhereOrNull((LAServer s) => s.id == id);

  /// The machine that runs [cluster], if it has one.
  LAServer? carrierOf(LACluster cluster) => serverById(cluster.serverId);

  /// A cluster the project places services on without owning it: a hub on one
  /// of the portal's compose clusters. It is never created, renamed or deleted
  /// from the hub's side.
  bool isBorrowed(LACluster cluster) => cluster.projectId != project.id;

  /// Compose clusters a service can be placed on, own or borrowed.
  List<LACluster> get composeClusters => clusters
      .where((LACluster c) => c.type == DeploymentType.dockerCompose)
      .toList();
}
