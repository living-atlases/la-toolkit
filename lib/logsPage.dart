import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/laTheme.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/cmdHistoryEntry.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/redux/appActions.dart';
import 'package:la_toolkit/utils/resultTypes.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:simple_moment/simple_moment.dart';

import 'components/laAppBar.dart';
import 'components/scrollPanel.dart';
import 'components/statusIcon.dart';
import 'models/cmd.dart';

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
            logsNum: store.state.currentProject.cmdHistoryEntries.length,
            onDeleteCmd: (log) => store.dispatch(DeleteLog(log)),
            onRepeatCmd: (project, cmdHistory) {
              if (cmdHistory.cmd.type.isDeploy) {
                store.dispatch(DeployUtils.doDeploy(
                    context: context,
                    store: store,
                    project: project,
                    deployCmd: cmdHistory.deployCmd));
              }
            },
            onOpenDeployResults: (cmdHistory) {
              store.dispatch(
                  DeployUtils.getCmdResults(context, cmdHistory, false));
            });
      },
      builder: (BuildContext context, _ViewModel vm) {
        return Scaffold(
            key: _scaffoldKey,
            appBar: LAAppBar(
                context: context,
                titleIcon: Icons.receipt_long,
                title: "Logs History",
                showLaIcon: false,
                showBack: true,
                actions: []),
            body: new ScrollPanel(
                child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                    child: Column(children: <Widget>[
                      ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: vm.logsNum,
                          // itemCount: appStateProv.appState.projects.length,
                          itemBuilder:
                              (BuildContext context, int index) =>
                                  LogItem(
                                      vm.project.cmdHistoryEntries[index],
                                      () => vm.onOpenDeployResults(
                                          vm.project.cmdHistoryEntries[index]),
                                      () => vm.onRepeatCmd(vm.project,
                                          vm.project.cmdHistoryEntries[index]),
                                      () => vm.onDeleteCmd(
                                          vm.project.cmdHistoryEntries[index])))
                    ]))));
      },
    );
  }
}

class LogItem extends StatelessWidget {
  final CmdHistoryEntry log;
  final VoidCallback onTap;
  final VoidCallback onRepeat;
  final VoidCallback onDelete;
  LogItem(this.log, this.onTap, this.onRepeat, this.onDelete);
  @override
  Widget build(BuildContext context) {
    // print(log.deployCmd.toStringClassic());
    return ListTile(
        title: Text(log.deployCmd.toString()),
        subtitle: Text(
            "Finished status: ${log.result.toS()}, ${Moment.now().from(log.date).toString()}"),
        onTap: () => onTap(),
        trailing: Wrap(
          spacing: 12, // space between two icons
          children: <Widget>[
            Tooltip(
                message: "Repeat this command",
                child: IconButton(
                  icon: Icon(Icons.play_arrow, color: ResultType.ok.color),
                  onPressed: () => onRepeat(),
                )), // icon-1
            Tooltip(
                message: "Delete this log",
                child: IconButton(
                  icon: Icon(Icons.delete, color: LAColorTheme.inactive),
                  onPressed: () => onDelete(),
                )), // icon-2
          ],
        ),
        leading: Padding(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: StatusIcon(log.result)));
  }
}

class _ViewModel {
  final LAProject project;
  final int logsNum;
  final void Function(CmdHistoryEntry entry) onOpenDeployResults;
  final void Function(LAProject project, CmdHistoryEntry entry) onRepeatCmd;
  final void Function(CmdHistoryEntry entry) onDeleteCmd;

  _ViewModel(
      {required this.project,
      required this.logsNum,
      required this.onOpenDeployResults,
      required this.onDeleteCmd,
      required this.onRepeatCmd});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ViewModel &&
          runtimeType == other.runtimeType &&
          project == other.project &&
          logsNum == other.logsNum;

  @override
  int get hashCode => project.hashCode ^ logsNum.hashCode;
}
