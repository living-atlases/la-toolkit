import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/resultsChart.dart';
import 'package:la_toolkit/components/termDialog.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/redux/appActions.dart';
import 'package:la_toolkit/routes.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:mdi/mdi.dart';

import 'components/laAppBar.dart';
import 'components/scrollPanel.dart';
import 'components/termCommandDesc.dart';
import 'components/tipsCard.dart';
import 'laTheme.dart';
import 'models/cmdHistoryEntry.dart';

class DeployResultsPage extends StatefulWidget {
  static const routeName = "deploy-results";

  @override
  _DeployResultsPageState createState() => _DeployResultsPageState();
}

class _DeployResultsPageState extends State<DeployResultsPage> {
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
            onClose: (project) {
              store.dispatch(OpenProjectTools(project));
              BeamerCond.of(context, LAProjectViewLocation());
            });
      },
      builder: (BuildContext context, _DeployResultsViewModel vm) {
        var cmdHistoryDetails = vm.project.lastCmdDetails;
        if (cmdHistoryDetails != null) {
          List<Widget> resultsDetails = cmdHistoryDetails.detailsWidgetList;
          bool failed = cmdHistoryDetails.failed;
          CmdResult result = cmdHistoryDetails.result;
          print(result);
          var nothingDone = !failed && cmdHistoryDetails.nothingDone;
          var noFailedButDone = !failed && !cmdHistoryDetails.nothingDone;
          return Scaffold(
              key: _scaffoldKey,
              appBar: LAAppBar(
                  context: context,
                  titleIcon: Icons.analytics_outlined,
                  title: cmdHistoryDetails.cmd!.deployCmd.getTitle(),
                  showLaIcon: false,
                  showBack: true,
                  actions: [
                    IconButton(
                        icon: Tooltip(
                            child: const Icon(Icons.close, color: Colors.white),
                            message: "Close"),
                        onPressed: () => vm.onClose(vm.project)),
                  ]),
              body: ScrollPanel(
                  withPadding: true,
                  child: Row(
                    children: <Widget>[
                      const Expanded(
                        flex: 1, // 10%
                        child: const SizedBox(),
                      ),
                      Expanded(
                          flex: 8, // 80%,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 20),
                              Text(cmdHistoryDetails.cmd!.deployCmd.toString(),
                                  style: DeployUtils.cmdStyle),
                              const SizedBox(height: 20),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                        noFailedButDone
                                            ? Mdi.checkboxMarkedCircleOutline
                                            : result == CmdResult.aborted
                                                ? Mdi.heartBroken
                                                : Icons.remove_done,
                                        size: 60,
                                        color: noFailedButDone
                                            ? LAColorTheme.up
                                            : nothingDone ||
                                                    result == CmdResult.aborted
                                                ? LAColorTheme.inactive
                                                : LAColorTheme.down),
                                    const SizedBox(width: 20),
                                    Text(
                                        noFailedButDone
                                            ? "All steps ok"
                                            : nothingDone
                                                ? "No steps were executed"
                                                : result == CmdResult.failed
                                                    ? "Uuppps! some step failed"
                                                    : result ==
                                                            CmdResult.aborted
                                                        ? "The command didn't finished correctly"
                                                        : "The command failed for some reason",
                                        style: DeployUtils.titleStyle)
                                  ]),
                              const SizedBox(height: 20),
                              ResultsChart(cmdHistoryDetails.resultsTotals),
                              SizedBox(height: 20),
                              const Text('Task details:',
                                  style: DeployUtils.subtitleStyle),
                              const SizedBox(height: 20),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: resultsDetails),
                              const SizedBox(height: 20),
                              const Text('Command executed:',
                                  style: DeployUtils.subtitleStyle),
                              const SizedBox(height: 20),
                              TermCommandDesc(
                                  cmdHistoryDetails: cmdHistoryDetails),
                              const SizedBox(height: 20),
                              Text('Ansible Logs:',
                                  style: DeployUtils.subtitleStyle),
                              const SizedBox(height: 20),
                              Container(
                                  height: 600,
                                  width: 1000,
                                  child: TermDialog.termArea()),
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
                        child: const SizedBox(),
                      )
                    ],
                  )));
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
}

class _DeployResultsViewModel {
  final LAProject project;
  final Function(LAProject) onClose;
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
