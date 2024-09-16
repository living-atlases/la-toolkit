import 'package:flutter/cupertino.dart';

class EmbedWebView extends StatelessWidget {
  const EmbedWebView(
      {super.key,
      required this.src,
      this.height,
      this.width,
      required this.notify});

  final String src;
  final double? height, width;
  final bool notify;

  @override
  Widget build(BuildContext context) {
    return const Text('Not implemented');
  }
}
