import 'package:badges/badges.dart';
import 'package:flutter/material.dart';

class SoftwareSelector extends StatefulWidget {
  final List<String> versions;
  final String? initialValue;
  final Function(String?) onChange;
  final String label;

  const SoftwareSelector(
      {Key? key,
      required this.label,
      required this.versions,
      this.initialValue,
      required this.onChange})
      : super(key: key);

  @override
  _SoftwareSelectorState createState() => _SoftwareSelectorState();
}

class _SoftwareSelectorState extends State<SoftwareSelector> {
  static const String outdatedTooltip = '''
  
New version available. 
Choose the latest release to update your portal.
''';
  static const String updatedTooltip = "This current version is up-to-date";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Map<String, DropdownMenuItem<String>> releases = {};
    for (String element in widget.versions) {
      // remove dups
      releases[element] = DropdownMenuItem(
          // remove starting 'v' from git tags
          child: Text(element.replaceFirst(RegExp(r'^v'), '')),
          value: element);
    }
    bool outDated = widget.initialValue != null &&
        widget.versions.isNotEmpty &&
        (widget.versions.first != widget.initialValue &&
            (widget.initialValue != 'custom' &&
                widget.initialValue != 'upstream'));
    List<DropdownMenuItem<String>> items = releases.values.toList();
    DropdownButtonFormField menu = DropdownButtonFormField(
        key: _formKey,
        icon: const Icon(Icons.arrow_drop_down),
        iconSize: 32,
        // hint: Text("Recommended a recent version"),
        // underline: SizedBox(),
        decoration: InputDecoration(
          // filled: true,
          // fillColor: Colors.grey[500],
          labelText: widget.label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        value: widget.initialValue != null && widget.initialValue!.isNotEmpty
            ? widget.initialValue
            : items.isNotEmpty
                ? items[0].value
                : "",
        items: items,
        onChanged: (value) {
          widget.onChange(value);
        });
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                        style: TextStyle(color: Colors.white)),
                    child: menu,
                  )
                : menu));
  }
}
