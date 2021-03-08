import 'package:flutter/material.dart';
import 'package:la_toolkit/utils/constants.dart';

class DeploySubResultWidget extends StatelessWidget {
  final String name;
  final dynamic results;

  DeploySubResultWidget(this.name, this.results);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
        child: Row(
          children: [
            Text("$name: ", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("changed (${results['changed']})",
                style: TextStyle(color: ResultsColors.changed)),
            Text(", "),
            Text("failures (${results['failures']})",
                style: TextStyle(color: ResultsColors.failure)),
            Text(", "),
            Text("ok (${results['ok']})",
                style: TextStyle(color: ResultsColors.ok)),
            Text(", "),
            Text("ignored (${results['ignored']})",
                style: TextStyle(color: ResultsColors.ignored)),
            if (results['rescued'] > 0 || results['skipped'] > 0) Text(", "),
            if (results['rescued'] > 0)
              Text("rescued (${results['rescued']})",
                  style: TextStyle(color: ResultsColors.rescued)),
            if (results['rescued'] > 0) Text(", "),
            if (results['skipped'] > 0)
              Text("skipped (${results['skipped']}) ",
                  style: TextStyle(color: ResultsColors.skipped)),
          ],
        ));
  }
}
