import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:la_toolkit/utils/cardConstants.dart';
import 'package:url_launcher/url_launcher.dart';

class TipsCard extends StatelessWidget {
  final String text;
  final EdgeInsets? margin;
  const TipsCard(
      {Key? key,
      required this.text,
      this.margin = const EdgeInsets.fromLTRB(0, 30, 0, 0)})
      : super(key: key);
  static const _markdownColor = Colors.black54;
  static const _markdownStyle = TextStyle(color: _markdownColor);

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: CardConstants.defaultElevation,
        shape: CardConstants.defaultShape,
        margin: margin,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      onTapLink: (text, href, title) async {
                        if (href != null) await launchUrl(Uri.parse(href));
                      },
                      data: text))
            ]));
  }
}
