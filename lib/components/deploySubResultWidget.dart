import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:la_toolkit/models/ansibleError.dart';
import 'package:la_toolkit/utils/resultTypes.dart';

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
              SelectableText.rich(
                //overflow: TextOverflow.visible,
                //softWrap: true,
                TextSpan(children: <TextSpan>[
                  TextSpan(text: "  Task:  "),
                  TextSpan(
                      text: error.taskName, style: GoogleFonts.robotoMono()),
                  TextSpan(text: " failed with message: \n"),
                  TextSpan(
                      text: "${error.msg}",
                      style: GoogleFonts.robotoMono(
                          color: ResultType.failures.color)),
                ]),
                textAlign: TextAlign.left,
                showCursor: true,
                autofocus: true,
                onTap: () => FlutterClipboard.copy(error.msg).then((value) =>
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Error copied to clipboard")))),
              ),

              // TextSpan(text: ""),
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
    List<Widget> resultTexts = ResultType.values
        .where((t) => results[t.toS()] != null && results[t.toS()] != 0)
        .map((type) => Text("${type.toS()} (${results[type.toS()]}) ",
            style: TextStyle(color: type.color)))
        .toList();

    return Row(children: [
      Text(title == "" ? "$name: " : "$title in $name: ", style: TextStyle()),
      for (Widget text in resultTexts) text
    ]);
  }
}
