import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:la_toolkit/main.dart';
import 'package:la_toolkit/utils/utils.dart';

import 'laIcon.dart';

class LAAppBar extends AppBar {
  final List<Widget> defActions = [];

  LAAppBar(
      {@required BuildContext context,
      @required String title,
      bool showLaIcon: false,
      List<Widget> actions})
      : super(
            /*
            // This breaks the Navigation
            leading: Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  tooltip:
                      MaterialLocalizations.of(context).openAppDrawerTooltip,
                );
              },
            ),*/
            actions: actions ?? List<Widget>.empty(growable: true),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: ListUtils.listWithoutNulls(<Widget>[
                showLaIcon
                    ? IconButton(
                        icon: Icon(LAIcon.la, size: 32, color: Colors.white),
                        onPressed: () {
                          Navigator.of(context).pushNamed(HomePage.routeName);
                        })
                    : null,
                Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(title,
                        style: GoogleFonts.signika(
                            textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w400))))
              ]),
            )) {
    super.actions.addAll(defActions);
  }
}
