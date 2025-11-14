import 'package:flutter/material.dart';

import 'help_icon.dart';

class TextWithHelp extends StatelessWidget {
  const TextWithHelp(
      {super.key,
      required this.text,
      required this.helpPage,
      this.padding = EdgeInsets.zero});
  final String text;
  final String helpPage;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        contentPadding: padding,
        title: Text(text),
        trailing: HelpIcon(wikipage: helpPage));
  }
}
