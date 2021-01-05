import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:la_toolkit/main.dart';

import 'laIcon.dart';

class LAAppBar extends AppBar {
  final List<Widget> defActions = [];

  LAAppBar({String title, bool showLaIcon: false, List<Widget> actions})
      : super(
            leading: new IconButton(
                icon: Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  scaffoldKey.currentState.openDrawer();
                }),
            actions: actions ?? List<Widget>.empty(growable: true),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                showLaIcon
                    ? Icon(LAIcon.la, size: 32, color: Colors.white)
                    : null,
                Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(title,
                        style: GoogleFonts.signika(
                            textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w400))))
              ],
            )) {
    super.actions.addAll(defActions);
  }
}
