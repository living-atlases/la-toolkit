import 'package:flutter/material.dart';

class NotInTheDemoPanel extends StatelessWidget {
  const NotInTheDemoPanel({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "This does not work in the demo",
        textAlign: TextAlign.center,
      ),
    );
  }
}
