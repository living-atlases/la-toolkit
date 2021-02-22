import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/selectUtils.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/laServer.dart';
import 'package:la_toolkit/redux/actions.dart';
import 'package:mdi/mdi.dart';
import 'package:smart_select/smart_select.dart';

import '../laTheme.dart';
import 'choiceEmptyPanel.dart';

class HostSelector extends StatefulWidget {
  final LAServer server;
  HostSelector({Key key, this.server}) : super(key: key);

  @override
  _HostSelectorState createState() => _HostSelectorState();
}

class _HostSelectorState extends State<HostSelector> {
  GlobalKey<S2MultiState<String>> _selectKey =
      GlobalKey<S2MultiState<String>>();

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _HostSelectorViewModel>(
        distinct: true,
        converter: (store) {
          return _HostSelectorViewModel(
              project: store.state.currentProject,
              onSaveProject: (project) =>
                  store.dispatch(SaveCurrentProject(project)));
        },
        builder: (BuildContext context, _HostSelectorViewModel vm) {
          LAProject currentProject = vm.project;
          List<String> serverList = currentProject.getServersNameList();
          serverList.remove(widget.server.name);
          return SmartSelect<String>.multiple(
              key: _selectKey,
              value: widget.server.gateways,
              title: "SSH Gateway",
              choiceItems: S2Choice.listFrom<String, String>(
                  source: serverList,
                  value: (index, e) => e,
                  title: (index, e) => e),
              // subtitle: (index, e) => e['desc']),
              placeholder: "Direct connection",
              modalHeader: true,
              modalTitle:
                  "Select the server (or servers) that is used as gateway to access to this server:",
              modalType: S2ModalType.popupDialog,
              choiceType: S2ChoiceType.checkboxes,
              modalConfirm: true,
              modalConfirmBuilder: (context, state) =>
                  SelectUtils.modalConfirmBuild(state),
              modalHeaderStyle: S2ModalHeaderStyle(
                  backgroundColor: LAColorTheme.laPalette,
                  textStyle: TextStyle(color: Colors.white)),
              tileBuilder: (context, state) {
                return S2Tile.fromState(state,
                    // padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    leading: const Icon(Mdi.doorClosedLock),
                    dense: false,
                    isTwoLine: true,
                    trailing: const Icon(Icons.keyboard_arrow_down)
                    // isTwoLine: true,
                    );
              },
              choiceEmptyBuilder: (a, b) => ChoiceEmptyPanel(
                  title: "This server doesn't have a ssh gateway associated",
                  body:
                      "If you access to this server using another server as a ssh gateway, you should add the gateway also as a server and select later here.",
                  footer:
                      "For more info see our ssh documentation in our wiki"),
              onChange: (state) {
                widget.server.gateways = state.value;
                currentProject.upsert(widget.server);
                vm.onSaveProject(currentProject);
              });
        });
  }
}

class _HostSelectorViewModel {
  final LAProject project;
  final void Function(LAProject project) onSaveProject;

  _HostSelectorViewModel({this.project, this.onSaveProject});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _HostSelectorViewModel &&
          runtimeType == other.runtimeType &&
          project == other.project;

  @override
  int get hashCode => project.hashCode;
}
