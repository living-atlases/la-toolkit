import 'package:flutter/material.dart';

class SoftwareSelector extends StatelessWidget {
  final List<String> versions;
  final String initialValue;
  final Function(String) onChange;
  final String label;
  final String tooltip;
  SoftwareSelector(
      {Key key,
      this.label,
      this.tooltip,
      this.versions,
      this.initialValue,
      this.onChange})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<String>> releases = [];
    versions.forEach((element) =>
        releases.add(DropdownMenuItem(child: Text(element), value: element)));
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        /* decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10)), */
        child: Tooltip(
            message: tooltip,
            child: DropdownButtonFormField(
                icon: Icon(Icons.arrow_drop_down),
                iconSize: 32,
                // hint: Text("Recommended a recent version"),
                // underline: SizedBox(),
                decoration: InputDecoration(
                  // filled: true,
                  // fillColor: Colors.grey[500],
                  labelText: label,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  // border: new CustomBorderTextFieldSkin().getSkin(),
                ),
                value: initialValue,
                items: releases,
                onChanged: (value) {
                  onChange(value);
                })));
  }
}
