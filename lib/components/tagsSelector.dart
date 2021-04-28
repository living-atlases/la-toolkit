import 'package:flutter/material.dart';
import 'package:la_toolkit/components/selectUtils.dart';
import 'package:smart_select/smart_select.dart';

import '../laTheme.dart';

class TagsSelector extends StatelessWidget {
  final GlobalKey<S2MultiState<String>> selectorKey;
  final List<String> tags;
  final IconData icon;
  final String title;
  final String placeHolder;
  final String modalTitle;
  final List<String> initialValue;
  final Function(List<String>) onChange;

  TagsSelector(
      {required this.selectorKey,
      required this.tags,
      required this.icon,
      required this.initialValue,
      required this.title,
      required this.placeHolder,
      required this.modalTitle,
      required this.onChange});

  @override
  Widget build(BuildContext context) {
    return SmartSelect<String>.multiple(
        key: selectorKey,
        value: initialValue,
        title: title,
        choiceItems: S2Choice.listFrom<String, String>(
            source: tags, value: (index, e) => e, title: (index, e) => e),
        placeholder: placeHolder,
        modalHeader: true,
        modalTitle: modalTitle,
        modalType: S2ModalType.popupDialog,
        choiceType: S2ChoiceType.chips,
        modalConfirm: true,
        modalConfirmBuilder: (context, state) =>
            SelectUtils.modalConfirmBuild(state),
        modalHeaderStyle: S2ModalHeaderStyle(
            backgroundColor: LAColorTheme.laPalette,
            textStyle: TextStyle(color: Colors.white)),
        tileBuilder: (context, state) {
          return S2Tile.fromState(state,
              // padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              leading: Icon(icon),
              dense: false,
              isTwoLine: true,
              trailing: const Icon(Icons.keyboard_arrow_down)
              // isTwoLine: true,
              );
        },
        onChange: (state) {
          onChange(state.value);
        });
  }
}
