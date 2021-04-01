import 'package:flutter/material.dart';
import 'package:la_toolkit/utils/utils.dart';

import 'defDivider.dart';

class TextTitle extends StatelessWidget {
  final String text;
  final bool separator;
  TextTitle({required this.text, this.separator = false});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      if (separator) const SizedBox(height: 20),
      if (separator) DefDivider(),
      const SizedBox(height: 20),
      Text(text, style: UiUtils.titleStyle),
      const SizedBox(height: 20),
    ]);
  }
}
