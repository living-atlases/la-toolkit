import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/term_dialog.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/cmd_history_details.dart';
import 'package:la_toolkit/models/la_project.dart';
import 'package:la_toolkit/utils/api.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'components/laAppBar.dart';
import 'components/project_drawer.dart';
import 'components/resultsPieChart.dart';
import 'components/scrollPanel.dart';
import 'components/termCommandDesc.dart';
import 'components/terms_drawer.dart';
import 'components/tipsCard.dart';
import 'laTheme.dart';
import 'models/cmdHistoryEntry.dart';

class CmdResultsPage extends StatefulWidget {
  static const routeName = "cmd-results";

  const CmdResultsPage({Key? key}) : super(key: key);

  @override
  State<CmdResultsPage> createState() => _CmdResultsPageState();
}

class _CmdResultsPageState extends State<CmdResultsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _loadCall = false;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _DeployResultsViewModel>(
      converter: (store) {
        return _DeployResultsViewModel(
            project: store.state.currentProject,
            onOpenDeployResults: (cmdHistory) {
              store.dispatch(
                  DeployUtils.getCmdResults(context, cmdHistory, false));
            },
            onClose: (project, cmdHistory) {
              closeTerm(cmdHistory);
              context.beamBack();
            });
      },
      builder: (BuildContext context, _DeployResultsViewModel vm) {
        CmdHistoryDetails? cmdHistoryDetails = vm.project.lastCmdDetails;

        if (cmdHistoryDetails != null) {
          List<Widget> resultsDetails = cmdHistoryDetails.detailsWidgetList;
          bool failed = cmdHistoryDetails.failed;
          CmdResult result = cmdHistoryDetails.result;
          CmdHistoryEntry cmdEntry = cmdHistoryDetails.cmd!;
          // print(result);
          bool nothingDone = !failed && cmdHistoryDetails.nothingDone;
          bool noFailedButDone = !failed && !cmdHistoryDetails.nothingDone;
          print(
              "failed $failed, nothingDone: $nothingDone, noFailedButDone: $noFailedButDone, numFails ${cmdHistoryDetails.numFailures()}");
          String title = cmdEntry.getTitle();
          String desc = cmdEntry.getDesc();
          bool isAnsibleDeploy = cmdEntry.isAnsibleDeploy();
          String pageTitle = "${vm.project.shortName} $title";
          return Title(
              title: pageTitle,
              color: LAColorTheme.laPalette,
              child: Scaffold(
                  key: _scaffoldKey,
                  drawer: const ProjectDrawer(),
                  endDrawer: const TermsDrawer(),
                  appBar: LAAppBar(
                      context: context,
                      titleIcon: Icons.analytics_outlined,
                      title: pageTitle,
                      showLaIcon: false,
                      showBack: true,
                      onBack: () => closeTerm(cmdHistoryDetails),
                      leading:
                          ProjectDrawer.appBarIcon(vm.project, _scaffoldKey),
                      actions: [
                        TermsDrawer.appBarIcon(vm.project, _scaffoldKey),
                        IconButton(
                            icon: const Tooltip(
                                message: "Close",
                                child: Icon(Icons.close, color: Colors.white)),
                            onPressed: () =>
                                vm.onClose(vm.project, cmdHistoryDetails)),
                      ]),
                  body: ScrollPanel(
                      withPadding: true,
                      child: Row(
                        children: <Widget>[
                          const Expanded(
                            flex: 1, // 10%
                            child: SizedBox(),
                          ),
                          Expanded(
                              flex: 8, // 80%,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 20),
                                  Text(desc, style: UiUtils.cmdTitleStyle),
                                  const SizedBox(height: 20),
                                  Text(
                                      "${LADateUtils.formatDate(cmdEntry.date)}${cmdEntry.duration != null ? ', duration: ${LADateUtils.formatDuration(cmdEntry.duration!)}' : ''}",
                                      style: UiUtils.dateStyle),
                                  const SizedBox(height: 20),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        if (isAnsibleDeploy)
                                          Icon(
                                              noFailedButDone
                                                  ? MdiIcons
                                                      .checkboxMarkedCircleOutline
                                                  : result == CmdResult.aborted
                                                      ? MdiIcons.heartBroken
                                                      : Icons.remove_done,
                                              size: 60,
                                              color: noFailedButDone
                                                  ? LAColorTheme.up
                                                  : nothingDone ||
                                                          result ==
                                                              CmdResult.aborted
                                                      ? LAColorTheme.inactive
                                                      : LAColorTheme.down),
                                        if (!isAnsibleDeploy)
                                          Icon(
                                              !failed
                                                  ? MdiIcons
                                                      .checkboxMarkedCircleOutline
                                                  : Icons.remove_done,
                                              size: 60,
                                              color: !failed
                                                  ? LAColorTheme.up
                                                  : LAColorTheme.down),
                                        const SizedBox(width: 20),
                                        Text(
                                            isAnsibleDeploy
                                                ? noFailedButDone
                                                    ? "All steps ok"
                                                    : nothingDone
                                                        ? "No steps were executed"
                                                        : result ==
                                                                CmdResult.failed
                                                            ? "Uuppps! some step failed"
                                                            : result ==
                                                                    CmdResult
                                                                        .aborted
                                                                ? "The command didn't finished correctly"
                                                                : "The command failed for some reason"
                                                :
                                                // no Ansible Logs
                                                failed
                                                    ? "Something were wrong"
                                                    : "The command ended correctly",
                                            style: UiUtils.titleStyle)
                                      ]),
                                  const SizedBox(height: 20),
                                  if (isAnsibleDeploy)
                                    const Text('Tasks summary:',
                                        style: UiUtils.subtitleStyle),
                                  // ignore: sized_box_for_whitespace
                                  if (isAnsibleDeploy)
                                    SizedBox(
                                        width: 400,
                                        height: 300,
                                        child: ResultsPieChart(
                                            cmdHistoryDetails.resultsTotals)),
                                  const SizedBox(height: 20),
                                  if (isAnsibleDeploy)
                                    const Text('Tasks details:',
                                        style: UiUtils.subtitleStyle),
                                  const SizedBox(height: 20),
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: resultsDetails),
                                  const SizedBox(height: 20),
                                  const Text('Command executed:',
                                      style: UiUtils.subtitleStyle),
                                  const SizedBox(height: 20),
                                  TermCommandDesc(
                                      cmdHistoryDetails: cmdHistoryDetails),
                                  const SizedBox(height: 20),
                                  Text(
                                      isAnsibleDeploy
                                          ? 'Ansible Logs:'
                                          : 'Logs',
                                      style: UiUtils.subtitleStyle),
                                  const SizedBox(height: 20),
                                  // ignore: sized_box_for_whitespace
                                  if (cmdHistoryDetails.port != null)
                                    SizedBox(
                                        height: 600,
                                        width: 1000,
                                        child: TermDialog.termArea(
                                            cmdHistoryDetails.port!, false)),
                                  if (cmdHistoryDetails.port == null)
                                    const Text(
                                        "For some reason, we couldn't open a terminal with these logs. Possible fix: restart your la-toolkit container"),
                                  TipsCard(text: """## Tips with the logs
This logs are located in the file `logs/${cmdHistoryDetails.cmd!.logsPrefix}-${cmdHistoryDetails.cmd!.logsSuffix}.log`.

This term shows the end of that log file using the command `less`. You can use your mouse scroll or the keyboard:

- `CTRL+B`: backward one page in the log file
- `CTRL+F`: forward one page
- `g`: go to the start of the log file
- `G`: go to the end

You can can search words backwards or forward:

- `?`: search for a pattern which will take you to the previous occurrence.
- `/`: search for a pattern which will take you to the next occurrence.
- `n`: for next match in forward

This is useful to search errors. For instance `?FAILED` will search backward the logs for the work `FAILED` and your can follow searching typing `n`.

More info about [how to navigate in this log file](https://www.thegeekstuff.com/2010/02/unix-less-command-10-tips-for-effective-navigation/).
"""),
                                ],
                              )),
                          const Expanded(
                            flex: 1, // 10%
                            child: SizedBox(),
                          )
                        ],
                      ))));
        } else {
          if (_loadCall == false) {
            _loadCall = true;
            vm.onOpenDeployResults(vm.project.lastCmdEntry!);
          }
          return const SizedBox();
        }
      },
    );
  }

  Future<void> closeTerm(CmdHistoryDetails cmdHistoryDetails) =>
      Api.termClose(port: cmdHistoryDetails.port!, pid: cmdHistoryDetails.pid!);
}

class _DeployResultsViewModel {
  final LAProject project;
  final Function(LAProject, CmdHistoryDetails cmdDetails) onClose;
  final void Function(CmdHistoryEntry entry) onOpenDeployResults;

  _DeployResultsViewModel(
      {required this.project,
      required this.onClose,
      required this.onOpenDeployResults});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _DeployResultsViewModel &&
          runtimeType == other.runtimeType &&
          project == other.project;

  @override
  int get hashCode => project.hashCode;
}
