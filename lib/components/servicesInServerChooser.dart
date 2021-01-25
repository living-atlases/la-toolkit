import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/laTheme.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/laServer.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:la_toolkit/redux/actions.dart';
import 'package:mdi/mdi.dart';
import 'package:smart_select/smart_select.dart';

class ServicesInServerChooser extends StatefulWidget {
  final LAServer server;

  ServicesInServerChooser({Key key, this.server}) : super(key: key);

  @override
  _ServicesInServerChooserState createState() =>
      _ServicesInServerChooserState();
}

class _ServicesInServerChooserState extends State<ServicesInServerChooser> {
  LAProject _project;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ServicesInServerChooserViewModel>(
        distinct: true,
        converter: (store) {
          return _ServicesInServerChooserViewModel(
              currentProject: store.state.currentProject,
              onAddServicesToServer: (server, assignedServices) {
                print('On Add Services to Server');
                _project.assign(server, assignedServices);
                _project.validateCreation();
                // store.dispatch(UpdateProject(_project));
                store.dispatch(
                    SaveCurrentProject(_project, store.state.currentStep));
              });
        },
        builder: (BuildContext context, _ServicesInServerChooserViewModel vm) {
          _project = vm.currentProject;
          var serverName = widget.server.name;
          var servicesInServer = _project.serverServices[serverName];
          if (servicesInServer == null) {
            dispose();
          }
          return Container(
              // If we want to limit the size:
              // width: 500.0,
              //
              // https://github.com/davigmacode/flutter_smart_select/tree/master/example
              child: SmartSelect<String>.multiple(
            title: "Services to run in ${widget.server.name}:",
            placeholder: 'Server empty, select one or more services',
            value: servicesInServer,
            // choiceItems: LAServiceDesc.names,
            choiceEmptyBuilder: (a, b) => Container(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(
                      Icons.search,
                      color: Colors.grey,
                      size: 120.0,
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      'This server is empty',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      "There aren't service available (also right now the multiple deploy of services is not supported)",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      "Maybe you should distribute your services between your servers better",
                      style: TextStyle(color: Colors.grey),
                    )
                  ],
                ),
              ),
            ),
            modalValidation: (List<String> selection) {
              Set<String> incompatible = {};
              selection.forEach((first) {
                // print("${otherNameInt} compatible with ${nameInt}");
                selection.forEach((second) {
                  if (first != second &&
                      !LAServiceDesc.get(first).isCompatibleWith(
                          _project.alaInstallRelease,
                          LAServiceDesc.get(second))) {
                    incompatible.addAll({first, second});
                  }
                });
              });
              return incompatible.length == 0
                  ? ""
                  : "Services: ${incompatible.join(', ')} cannot installed together.";
            },
            choiceItems: S2Choice.listFrom<String, String>(
              source:
                  _project.getServicesNameListInUse(), // LAServiceDesc.names,
              // source: LAServiceDesc.keyNames,
              // This fails
              // source: widget.servicesInUse,
              value: (index, nameInt) => nameInt,
              title: (index, nameInt) => LAServiceDesc.get(nameInt).name,
              hidden: (index, nameInt) {
                // If is some service in this server => show
                if (servicesInServer.contains(nameInt)) return false;
                // If is some service in other server => hide
                if (_project.getServicesNameListSelected().contains(nameInt))
                  return true;
                return false;
              },
              // useful for disable elements (incompatibility):
              /* disabled: (index, nameInt) {
          var compatible = true;
          // widget.servicesInUse
          widget.servicesInServer.forEach((otherNameInt) {
            // print("${otherNameInt} compatible with ${nameInt}");
            compatible = compatible &&
                LAServiceDesc.map[nameInt]
                    .isCompatibleWith(LAServiceDesc.map[otherNameInt]);
          });
          return !compatible;
        },*/
            ),
            onChange: (state) =>
                vm.onAddServicesToServer(widget.server, state.value),
            // modalType: S2ModalType.popupDialog,
            choiceType: S2ChoiceType.chips,
            // The current confirm icon is not very clear
            // modalConfirm: true,
            modalHeader: true,
            // This is for enable search:
            // modalFilter: true,
            modalType: S2ModalType.bottomSheet,
            choiceStyle: S2ChoiceStyle(
                showCheckmark: true,
                color: Colors.blueGrey[300],
                titleStyle: TextStyle(fontWeight: FontWeight.w500),
                // subtitleStyle: TextStyle(fontWeight: FontWeight.w500),
                borderOpacity: 0.4,
                activeBorderOpacity: 1,
                activeColor: LAColorTheme.laPalette),
            modalHeaderStyle: S2ModalHeaderStyle(
                backgroundColor: LAColorTheme.laPalette,
                textStyle: TextStyle(color: Colors.white)),
            modalStyle: S2ModalStyle(backgroundColor: Colors.grey[300]),
            tileBuilder: (context, state) => S2Tile.fromState(
              state,
              isTwoLine: true,
              trailing: const Icon(Mdi.serverPlus),
              leading: Container(
                width: 40,
                alignment: Alignment.center,
                child: const Icon(Mdi.server),
              ),
            ),
          ));
        });
  }
}

class _ServicesInServerChooserViewModel {
  final LAProject currentProject;
  final Function(LAServer, List<String>) onAddServicesToServer;

  _ServicesInServerChooserViewModel(
      {this.currentProject, this.onAddServicesToServer});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ServicesInServerChooserViewModel &&
          runtimeType == other.runtimeType &&
          currentProject == other.currentProject &&
          onAddServicesToServer == other.onAddServicesToServer;

  @override
  int get hashCode => currentProject.hashCode ^ onAddServicesToServer.hashCode;
}
