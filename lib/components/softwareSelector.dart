import 'package:badges/badges.dart';
import 'package:flutter/material.dart';

class SoftwareSelector extends StatefulWidget {
  final List<String> versions;
  final String? initialValue;
  final Function(String?) onChange;
  final String label;
  final bool roundStyle;
  final bool useBadge;

  const SoftwareSelector(
      {Key? key,
      required this.label,
      required this.versions,
      this.initialValue,
      required this.onChange,
      this.useBadge = true,
      this.roundStyle = true})
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
  static const Color outdatedColor = Colors.orangeAccent;

  @override
  Widget build(BuildContext context) {
    Map<String, DropdownMenuItem<String>> releases = {};
    bool emptyInitialValue =
        widget.initialValue != null && widget.initialValue!.isEmpty;
    String? initialValue = widget.initialValue;
    if (!emptyInitialValue && !widget.versions.contains(widget.initialValue)) {
      // A list that does not contains the initial value
      initialValue = null;
      emptyInitialValue = true;
    }
    for (String element in widget.versions) {
      // remove dups
      releases[element] = DropdownMenuItem(
          // remove starting 'v' from git tags
          child: Text(element.replaceFirst(RegExp(r'^v'), '')),
          value: element);
    }

    var initialValueNotEmpty = initialValue != null && initialValue.isNotEmpty;
    bool outDated = initialValueNotEmpty &&
        widget.versions.isNotEmpty &&
        (widget.versions.first != initialValue &&
            (initialValue != 'custom' && initialValue != 'upstream'));
    List<DropdownMenuItem<String>> items = releases.values.toList();

    DropdownButtonFormField menu = DropdownButtonFormField(
        key: _formKey,
        icon: Icon(Icons.arrow_drop_down,
            color: !widget.useBadge
                ? outDated
                    ? outdatedColor
                    : null
                : null),
        iconSize: 32,
        // hint: Text("Recommended a recent version"),
        // underline: SizedBox(),
        decoration: InputDecoration(
          // filled: true,
          // fillColor: Colors.grey[500],
          labelText: widget.label,
          border: widget.roundStyle
              ? OutlineInputBorder(borderRadius: BorderRadius.circular(10))
              : null,
        ),
        value: initialValueNotEmpty
            ? initialValue
            : items.isNotEmpty
                ? items[0].value
                : "",
        items: items,
        onChanged: (value) {
          widget.onChange(value);
        });

    Widget menuConditionalBadge = outDated && widget.useBadge
        // https://pub.dev/packages/badges
        ? Badge(
            toAnimate: false,
            shape: BadgeShape.square,
            badgeColor: outdatedColor,
            borderRadius: BorderRadius.circular(8),
            badgeContent:
                const Text('NEW', style: TextStyle(color: Colors.white)),
            child: menu,
          )
        : menu;
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: emptyInitialValue
            ? menuConditionalBadge
            : Tooltip(
                message: outDated ? outdatedTooltip : updatedTooltip,
                child: menuConditionalBadge));
  }
}
