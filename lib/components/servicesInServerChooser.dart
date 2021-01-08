import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:la_toolkit/laTheme.dart';
import 'package:la_toolkit/models/laServer.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:mdi/mdi.dart';
import 'package:smart_select/smart_select.dart';

class ServicesInServerChooser extends StatefulWidget {
  final LAServer server;
  final List<String> servicesInUse;
  final List<String> servicesInServer;
  final List<String> servicesSelected;
  final ValueChanged<List<String>> onChange;
  final List<String> servicesNotInUse;
  ServicesInServerChooser({
    @required this.server,
    @required this.servicesInUse,
    @required this.servicesNotInUse,
    @required this.servicesSelected,
    @required this.servicesInServer,
    @required this.onChange,
  });

  @override
  _ServicesInServerChooserState createState() =>
      _ServicesInServerChooserState();
}

class _ServicesInServerChooserState extends State<ServicesInServerChooser> {
  @override
  Widget build(BuildContext context) {
    return Container(
        // If we want to limit the size:
        // width: 500.0,
        child: SmartSelect<String>.multiple(
      title: "Services to run in ${widget.server.name}:",
      placeholder: 'Server empty, select one or more services',
      value: widget.servicesInServer,
      // choiceItems: LAServiceDesc.names,
      choiceItems: S2Choice.listFrom<String, String>(
        //source: widget.servicesInUse, // LAServiceDesc.names,
        source: LAServiceDesc.names, // widget.servicesInUse,
        value: (index, item) => item,
        title: (index, item) => LAServiceDesc.map[item].name,
        hidden: (index, item) {
          // If is some service in this server => show
          if (widget.servicesInServer.contains(item)) return false;
          // If is some service in other server => hide
          if (widget.servicesSelected.contains(item) ||
              widget.servicesNotInUse.contains(item)) return true;
          return false;
        },
        // useful for disable elements (incompatibility):
        /* disabled: (index, item) {
           return servicesInServer
              .contains(item); // item widget.servicesInServer.contains(item)
        }, */
      ),
      onChange: (state) => setState(() => widget.onChange(state.value)),
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
          color: Colors.blueGrey,
          activeColor: LAColorTheme.laPalette),
      modalHeaderStyle:
          S2ModalHeaderStyle(backgroundColor: LAColorTheme.laPalette),
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
  }
}
