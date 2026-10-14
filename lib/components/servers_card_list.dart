import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit_core/models/deployment_type.dart';
import 'package:la_toolkit_core/models/la_cluster.dart';
import 'package:la_toolkit_core/models/la_project.dart';
import 'package:la_toolkit_core/models/la_releases.dart';
import 'package:la_toolkit_core/models/la_server.dart';
import 'package:la_toolkit_core/models/la_service.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:redux/redux.dart';

import '../la_theme.dart';
import '../models/app_state.dart';
import '../redux/actions.dart';
import '../utils/card_constants.dart';
import '../utils/debounce.dart';
import 'server_services_edit_card.dart';

class ServersCardList extends StatelessWidget {
  const ServersCardList({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ServersCardListViewModel>(
      // Default value, so commenting
      // distinct: false,
      converter: (Store<AppState> store) {
        return ServersCardListViewModel(
          currentProject: store.state.currentProject,
          laReleases: store.state.laReleases,
          loading: store.state.loading,
          onSaveCurrentProject: (LAProject project) {
            store.dispatch(SaveCurrentProject(project));
          },
          onUpdateProjectLocal: (LAProject project) {
            store.dispatch(UpdateProjectLocal(project));
          },
        );
      },
      builder: (BuildContext context, ServersCardListViewModel vm) {
        final LAProject project = vm.currentProject;
        final bool dockerEnabled = project.isDockerClusterConfigured();

        // Build VM cards
        final List<Widget> vmCards = <Widget>[
          for (final LAServer server in project.servers)
            ServerServicesHoverCard(
              key: ValueKey<String>('server-${server.id}'),
              server: server,
              project: project,
              vm: vm,
            ),
        ];

        // Build Cluster cards. Through `placement`: a data hub places its
        // services on the portal's compose clusters, which it borrows here
        // without owning them (no delete, no rename from this side).
        final List<Widget> clusterCards = <Widget>[
          if (dockerEnabled)
            for (final LACluster cluster in project.placement.clusters)
              ServerServicesHoverCard(
                key: ValueKey<String>('cluster-${cluster.id}'),
                cluster: cluster,
                project: project,
                vm: vm,
                borrowed: project.placement.isBorrowed(cluster),
              ),
        ];
        final bool anyBorrowed =
            dockerEnabled &&
            project.placement.clusters.any(project.placement.isBorrowed);

        // Build the layout: VMs on top, Clusters below (if any)
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // VMs section - always shown
            Wrap(children: vmCards),
            // Clusters section - only if there are clusters
            if (clusterCards.isNotEmpty) ...<Widget>[
              // Horizontal divider
              Container(
                height: 2,
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      LAColorTheme.inactive.withValues(alpha: 0.1),
                      LAColorTheme.inactive.withValues(alpha: 0.3),
                      LAColorTheme.inactive.withValues(alpha: 0.1),
                    ],
                  ),
                ),
              ),
              // Clusters header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Row(
                  children: <Widget>[
                    Icon(
                      MdiIcons.docker,
                      color: LAColorTheme.inactive,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Docker Clusters',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: LAColorTheme.inactive,
                      ),
                    ),
                  ],
                ),
              ),
              if (anyBorrowed)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                  child: Text(
                    'These clusters belong to the portal ${project.parent?.shortName}: '
                    'the hub runs its containers inside that stack, on the same machines. '
                    'The machines themselves are managed from the portal.',
                    style: const TextStyle(color: LAColorTheme.inactive),
                  ),
                ),
              // Clusters cards
              Wrap(children: clusterCards),
            ],
          ],
        );
      },
    );
  }
}

class ServerServicesHoverCard extends StatefulWidget {
  const ServerServicesHoverCard({
    super.key,
    this.borrowed = false,
    this.server,
    this.cluster,
    required this.project,
    required this.vm,
  });

  final LAServer? server;
  final LACluster? cluster;
  final LAProject project;
  final ServersCardListViewModel vm;

  /// The cluster is the parent portal's: a hub assigns services onto it but
  /// never deletes or renames it from here.
  final bool borrowed;

  @override
  State<ServerServicesHoverCard> createState() =>
      _ServerServicesHoverCardState();
}

class _ServerServicesHoverCardState extends State<ServerServicesHoverCard> {
  final Debouncer _debouncer = Debouncer(milliseconds: 2000);
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final bool isAServer = widget.server != null;
    final LACluster? cluster = widget.cluster;
    final LAServer? server = widget.server;

    if (!isAServer && cluster == null) {
      return const SizedBox.shrink();
    }

    final DeploymentType type = isAServer ? DeploymentType.vm : cluster!.type;
    final String sId = isAServer ? server!.id : cluster!.id;
    final String name = isAServer
        ? server!.name
        : widget.borrowed
            ? '${cluster!.name} (portal ${widget.project.parent?.shortName})'
            : cluster!.name;
    final Map<String, List<LAService>> servicesAssignable = widget.project
        .getServerServicesAssignable(type);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _expanded
          ? ServerServicesEditCard(
              key: const ValueKey<String>('expanded'),
              server: widget.server,
              cluster: widget.cluster,
              type: type,
              isHub: widget.project.isHub,
              borrowed: widget.borrowed,
              currentServerServices: isAServer
                  ? widget.project.getServerServices(serverId: server!.id)
                  : widget.project.getClusterServices(clusterId: cluster!.id),
              availableServicesForServer:
                  servicesAssignable[sId] ?? <LAService>[],
              allServices: widget.project.services,
              onAssigned: (List<String> list) {
                widget.project.assignByType(
                  sId,
                  type,
                  list,
                  null,
                  widget.vm.laReleases,
                );
                widget.vm.onUpdateProjectLocal(widget.project);
                _debouncer.run(
                  () => widget.vm.onSaveCurrentProject(widget.project),
                );
              },
              onUnassigned: (String service) {
                widget.project.unAssignByType(sId, type, service);
                widget.vm.onUpdateProjectLocal(widget.project);
                _debouncer.run(
                  () => widget.vm.onSaveCurrentProject(widget.project),
                );
              },
              onRename: (String newName) {
                if (isAServer) {
                  widget.server!.name = newName;
                  widget.project.upsertServer(widget.server!);
                  widget.vm.onUpdateProjectLocal(widget.project);
                  _debouncer.run(
                    () => widget.vm.onSaveCurrentProject(widget.project),
                  );
                }
              },
              onDeleted: (LAServer server) {
                widget.project.delete(server);
                widget.vm.onUpdateProjectLocal(widget.project);
                _debouncer.run(
                  () => widget.vm.onSaveCurrentProject(widget.project),
                );
              },
              onDeletedCluster: (LACluster cluster) {
                widget.project.deleteCluster(cluster);
                widget.vm.onUpdateProjectLocal(widget.project);
                _debouncer.run(
                  () => widget.vm.onSaveCurrentProject(widget.project),
                );
              },
              onEditing: () {},
              onToggleExpand: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
              loading: widget.vm.loading,
            )
          : ServerServicesViewCard(
              key: const ValueKey<String>('collapsed'),
              id: sId,
              name: name,
              type: type,
              project: widget.project,
              vm: widget.vm,
              cluster: cluster,
              // A hub borrows its portal's clusters: their stage is the portal's.
              onStageChanged: cluster == null || widget.borrowed
                  ? null
                  : (ClusterStage stage) {
                      cluster.stage = stage;
                      widget.vm.onUpdateProjectLocal(widget.project);
                      _debouncer.run(
                        () => widget.vm.onSaveCurrentProject(widget.project),
                      );
                    },
              onToggleExpand: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
            ),
    );
  }
}

class ServerServicesViewCard extends StatelessWidget {
  const ServerServicesViewCard({
    super.key,
    required this.name,
    required this.id,
    required this.type,
    required this.project,
    required this.vm,
    required this.onToggleExpand,
    this.cluster,
    this.onStageChanged,
  });

  final String id;
  final String name;
  final DeploymentType type;
  final LAProject project;
  final ServersCardListViewModel vm;
  final VoidCallback onToggleExpand;

  /// The compose cluster this card shows, if it is one.
  final LACluster? cluster;

  /// Switches the cluster between production and staging; null hides it.
  final ValueChanged<ClusterStage>? onStageChanged;

  @override
  Widget build(BuildContext context) {
    final bool isDockerSwarm = type == DeploymentType.dockerSwarm;
    final ShapeBorder cardShape = type == DeploymentType.vm
        ? CardConstants.defaultShape
        : isDockerSwarm
        ? CardConstants.deprecatedClusterShape
        : CardConstants.defaultClusterShape;

    return IntrinsicWidth(
      child: Card(
        margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        elevation: CardConstants.defaultElevation,
        shape: cardShape,
        child: Container(
          width: 300,
          margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
          child: Stack(
            children: <Widget>[
              ListTile(
                key: ValueKey<String>('${name}basic-tile'),
                contentPadding: EdgeInsets.zero,
                title: Row(
                  children: <Widget>[
                    Icon(
                      type == DeploymentType.vm ? Icons.dns : MdiIcons.docker,
                      color: LAColorTheme.inactive,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: isDockerSwarm
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(name),
                                const Text(
                                  'Deprecated',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            )
                          : Text(name),
                    ),
                    if (cluster != null &&
                        cluster!.type == DeploymentType.dockerCompose &&
                        onStageChanged != null)
                      _StageChip(
                        key: ValueKey<String>('${name}stage-chip'),
                        stage: cluster!.stage,
                        onChanged: onStageChanged!,
                      ),
                  ],
                ),
                subtitle: Text(
                  LAService.servicesForHumans(
                    project.getServerServicesFull(id: id, type: type),
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.expand_more),
                  onPressed: onToggleExpand,
                  tooltip: 'Expand to assign services',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Production (real data) or staging (services still empty or being tried) of
/// a compose cluster. A tap switches it.
class _StageChip extends StatelessWidget {
  const _StageChip({super.key, required this.stage, required this.onChanged});

  final ClusterStage stage;
  final ValueChanged<ClusterStage> onChanged;

  @override
  Widget build(BuildContext context) {
    final bool staging = stage == ClusterStage.staging;
    return Tooltip(
      message:
          'Production: real data. Staging: services still empty or being '
          'tried; production hosts never resolve its names and it runs its '
          'own databases. Tap to switch, then deploy.',
      child: ActionChip(
        visualDensity: VisualDensity.compact,
        backgroundColor: staging ? Colors.orange.shade100 : null,
        label: Text(
          staging ? 'Staging' : 'Production',
          style: const TextStyle(fontSize: 11),
        ),
        onPressed: () => onChanged(
          staging ? ClusterStage.production : ClusterStage.staging,
        ),
      ),
    );
  }
}

@immutable
class ServersCardListViewModel {
  const ServersCardListViewModel({
    required this.currentProject,
    required this.onSaveCurrentProject,
    required this.onUpdateProjectLocal,
    required this.laReleases,
    required this.loading,
  });

  final LAProject currentProject;
  final bool loading;
  final void Function(LAProject project) onSaveCurrentProject;
  final void Function(LAProject project) onUpdateProjectLocal;
  final Map<String, LAReleases> laReleases;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServersCardListViewModel &&
          runtimeType == other.runtimeType &&
          currentProject == other.currentProject &&
          loading == other.loading;

  @override
  int get hashCode => currentProject.hashCode ^ loading.hashCode;
}
