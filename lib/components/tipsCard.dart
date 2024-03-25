import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/cardConstants.dart';

class TipsCard extends StatelessWidget {
  const TipsCard(
      {super.key,
      required this.text,
      this.margin = const EdgeInsets.fromLTRB(0, 30, 0, 0)});
  final String text;
  final EdgeInsets? margin;
  static const Color _markdownColor = Colors.black54;
  static const TextStyle _markdownStyle = TextStyle(color: _markdownColor);

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: CardConstants.defaultElevation,
        shape: CardConstants.defaultShape,
        margin: margin,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 0, 20),
                  child: Icon(Icons.info, color: Colors.grey)),
              Expanded(
                  child: Markdown(
                      shrinkWrap: true,
                      styleSheet: MarkdownStyleSheet(
                        h2: _markdownStyle,
                        p: _markdownStyle,
                        a: const TextStyle(
                            color: _markdownColor,
                            decoration: TextDecoration.underline),
                      ),
                      onTapLink: (String text, String? href, String title) async {
                        if (href != null) await launchUrl(Uri.parse(href));
                      },
                      data: text))
            ]));
  }
}
