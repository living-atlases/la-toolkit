import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/serversStatusPanel.dart';
import 'package:la_toolkit/laTheme.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/redux/appActions.dart';

import 'components/countdownWidget.dart';
import 'components/laAppBar.dart';
import 'components/scrollPanel.dart';
import 'components/servicesStatusPanel.dart';
import 'components/textTitle.dart';
import 'models/laProject.dart';

class PortalStatusPage extends StatelessWidget {
  static const routeName = "status";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _PortalStatusViewModel>(
      distinct: true,
      converter: (store) {
        return _PortalStatusViewModel(
            project: store.state.currentProject,
            loading: store.state.loading,
            checkServices: () => store.dispatch(
                TestConnectivityProject(store.state.currentProject, () {})));
      },
      builder: (BuildContext context, _PortalStatusViewModel vm) {
        /*if (vm.loading)
          context.showLoaderOverlay();
        else
          context.hideLoaderOverlay(); */
        return Scaffold(
          key: _scaffoldKey,
          appBar: LAAppBar(
              context: context,
              titleIcon: Icons.fact_check,
              title: "${vm.project.shortName} Portal Status",
              showLaIcon: false,
              showBack: true,
              bottom: PreferredSize(
                  preferredSize: Size(double.infinity, 1.0),
                  child: vm.loading
                      ? LinearProgressIndicator(
                          backgroundColor: LAColorTheme.laPaletteAccent,
                        )
                      : Container()),
              actions: []),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          body: ScrollPanel(
              withPadding: true,
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1, // 10%
                    child: Container(),
                  ),
                  Expanded(
                      flex: 8, // 80%,
                      child: Column(children: [
                        // Add
                        // https://pub.dev/packages/circular_countdown_timer
                        // or similar and a sliderdesc
                        TextTitle(text: "Servers"),
                        ServersStatusPanel(extendedStatus: true),
                        TextTitle(text: "Services", separator: true),
                        ServicesStatusPanel(),
                      ])),
                  Expanded(
                    flex: 1, // 10%
                    child: Container(),
                  )
                ],
              )),
          floatingActionButton:
              CountDownWidget(onReload: () => vm.checkServices()),
        );
      },
    );
  }
}

class _PortalStatusViewModel {
  final LAProject project;
  final void Function() checkServices;
  final bool loading;

  _PortalStatusViewModel(
      {required this.project,
      required this.loading,
      required this.checkServices});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _PortalStatusViewModel &&
          runtimeType == other.runtimeType &&
          loading == other.loading &&
          project == other.project;

  @override
  int get hashCode => project.hashCode ^ loading.hashCode;
}