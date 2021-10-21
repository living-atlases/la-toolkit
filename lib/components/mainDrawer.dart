import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:la_toolkit/components/termDialog.dart';
import 'package:la_toolkit/laTheme.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../routes.dart';
import 'laIcon.dart';
import 'listTileLink.dart';

class MainDrawer extends StatefulWidget {
  final String appName;
  final String currentRoute;
  final PackageInfo packageInfo;

  const MainDrawer(
      {Key? key,
      required this.appName,
      required this.currentRoute,
      required this.packageInfo})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MainDrawerState();
  }
}

class _MainDrawerState extends State<MainDrawer> {
  _MainDrawerState();

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
                  Text(widget.appName,
                      style: const TextStyle(
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
            leading: const Icon(MdiIcons.key),
            title: const Text('SSH Keys'),
            onTap: () {
              BeamerCond.of(context, SshKeysLocation());
            },
          ),
          TermDialog.drawerItem(context),
          if (AppUtils.isDev())
            ListTile(
              leading: const Icon(Icons.build),
              title: const Text('Sandbox'),
              onTap: () {
                BeamerCond.of(context, SandboxLocation());
              },
            ),
          Column(children: ListTileLink.drawerBottomLinks(context, false)),
          AboutListTile(
              icon: const Icon(LAIcon.la),
              applicationName: widget.appName,
              applicationVersion:
                  "Version: ${widget.packageInfo.version} build: ${widget.packageInfo.buildNumber}",
              applicationIcon: const Icon(LAIcon.la),
              applicationLegalese:
                  "© 2020-${DateTime.now().year.toString()} Living Atlases, under Apache 2.0",
              aboutBoxChildren: const <Widget>[
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
