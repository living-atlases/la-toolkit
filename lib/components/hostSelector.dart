import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/selectUtils.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/laServer.dart';
import 'package:la_toolkit/redux/actions.dart';
import 'package:smart_select/smart_select.dart';

import '../laTheme.dart';
import 'choiceEmptyPanel.dart';

class HostSelector extends StatefulWidget {
  final LAServer exclude;
  final List<String> initialValue;
  final List<String> serverList;
  final String title;
  final IconData icon;
  final String modalTitle;
  final String emptyPlaceholder;
  final ChoiceEmptyPanel choiceEmptyPanel;
  final Function(List<String>) onChange;
  HostSelector(
      {Key key,
      this.exclude,
      this.initialValue,
      this.serverList,
      this.icon,
      this.title,
      this.modalTitle,
      this.emptyPlaceholder,
      this.choiceEmptyPanel,
      this.onChange})
      : super(key: key);

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
          List<String> serverList = widget.serverList;
          if (widget.exclude != null) serverList.remove(widget.exclude.name);
          return SmartSelect<String>.multiple(
              key: _selectKey,
              value: widget.initialValue,
              title: widget.title,
              choiceItems: S2Choice.listFrom<String, String>(
                  source: serverList,
                  value: (index, e) => e,
                  title: (index, e) => e),
              // subtitle: (index, e) => e['desc']),
              placeholder: widget.emptyPlaceholder,
              modalHeader: true,
              modalTitle: widget.modalTitle,
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
                    leading: Icon(widget.icon),
                    dense: false,
                    isTwoLine: true,
                    trailing: const Icon(Icons.keyboard_arrow_down)
                    // isTwoLine: true,
                    );
              },
              choiceEmptyBuilder: (a, b) => widget.choiceEmptyPanel,
              onChange: (state) {
                widget.onChange(state.value);
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
