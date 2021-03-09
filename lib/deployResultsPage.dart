import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/deploySubResultWidget.dart';
import 'package:la_toolkit/components/resultsChart.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/redux/appActions.dart';
import 'package:mdi/mdi.dart';

import 'components/laAppBar.dart';
import 'components/scrollPanel.dart';
import 'laTheme.dart';

class DeployResultsPage extends StatelessWidget {
  static const routeName = "deploy-results";

  // final Terminal terminal = Terminal(theme: TerminalThemes.defaultTheme);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  static const resultTypes = [
    "changed",
    "failures",
    "ignored",
    "ok",
    "rescued",
    "skipped",
    "unreachable"
  ];

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _DeployResultsViewModel>(
      converter: (store) {
        return _DeployResultsViewModel(
            project: store.state.currentProject,
            onClose: (project) => store.dispatch(OpenProjectTools(project)));
      },
      builder: (BuildContext context, _DeployResultsViewModel vm) {
        Map<String, int> resultsTotals = {};
        resultTypes.forEach((type) => resultsTotals[type] = 0);
        List<Widget> resultsDetails = List.empty(growable: true);
        vm.project.lastDeploymentResults.forEach((result) {
          result['stats'].keys.forEach((key) {
            var subResult = DeploySubResultWidget(key, result['stats'][key]);
            resultsDetails.add(subResult);
            resultTypes.forEach((type) => resultsTotals[type] =
                resultsTotals[type] + result['stats'][key][type]);
          });
        });

        int failures = resultsTotals['failures'];
        bool noFailures = failures == 0;
        return Scaffold(
            key: _scaffoldKey,
            appBar: LAAppBar(
                context: context,
                titleIcon: Icons.analytics_outlined,
                title: "Deployment Results",
                showLaIcon: false,
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
                          children: [
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
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ))
                                ]),
                            SizedBox(height: 20),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [Column(children: resultsDetails)]),
                            SizedBox(height: 40),
                            ResultsChart(resultsTotals)
                          ],
                        )),
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

class _DeployResultsViewModel {
  final LAProject project;
  final Function(LAProject) onClose;

  _DeployResultsViewModel({this.project, this.onClose});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _DeployResultsViewModel &&
          runtimeType == other.runtimeType &&
          project == other.project;

  @override
  int get hashCode => project.hashCode;
}
