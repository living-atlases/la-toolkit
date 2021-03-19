import 'package:flutter/material.dart';

import 'helpIcon.dart';

class TextWithHelp extends StatelessWidget {
  final String text;
  final String helpPage;

  TextWithHelp({required this.text, required this.helpPage});
  @override
  Widget build(BuildContext context) {
    return ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(text),
        trailing: HelpIcon(wikipage: helpPage));
  }
}
