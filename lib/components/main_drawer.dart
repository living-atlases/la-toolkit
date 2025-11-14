import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../la_theme.dart';
import '../routes.dart';
import '../utils/utils.dart';
import 'la_icon.dart';
import 'list_tile_link.dart';
import 'term_dialog.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({super.key, required this.appName, required this.currentRoute, required this.packageInfo});
  final String appName;
  final String currentRoute;
  final PackageInfo packageInfo;

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
              decoration: BoxDecoration(
                color: LAColorTheme.laPalette.shade300,
              ),
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
            ),
          ),
          ListTile(
            leading: Icon(MdiIcons.key),
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
              applicationVersion: 'Version: ${widget.packageInfo.version}',
              applicationIcon: const Icon(LAIcon.la),
              applicationLegalese: '© 2020-${DateTime.now().year} Living Atlases, under Apache 2.0',
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
