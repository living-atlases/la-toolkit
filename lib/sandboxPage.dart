import 'package:flutter/material.dart';

import 'components/laAppBar.dart';

class SandboxPage extends StatelessWidget {
  static const routeName = "sandbox";
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        // backgroundColor: Colors.white,
        appBar: LAAppBar(title: 'Sandbox'),
        body: Column(children: [Container()]));
  }
}
