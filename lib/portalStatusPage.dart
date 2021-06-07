import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/checkResultCard.dart';
import 'package:la_toolkit/components/serversStatusPanel.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/redux/appActions.dart';
import 'package:mdi/mdi.dart';
import 'package:tuple/tuple.dart';

import 'components/laAppBar.dart';
import 'components/scrollPanel.dart';
import 'components/servicesStatusPanel.dart';
import 'components/textTitle.dart';
import 'laTheme.dart';
import 'models/hostServicesChecks.dart';
import 'models/laProject.dart';
import 'models/laServer.dart';
import 'models/laService.dart';
import 'models/prodServiceDesc.dart';

class PortalStatusPage extends StatefulWidget {
  static const routeName = "status";

  @override
  _PortalStatusPageState createState() => _PortalStatusPageState();
}

class _PortalStatusPageState extends State<PortalStatusPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _PortalStatusViewModel>(
      distinct: true,
      converter: (store) {
        return _PortalStatusViewModel(
            project: store.state.currentProject,
            checkResults: store.state.currentProject.checkResults,
            serverServicesToMonitor:
                store.state.currentProject.serverServicesToMonitor(),
            loading: store.state.loading,
            checkServices: (hostsServicesChecks) {
              store.dispatch(TestServicesProject(
                  store.state.currentProject,
                  hostsServicesChecks,
                  () => store.dispatch(TestConnectivityProject(
                      store.state.currentProject, () => {}, () => {})),
                  () => {}));
            });
      },
      builder: (BuildContext context, _PortalStatusViewModel vm) {
        List<Widget> resultWidgets = [];
        vm.checkResults.keys.forEach((String serverId) {
          LAServer s = vm.project.servers.firstWhere((s) => s.id == serverId);
          resultWidgets.add(TextTitle(text: s.name, separator: false));
          vm.checkResults[serverId]!.forEach((check) {
            ServiceStatus st = int.parse(check['code']) == 0
                ? ServiceStatus.success
                : ServiceStatus.failed;
            String args = check['service'] == "check_url"
                ? utf8.decode(base64.decode(check['args']))
                : check['args'];
            resultWidgets.add(CheckResultCard(
                title: "${check['service']} $args",
                status: st,
                subtitle: utf8.decode(base64.decode(check['msg']))));
          });
        });
        var pageTitle = "${vm.project.shortName} Portal Status";
        return Title(
            title: pageTitle,
            color: LAColorTheme.laPalette,
            child: Scaffold(
              key: _scaffoldKey,
              appBar: LAAppBar(
                  context: context,
                  titleIcon: Icons.fact_check,
                  title: pageTitle,
                  showLaIcon: false,
                  showBack: true,
                  loading: vm.loading,
                  actions: [
                    IconButton(
                      icon: Tooltip(
                          child: Icon(Icons.pause, color: Colors.white),
                          message: "Pause to check services"),
                      onPressed: () {
                        //
                      },
                    ),
                    Container(
                        margin: const EdgeInsets.only(right: 10.0),
                        child: IconButton(
                          icon: Tooltip(
                              child: Icon(Mdi.reload, color: Colors.white),
                              message: "Recheck the status of the portal"),
                          onPressed: () {
                            vm.checkServices(vm.serverServicesToMonitor.item2);
                          },
                        ))
                  ]),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              // TODO: use here badges
              // https://github.com/hacktons/convex_bottom_bar/
              // {0: '99+', 1: Icons.assistant_photo, 2: Colors.redAccent},
              bottomNavigationBar: ConvexAppBar(
                backgroundColor: LAColorTheme.laPalette,
                style: TabStyle.react,
                items: [
                  TabItem(icon: Mdi.server, title: "Servers"),
                  TabItem(icon: Icons.fact_check, title: "Services"),
                  TabItem(icon: Icons.receipt_long, title: "Details"),
                ],
                initialActiveIndex: 0, //optional, default as 0
                onTap: (int i) => setState(() => _tab = i),
              ),
              body: ScrollPanel(
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
                          child: Column(children: [
                            // Add
                            // https://pub.dev/packages/circular_countdown_timer
                            // or similar and a sliderdesc
                            if (_tab == 0) TextTitle(text: "Servers"),
                            if (_tab == 0)
                              ServersStatusPanel(
                                  extendedStatus: true,
                                  results: vm.checkResults),
                            if (_tab == 1)
                              TextTitle(text: "Services", separator: false),
                            if (_tab == 1)
                              ServicesStatusPanel(
                                  services: vm.serverServicesToMonitor.item1),
                            if (_tab == 2)
                              TextTitle(text: "Details", separator: false),
                            if (_tab == 2)
                              for (Widget w in resultWidgets) w
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
            ));
      },
    );
  }
}

class _PortalStatusViewModel {
  final LAProject project;
  final Map<String, dynamic> checkResults;
  final Tuple2<List<ProdServiceDesc>, HostsServicesChecks>
      serverServicesToMonitor;
  final void Function(HostsServicesChecks) checkServices;
  final bool loading;

  _PortalStatusViewModel(
      {required this.project,
      required this.checkResults,
      required this.loading,
      required this.checkServices,
      required this.serverServicesToMonitor});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _PortalStatusViewModel &&
          runtimeType == other.runtimeType &&
          loading == other.loading &&
          DeepCollectionEquality.unordered()
              .equals(checkResults, other.checkResults) &&
          serverServicesToMonitor == other.serverServicesToMonitor &&
          project == other.project;

  @override
  int get hashCode =>
      project.hashCode ^
      loading.hashCode ^
      serverServicesToMonitor.hashCode ^
      DeepCollectionEquality.unordered().hash(checkResults);
}
