import 'package:flutter/material.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import '../models/la_server.dart';
import '../utils/card_constants.dart';

class ServerSelector extends StatefulWidget {
  const ServerSelector(
      {super.key,
      required this.selectorKey,
      required this.hosts,
      required this.icon,
      required this.initialValue,
      required this.title,
      required this.placeHolder,
      required this.modalTitle,
      this.exclude,
      required this.onChange});

  final GlobalKey<FormFieldState<dynamic>> selectorKey;
  final List<String> hosts;
  final IconData icon;
  final String title;
  final String placeHolder;
  final String modalTitle;
  final List<String> initialValue;
  final Function(List<String>) onChange;
  final LAServer? exclude;

  @override
  State<ServerSelector> createState() => _ServerSelectorState();
}

class _ServerSelectorState extends State<ServerSelector> {
  List<String> _selected = <String>[];

  @override
  void initState() {
    _selected = widget.initialValue;
    super.initState();
  }

  @override
  void didUpdateWidget(ServerSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update selected values when initialValue changes from outside
    if (widget.initialValue != oldWidget.initialValue) {
      setState(() {
        _selected = widget.initialValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> serverList = widget.hosts;
    if (widget.exclude != null) {
      serverList.remove(widget.exclude!.name);
    }
    return Card(
        elevation: CardConstants.defaultElevation,
        // color: Colors.black12,
        margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              MultiSelectDialogField<String>(
                listType: MultiSelectListType.LIST,
                searchable: true,
                confirmText: const Text('CONFIRM'),
                //selectedColor: Theme.of(context).primaryColor.withOpacity(.2),
                decoration: const BoxDecoration(
                    //color: Colors.grey.shade100
                    // border: Border.all(),
                    ),
                buttonIcon: Icon(widget.icon, color: Colors.grey),
                buttonText: Text(widget.title, style: const TextStyle(fontSize: 16)),
                title: Text(widget.modalTitle, style: const TextStyle(fontSize: 16)),
                initialValue: _selected,
                items: serverList.map((String host) => MultiSelectItem<String>(host, host)).toList(),
                onConfirm: (List<String> values) {
                  widget.onChange(values);
                  if (mounted) {
                    setState(() {
                      _selected = values;
                    });
                  }
                },
                chipDisplay: MultiSelectChipDisplay<String>(
                  // icon: Icon(widget.icon),
                  chipColor: Colors.grey.withValues(alpha: 0.9),
                  textStyle: const TextStyle(color: Colors.white),

                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(2))),
                  /* onTap: (value) {
                    setState(() {
                      _selected.remove(value);
                    });
                  }, */
                ),
              ),
              if (_selected.isEmpty)
                Container(
                    padding: const EdgeInsets.all(10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.placeHolder,
                      style: const TextStyle(color: Colors.black45),
                    ))
              else
                const Text(''),
            ],
          ),
        ));
  }
}
