import 'package:flutter/material.dart';
import 'package:la_toolkit/utils/cardConstants.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';

class ChoicesSelector extends StatefulWidget {
  final GlobalKey<FormFieldState> selectorKey;
  final List<String> choices;
  final IconData icon;
  final String title;
  final String placeHolder;
  final String modalTitle;
  final List<String> initialValue;
  final Function(List<String>) onChange;

  const ChoicesSelector(
      {Key? key,
      required this.selectorKey,
      required this.choices,
      required this.icon,
      required this.initialValue,
      required this.title,
      required this.placeHolder,
      required this.modalTitle,
      required this.onChange})
      : super(key: key);

  @override
  State<ChoicesSelector> createState() => _ChoicesSelectorState();
}

class _ChoicesSelectorState extends State<ChoicesSelector> {
  List<String> _selected = [];

  @override
  void initState() {
    _selected = widget.initialValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: CardConstants.defaultElevation,
        margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(children: <Widget>[
              Column(
                children: <Widget>[
                  MultiSelectDialogField<String>(
                    // initialChildSize: 0.5,
                    listType: MultiSelectListType.CHIP,
                    searchable: true,
                    confirmText: const Text("CONFIRM"),
                    selectedColor:
                        Theme.of(context).primaryColor.withOpacity(.2),
                    buttonIcon: Icon(widget.icon, color: Colors.grey),
                    buttonText: Text(widget.title,
                        style: const TextStyle(fontSize: 16)),
                    title: Text(widget.modalTitle,
                        style: const TextStyle(fontSize: 16)),
                    initialValue: _selected,
                    items: widget.choices
                        .map((tag) => MultiSelectItem<String>(tag, tag))
                        .toList(),
                    onConfirm: (values) {
                      setState(() {
                        _selected = values;
                      });
                      widget.onChange(values);
                    },
                    chipDisplay: MultiSelectChipDisplay<String>(
                      // icon: Icon(MdiIcons.tag, size: 6, color: Colors.white),
                      chipColor: Theme.of(context).primaryColor.withOpacity(.8),
                      textStyle: const TextStyle(color: Colors.white),
                      onTap: (value) {
                        _selected.remove(value);
                      },
                    ),
                  ),
                  _selected.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(10),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            widget.placeHolder,
                            style: const TextStyle(color: Colors.black45),
                          ))
                      : Container(),
                ],
              ),
            ])));
  }
}
