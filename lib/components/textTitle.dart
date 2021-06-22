import 'package:flutter/material.dart';
import 'package:la_toolkit/utils/utils.dart';

import 'defDivider.dart';

class TextTitle extends StatelessWidget {
  final String text;
  final bool separator;
  const TextTitle({Key? key, required this.text, this.separator = false})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      if (separator) const SizedBox(height: 20),
      if (separator) const DefDivider(),
      const SizedBox(height: 20),
      Text(text, style: UiUtils.titleStyle),
      const SizedBox(height: 20),
    ]);
  }
}
