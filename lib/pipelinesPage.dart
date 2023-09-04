import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/pipelinesTimeline.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/pipelinesStepDesc.dart';
import 'package:la_toolkit/models/pipelinesStepName.dart';
import 'package:la_toolkit/redux/appActions.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:toggle_switch/toggle_switch.dart';

import 'components/alertCard.dart';
import 'components/deployBtn.dart';
import 'components/laAppBar.dart';
import 'components/scrollPanel.dart';
import 'laTheme.dart';
import 'models/commonCmd.dart';
import 'models/laProject.dart';
import 'models/pipelinesCmd.dart';

class PipelinesPage extends StatefulWidget {
  static const routeName = "pipelines";

  const PipelinesPage({Key? key}) : super(key: key);

  @override
  State<PipelinesPage> createState() => _PipelinesPageState();
}

class _PipelinesPageState extends State<PipelinesPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      // The switch fails
      // distinct: true,
      converter: (store) {
        return _ViewModel(
            project: store.state.currentProject,
            onCancel: (project) {},
            onSaveCmd: (cmd) {
              store.dispatch(SaveCurrentCmd(cmd: cmd));
            },
            onRunPipelines: (project, cmd) {
              // We order the steps in the same order expected by pipelines
              Set<String> sortedSteps = PipelinesStepDesc.list
                  .where((step) => cmd.steps.contains(step.name))
                  .map((step) => step.name)
                  .toList()
                  .toSet();
              cmd.steps = sortedSteps;
              // if do-all, we don't add these steps
              if (cmd.allSteps) {
                cmd.steps.removeWhere(
                    (String s) => PipelinesStepDesc.allStringList.contains(s));
                cmd.steps.add("do-all");
              }
              print(cmd);
              DeployUtils.pipelinesRun(
                  context: context, store: store, project: project, cmd: cmd);
            },
            cmd: store.state.repeatCmd.runtimeType != PipelinesCmd
                ? PipelinesCmd(
                    master:
                        store.state.currentProject.getPipelinesMaster()!.name,
                    mode: store.state.currentProject.inProduction &&
                            !AppUtils.isDev()
                        ? 2
                        : 1)
                : store.state.repeatCmd as PipelinesCmd);
      },
      builder: (BuildContext context, _ViewModel vm) {
        String execBtn = "Run";
        PipelinesCmd cmd = vm.cmd;
        print("Building pipelines page for $cmd");

        if (vm.project.getPipelinesMaster() != null) {
          cmd.master = vm.project.masterPipelinesServer!.name;
        }
        VoidCallback? onTap = cmd.isACmdForAll ||
                ((cmd.allDrs || (cmd.drs != null && cmd.drs!.isNotEmpty)) &&
                    (cmd.steps.isNotEmpty || cmd.allSteps))
            ? () => vm.onRunPipelines(vm.project, cmd)
            : null;
        String pageTitle = "${vm.project.shortName} Pipelines";
        return Title(
            title: pageTitle,
            color: LAColorTheme.laPalette,
            child: Scaffold(
                key: _scaffoldKey,
                appBar: LAAppBar(
                    context: context,
                    titleIcon: MdiIcons.pipe,
                    showBack: true,
                    title: pageTitle,
                    showLaIcon: false,
                    actions: const []),
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
                                PipelinesTimeline(
                                    project: vm.project,
                                    cmd: vm.cmd,
                                    onChange: (changedCmd) {
                                      cmd = changedCmd;
                                      vm.onSaveCmd(cmd);
                                    }),
                                const SizedBox(height: 20),
                                Tooltip(
                                    message:
                                        "Run locally, in spark embedded or in the spark cluster",
                                    child: ToggleSwitch(
                                      minWidth: 90.0,
                                      cornerRadius: 20.0,
                                      activeBgColors: [
                                        [LAColorTheme.laPalette.shade200],
                                        [LAColorTheme.laPalette.shade400],
                                        [LAColorTheme.laPalette.shade800],
                                      ],
                                      activeFgColor: Colors.white,
                                      inactiveBgColor: Colors.grey,
                                      inactiveFgColor: Colors.white,
                                      initialLabelIndex: cmd.mode,
                                      totalSwitches: 3,
                                      labels: const [
                                        'Local',
                                        'Embedded',
                                        'Cluster'
                                      ],
                                      radiusStyle: true,
                                      onToggle: (index) {
                                        print("Current mode $index");
                                        cmd = cmd.copyWith(mode: index);
                                        vm.onSaveCmd(cmd);
                                      },
                                    )),
                                if (((cmd.steps.contains(clustering) ||
                                            cmd.steps.contains(jackknife)) ||
                                        cmd.allSteps) &&
                                    !cmd.allDrs &&
                                    cmd.drs != null &&
                                    cmd.drs!.isNotEmpty)
                                  const AlertCard(
                                    message:
                                        "Run 'clustering' and/or 'jackkife' steps only with all drs",
                                  ),
                                LaunchBtn(
                                    onTap: onTap,
                                    execBtn: execBtn,
                                    icon: MdiIcons.pipe),
                              ],
                            )),
                        Expanded(
                          flex: 1, // 10%
                          child: Container(),
                        )
                      ],
                    ))));
      },
    );
  }
}

class _ViewModel {
  final LAProject project;
  final Function(LAProject, PipelinesCmd) onRunPipelines;
  final PipelinesCmd cmd;
  final Function(LAProject) onCancel;
  final Function(CommonCmd) onSaveCmd;

  _ViewModel(
      {required this.project,
      required this.onRunPipelines,
      required this.cmd,
      required this.onSaveCmd,
      required this.onCancel});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ViewModel &&
          runtimeType == other.runtimeType &&
          cmd == other.cmd &&
          project == other.project;

  @override
  int get hashCode => project.hashCode ^ project.hashCode ^ cmd.hashCode;
}
