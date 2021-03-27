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
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:la_toolkit/utils/StringUtils.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:mdi/mdi.dart';
import 'package:url_launcher/url_launcher.dart';

import '../routes.dart';

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
                Beamer.of(context).beamTo(SshKeysLocation());
              },
            ),
            TermDialog.drawerItem(context),
            Column(children: _createProjectLinks(vm.state.currentProject)),
            if (AppUtils.isDev())
              ListTile(
                leading: const Icon(Icons.build),
                title: Text('Sandbox'),
                onTap: () {
                  Beamer.of(context).beamTo(SandboxLocation());
                },
              ),
            Column(children: ListTileLink.drawerBottomLinks(context, false))
          ]));
    });
  }

  List<Widget> _createProjectLinks(LAProject currentProject) {
    return currentProject
        .getServicesNameListInUse()
        .where((nameInt) =>
            !LAServiceDesc.get(nameInt).withoutUrl &&
            nameInt != LAServiceName.branding.toS())
        .map((nameInt) {
      LAServiceDesc desc = LAServiceDesc.get(nameInt);
      String url = currentProject
          .getService(nameInt)
          .fullUrl(currentProject.useSSL, currentProject.domain);

      String name = StringUtils.capitalize(desc.name);
      List<Widget> allServices = List<Widget>.empty(growable: true);
      String? help = nameInt == LAServiceName.solr.toS()
          ? "Secure-your-LA-infrastructure#protect-you-solr-admin-interface"
          : null;
      ListTileLink mainServices = _createServiceTileLink(
          name: name,
          icon: desc.icon,
          url: url,
          admin: desc.admin,
          alaAdmin: desc.alaAdmin,
          help: help);
      // This is for userdetails, apikeys, etc
      if (nameInt != LAServiceName.cas.toS()) allServices.add(mainServices);
      // print('service: $nameInt, url: $url, help: $help');
      desc.subServices.forEach((sub) => allServices.add(_createServiceTileLink(
            name: sub.name,
            icon: sub.icon,
            url: url + sub.path,
            admin: sub.admin,
            alaAdmin: sub.alaAdmin,
          )));
      return Column(children: allServices);
    }).toList();
  }

  ListTileLink _createServiceTileLink(
      {icon, name, url, admin, alaAdmin, String? help}) {
    return ListTileLink(
      icon: Icon(icon),
      title: name,
      tooltip: name != "Index"
          ? "Open the $name service"
          : "This is protected by default, see our wiki for more info",
      url: url,
      additionalTrailingIcon: alaAdmin
          ? new IconButton(
              icon: Icon(Icons.admin_panel_settings_outlined),
              tooltip: "alaAdmin section",
              onPressed: () async => await launch(url + '/alaAdmin'))
          : null,
      trailingIcon: help != null
          ? HelpIcon(
              wikipage: help,
            )
          : admin
              ? IconButton(
                  icon: Icon(Icons.admin_panel_settings_rounded),
                  tooltip: "Admin section",
                  onPressed: () async => await launch(url + '/admin'))
              : null,
    );
  }
}

class _ProjectDrawerViewModel {
  final AppState state;

  _ProjectDrawerViewModel({required this.state});
}
