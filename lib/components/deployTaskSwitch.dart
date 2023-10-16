import 'package:flutter/material.dart';

import '../laTheme.dart';
import 'help_icon.dart';

class DeployTaskSwitch extends StatelessWidget {
  final String title;
  final String? help;
  final bool initialValue;
  final Function(bool) onChanged;

  const DeployTaskSwitch({
    Key? key,
    required this.title,
    this.help,
    required this.initialValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
        // contentPadding: EdgeInsets.zero,
        value: initialValue,
        title: Text(title,
            style: TextStyle(color: LAColorTheme.laThemeData.hintColor)),
        secondary: help != null ? HelpIcon(wikipage: help!) : null,
        onChanged: (bool newValue) {
          onChanged(newValue);
        });
  }
}
