import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:la_toolkit/utils/utils.dart';

import '../routes.dart';
import 'laIcon.dart';

class LAAppBar extends AppBar {
  LAAppBar(
      {required BuildContext context,
      required String title,
      String? projectIcon,
      bool showLaIcon: false,
      NamedBeamLocation? backLocation,
      bool showBack: false,
      List<Widget>? actions,
      Widget? leading,
      IconData? titleIcon,
      PreferredSize? bottom})
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
            toolbarHeight: kToolbarHeight * 1.2,
            actions: actions ?? List<Widget>.empty(growable: true),
            leading: leading,
            bottom: bottom,
            title: SizedBox(
              height: kToolbarHeight * 1.2,
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                if (showBack)
                  IconButton(
                      tooltip: "Back",
                      icon:
                          Icon(Icons.arrow_back, size: 28, color: Colors.black),
                      onPressed: () {
                        if (backLocation != null) {
                          BeamerCond.of(context, backLocation);
                        } else {
                          try {
                            context.beamBack();
                          } catch (e) {
                            BeamerCond.of(context, HomeLocation());
                          }
                        }
                      }),
                if (showLaIcon)
                  IconButton(
                      tooltip: "Homepage",
                      icon: Icon(LAIcon.la, size: 34, color: Colors.white),
                      onPressed: () {
                        BeamerCond.of(context, HomeLocation());
                      }),
                Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(children: [
                      if (projectIcon != null && !AppUtils.isDemo())
                        SizedBox(width: 8),
                      if (projectIcon != null && !AppUtils.isDemo())
                        ImageIcon(NetworkImage(AppUtils.proxyImg(projectIcon)),
                            color: Colors.white, size: 26),
                      if (projectIcon != null && !AppUtils.isDemo())
                        SizedBox(width: 8),
                      if (titleIcon != null)
                        Icon(titleIcon, size: 26, color: Colors.white),
                      if (titleIcon != null) SizedBox(width: 8),
                      Text(title,
                          style: GoogleFonts.signika(
                              textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w400)))
                    ]))
              ]),
            ));
}
