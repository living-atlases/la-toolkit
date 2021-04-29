import 'package:flutter/material.dart';
import 'package:multi_select_flutter/bottom_sheet/multi_select_bottom_sheet_field.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';

class TagsSelector extends StatefulWidget {
  final GlobalKey<FormFieldState> selectorKey;
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
  _TagsSelectorState createState() => _TagsSelectorState();
}

class _TagsSelectorState extends State<TagsSelector> {
  List<Object?> _selected = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 5, 10, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        children: <Widget>[
          MultiSelectBottomSheetField(
            initialChildSize: 0.5,
            listType: MultiSelectListType.CHIP,
            searchable: true,
            confirmText: Text("CONFIRM"),
            selectedColor: Theme.of(context).primaryColor.withOpacity(.2),
            buttonIcon: Icon(widget.icon, color: Colors.grey),
            buttonText: Text(widget.title, style: TextStyle(fontSize: 16)),
            title: Text(widget.modalTitle, style: TextStyle(fontSize: 16)),
            initialValue: widget.initialValue
                .map((tag) => MultiSelectItem<String>(tag, tag))
                .toList(),
            items: widget.tags
                .map((tag) => MultiSelectItem<String>(tag, tag))
                .toList(),
            onConfirm: (List<Object?> values) {
              setState(() {
                _selected = values;
              });
              widget.onChange(values.map((obj) => obj.toString()).toList());
            },
            chipDisplay: MultiSelectChipDisplay(
              // icon: Icon(widget.icon),
              chipColor: Theme.of(context).primaryColor.withOpacity(.2),
              textStyle: TextStyle(color: Colors.black54),
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
