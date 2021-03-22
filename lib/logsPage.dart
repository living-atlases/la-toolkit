import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/cmdHistoryEntry.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/projectViewPage.dart';
import 'package:la_toolkit/redux/appActions.dart';
import 'package:simple_moment/simple_moment.dart';

import 'components/laAppBar.dart';
import 'components/scrollPanel.dart';
import 'deployPage.dart';

class LogsHistoryPage extends StatelessWidget {
  static const routeName = "logs";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      distinct: true,
      converter: (store) {
        return _ViewModel(
            project: store.state.currentProject,
            onOpenDeployResults: (cmdHistory) {
              store.dispatch(CmdUtils.getCmdResults(cmdHistory, context));
            });
      },
      builder: (BuildContext context, _ViewModel vm) {
        int num = vm.project.cmdHistory.length;
        return Scaffold(
            key: _scaffoldKey,
            appBar: LAAppBar(
                context: context,
                titleIcon: Icons.receipt_long,
                title: "Logs History",
                showLaIcon: false,
                showBack: true,
                backRoute: LAProjectViewPage.routeName,
                actions: []),
            body: new ScrollPanel(
                child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                    child: Column(children: <Widget>[
                      ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: num,
                          // itemCount: appStateProv.appState.projects.length,
                          itemBuilder: (BuildContext context, int index) =>
                              LogItem(
                                  vm.project.cmdHistory[index],
                                  () => vm.onOpenDeployResults(
                                      vm.project.cmdHistory[index])))
                    ]))));
      },
    );
  }
}

class LogItem extends StatelessWidget {
  final CmdHistoryEntry log;
  final VoidCallback onTap;
  LogItem(this.log, this.onTap);
  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(log.title),
        subtitle: Text(
            "Finished status: ${log.result.toS()}, ${Moment.now().from(log.date).toString()}"),
        onTap: () => onTap(),
        leading: Padding(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Icon(Icons.circle, size: 12, color: log.result.iconColor)));
  }
}

class _ViewModel {
  final LAProject project;
  final void Function(CmdHistoryEntry entry) onOpenDeployResults;

  _ViewModel({
    required this.project,
    required this.onOpenDeployResults,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ViewModel &&
          runtimeType == other.runtimeType &&
          project == other.project;

  @override
  int get hashCode => project.hashCode;
}
