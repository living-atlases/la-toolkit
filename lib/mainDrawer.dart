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
  return new ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: listWithoutNulls(<Widget>[
        new GestureDetector(
          onTap: () {
            Navigator.popAndPushNamed(context, '/');
          },
          child: new DrawerHeader(
            child: new Column(
              children: <Widget>[
                new Image.asset(
                  'assets/images/la-icon.png',
                  fit: BoxFit.scaleDown,
                  height: 80.0,
                ),
                const SizedBox(height: 20.0),
                new Text(appName,
                    style: new TextStyle(
                      fontSize: 24.0,
                      color: Colors.white,
                    )),
              ],
            ),
            decoration: new BoxDecoration(
              color: LAColorTheme.laPalette.shade300,
            ),
          ),
        ),
        new Divider(),
        /*  new ListTile(
                leading: const Icon(Icons.favorite),
                selected: currentRoute == SupportPage.routeName,
                title: new Text(S.of(context).supportThisInitiative),
                onTap: () {
                  Navigator.popAndPushNamed(context, SupportPage.routeName);
                },
              ), */

        // globals.isDevelopment
        true
            ? new ListTile(
                leading: const Icon(Icons.bug_report),
                title: new Text('Sandbox'),
                selected: currentRoute == SandboxPage.routeName,
                onTap: () {
                  Navigator.popAndPushNamed(context, SandboxPage.routeName);
                },
              )
            : null,
        new AboutListTile(
            icon: Icon(LAIcon.la),
            // Icon(LAIcon.la, size: 32, color: Colors.white)
            applicationName: appName,
            /*
                  applicationVersion: globals.appVersion,*/
            applicationIcon: Icon(LAIcon.la),
            /* applicationLegalese:
                      S.of(context).appLicense(DateTime.now().year.toString()), */
            aboutBoxChildren: <Widget>[
              new SizedBox(height: 10.0),
              /* new Text(S.of(context).appMoto),
                    // , style: new TextStyle(fontStyle: FontStyle.italic)),
                    new SizedBox(height: 10.0),
                    new Text(S.of(context).NASAAck, style: bottomTextStyle), */
              // More ?
            ])
      ]));
}
