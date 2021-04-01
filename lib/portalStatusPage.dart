import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/serversStatusPanel.dart';
import 'package:la_toolkit/models/appState.dart';

import 'components/laAppBar.dart';
import 'components/scrollPanel.dart';
import 'models/laProject.dart';

class PortalStatusPage extends StatelessWidget {
  static const routeName = "status";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _PortalStatusViewModel>(
      converter: (store) {
        return _PortalStatusViewModel(project: store.state.currentProject);
      },
      builder: (BuildContext context, _PortalStatusViewModel vm) {
        return Scaffold(
            key: _scaffoldKey,
            appBar: LAAppBar(
                context: context,
                titleIcon: Icons.fact_check,
                title: "${vm.project.shortName} Portal Status",
                showLaIcon: false,
                showBack: true,
                actions: []),
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
                        child: ServersStatusPanel(extendedStatus: true)),
                    Expanded(
                      flex: 1, // 10%
                      child: Container(),
                    )
                  ],
                )));
      },
    );
  }
}

class _PortalStatusViewModel {
  final LAProject project;

  _PortalStatusViewModel({required this.project});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _PortalStatusViewModel &&
          runtimeType == other.runtimeType &&
          project == other.project;

  @override
  int get hashCode => project.hashCode;
}
