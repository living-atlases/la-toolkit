import 'package:flutter/widgets.dart';

import 'alert_card.dart';

class LintErrorPanel extends StatelessWidget {

  const LintErrorPanel(this.errors, {super.key});
  final List<String> errors;
  @override
  Widget build(BuildContext context) {
    return Column(children: errors.map((String e) => AlertCard(message: e)).toList());
  }
}
