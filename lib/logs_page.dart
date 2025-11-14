import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import 'components/la_app_bar.dart';
import 'components/status_icon.dart';
import 'la_theme.dart';
import 'logs_list.dart';
import 'models/appState.dart';
import 'models/cmd.dart';
import 'models/cmdHistoryEntry.dart';
import 'models/la_project.dart';
import 'redux/app_actions.dart';
import 'redux/entityActions.dart';
import 'utils/result_types.dart';
import 'utils/utils.dart';

class LogsHistoryPage extends StatelessWidget {
  LogsHistoryPage({super.key});

  static const String routeName = 'logs';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // https://sailsjs.com/documentation/reference/bluedebugPrint-api/find-where
  // Pagination
  // http://127.0.0.1:1337/CmdHistoryEntry?populate=cmd&where={%22projectId%22:%22609a1d0756d6b525227ce1e6%22}&sort=createdAt%20DESC
  // ?limit=100
  // ?skip=30

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      distinct: true,
      converter: (Store<AppState> store) {
        return _ViewModel(
            project: store.state.currentProject,
            logsNum: store.state.currentProject.cmdHistoryEntries.length,
            onDeleteCmd: (CmdHistoryEntry log) =>
                store.dispatch(DeleteLog(log)),
            onRepeatCmd: (LAProject project, CmdHistoryEntry cmdHistory) {
              store.dispatch(DeployUtils.doDeploy(
                  context: context,
                  store: store,
                  project: project,
                  commonCmd: cmdHistory.isAnsibleDeploy()
                      ? cmdHistory.deployCmd!
                      : cmdHistory.cmd.type == CmdType.laPipelines
                          ? cmdHistory.pipelinesCmd!
                          : cmdHistory.parsedBrandingDeployCmd!));
            },
            onOpenDeployResults: (CmdHistoryEntry cmdHistory) {
              store.dispatch(
                  DeployUtils.getCmdResults(context, cmdHistory, false));
            },
            onUpdateDesc: (CmdHistoryEntry cmdHistory, String desc) {
              store.dispatch(RequestUpdateOneProps<CmdHistoryEntry>(
                  cmdHistory.id, <String, dynamic>{'desc': desc}));
            });
      },
      builder: (BuildContext context, _ViewModel vm) {
        final String pageTitle = '${vm.project.shortName} Tasks Logs History';
        return Title(
            title: pageTitle,
            color: LAColorTheme.laPalette,
            child: Scaffold(
              key: _scaffoldKey,
              appBar: LAAppBar(
                  context: context,
                  titleIcon: Icons.receipt_long,
                  title: pageTitle,
                  // showLaIcon: false,
                  showBack: true,
                  actions: const <Widget>[]),
              body: LogList(
                  projectId: vm.project.id,
                  onTap: (CmdHistoryEntry cmd) => vm.onOpenDeployResults(cmd),
                  onRepeat: (CmdHistoryEntry cmd) =>
                      vm.onRepeatCmd(vm.project, cmd),
                  onDelete: (CmdHistoryEntry cmd) => vm.onDeleteCmd(cmd),
                  onUpdateDesc: (CmdHistoryEntry cmd, String desc) =>
                      vm.onUpdateDesc(cmd, desc)),
            ));
      },
    );
  }
}

class LogItem extends StatelessWidget {
  const LogItem(
      this.log, this.onTap, this.onRepeat, this.onDelete, this.onUpdateDesc,
      {super.key});

  final CmdHistoryEntry log;
  final VoidCallback onTap;
  final VoidCallback onRepeat;
  final VoidCallback onDelete;
  final Function(String desc) onUpdateDesc;

  @override
  Widget build(BuildContext context) {
    final String desc = log.getDesc();
    if (log.desc != log.getDesc()) {
      onUpdateDesc(desc); // Update the backend (not done in db migration)
    }
    final String duration = log.duration != null
        ? 'duration: ${LADateUtils.formatDuration(log.duration!)}, '
        : '';
    return ListTile(
        title: Text(desc),
        subtitle: Text(
            '${LADateUtils.formatDate(log.date)}, ${duration}finished status: ${log.result.toS()}'),
        onTap: () => onTap(),
        trailing: Wrap(
          spacing: 12, // space between two icons
          children: <Widget>[
            Tooltip(
                message: 'Repeat this command',
                child: IconButton(
                  icon: Icon(Icons.play_arrow, color: ResultType.ok.color),
                  onPressed: () => onRepeat(),
                )), // icon-1
            Tooltip(
                message: 'Delete this log',
                child: IconButton(
                  icon: const Icon(Icons.delete, color: LAColorTheme.inactive),
                  onPressed: () => onDelete(),
                )), // icon-2
          ],
        ),
        leading: Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: StatusIcon(log.result)));
  }
}

class _ViewModel {
  _ViewModel(
      {required this.project,
      required this.logsNum,
      required this.onOpenDeployResults,
      required this.onDeleteCmd,
      required this.onRepeatCmd,
      required this.onUpdateDesc});

  final LAProject project;
  final int logsNum;
  final void Function(CmdHistoryEntry entry) onOpenDeployResults;
  final void Function(LAProject project, CmdHistoryEntry entry) onRepeatCmd;
  final void Function(CmdHistoryEntry entry) onDeleteCmd;
  final void Function(CmdHistoryEntry entry, String desc) onUpdateDesc;

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
