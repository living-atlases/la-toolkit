import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/serverServicesEditCard.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/laServer.dart';
import 'package:la_toolkit/models/laService.dart';
import 'package:la_toolkit/redux/appActions.dart';

class ServersServicesEditPanel extends StatefulWidget {
  const ServersServicesEditPanel({Key? key}) : super(key: key);

  @override
  State<ServersServicesEditPanel> createState() =>
      _ServersServicesEditPanelState();
}

class _ServersServicesEditPanelState extends State<ServersServicesEditPanel> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ServersServicesEditPanelViewModel>(
        distinct: true,
        converter: (store) {
          return _ServersServicesEditPanelViewModel(
              project: store.state.currentProject,
              onSaveCurrentProject: (project) {
                // store.dispatch(UpdateProject(_project));
                store.dispatch(SaveCurrentProject(project));
              });
        },
        builder: (BuildContext context, _ServersServicesEditPanelViewModel vm) {
          LAProject project = vm.project;
          Map<String, List<LAService>> servicesAssignable =
              project.getServerServicesAssignable();
          return Wrap(children: [
            for (LAServer server in vm.project.servers)
              ServerServicesEditCard(
                server: server,
                isHub: project.isHub,
                currentServerServices:
                    project.getServerServices(serverId: server.id),
                availableServicesForServer: servicesAssignable[server.id]!,
                allServices: project.services,
                onAssigned: (list) {
                  project.assign(server, list);
                  vm.onSaveCurrentProject(project);
                },
                onUnassigned: (service) {
                  project.unAssign(server, service);
                  vm.onSaveCurrentProject(project);
                },
                onRename: (String newName) {
                  server.name = newName;
                  project.upsertServer(server);
                  vm.onSaveCurrentProject(project);
                },
                onDeleted: (LAServer server) {
                  project.delete(server);
                  vm.onSaveCurrentProject(project);
                },
                onEditing: () {},
              )
          ]);
        });
  }
}

class _ServersServicesEditPanelViewModel {
  final LAProject project;
  final Function(LAProject) onSaveCurrentProject;

  _ServersServicesEditPanelViewModel(
      {required this.project, required this.onSaveCurrentProject});
}
