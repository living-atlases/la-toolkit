import 'dart:convert';

import 'package:beamer/beamer.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:la_toolkit/components/deploySubResultWidget.dart';
import 'package:la_toolkit/components/resultsChart.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/cmdHistoryDetails.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/redux/appActions.dart';
import 'package:la_toolkit/routes.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:mdi/mdi.dart';
import 'package:xterm/frontend/terminal_view.dart';
import 'package:xterm/terminal/terminal.dart';

import 'components/laAppBar.dart';
import 'components/scrollPanel.dart';
import 'laTheme.dart';
import 'models/ansibleError.dart';
import 'models/cmdHistoryEntry.dart';

class DeployResultsPage extends StatelessWidget {
  static const routeName = "deploy-results";

  // final Terminal terminal = Terminal(theme: TerminalThemes.defaultTheme);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
                    String action = task['hosts'][host]['action'];
                    String msg = task['hosts'][host]['msg'];
                    errors.add(AnsibleError(
                        host: host, playName: name, action: action, msg: msg));
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
          bool fistRetrieved = cmdHistoryDetails.fstRetrieved;
          num failures = resultsTotals['failures'] ?? 0;
          bool noFailures = failures == 0;
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
                      Expanded(
                        flex: 1, // 10%
                        child: Container(),
                      ),
                      Expanded(
                          flex: 8, // 80%,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(height: 20),
                              Text(cmdHistoryDetails.cmd!.deployCmd.toString(),
                                  style: DeployUtils.cmdStyle),
                              SizedBox(height: 20),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                        noFailures
                                            ? Mdi.checkboxMarkedCircleOutline
                                            : Icons.remove_done,
                                        size: 60,
                                        color: noFailures
                                            ? LAColorTheme.up
                                            : LAColorTheme.down),
                                    SizedBox(width: 20),
                                    Text(
                                        noFailures
                                            ? "All steps ok"
                                            : "Uuppps! Some step${failures > 1 ? 's' : ''} failed",
                                        style: DeployUtils.titleStyle)
                                  ]),
                              SizedBox(height: 20),
                              ResultsChart(resultsTotals),
                              SizedBox(height: 20),
                              Text('Task details:',
                                  style: DeployUtils.subtitleStyle),
                              SizedBox(height: 20),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: resultsDetails),
                              SizedBox(height: 20),
                              Text('Command executed:',
                                  style: DeployUtils.subtitleStyle),
                              SizedBox(height: 20),
                              AnsiblewCmdPanel(
                                  cmdHistoryDetails: cmdHistoryDetails),
                              SizedBox(height: 20),
                              if (!fistRetrieved)
                                Text('Ansible Logs:',
                                    style: DeployUtils.subtitleStyle),
                              if (!fistRetrieved) SizedBox(height: 20),
                              if (!fistRetrieved)
                                Container(
                                    height: 400,
                                    width: 600,
                                    child: SafeArea(
                                      child: TerminalPanel(cmdHistoryDetails),
                                    ))
                            ],
                          )),
                      Expanded(
                        flex: 1, // 10%
                        child: Container(),
                      )
                    ],
                  )));
        } else {
          vm.onOpenDeployResults(vm.project.lastCmdEntry!);
          return Container();
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

class TerminalPanel extends StatelessWidget {
  final CmdHistoryDetails cmdHistoryDetails;
  TerminalPanel(this.cmdHistoryDetails);

  @override
  Widget build(BuildContext context) {
    Terminal terminal = Terminal(theme: DeployUtils.laTerminalTheme);
    var convertedLog = utf8
        .decode(Base64Decoder().convert(cmdHistoryDetails.logsColorized))
        // this should match banner of docker/logs-colorized-ansible-callback.py
        .replaceAll('\n', '\r\n');
    terminal.resize(101, 40);
    terminal.write(convertedLog);

    return Container(
        padding: EdgeInsets.all(10),
        color: Color(DeployUtils.laTerminalTheme.background.value),
        child: TerminalView(
          terminal: terminal,

          opacity: .7,
          // style: TerminalStyle(),
        ));
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
