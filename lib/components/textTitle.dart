import 'package:flutter/material.dart';
import '../utils/utils.dart';

import 'defDivider.dart';

class TextTitle extends StatelessWidget {
  const TextTitle({super.key, required this.text, this.separator = false});
  final String text;
  final bool separator;
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      if (separator) const SizedBox(height: 20),
      if (separator) const DefDivider(),
      const SizedBox(height: 20),
      Text(text, style: UiUtils.titleStyle),
      const SizedBox(height: 20),
    ]);
  }
}
