import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:la_toolkit/laTheme.dart';
import 'package:la_toolkit/models/laServer.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:mdi/mdi.dart';
import 'package:smart_select/smart_select.dart';

class ServicesInServerChooser extends StatelessWidget {
  final LAServer server;
  final List<String> servicesInUse;
  final List<String> servicesInServer;
  final List<String> servicesSelected;
  final ValueChanged<List<String>> onChange;
  ServicesInServerChooser({
    @required this.server,
    @required this.servicesInUse,
    @required this.servicesSelected,
    @required this.servicesInServer,
    @required this.onChange,
  });

  Widget build(BuildContext context) {
    return Container(
        // If we want to limit the size:
        // width: 500.0,
        //
        // https://github.com/davigmacode/flutter_smart_select/tree/master/example

        child: SmartSelect<String>.multiple(
      title: "Services to run in ${server.name}:",
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
                !LAServiceDesc.get(first)
                    .isCompatibleWith(LAServiceDesc.get(second))) {
              incompatible.addAll({first, second});
            }
          });
        });
        return incompatible.length == 0
            ? ""
            : "Services: ${incompatible.join(', ')} cannot installed together.";
      },
      choiceItems: S2Choice.listFrom<String, String>(
        source: servicesInUse, // LAServiceDesc.names,
        // source: LAServiceDesc.keyNames,
        // This fails
        // source: widget.servicesInUse,
        value: (index, nameInt) => nameInt,
        title: (index, nameInt) => LAServiceDesc.get(nameInt).name,
        hidden: (index, nameInt) {
          // If is some service in this server => show
          if (servicesInServer.contains(nameInt)) return false;
          // If is some service in other server => hide
          if (servicesSelected.contains(nameInt)) return true;
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
      onChange: (state) => onChange(state.value),
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
  }
}
