import 'package:flutter/material.dart';

class SoftwareSelector extends StatelessWidget {
  final List<String> versions;
  final String? initialValue;
  final Function(String?) onChange;
  final String label;
  final String tooltip;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  SoftwareSelector(
      {Key? key,
      required this.label,
      required this.tooltip,
      required this.versions,
      this.initialValue,
      required this.onChange})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, DropdownMenuItem<String>> releases = {};
    versions.forEach((element) {
      // remove dups
      releases[element] =
          DropdownMenuItem(child: Text(element), value: element);
    });
    List<DropdownMenuItem<String>> items = releases.values.toList();
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Tooltip(
            message: tooltip,
            child: DropdownButtonFormField(
                key: _formKey,
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
                ),
                value: initialValue != null && initialValue!.isNotEmpty
                    ? initialValue
                    : items.length > 0
                        ? items[0].value
                        : "",
                items: items,
                onChanged: (String? value) {
                  onChange(value);
                })));
  }
}
