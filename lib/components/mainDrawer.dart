import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:la_toolkit/components/termDialog.dart';
import 'package:la_toolkit/laTheme.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:mdi/mdi.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../routes.dart';
import 'laIcon.dart';
import 'listTileLink.dart';

class MainDrawer extends StatefulWidget {
  final String appName;
  final String currentRoute;
  final PackageInfo packageInfo;

  MainDrawer(
      {required this.appName,
      required this.currentRoute,
      required this.packageInfo});
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
            children: <Widget>[
          GestureDetector(
            onTap: () {
              context.beamBack();
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
          ListTile(
            leading: const Icon(Mdi.key),
            title: Text('SSH Keys'),
            onTap: () {
              Beamer.of(context).beamTo(SshKeysLocation());
            },
          ),
          TermDialog.drawerItem(context),
          if (AppUtils.isDev())
            ListTile(
              leading: const Icon(Icons.build),
              title: Text('Sandbox'),
              onTap: () {
                Beamer.of(context).beamTo(SandboxLocation());
              },
            ),
          Column(children: ListTileLink.drawerBottomLinks(context, false)),
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
        ]));
  }
}
