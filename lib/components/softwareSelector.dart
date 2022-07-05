import 'package:badges/badges.dart';
import 'package:flutter/material.dart';

class SoftwareSelector extends StatelessWidget {
  final List<String> versions;
  final Map<String, TextStyle> highlight;
  final String? initialValue;
  final Function(String?) onChange;
  final String label;
  final bool roundStyle;
  final bool useBadge;

  SoftwareSelector(
      {Key? key,
      required this.label,
      required this.versions,
      Map<String, TextStyle>? highlight,
      this.initialValue,
      required this.onChange,
      this.useBadge = true,
      this.roundStyle = true})
      : highlight = highlight ?? {},
        super(key: key);

  static const String outdatedTooltip = '''
  
New version available. 
Choose the latest release to update your portal.
''';
  static const String updatedTooltip = "This current version is up-to-date";
  // final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  static const Color outdatedColor = Colors.orangeAccent;

  @override
  Widget build(BuildContext context) {
    if (versions.isEmpty) return Container();
    List<DropdownMenuItem<String>> items = [];
    bool initialValueEmpty = initialValue != null && initialValue!.isEmpty;
    if (!initialValueEmpty && !versions.contains(initialValue)) {
      // A list that does not contains the initial value
      // initialValue = null;
      initialValueEmpty = true;
    }
    // remove duplicates
    for (String version in versions.toSet().toList()) {
      TextStyle? style = highlight[version];
      items.add(DropdownMenuItem<String>(
          // remove starting 'v' from git tags
          child: Text(version.replaceFirst(RegExp(r'^v'), ''), style: style),
          value: version));
    }
    bool initialValueStillNotEmpty =
        initialValue != null && initialValue!.isNotEmpty;
    bool outDated = initialValueStillNotEmpty &&
        versions.isNotEmpty &&
        (versions.first != initialValue &&
            (initialValue != 'custom' && initialValue != 'upstream'));

    String currentValueOrFirst =
        initialValueStillNotEmpty && versions.contains(initialValue!)
            ? initialValue!
            : items.isNotEmpty
                ? items[0].value!
                : "";

    Container menu = Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: InputDecorator(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              labelText: label,
              border: roundStyle
                  ? OutlineInputBorder(borderRadius: BorderRadius.circular(10))
                  : null,
              contentPadding: const EdgeInsets.all(10),
            ),
            child: ButtonTheme(
              materialTapTargetSize: MaterialTapTargetSize.padded,
              child: DropdownButton<String>(
                //  hint: Text(label),
                isExpanded: true,
                value: currentValueOrFirst,
                elevation: 16,
                icon: Icon(Icons.arrow_drop_down,
                    color: !useBadge
                        ? outDated
                            ? outdatedColor
                            : null
                        : null),
                iconSize: 32,
                underline: DropdownButtonHideUnderline(
                  child: Container(),
                ),
                onChanged: (String? newValue) {
                  onChange(newValue);
                },
                items: items,
              ),
            ),
          ),
        ));

    Widget menuConditionalBadge = outDated && useBadge
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
    return menuConditionalBadge;
  }
}

/* initialValueEmpty
        ? menuConditionalBadge
        : Tooltip(
            message: outDated ? outdatedTooltip : updatedTooltip,
            preferBelow: true,
            child: menuConditionalBadge); */
