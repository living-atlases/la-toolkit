import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';


import '../models/appState.dart';
import '../models/deploymentType.dart';
import '../models/laCluster.dart';
import '../models/laReleases.dart';
import '../models/laServer.dart';
import '../models/la_project.dart';
import '../models/la_service.dart';
import '../redux/actions.dart';
import '../utils/card_constants.dart';
import 'server_services_edit_card.dart';

class ServersCardList extends StatelessWidget {
  const ServersCardList({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ServersCardListViewModel>(
        // distinct: false,
        converter: (Store<AppState> store) {
      return ServersCardListViewModel(
          currentProject: store.state.currentProject,
          laReleases: store.state.laReleases,
          onSaveCurrentProject: (LAProject project) {
            store.dispatch(SaveCurrentProject(project));
          });
    }, builder: (BuildContext context, ServersCardListViewModel vm) {
      final LAProject project = vm.currentProject;
      final bool dockerEnabled = project.isDockerClusterConfigured();
      return Wrap(children: <Widget>[
        if (dockerEnabled)
          for (final LACluster cluster in project.clusters)
            ServerServicesHoverCard(cluster: cluster, project: project, vm: vm),
        for (final LAServer server in project.servers)
          ServerServicesHoverCard(server: server, project: project, vm: vm),
      ]);
    });
  }
}

class ServerServicesHoverCard extends StatefulWidget {
  const ServerServicesHoverCard(
      {super.key,
      this.server,
      this.cluster,
      required this.project,
      required this.vm});

  final LAServer? server;
  final LACluster? cluster;
  final LAProject project;
  final ServersCardListViewModel vm;

  @override
  State<ServerServicesHoverCard> createState() =>
      _ServerServicesHoverCardState();
}

class _ServerServicesHoverCardState extends State<ServerServicesHoverCard> {
  bool _editing = false;
  bool _hover = false;
  bool _stillHover = false;

  @override
  Widget build(BuildContext context) {
    final bool isAServer = widget.server != null;
    final DeploymentType type =
        isAServer ? DeploymentType.vm : DeploymentType.dockerSwarm;
    final String sId = isAServer ? widget.server!.id : widget.cluster!.id;
    final String name = isAServer ? widget.server!.name : widget.cluster!.name;
    final Map<String, List<LAService>> servicesAssignable =
        widget.project.getServerServicesAssignable(type);
    return MouseRegion(
        cursor: SystemMouseCursors.click,
        onHover: (PointerHoverEvent s) {
          setState(() {
            _hover = true;
          });
          Future<void>.delayed(const Duration(milliseconds: 500), () {
            setState(() {
              if (_hover) {
                _stillHover = true;
              }
            });
          });
        },
        onExit: (PointerExitEvent s) {
          setState(() {
            _hover = false;
          });
          if (!_editing) {
            Future<void>.delayed(const Duration(milliseconds: 1000), () {
              setState(() {
                if (!_hover) {
                  _stillHover = false;
                }
              });
            });
          }
        },
        child: AnimatedSwitcher(
          duration: const Duration(microseconds: 1200),
          child: _stillHover
              ? ServerServicesEditCard(
                  server: widget.server,
                  cluster: widget.cluster,
                  type: type,
                  isHub: widget.project.isHub,
                  currentServerServices: isAServer
                      ? widget.project
                          .getServerServices(serverId: widget.server!.id)
                      : widget.project
                          .getClusterServices(clusterId: widget.cluster!.id),
                  availableServicesForServer:
                      servicesAssignable[sId] ?? <LAService>[],
                  allServices: widget.project.services,
                  onAssigned: (List<String> list) {
                    widget.project.assignByType(
                        sId, type, list, null, widget.vm.laReleases);
                    widget.vm.onSaveCurrentProject(widget.project);
                  },
                  onUnassigned: (String service) {
                    widget.project.unAssignByType(sId, type, service);
                    widget.vm.onSaveCurrentProject(widget.project);
                  },
                  onRename: (String newName) {
                    if (isAServer) {
                      widget.server!.name = newName;
                      widget.project.upsertServer(widget.server!);
                      widget.vm.onSaveCurrentProject(widget.project);
                      setState(() {
                        _editing = false;
                      });
                    }
                  },
                  onDeleted: (LAServer server) {
                    setState(() {
                      _editing = false;
                    });
                    widget.project.delete(server);
                    widget.vm.onSaveCurrentProject(widget.project);
                  },
                  onEditing: () => setState(() {
                        _editing = true;
                      }))
              : ServerServicesViewCard(
                  id: sId,
                  name: name,
                  type: type,
                  project: widget.project,
                  vm: widget.vm),
        ));
  }
}

class ServerServicesViewCard extends StatelessWidget {
  const ServerServicesViewCard(
      {super.key,
      required this.name,
      required this.id,
      required this.type,
      required this.project,
      required this.vm});

  final String id;
  final String name;
  final DeploymentType type;
  final LAProject project;
  final ServersCardListViewModel vm;

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
        child: Card(
            margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            elevation: CardConstants.defaultElevation,
            shape: type == DeploymentType.vm
                ? CardConstants.defaultShape
                : CardConstants.defaultClusterShape,
            child: Container(
                width: 300,
                margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: ListTile(
                  key: ValueKey<String>('${name}basic-tile'),
                  contentPadding: EdgeInsets.zero,
                  title: Text(name),
                  subtitle: Text(LAService.servicesForHumans(
                      project.getServerServicesFull(id: id, type: type))),
                ))));
  }
}

@immutable
class ServersCardListViewModel {
  const ServersCardListViewModel(
      {required this.currentProject,
      required this.onSaveCurrentProject,
      required this.laReleases});

  final LAProject currentProject;
  final void Function(LAProject project) onSaveCurrentProject;
  final Map<String, LAReleases> laReleases;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServersCardListViewModel &&
          runtimeType == other.runtimeType &&
          currentProject == other.currentProject;

  @override
  int get hashCode => currentProject.hashCode;
}
