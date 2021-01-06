import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:la_toolkit/laTheme.dart';
import 'package:la_toolkit/sandboxPage.dart';
import 'package:la_toolkit/utils/utils.dart';

import 'components/laIcon.dart';

class MainDrawer extends Drawer {
  final String appName;
  MainDrawer(BuildContext context, String currentRoute, this.appName, {key})
      : super(key: key, child: mainDrawer(context, currentRoute, appName));
}

Widget mainDrawer(BuildContext context, String currentRoute, String appName) {
  return ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: ListUtils.listWithoutNulls(<Widget>[
        GestureDetector(
          onTap: () {
            Navigator.popAndPushNamed(context, '/');
          },
          child: DrawerHeader(
            child: Column(
              children: <Widget>[
                Image.asset(
                  'assets/images/la-icon.png',
                  fit: BoxFit.scaleDown,
                  height: 80.0,
                ),
                const SizedBox(height: 20.0),
                Text(appName,
                    style: TextStyle(
                      fontSize: 24.0,
                      color: Colors.white,
                    )),
              ],
            ),
            decoration: BoxDecoration(
              color: LAColorTheme.laPalette.shade300,
            ),
          ),
        ),
        Divider(),
        /*  ListTile(
                leading: const Icon(Icons.favorite),
                selected: currentRoute == SupportPage.routeName,
                title: Text(S.of(context).supportThisInitiative),
                onTap: () {
                  Navigator.popAndPushNamed(context, SupportPage.routeName);
                },
              ), */

        // globals.isDevelopment
        true
            ? ListTile(
                leading: const Icon(Icons.bug_report),
                title: Text('Sandbox'),
                selected: currentRoute == SandboxPage.routeName,
                onTap: () {
                  Navigator.popAndPushNamed(context, SandboxPage.routeName);
                },
              )
            : null,
        ListTile(
          leading: const Icon(Icons.feedback),
          title: Text('Feedback (WIP)'),
          // selected: currentRoute == SandboxPage.routeName,
          onTap: () {
            BetterFeedback.of(context).show();
          },
        ),
        AboutListTile(
            icon: Icon(LAIcon.la),
            // Icon(LAIcon.la, size: 32, color: Colors.white)
            applicationName: appName,
            /*
                  applicationVersion: globals.appVersion,*/
            applicationIcon: Icon(LAIcon.la),
            /* applicationLegalese:
                      S.of(context).appLicense(DateTime.now().year.toString()), */
            aboutBoxChildren: <Widget>[
              SizedBox(height: 10.0),
              /* Text(S.of(context).appMoto),
                    // , style: TextStyle(fontStyle: FontStyle.italic)),
                    SizedBox(height: 10.0),
                    Text(S.of(context).NASAAck, style: bottomTextStyle), */
              // More ?
            ])
      ]));
}
