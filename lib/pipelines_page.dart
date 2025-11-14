import 'dart:developer';


import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:redux/redux.dart';
import 'package:toggle_switch/toggle_switch.dart';


import 'components/alert_card.dart';
import 'components/deploy_btn.dart';
import 'components/la_app_bar.dart';
import 'components/pipelines_timeline.dart';
import 'components/scroll_panel.dart';
import 'la_theme.dart';
import './models/app_state.dart';
import './models/common_cmd.dart';
import 'models/la_project.dart';
import './models/pipelines_cmd.dart';
import './models/pipelines_step_desc.dart';
import './models/pipelines_step_name.dart';
import 'redux/app_actions.dart';
import 'utils/utils.dart';

class PipelinesPage extends StatefulWidget {
  const PipelinesPage({super.key});

  static const String routeName = 'pipelines';

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
      converter: (Store<AppState> store) {
        return _ViewModel(
            project: store.state.currentProject,
            onCancel: (LAProject project) {},
            onSaveCmd: (CommonCmd cmd) {
              store.dispatch(SaveCurrentCmd(cmd: cmd));
            },
            onRunPipelines: (LAProject project, PipelinesCmd cmd) {
              // We order the steps in the same order expected by pipelines
              final Set<String> sortedSteps = PipelinesStepDesc.list
                  .where(
                      (PipelinesStepDesc step) => cmd.steps.contains(step.name))
                  .map((PipelinesStepDesc step) => step.name)
                  .toList()
                  .toSet();
              cmd.steps = sortedSteps;
              // if do-all, we don't add these steps
              if (cmd.allSteps) {
                cmd.steps.removeWhere(
                    (String s) => PipelinesStepDesc.allStringList.contains(s));
                cmd.steps.add('do-all');
              }
              log(cmd.toString());
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
        const String execBtn = 'Run';
        PipelinesCmd cmd = vm.cmd;
        log('Building pipelines page for $cmd');

        if (vm.project.getPipelinesMaster() != null) {
          cmd.master = vm.project.masterPipelinesServer!.name;
        }
        final VoidCallback? onTap = cmd.isACmdForAll ||
                ((cmd.allDrs || (cmd.drs != null && cmd.drs!.isNotEmpty)) &&
                    (cmd.steps.isNotEmpty || cmd.allSteps))
            ? () => vm.onRunPipelines(vm.project, cmd)
            : null;
        final String pageTitle = '${vm.project.shortName} Pipelines';
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
                    // showLaIcon: false,
                    actions: const <Widget>[]),
                body: ScrollPanel(
                    withPadding: true,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          // flex: 1, // 10%
                          child: Container(),
                        ),
                        Expanded(
                            flex: 8, // 80%,
                            child: Column(
                              children: <Widget>[
                                PipelinesTimeline(
                                    project: vm.project,
                                    cmd: vm.cmd,
                                    onChange: (PipelinesCmd changedCmd) {
                                      cmd = changedCmd;
                                      vm.onSaveCmd(cmd);
                                    }),
                                const SizedBox(height: 20),
                                Tooltip(
                                    message:
                                        'Run locally, in spark embedded or in the spark cluster',
                                    child: ToggleSwitch(
                                      minWidth: 90.0,
                                      cornerRadius: 20.0,
                                      activeBgColors: <List<Color>?>[
                                        <Color>[
                                          LAColorTheme.laPalette.shade200
                                        ],
                                        <Color>[
                                          LAColorTheme.laPalette.shade400
                                        ],
                                        <Color>[
                                          LAColorTheme.laPalette.shade800
                                        ],
                                      ],
                                      activeFgColor: Colors.white,
                                      inactiveBgColor: Colors.grey,
                                      inactiveFgColor: Colors.white,
                                      initialLabelIndex: cmd.mode,
                                      totalSwitches: 3,
                                      labels: const <String>[
                                        'Local',
                                        'Embedded',
                                        'Cluster'
                                      ],
                                      radiusStyle: true,
                                      onToggle: (int? index) {
                                        if (index != null) {
                                          log('Current mode $index');
                                          cmd = cmd.copyWith(mode: index);
                                          vm.onSaveCmd(cmd);
                                        }
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
                          // flex: 1, // 10%
                          child: Container(),
                        )
                      ],
                    ))));
      },
    );
  }
}

class _ViewModel {
  _ViewModel(
      {required this.project,
      required this.onRunPipelines,
      required this.cmd,
      required this.onSaveCmd,
      required this.onCancel});

  final LAProject project;
  final Function(LAProject, PipelinesCmd) onRunPipelines;
  final PipelinesCmd cmd;
  final Function(LAProject) onCancel;
  final Function(CommonCmd) onSaveCmd;

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
