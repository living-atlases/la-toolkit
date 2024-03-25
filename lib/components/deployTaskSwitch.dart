import 'package:flutter/material.dart';

import 'help_icon.dart';

class DeployTaskSwitch extends StatelessWidget {
  const DeployTaskSwitch({
    super.key,
    required this.title,
    this.help,
    required this.initialValue,
    required this.onChanged,
  });

  final String title;
  final String? help;
  final bool initialValue;
  final Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
        // contentPadding: EdgeInsets.zero,
        value: initialValue,
        title:
            Text(title, style: TextStyle(color: Theme.of(context).hintColor)),
        secondary: help != null ? HelpIcon(wikipage: help!) : null,
        onChanged: (bool newValue) {
          onChanged(newValue);
        });
  }
}
