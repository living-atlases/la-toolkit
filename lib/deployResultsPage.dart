import 'package:beamer/beamer.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:la_toolkit/components/deploySubResultWidget.dart';
import 'package:la_toolkit/components/resultsChart.dart';
import 'package:la_toolkit/components/termDialog.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/cmdHistoryDetails.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/redux/appActions.dart';
import 'package:la_toolkit/routes.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:mdi/mdi.dart';

import 'components/laAppBar.dart';
import 'components/scrollPanel.dart';
import 'components/tipsCard.dart';
import 'laTheme.dart';
import 'models/ansibleError.dart';
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
              Beamer.of(context).beamTo(LAProjectViewLocation());
            });
      },
      builder: (BuildContext context, _DeployResultsViewModel vm) {
        var cmdHistoryDetails = vm.project.lastCmdDetails;
        if (cmdHistoryDetails != null) {
          List<Widget> resultsDetails = List.empty(growable: true);
          List<dynamic> results = cmdHistoryDetails.results;
          Map<String, num> resultsTotals = cmdHistoryDetails.resultsTotals;
          results.forEach((result) {
            List<String> playNames = [];
            List<AnsibleError> errors = [];
            result['plays'].forEach((play) {
              String name = play['play']['name'];
              if (name != 'all') playNames.add(name);
              play['tasks'].forEach((task) {
                task['hosts'].keys.forEach((host) {
                  if (task['hosts'][host]['failed'] != null &&
                      task['hosts'][host]['failed'] == true) {
                    String taskName =
                        task['task'] != null ? task['task']['name'] : '';
                    String msg = task['hosts'][host] != null
                        ? task['hosts'][host]['msg']
                        : '';
                    errors.add(AnsibleError(
                        host: host,
                        playName: name,
                        taskName: taskName,
                        msg: msg));
                  }
                });
              });
            });

            /* "tasks": [ { "hosts": {
                        "ala-install-test-2": {
                            "_ansible_no_log": false,
                            "action": "postgresql_db",
                            "changed": false,
                            "failed": true,
                            },
                            "msg" : "Error" */

            result['stats'].keys.forEach((key) {
              DeploySubResultWidget subResult = DeploySubResultWidget(
                  title: playNames.join(', '),
                  name: key,
                  results: result['stats'][key],
                  errors: errors);
              resultsDetails.add(subResult);
            });
          });
          bool failed = cmdHistoryDetails.failed;
          CmdResult result = cmdHistoryDetails.result;
          print(result);
          return Scaffold(
              key: _scaffoldKey,
              appBar: LAAppBar(
                  context: context,
                  titleIcon: Icons.analytics_outlined,
                  title: "Deployment Results",
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
                                        !failed
                                            ? Mdi.checkboxMarkedCircleOutline
                                            : result == CmdResult.aborted
                                                ? Mdi.heartBroken
                                                : Icons.remove_done,
                                        size: 60,
                                        color: !failed
                                            ? LAColorTheme.up
                                            : LAColorTheme.down),
                                    const SizedBox(width: 20),
                                    Text(
                                        !failed
                                            ? "All steps ok"
                                            : result == CmdResult.failed
                                                ? "Uuppps! some step failed"
                                                : result == CmdResult.aborted
                                                    ? "The command didn't finished correctly"
                                                    : "The command failed for some reason",
                                        style: DeployUtils.titleStyle)
                                  ]),
                              const SizedBox(height: 20),
                              ResultsChart(resultsTotals),
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
                              AnsiblewCmdPanel(
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

class AnsiblewCmdPanel extends StatelessWidget {
  const AnsiblewCmdPanel({
    Key? key,
    required this.cmdHistoryDetails,
  }) : super(key: key);

  final CmdHistoryDetails cmdHistoryDetails;

  @override
  Widget build(BuildContext context) {
    String cmd = cmdHistoryDetails.cmd!.cmd;
    return ListTile(
        title: Text(cmd,
            style: GoogleFonts.robotoMono(
                color: LAColorTheme.inactive, fontSize: 18)),
        trailing: Tooltip(
            message: "Press to copy the command",
            child: IconButton(
              icon: Icon(Icons.copy),
              onPressed: () => FlutterClipboard.copy(cmd).then((value) =>
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Command copied to clipboard")))),
            )));
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
