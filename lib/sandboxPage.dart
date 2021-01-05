import 'package:flutter/material.dart';

import 'components/laProjectTimeline.dart';

class SandboxPage extends StatelessWidget {
  static const routeName = "sandbox";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        // appBar: LAAppBar(title: 'Sandbox'),
        body: LAProjectTimeline());
  }
}
