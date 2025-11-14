import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:redux/redux.dart';

import '../la_theme.dart';
import '../models/appState.dart';
import '../models/laServiceDesc.dart';
import '../models/la_project.dart';
import '../models/prodServiceDesc.dart';
import '../routes.dart';
import '../utils/utils.dart';
import 'admin_icon_button.dart';
import 'help_icon.dart';
import 'la_icon.dart';
import 'list_tile_link.dart';
import 'term_dialog.dart';

class ProjectDrawer extends StatelessWidget {
  const ProjectDrawer({super.key});

  static Widget appBarIcon(LAProject project, GlobalKey<ScaffoldState> key) {
    return IconButton(
      color: Colors.white,
      icon: Icon(MdiIcons.vectorLink),
      tooltip: '${project.shortName} links drawer',
      onPressed: () => key.currentState?.openDrawer(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ProjectDrawerViewModel>(
        converter: (Store<AppState> store) {
      return _ProjectDrawerViewModel(
        state: store.state,
      );
    }, builder: (BuildContext context, _ProjectDrawerViewModel vm) {
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
                    if (vm.state.currentProject
                                .getVariableValue('favicon_url') !=
                            null &&
                        !AppUtils.isDemo())
                      ImageIcon(
                          NetworkImage(AppUtils.proxyImg(vm.state.currentProject
                              .getVariableValue('favicon_url')! as String)),
                          color: LAColorTheme.laPalette,
                          size: 80)
                    else
                      Image.asset(
                        'assets/images/la-icon.png',
                        fit: BoxFit.scaleDown,
                        height: 80.0,
                      ),
                    const SizedBox(height: 10.0),
                    // FIXME
                    Text(vm.state.currentProject.shortName,
                        style: const TextStyle(
                          fontSize: 24.0,
                          color: Colors.white,
                        )),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(LAIcon.la),
              title: const Text('Home'),
              onTap: () {
                context.beamBack();
              },
            ),
            ListTile(
              leading: Icon(MdiIcons.key),
              title: const Text('SSH Keys'),
              onTap: () {
                BeamerCond.of(context, SshKeysLocation());
              },
            ),
            TermDialog.drawerItem(context),
            Column(children: _createProjectLinks(vm.state.currentProject)),
            if (AppUtils.isDev())
              ListTile(
                leading: const Icon(Icons.build),
                title: const Text('Sandbox'),
                onTap: () {
                  BeamerCond.of(context, SandboxLocation());
                },
              ),
            Column(children: ListTileLink.drawerBottomLinks(context, false))
          ]));
    });
  }

  List<Widget> _createProjectLinks(LAProject currentProject) {
    return <Widget>[
      for (final ProdServiceDesc serviceDesc in currentProject.prodServices)
        if (!LAServiceDesc.internalServices.contains(serviceDesc.nameInt))
          ServiceListTileLink(desc: serviceDesc)
    ];
  }
}

class ServiceListTileLink extends StatelessWidget {
  ServiceListTileLink({super.key, required ProdServiceDesc desc})
      : icon = desc.icon,
        name = desc.name,
        tooltip = desc.tooltip,
        url = desc.url,
        admin = desc.admin,
        alaAdmin = desc.alaAdmin,
        help = desc.help;
  final IconData icon;
  final String name;
  final String tooltip;
  final String url;
  final bool admin;
  final bool alaAdmin;
  final String? help;

  @override
  Widget build(BuildContext context) {
    return ListTileLink(
      icon: Icon(icon),
      title: name,
      tooltip: tooltip,
      url: url,
      additionalTrailingIcon:
          alaAdmin ? AdminIconButton(url: url, alaAdmin: true) : null,
      trailingIcon: help != null
          ? HelpIcon(
              wikipage: help!,
            )
          : admin
              ? AdminIconButton(
                  url: url,
                  // alaAdmin: false
                )
              : null,
    );
  }
}

class _ProjectDrawerViewModel {
  _ProjectDrawerViewModel({required this.state});

  final AppState state;
}
