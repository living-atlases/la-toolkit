import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/laIcon.dart';
import 'package:la_toolkit/components/listTileLink.dart';
import 'package:la_toolkit/laTheme.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:la_toolkit/sandboxPage.dart';
import 'package:la_toolkit/utils/StringUtils.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';

class ProjectDrawer extends StatefulWidget {
  ProjectDrawer();

  @override
  _ProjectDrawerState createState() => _ProjectDrawerState();
}

class _ProjectDrawerViewModel {
  final AppState state;

  _ProjectDrawerViewModel({this.state});
}

class _ProjectDrawerState extends State<ProjectDrawer> {
  _ProjectDrawerState();

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
                    Navigator.popAndPushNamed(context, HomePage.routeName);
                  },
                ),
                Column(children: _createProjectLinks(vm.state.currentProject)),
                AppUtils.isDev()
                    ? ListTile(
                        leading: const Icon(Icons.build),
                        title: Text('Sandbox'),
                        onTap: () {
                          Navigator.popAndPushNamed(
                              context, SandboxPage.routeName);
                        },
                      )
                    : null,
                Column(children: ListTileLink.drawerBottomLinks)
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
              ])));
    });
  }

  List<Widget> _createProjectLinks(LAProject currentProject) {
    return currentProject
        .getServicesNameListInUse()
        .where((nameInt) => !LAServiceDesc.map[nameInt].withoutUrl)
        .map((nameInt) {
      LAServiceDesc desc = LAServiceDesc.map[nameInt];
      String url = currentProject.services[nameInt]
          .fullUrl(currentProject.useSSL, currentProject.domain);
      String name = StringUtils.capitalize(desc.name);
      List<Widget> allServices = List<Widget>.empty(growable: true);
      ListTileLink mainServices = _createServiceTileLink(
          name: name,
          icon: desc.icon,
          url: url,
          admin: desc.admin,
          alaAdmin: desc.alaAdmin);
      // This is for userdetails, apikeys, etc
      if (nameInt != 'cas') allServices.add(mainServices);
      desc.subServices.forEach((sub) => allServices.add(_createServiceTileLink(
          name: sub.name,
          icon: sub.icon,
          url: url,
          admin: sub.admin,
          alaAdmin: sub.alaAdmin)));
      return Column(children: allServices);
    }).toList();
  }

  ListTileLink _createServiceTileLink({icon, name, url, admin, alaAdmin}) {
    return ListTileLink(
      icon: Icon(icon),
      title: name,
      tooltip: "Open the $name service",
      url: url,
      additionalTrailingIcon: alaAdmin
          ? new IconButton(
              icon: Icon(Icons.admin_panel_settings_outlined),
              tooltip: "alaAdmin section",
              onPressed: () async => await launch(url + '/alaAdmin'))
          : null,
      trailingIcon: admin
          ? new IconButton(
              icon: Icon(Icons.admin_panel_settings_rounded),
              tooltip: "Admin section",
              onPressed: () async => await launch(url + '/admin'))
          : null,
    );
  }
}
