import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/helpIcon.dart';
import 'package:la_toolkit/components/laIcon.dart';
import 'package:la_toolkit/components/listTileLink.dart';
import 'package:la_toolkit/components/termDialog.dart';
import 'package:la_toolkit/laTheme.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/serviceLinkDesc.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:mdi/mdi.dart';

import '../routes.dart';
import 'adminIconButton.dart';

class ProjectDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ProjectDrawerViewModel>(
        converter: (store) {
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
                child: Column(
                  children: <Widget>[
                    vm.state.currentProject.getVariableValue("favicon_url") !=
                                null &&
                            !AppUtils.isDemo()
                        ? ImageIcon(
                            NetworkImage(AppUtils.proxyImg(vm
                                .state.currentProject
                                .getVariableValue("favicon_url"))),
                            color: LAColorTheme.laPalette,
                            size: 80)
                        : Image.asset(
                            'assets/images/la-icon.png',
                            fit: BoxFit.scaleDown,
                            height: 80.0,
                          ),
                    const SizedBox(height: 10.0),
                    // FIXME
                    Text(vm.state.currentProject.shortName,
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
              leading: const Icon(LAIcon.la),
              title: Text('Home'),
              onTap: () {
                context.beamBack();
              },
            ),
            ListTile(
              leading: const Icon(Mdi.key),
              title: Text('SSH Keys'),
              onTap: () {
                BeamerCond.of(context, SshKeysLocation());
              },
            ),
            TermDialog.drawerItem(context),
            Column(children: _createProjectLinks(vm.state.currentProject)),
            if (AppUtils.isDev())
              ListTile(
                leading: const Icon(Icons.build),
                title: Text('Sandbox'),
                onTap: () {
                  BeamerCond.of(context, SandboxLocation());
                },
              ),
            Column(children: ListTileLink.drawerBottomLinks(context, false))
          ]));
    });
  }

  List<Widget> _createProjectLinks(LAProject currentProject) {
    return [
      for (var serviceDesc in currentProject.linkList)
        ServiceListTileLink(desc: serviceDesc)
    ];
  }
}

class ServiceListTileLink extends StatelessWidget {
  final IconData icon;
  final String name;
  final String tooltip;
  final String url;
  final bool admin;
  final bool alaAdmin;
  final String? help;

  ServiceListTileLink({required ServiceLinkDesc desc})
      : this.icon = desc.icon,
        this.name = desc.name,
        this.tooltip = desc.tooltip,
        this.url = desc.name,
        this.admin = desc.admin,
        this.alaAdmin = desc.alaAdmin,
        this.help = desc.help;

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
              ? AdminIconButton(url: url, alaAdmin: false)
              : null,
    );
  }
}

class _ProjectDrawerViewModel {
  final AppState state;

  _ProjectDrawerViewModel({required this.state});
}
