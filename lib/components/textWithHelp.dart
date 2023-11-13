import 'package:flutter/material.dart';

import 'help_icon.dart';

class TextWithHelp extends StatelessWidget {
  final String text;
  final String helpPage;
  final EdgeInsets padding;

  const TextWithHelp(
      {Key? key,
      required this.text,
      required this.helpPage,
      this.padding = EdgeInsets.zero})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        contentPadding: padding,
        title: Text(text),
        trailing: HelpIcon(wikipage: helpPage));
  }
}
