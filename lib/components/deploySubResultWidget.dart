import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:la_toolkit/models/ansibleError.dart';
import 'package:la_toolkit/utils/constants.dart';

class DeploySubResultWidget extends StatelessWidget {
  final String name;
  final String title;
  final dynamic results;
  final List<AnsibleError> errors;
  DeploySubResultWidget(
      {required this.name,
      required this.title,
      required this.results,
      required this.errors});

  @override
  Widget build(BuildContext context) {
    List<Widget> errorsWidgets = [];
    errors.forEach((error) {
      errorsWidgets.addAll([
        Padding(
            padding: EdgeInsets.fromLTRB(20, 10, 0, 0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              RichText(
                  overflow: TextOverflow.visible,
                  textAlign: TextAlign.left,
                  softWrap: true,
                  text: TextSpan(children: <TextSpan>[
                    TextSpan(text: "Task "),
                    TextSpan(
                        text: error.action, style: GoogleFonts.robotoMono()),
                    TextSpan(text: " failed with message: ")
                  ])),
              RichText(
                  overflow: TextOverflow.visible,
                  textAlign: TextAlign.left,
                  softWrap: true,
                  text: TextSpan(children: <TextSpan>[
                    TextSpan(
                        text: "${error.msg}",
                        style: GoogleFonts.robotoMono(
                            color: ResultsColors.failure)),
                    // TextSpan(text: ""),
                  ]))
            ]))
      ]);
    });
    DeployTextSummary summary =
        DeployTextSummary(title: title, name: name, results: results);
    List<Widget> columnChildren = [summary];
    if (errorsWidgets.length > 0) SizedBox(height: 10);
    if (errorsWidgets.length > 0) columnChildren.addAll(errorsWidgets);
    return Padding(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: columnChildren,
        ));
  }
}

class DeployTextSummary extends StatelessWidget {
  const DeployTextSummary({
    Key? key,
    required this.title,
    required this.name,
    required this.results,
  }) : super(key: key);

  final String title;
  final String name;
  final dynamic results;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(title == "" ? "$name: " : "$title in $name: ", style: TextStyle()),
      if (results['changed'] > 0)
        Text("changed (${results['changed']})",
            style: TextStyle(color: ResultsColors.changed)),
      if (results['changed'] > 0) Text(", "),
      if (results['failures'] > 0)
        Text("failures (${results['failures']})",
            style: TextStyle(color: ResultsColors.failure)),
      if (results['failures'] > 0) Text(", "),
      Text("ok (${results['ok']})", style: TextStyle(color: ResultsColors.ok)),
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
            style: TextStyle(color: ResultsColors.skipped))
    ]);
  }
}
