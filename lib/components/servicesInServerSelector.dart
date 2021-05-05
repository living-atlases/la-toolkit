import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/laTheme.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/laServer.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:la_toolkit/redux/appActions.dart';
import 'package:la_toolkit/utils/cardConstants.dart';
import 'package:mdi/mdi.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class ServicesInServerSelector extends StatefulWidget {
  final LAServer server;

  ServicesInServerSelector({Key? key, required this.server}) : super(key: key);

  @override
  _ServicesInServerSelectorState createState() =>
      _ServicesInServerSelectorState();
}

class _ServicesInServerSelectorState extends State<ServicesInServerSelector> {
  List<String> _selected = [];
  final _multiSelectKey = GlobalKey<FormFieldState>();

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ServicesInServerSelectorViewModel>(
        converter: (store) {
      return _ServicesInServerSelectorViewModel(
          currentProject: store.state.currentProject,
          onAddServicesToServer: (project, server, assignedServices) {
            print('On Add Services to Server');
            project.assign(server, assignedServices);
            project.validateCreation();
            // store.dispatch(UpdateProject(_project));
            store.dispatch(SaveCurrentProject(project));
          });
    }, builder: (BuildContext context, _ServicesInServerSelectorViewModel vm) {
      String id = widget.server.id;
      LAProject _project = vm.currentProject;
      List<String> servicesInServer = _project.getServerServices(serverId: id);
      List<String> allServices = _project
          .getServicesNameListInUse()
          .where((nameInt) => servicesInServer.contains(nameInt)
              ? true
              : _project.getServicesAssignedToServers().contains(nameInt)
                  ? false
                  : true)
          .toList();
      _selected = servicesInServer;
      return Container(
          decoration: BoxDecoration(
              /* color: Theme.of(context).primaryColor.withOpacity(.4), */
              /* border: Border.all(
          color: Theme.of(context).primaryColor,
          width: 2,
        ), */
              ),
          child: Card(
              elevation: CardConstants.defaultElevation,
              // color: Colors.black12,
              margin: const EdgeInsets.all(10),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    Tooltip(
                        message: "Select the LA services to run in this server",
                        child: MultiSelectBottomSheetField<String>(
                          key: _multiSelectKey,
                          // initialChildSize: 0.4,
                          listType: MultiSelectListType.CHIP,
                          searchable: false,
                          initialValue: _selected,
                          // shape: StadiumBorder(side: BorderSide()),
                          buttonIcon:
                              Icon(Mdi.serverPlus, color: Colors.black45),
                          // Remove the lines
                          decoration: BoxDecoration(
                              // color: Colors.black12
                              //  border: Border.all(),
                              ),
                          buttonText:
                              Text("Services to run in ${widget.server.name}:"),
                          title:
                              Text("Services to run in ${widget.server.name}:"),
                          items: allServices
                              .map((service) => MultiSelectItem<String>(
                                  service, LAServiceDesc.get(service).name))
                              .toList(),
                          onSelectionChanged: (values) =>
                              _multiSelectKey.currentState!.validate(),
                          onConfirm: (values) {
                            setState(() {
                              _selected = values;
                            });
                            _multiSelectKey.currentState!.validate();
                            vm.onAddServicesToServer(
                                _project, widget.server, values);
                          },
                          validator: (selection) {
                            if (selection != null) {
                              Set<String> incompatible = {};
                              selection.forEach((first) {
                                selection.forEach((second) {
                                  // print("$first compatible with $second");
                                  if (first != second &&
                                      !LAServiceDesc.get(first)
                                          .isCompatibleWith(
                                              _project.alaInstallRelease,
                                              LAServiceDesc.get(second))) {
                                    incompatible.addAll({first, second});
                                  }
                                });
                              });
                              return incompatible.length == 0
                                  ? ""
                                  : "Services: ${incompatible.join(', ')} can't be installed together.";
                            }
                            return null;
                          },
                          chipDisplay: MultiSelectChipDisplay<String>(
                            shape: StadiumBorder(
                                side:
                                    BorderSide(color: LAColorTheme.laPalette)),
                            textStyle: TextStyle(color: LAColorTheme.laPalette),
                            onTap: (value) {
                              // setState(() {});
                              _multiSelectKey.currentState!.validate();
                            },
                          ),
                        )),
                    if (_selected.isEmpty)
                      Container(
                          padding: EdgeInsets.all(10),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "None selected",
                            style: TextStyle(color: Colors.black54),
                          )),
                  ],
                ),
              )));
    });
  }
}

class _ServicesInServerSelectorViewModel {
  final LAProject currentProject;
  final Function(LAProject, LAServer, List<String>) onAddServicesToServer;

  _ServicesInServerSelectorViewModel(
      {required this.currentProject, required this.onAddServicesToServer});
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ServicesInServerSelectorViewModel &&
          runtimeType == other.runtimeType &&
          currentProject == other.currentProject &&
          onAddServicesToServer == other.onAddServicesToServer;

  @override
  int get hashCode => currentProject.hashCode ^ onAddServicesToServer.hashCode;
}
