import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:redux/redux.dart';

import '../la_theme.dart';
import '../models/app_state.dart';
import '../models/la_project.dart';
import '../models/la_server.dart';
import '../models/prod_service_desc.dart';
import '../utils/utils.dart';
import 'admin_icon_button.dart';
import 'help_icon.dart';
import 'list_tile_link.dart';
import 'term_dialog.dart';

class TermsDrawer extends StatelessWidget {
  const TermsDrawer({super.key});

  static Widget appBarIcon(LAProject project, GlobalKey<ScaffoldState> key) {
    return IconButton(
      color: Colors.white,
      icon: Icon(MdiIcons.console),
      tooltip: '${project.shortName} terminals',
      onPressed: () => key.currentState?.openEndDrawer(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _TermsDrawerViewModel>(
      converter: (Store<AppState> store) {
        return _TermsDrawerViewModel(
          state: store.state,
          openTerm: (LAProject project, LAServer server) =>
              TermDialog.openTerm(context, false, project.id, server.name),
        );
      },
      builder: (BuildContext context, _TermsDrawerViewModel vm) {
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
                      if (vm.state.currentProject.getVariableValue(
                                'favicon_url',
                              ) !=
                              null &&
                          !AppUtils.isDemo())
                        ImageIcon(
                          NetworkImage(
                            AppUtils.proxyImg(
                              vm.state.currentProject.getVariableValue(
                                    'favicon_url',
                                  )!
                                  as String,
                            ),
                          ),
                          color: LAColorTheme.laPalette,
                          size: 80,
                        )
                      else
                        Image.asset(
                          'assets/images/la-icon.png',
                          fit: BoxFit.scaleDown,
                          height: 80.0,
                        ),
                      const SizedBox(height: 10.0),
                      Text(
                        '${vm.state.currentProject.shortName} Terminals',
                        style: const TextStyle(
                          fontSize: 24.0,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // The docker console
              TermDialog.drawerItem(context),
              for (final LAServer server in vm.state.currentProject.servers)
                Tooltip(
                  message: 'Open a terminal in ${server.name}',
                  child: ListTile(
                    leading: Icon(MdiIcons.console),
                    title: Text(server.name),
                    onTap: () => vm.openTerm(vm.state.currentProject, server),
                  ),
                ),
            ],
          ),
        );
      },
    );
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
      additionalTrailingIcon: alaAdmin
          ? AdminIconButton(url: url, alaAdmin: true)
          : null,
      trailingIcon: help != null
          ? HelpIcon(wikipage: help!)
          : admin
          ? AdminIconButton(
              url: url,
              // alaAdmin: false
            )
          : null,
    );
  }
}

class _TermsDrawerViewModel {
  _TermsDrawerViewModel({required this.state, required this.openTerm});

  final AppState state;
  final void Function(LAProject, LAServer) openTerm;
}
