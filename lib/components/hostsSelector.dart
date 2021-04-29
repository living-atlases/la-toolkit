import 'package:flutter/material.dart';
import 'package:la_toolkit/models/laServer.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';

class HostsSelector extends StatefulWidget {
  final GlobalKey<FormFieldState> selectorKey;
  final List<String> hosts;
  final IconData icon;
  final String title;
  final String placeHolder;
  final String modalTitle;
  final List<String> initialValue;
  final Function(List<String>) onChange;
  final LAServer? exclude;
  HostsSelector(
      {required this.selectorKey,
      required this.hosts,
      required this.icon,
      required this.initialValue,
      required this.title,
      required this.placeHolder,
      required this.modalTitle,
      this.exclude,
      required this.onChange});

  @override
  _HostsSelectorState createState() => _HostsSelectorState();
}

class _HostsSelectorState extends State<HostsSelector> {
  List<String> _selected = [];

  @override
  void initState() {
    _selected = widget.initialValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<String> serverList = widget.hosts;
    if (widget.exclude != null) serverList.remove(widget.exclude!.name);
    return Container(
      margin: EdgeInsets.fromLTRB(10, 5, 10, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        children: <Widget>[
          MultiSelectDialogField<String>(
            listType: MultiSelectListType.LIST,
            searchable: true,
            confirmText: Text("CONFIRM"),
            //selectedColor: Theme.of(context).primaryColor.withOpacity(.2),
            buttonIcon: Icon(widget.icon, color: Colors.grey),
            buttonText: Text(widget.title, style: TextStyle(fontSize: 16)),
            title: Text(widget.modalTitle, style: TextStyle(fontSize: 16)),
            initialValue: _selected,
            items: serverList
                .map((host) => MultiSelectItem<String>(host, host))
                .toList(),
            onConfirm: (values) {
              setState(() {
                _selected = values;
              });
              widget.onChange(values);
            },
            chipDisplay: MultiSelectChipDisplay<String>(
              // icon: Icon(widget.icon),
              chipColor: Colors.grey.withOpacity(.8),
              textStyle: TextStyle(color: Colors.white),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              onTap: (value) {
                setState(() {
                  _selected.remove(value);
                });
              },
            ),
          ),
          _selected.isEmpty
              ? Container(
                  padding: EdgeInsets.all(10),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.placeHolder,
                    style: TextStyle(color: Colors.black45),
                  ))
              : Container(),
        ],
      ),
    );
  }
}
