import 'dart:async';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/ansible_error.dart';
import '../utils/result_types.dart';

class DeploySubResultWidget extends StatelessWidget {
  const DeploySubResultWidget({
    super.key,
    required this.host,
    required this.title,
    required this.results,
    required this.errors,
  });

  final String host;
  final String title;
  final Map<String, dynamic> results;
  final List<AnsibleError> errors;

  @override
  Widget build(BuildContext context) {
    final List<Widget> errorsWidgets = <Widget>[];
    for (final AnsibleError error in errors) {
      errorsWidgets.addAll(<Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SelectableText.rich(
                //overflow: TextOverflow.visible,
                //softWrap: true,
                TextSpan(
                  children: <TextSpan>[
                    const TextSpan(text: '  Task:  '),
                    TextSpan(
                      text: error.taskName,
                      style: GoogleFonts.robotoMono(),
                    ),
                    const TextSpan(text: ' failed with message: \n'),
                    TextSpan(
                      text: error.msg,
                      style: GoogleFonts.robotoMono(
                        color: ResultType.failures.color,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.left,
                showCursor: true,
                // autofocus: false,
                onTap: () {
                  unawaited(
                    FlutterClipboard.copy(error.msg).then((void value) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Error copied to clipboard'),
                          ),
                        );
                      }
                    }),
                  );
                },
              ),

              // TextSpan(text: ""),
            ],
          ),
        ),
      ]);
    }
    final List<Widget> columnChildren = <Widget>[];
    if (results.isNotEmpty) {
      final DeployTextSummary summary = DeployTextSummary(
        host: host,
        title: title,
        results: results,
      );
      columnChildren.addAll(<Widget>[summary]);
    }
    if (errorsWidgets.isNotEmpty) {
      const SizedBox(height: 10);
    }
    if (errorsWidgets.isNotEmpty) {
      columnChildren.addAll(errorsWidgets);
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      child: Column(
        //mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: columnChildren,
      ),
    );
  }
}

class DeployTextSummary extends StatelessWidget {
  const DeployTextSummary({
    super.key,
    required this.host,
    required this.title,
    required this.results,
    this.defFontSize = 16,
  });

  final String host;
  final String title;
  final Map<String, dynamic> results;
  final double defFontSize;

  @override
  Widget build(BuildContext context) {
    final List<TextSpan> resultTexts = ResultType.values
        .where(
          (ResultType t) => results[t.toS()] != null && results[t.toS()] != 0,
        )
        .map(
          (ResultType type) => TextSpan(
            text: '${type.toS()} (${results[type.toS()]}) ',
            style: TextStyle(fontSize: defFontSize, color: type.color),
          ),
        )
        .toList();

    return RichText(
      overflow: TextOverflow.visible,
      textAlign: TextAlign.left,
      // softWrap: true,
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: host,
            style: TextStyle(
              fontSize: defFontSize /* decoration: TextDecoration.underline */,
            ),
          ),
          TextSpan(
            text: ' ($title): ',
            style: TextStyle(fontSize: defFontSize),
          ),
          for (final TextSpan text in resultTexts) text,
        ],
      ),
    );
  }
}
