import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:la_toolkit/components/laAppBar.dart';

class SandboxPage extends StatelessWidget {
  static const routeName = "sandbox";
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        // backgroundColor: Colors.white,
        appBar: LAAppBar(title: 'Sandbox'),
        body: Column(children: [
          Container(
              child: Column(
            children: [
              IconButton(icon: Icon(Icons.swap_horiz))
              /* NeumorphicCheckbox(
                // margin: EdgeInsets.only(top: 12),
                padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                margin: EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
                onChanged: (value) {},

                value: true,
              ),
              NeumorphicCheckbox(
                // margin: EdgeInsets.only(top: 12),
                padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                margin: EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
                onChanged: (value) {},
                value: false,
              )*/
            ],
          ))
        ]));
  }

  Color _textColor(BuildContext context) {
    //if (NeumorphicTheme.isUsingDark(context)) {
    return Colors.black;
    ////return Colors.black;
    //}
  }
}
