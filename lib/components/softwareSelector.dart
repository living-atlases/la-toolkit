import 'package:badges/badges.dart';
import 'package:flutter/material.dart';

class SoftwareSelector extends StatelessWidget {
  final List<String> versions;
  final String? initialValue;
  final Function(String?) onChange;
  final String label;
  static const String outdatedTooltip = '''
  
New version available. 
Choose the latest release to update your portal.
''';
  static const String updatedTooltip = "This current version is up-to-date";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  SoftwareSelector(
      {Key? key,
      required this.label,
      required this.versions,
      this.initialValue,
      required this.onChange})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, DropdownMenuItem<String>> releases = {};
    versions.forEach((String element) {
      // remove dups
      releases[element] = DropdownMenuItem(
          // remove starting 'v' from git tags
          child: Text(element.replaceFirst(RegExp(r'^v'), '')),
          value: element);
    });
    bool outDated = versions.first != initialValue &&
        (initialValue != 'custom' || initialValue != 'upstream');
    List<DropdownMenuItem<String>> items = releases.values.toList();
    DropdownButtonFormField menu = DropdownButtonFormField(
        key: _formKey,
        icon: Icon(Icons.arrow_drop_down),
        iconSize: 32,
        // hint: Text("Recommended a recent version"),
        // underline: SizedBox(),
        decoration: InputDecoration(
          // filled: true,
          // fillColor: Colors.grey[500],
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        value: initialValue != null && initialValue!.isNotEmpty
            ? initialValue
            : items.length > 0
                ? items[0].value
                : "",
        items: items,
        onChanged: (value) {
          onChange(value);
        });
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Tooltip(
            message: outDated ? outdatedTooltip : updatedTooltip,
            child: outDated
                // https://pub.dev/packages/badges
                ? Badge(
                    toAnimate: false,
                    shape: BadgeShape.square,
                    badgeColor: Colors.orangeAccent,
                    borderRadius: BorderRadius.circular(8),
                    badgeContent: const Text('NEW',
                        style: const TextStyle(color: Colors.white)),
                    child: menu,
                  )
                : menu));
  }
}
