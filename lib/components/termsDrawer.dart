import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/helpIcon.dart';
import 'package:la_toolkit/components/listTileLink.dart';
import 'package:la_toolkit/components/termDialog.dart';
import 'package:la_toolkit/laTheme.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/laServer.dart';
import 'package:la_toolkit/models/prodServiceDesc.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:mdi/mdi.dart';

import 'adminIconButton.dart';

class TermsDrawer extends StatelessWidget {
  const TermsDrawer({Key? key}) : super(key: key);

  static Widget appBarIcon(LAProject project, GlobalKey<ScaffoldState> key) {
    return IconButton(
      color: Colors.white,
      icon: const Icon(Mdi.console),
      tooltip: "${project.shortName} terminals",
      onPressed: () => key.currentState?.openEndDrawer(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _TermsDrawerViewModel>(converter: (store) {
      return _TermsDrawerViewModel(
        state: store.state,
        openTerm: (project, server) =>
            TermDialog.openTerm(context, project.id, server.name),
      );
    }, builder: (BuildContext context, _TermsDrawerViewModel vm) {
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
                    Text("${vm.state.currentProject.shortName} Terminals",
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
            for (LAServer server in vm.state.currentProject.servers)
              Tooltip(
                  message: "Open a terminal in ${server.name}",
                  child: ListTile(
                      leading: const Icon(Mdi.console),
                      title: Text(server.name),
                      onTap: () =>
                          vm.openTerm(vm.state.currentProject, server))),
            TermDialog.drawerItem(context),
          ]));
    });
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

  ServiceListTileLink({Key? key, required ProdServiceDesc desc})
      : icon = desc.icon,
        name = desc.name,
        tooltip = desc.tooltip,
        url = desc.url,
        admin = desc.admin,
        alaAdmin = desc.alaAdmin,
        help = desc.help,
        super(key: key);

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

class _TermsDrawerViewModel {
  final AppState state;
  final void Function(LAProject, LAServer) openTerm;

  _TermsDrawerViewModel({required this.state, required this.openTerm});
}
