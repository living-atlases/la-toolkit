import 'package:flutter/material.dart';
import 'package:la_toolkit/laTheme.dart';
import 'package:la_toolkit/sandboxPage.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:mdi/mdi.dart';
import 'package:package_info_plus/package_info_plus.dart';
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

              createLinkItem(
                  icon: Icon(Icons.bug_report),
                  title: 'Report an issue',
                  url: "https://github.com/living-atlases/la-toolkit/issues"),

              // TODO:
              // - Verify environment
              // - ssh-keys
              // - check for updates
              AppUtils.isDev()
                  ? ListTile(
                      leading: const Icon(Icons.build),
                      title: Text('Sandbox'),
                      selected: currentRoute == SandboxPage.routeName,
                      onTap: () {
                        Navigator.popAndPushNamed(
                            context, SandboxPage.routeName);
                      },
                    )
                  : null,
              /*
              Screenshots does not work yet:
              https://github.com/ueman/feedback/issues/13
              ListTile(
                leading: const Icon(Icons.feedback),
                title: Text('Feedback (WIP)'),
                // selected: currentRoute == SandboxPage.routeName,
                onTap: () {
                  BetterFeedback.of(context).show();
                },
              ),*/
              Divider(),
              createLinkItem(
                  icon: Icon(LAIcon.la),
                  title: 'Living Atlases Community',
                  url: "https://living-atlases.gbif.org"),
              createLinkItem(
                  icon: ImageIcon(AssetImage("images/ala-icon.png")),
                  /* NetworkImage(
                          "https://www.ala.org.au/app/uploads/2019/01/cropped-favicon-32x32.png")), */
                  title: 'Atlas of Living Australia',
                  url: "https://ala.org.au"),
              Divider(),
              createLinkItem(
                  icon: Icon(Mdi.github),
                  title: 'This software on github',
                  url: "https://github.com/living-atlases/la-toolkit/"),
              AboutListTile(
                  icon: Icon(LAIcon.la),
                  applicationName: appName,
                  applicationVersion:
                      "Version: ${packageInfo.version} build: ${packageInfo.buildNumber}",
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

  Widget createLinkItem({Widget icon, String title, String url}) {
    return ListTile(
      leading: icon,
      title: Text(title),
      onTap: () async {
        await launch(url);
      },
    );
  }
}
