import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:la_toolkit/laTheme.dart';
import 'package:la_toolkit/sandboxPage.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

import 'laIcon.dart';

class MainDrawer extends StatefulWidget {
  final String appName;
  final String currentRoute;
  final PackageInfo packageInfo;

  MainDrawer({this.appName, this.currentRoute, this.packageInfo});
  /*  : super(
            key: key,
            child: mainDrawer(context, currentRoute, appName, packageInfo)); */

  @override
  _MainDrawerState createState() =>
      _MainDrawerState(appName, currentRoute, packageInfo);
}

class _MainDrawerState extends State<MainDrawer> {
  final String appName;
  final String currentRoute;
  final PackageInfo packageInfo;

  _MainDrawerState(this.appName, this.currentRoute, this.packageInfo);

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
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
              ListTile(
                leading: const Icon(Icons.bug_report),
                title: Text('Report an issue'),
                selected: currentRoute == SandboxPage.routeName,
                onTap: () async {
                  await launch(
                      "https://github.com/living-atlases/la-toolkit/issues");
                },
              ),
              AppUtils.isDev()
                  ? ListTile(
                      leading: const Icon(Icons.build),
                      title: Text('Sandbox'),
                      selected: currentRoute == SandboxPage.routeName,
                      onTap: () {
                        Navigator.pushNamed(context, SandboxPage.routeName);
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
                  applicationName: appName,
                  applicationVersion: packageInfo.buildNumber,
                  applicationIcon: Icon(LAIcon.la),
                  applicationLegalese:
                      "© 2020-${DateTime.now().year.toString()} Living Atlases, under Apache 2.0",
                  aboutBoxChildren: <Widget>[
                    SizedBox(height: 10.0),
                    /* Text(S.of(context).appMoto),
                    // , style: TextStyle(fontStyle: FontStyle.italic)),
                    SizedBox(height: 10.0),
                    Text(S.of(context).NASAAck, style: bottomTextStyle), */
                    // More ?
                  ])
            ])));
  }
}
