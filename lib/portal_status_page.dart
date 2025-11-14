import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:redux/redux.dart';
import 'package:tuple/tuple.dart';

import './models/app_state.dart';
import 'components/app_snack_bar.dart';
import 'components/check_result_card.dart';
import 'components/la_app_bar.dart';
import 'components/scroll_panel.dart';
import 'components/servers_status_panel.dart';
import 'components/service_check_progress_indicator.dart';
import 'components/services_status_panel.dart';
import 'components/text_title.dart';
import 'la_theme.dart';
import 'models/host_services_checks.dart';
import 'models/la_project.dart';
import 'models/la_server.dart';
import 'models/la_service.dart';
import 'models/prod_service_desc.dart';
import 'redux/app_actions.dart';

class PortalStatusPage extends StatefulWidget {
  const PortalStatusPage({super.key});

  static const String routeName = 'status';

  @override
  State<PortalStatusPage> createState() => _PortalStatusPageState();
}

class _PortalStatusPageState extends State<PortalStatusPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _PortalStatusViewModel>(
      distinct: true,
      converter: (Store<AppState> store) {
        return _PortalStatusViewModel(
            project: store.state.currentProject,
            checkResults: store.state.currentProject.checkResults,
            serverServicesToMonitor:
                store.state.currentProject.serverServicesToMonitor(),
            loading: store.state.loading,
            serviceCheckProgress: store.state.serviceCheckProgress,
            checkServices: (HostsServicesChecks hostsServicesChecks) {
              store.dispatch(TestServicesProject(
                  store.state.currentProject,
                  hostsServicesChecks,
                  () => store.dispatch(TestConnectivityProject(
                      store.state.currentProject, () {}, () {})),
                  () {}));
            });
      },
      builder: (BuildContext context, _PortalStatusViewModel vm) {
        final List<Widget> resultWidgets = <Widget>[];
        for (final String serverId in vm.checkResults.keys) {
          // Skip special keys like _monitoring_{serverId}
          if (serverId.startsWith('_')) {
            continue;
          }

          final LAServer s =
              vm.project.servers.firstWhere((LAServer s) => s.id == serverId);
          resultWidgets.add(TextTitle(text: s.name));
          vm.checkResults[serverId]!.forEach((dynamic check) {
            final ServiceStatus st = int.parse(check['code'] as String) == 0
                ? ServiceStatus.success
                : ServiceStatus.failed;
            final String args = check['service'] as String == 'check_url'
                ? utf8.decode(base64.decode(check['args'] as String))
                : check['args'] as String;
            resultWidgets.add(CheckResultCard(
                title: "${check['service']} $args",
                status: st,
                subtitle: utf8.decode(base64.decode(check['msg'] as String))));
          });
        }
        final String pageTitle = '${vm.project.shortName} Portal Status';
        return Title(
            title: pageTitle,
            color: LAColorTheme.laPalette,
            child: Scaffold(
                key: _scaffoldKey,
                appBar: LAAppBar(
                    context: context,
                    titleIcon: Icons.fact_check,
                    title: pageTitle,
                    showBack: true,
                    loading: vm.loading,
                    actions: <Widget>[
                      IconButton(
                        icon: const Tooltip(
                            message: 'Pause to check services',
                            child: Icon(Icons.pause, color: Colors.white)),
                        onPressed: () {
                          //
                        },
                      ),
                      Container(
                          margin: const EdgeInsets.only(right: 10.0),
                          child: IconButton(
                            icon: Tooltip(
                                message: 'Recheck the status of the portal',
                                child:
                                    Icon(MdiIcons.reload, color: Colors.white)),
                            onPressed: () {
                              vm.checkServices(
                                  vm.serverServicesToMonitor.item2);
                            },
                          ))
                    ]),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
                // TODO: use here badges
                // https://github.com/hacktons/convex_bottom_bar/
                // {0: '99+', 1: Icons.assistant_photo, 2: Colors.redAccent},
                bottomNavigationBar: ConvexAppBar(
                  backgroundColor: LAColorTheme.laPalette.shade300,
                  color: Colors.black,
                  activeColor: Colors.black,
                  style: TabStyle.react,
                  items: <TabItem<dynamic>>[
                    TabItem(icon: MdiIcons.server, title: 'Servers'),
                    const TabItem<dynamic>(
                        icon: Icons.fact_check, title: 'Services'),
                    const TabItem<dynamic>(
                        icon: Icons.receipt_long, title: 'Details'),
                  ],
                  initialActiveIndex: 0,
                  //optional, default as 0
                  onTap: (int i) => setState(() => _tab = i),
                ),
                body: AppSnackBar(
                  ScrollPanel(
                      withPadding: true,
                      padding: 40,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 0, // 10%
                            child: Container(),
                          ),
                          Expanded(
                              flex: 10, // 80%,
                              child: Column(children: <Widget>[
                                // Show progress indicators if checks are running
                                if (vm.loading &&
                                    vm.serviceCheckProgress.isNotEmpty)
                                  Column(
                                    children: <Widget>[
                                      const TextTitle(
                                          text: 'Checking Services...'),
                                      const SizedBox(height: 16),
                                      for (final MapEntry<String,
                                              Map<String, dynamic>> entry
                                          in vm.serviceCheckProgress.entries)
                                        ServiceCheckProgressIndicator(
                                          serverName: entry.value['serverName']
                                              as String,
                                          status:
                                              entry.value['status'] as String,
                                          resultsCount: entry
                                              .value['resultsCount'] as int,
                                        ),
                                      const SizedBox(height: 24),
                                      const Divider(),
                                    ],
                                  ),
                                // Add
                                // https://pub.dev/packages/circular_countdown_timer
                                // or similar and a sliderdesc
                                if (_tab == 0) const TextTitle(text: 'Servers'),
                                if (_tab == 0)
                                  ServersStatusPanel(
                                      extendedStatus: true,
                                      results: vm.checkResults),
                                if (_tab == 1)
                                  const TextTitle(text: 'Services'),
                                if (_tab == 1)
                                  ServicesStatusPanel(
                                      services:
                                          vm.serverServicesToMonitor.item1),
                                if (_tab == 2) const TextTitle(text: 'Details'),
                                if (_tab == 2)
                                  for (final Widget w in resultWidgets) w
                              ])),
                          Expanded(
                            flex: 0, // 10%
                            child: Container(),
                          )
                        ],
                      )),
                  /* floatingActionButton: ReCheckBtns(
              () => vm.checkServices(vm.serverServicesToMonitor.item2)), */
                  /* floatingActionButton:  CountDownWidget(
              onReload: () =>
                  vm.checkServices(vm.serverServicesToMonitor.item2)), */
                )));
      },
    );
  }
}

class _PortalStatusViewModel {
  _PortalStatusViewModel(
      {required this.project,
      required this.checkResults,
      required this.loading,
      required this.checkServices,
      required this.serviceCheckProgress,
      required this.serverServicesToMonitor});

  final LAProject project;
  final Map<String, dynamic> checkResults;
  final Tuple2<List<ProdServiceDesc>, HostsServicesChecks>
      serverServicesToMonitor;
  final void Function(HostsServicesChecks) checkServices;
  final bool loading;
  final Map<String, Map<String, dynamic>> serviceCheckProgress;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _PortalStatusViewModel &&
          runtimeType == other.runtimeType &&
          loading == other.loading &&
          const DeepCollectionEquality.unordered()
              .equals(serviceCheckProgress, other.serviceCheckProgress) &&
          const DeepCollectionEquality.unordered()
              .equals(checkResults, other.checkResults) &&
          serverServicesToMonitor == other.serverServicesToMonitor &&
          project == other.project;

  @override
  int get hashCode =>
      project.hashCode ^
      loading.hashCode ^
      serverServicesToMonitor.hashCode ^
      const DeepCollectionEquality.unordered().hash(checkResults) ^
      const DeepCollectionEquality.unordered().hash(serviceCheckProgress);
}
