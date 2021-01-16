import 'package:flutter/material.dart';

import 'helpIcon.dart';

class TextWithHelp extends StatelessWidget {
  final String text;
  final String helpPage;

  TextWithHelp({this.text, this.helpPage});
  @override
  Widget build(BuildContext context) {
    return ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(text),
        trailing: HelpIcon(wikipage: helpPage));
  }
}
