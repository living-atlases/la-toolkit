import 'package:flutter/material.dart';

class ScrollPanel extends StatelessWidget {
  final Widget child;
  final bool withPadding;
  final double padding;

  const ScrollPanel(
      {Key? key,
      required this.child,
      this.withPadding = false,
      this.padding = 80})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        child: Scrollbar(
            child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: withPadding
                    ? Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: padding, vertical: 20),
                        child: child)
                    : child)));
  }
}
