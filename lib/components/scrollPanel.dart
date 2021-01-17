import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ScrollPanel extends StatelessWidget {
  final Widget child;

  final bool withPadding;

  ScrollPanel({this.child, this.withPadding = false});
  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: new BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9),
        child: new Scrollbar(
            child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: withPadding
                    ? Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                        child: child)
                    : child)));
  }
}
