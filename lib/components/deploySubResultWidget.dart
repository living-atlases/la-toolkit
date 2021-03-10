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
            if (results['changed'] > 0)
              Text("changed (${results['changed']})",
                  style: TextStyle(color: ResultsColors.changed)),
            if (results['changed'] > 0) Text(", "),
            if (results['failures'] > 0)
              Text("failures (${results['failures']})",
                  style: TextStyle(color: ResultsColors.failure)),
            if (results['failures'] > 0) Text(", "),
            Text("ok (${results['ok']})",
                style: TextStyle(color: ResultsColors.ok)),
            if (results['ignored'] > 0) Text(", "),
            if (results['ignored'] > 0)
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
