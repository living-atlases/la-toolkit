import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/serverServicesEditCard.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/laService.dart';
import 'package:la_toolkit/redux/actions.dart';
import 'package:la_toolkit/utils/cardConstants.dart';

import '../models/laServer.dart';

class ServersCardList extends StatelessWidget {
  const ServersCardList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ServersCardListViewModel>(
        distinct: false,
        converter: (store) {
          return _ServersCardListViewModel(
              currentProject: store.state.currentProject,
              onSaveCurrentProject: (project) {
                store.dispatch(SaveCurrentProject(project));
              });
        },
        builder: (BuildContext context, _ServersCardListViewModel vm) {
          final project = vm.currentProject;
          return Wrap(children: [
            for (LAServer server in project.servers)
              ServerServicesHoverCard(server: server, project: project, vm: vm)
          ]);
        });
  }
}

class ServerServicesHoverCard extends StatefulWidget {
  final LAServer server;
  final LAProject project;
  final _ServersCardListViewModel vm;

  const ServerServicesHoverCard(
      {Key? key, required this.server, required this.project, required this.vm})
      : super(key: key);

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
    Map<String, List<LAService>> servicesAssignable =
        widget.project.getServerServicesAssignable();
    return MouseRegion(
        cursor: SystemMouseCursors.click,
        onHover: (s) {
          setState(() {
            _hover = true;
          });
          Future.delayed(const Duration(milliseconds: 500), () {
            setState(() {
              if (_hover) {
                _stillHover = true;
              }
            });
          });
        },
        onExit: (s) {
          setState(() {
            _hover = false;
          });
          if (!_editing) {
            Future.delayed(const Duration(milliseconds: 1000), () {
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
                  isHub: widget.project.isHub,
                  currentServerServices: widget.project
                      .getServerServices(serverId: widget.server.id),
                  availableServicesForServer:
                      servicesAssignable[widget.server.id]!,
                  allServices: widget.project.services,
                  onAssigned: (list) {
                    widget.project.assign(widget.server, list);
                    widget.vm.onSaveCurrentProject(widget.project);
                  },
                  onUnassigned: (service) {
                    widget.project.unAssign(widget.server, service);
                    widget.vm.onSaveCurrentProject(widget.project);
                  },
                  onRename: (String newName) {
                    widget.server.name = newName;
                    widget.project.upsertServer(widget.server);
                    widget.vm.onSaveCurrentProject(widget.project);
                    setState(() {
                      _editing = false;
                    });
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
                  server: widget.server,
                  project: widget.project,
                  vm: widget.vm),
        ));
  }
}

class ServerServicesViewCard extends StatelessWidget {
  const ServerServicesViewCard(
      {Key? key, required this.server, required this.project, required this.vm})
      : super(key: key);

  final LAServer server;
  final LAProject project;
  final _ServersCardListViewModel vm;

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
        child: Card(
            margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            elevation: CardConstants.defaultElevation,
            shape: CardConstants.defaultShape,
            child: Container(
                width: 300,
                margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: ListTile(
                  key: ValueKey("${server.name}basic-tile"),
                  contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  title: Text(server.name),
                  subtitle: Text(LAService.servicesForHumans(
                      project.getServerServicesFull(serverId: server.id))),
                  /* trailing: Wrap(spacing: 12, // space between two icons
                        children: <Widget>[
                          RenameServerIcon(server, (String newName) {
                            LAServer s = server;
                            s.name = newName;
                            project.upsertServer(s);
                            vm.onSaveCurrentProject(project);
                          }),
                          Tooltip(
                              message: "Delete this server",
                              child: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () =>
                                      UiUtils.showAlertDialog(context, () {
                                        project.delete(server);
                                        vm.onSaveCurrentProject(project);
                                      }, () => {},
                                          title:
                                              "Deleting the server '${server.name}'"))),
                        ]) */
                ))));
  }
}

class _ServersCardListViewModel {
  final LAProject currentProject;
  final void Function(LAProject project) onSaveCurrentProject;

  _ServersCardListViewModel(
      {required this.currentProject, required this.onSaveCurrentProject});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ServersCardListViewModel &&
          runtimeType == other.runtimeType &&
          currentProject == other.currentProject;

  @override
  int get hashCode => currentProject.hashCode;
}
