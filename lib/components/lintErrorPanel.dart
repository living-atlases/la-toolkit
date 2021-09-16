import 'package:flutter/widgets.dart';

import 'alertCard.dart';

class LintErrorPanel extends StatelessWidget {
  final List<String> errors;

  const LintErrorPanel(this.errors, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(children: errors.map((e) => AlertCard(message: e)).toList());
  }
}
