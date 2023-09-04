import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/serverDetailsCardList.dart';
import 'package:la_toolkit/models/laVariableDesc.dart';
import 'package:la_toolkit/projectTunePage.dart';
import 'package:la_toolkit/redux/appActions.dart';
import 'package:la_toolkit/routes.dart';
import 'package:la_toolkit/serverTextField.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:tap_debouncer/tap_debouncer.dart';

import 'components/appSnackBar.dart';
import 'components/helpIcon.dart';
import 'components/laAppBar.dart';
import 'components/lintProjectPanel.dart';
import 'components/scrollPanel.dart';
import 'components/serversCardList.dart';
import 'components/tipsCard.dart';
import 'laTheme.dart';
import 'models/appState.dart';
import 'models/laProject.dart';
import 'models/laProjectStatus.dart';
import 'models/laServer.dart';

class LAProjectServersPage extends StatefulWidget {
  static const routeName = "servers";

  const LAProjectServersPage({Key? key}) : super(key: key);

  @override
  State<LAProjectServersPage> createState() => _LAProjectServersPageState();
}

class _LAProjectServersPageState extends State<LAProjectServersPage> {
  int _step = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];
  final List<FocusNode?> _focusNodes = [
    FocusNode(),
    FocusNode(),
  ];

  final _serverTextFieldController = TextEditingController();
  final _serverAdditionalTextFieldController = TextEditingController();
  static const _serversToServiceStep = 0;
  static const _serversAdditional = 1;

  static const StepperType stepperType = StepperType.vertical;

  @override
  void dispose() {
    super.dispose();
    context.loaderOverlay.hide();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ProjectPageViewModel>(
        // with true fails ssh advanced, and delete
        distinct: false,
        onInitialBuild: (_) {
          context.loaderOverlay.hide();
        },
        converter: (store) {
          return _ProjectPageViewModel(
              state: store.state,
              project: store.state.currentProject,
              advancedEdit: store.state.currentProject.advancedEdit,
              onFinish: (project) {
                project.validateCreation();
                if (store.state.status == LAProjectViewStatus.create) {
                  store.dispatch(AddProject(project));
                  if (project.isHub) {
                    store.dispatch(OpenProjectTools(project.parent!));
                    BeamerCond.of(context, LAProjectViewLocation());
                  } else {
                    BeamerCond.of(context, HomeLocation());
                  }
                } else {
                  store.dispatch(UpdateProject(project));
                  BeamerCond.of(context, LAProjectViewLocation());
                }
              },
              onCancel: (project) {
                store.dispatch(OpenProjectTools(project));
                BeamerCond.of(context, LAProjectViewLocation());
              },
              onSaveCurrentProject: (project) {
                print('On Save Current Project');
                project.validateCreation();
                store.dispatch(SaveCurrentProject(project));
              },
              onGoto: (step) {
                FocusScope.of(context).requestFocus(_focusNodes[step]);
                store.dispatch(GotoStepEditProject(step));
              });
        },
        builder: (BuildContext context, _ProjectPageViewModel vm) {
          print('build project servers page');
          final LAProject project = vm.project;

          print(
              'Building project servers currentStep: $_step key: $_scaffoldKey');
          final List<Step> steps = [];
          steps.add(Step(
              isActive: _setIsActive(_step, _serversToServiceStep),
              state: _setSetStatus(_step, _serversToServiceStep),
              title: const Text(
                  'Servers & define which services will run in which servers'),
              subtitle: const Text(
                  "Some service can be deployed in several servers for web redundancy or to conform a cluster. Note: the la-toolkit does not configure load balancing in redundant web services."),
              content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ServersCardList(),
                    // const ServersServicesEditPanel(),
                    const SizedBox(height: 10),
                    const Text("Add servers:", style: TextStyle(fontSize: 18)),
                    ServerTextField(
                        controller: _serverAdditionalTextFieldController,
                        focusNode: _focusNodes[_serversToServiceStep]!,
                        formKey: _formKeys[_serversToServiceStep],
                        onAddServer: (name) => _addServer(name.trim(), vm)),
                  ])));
          steps.add(Step(
              isActive: _setIsActive(_step, _serversAdditional),
              state: _setSetStatus(_step, _serversAdditional),
              title: const Text('Define better your servers'),
              subtitle: const Text(
                  "Information to know how to reach and access to your servers, like IP Addressing, names aliases, secure access information"),
              content: Form(
                  key: _formKeys[_serversAdditional],
                  child: Column(children: [
                    const TipsCard(text: '''
Here we'll define how to connect to your server (thanks to the [IP address](https://en.wikipedia.org/wiki/IP_address)) and how to do it securely (thanks to [SSH](https://en.wikipedia.org/wiki/SSH_(Secure_Shell))).

This is the most difficult part of all this project definition. If we configure correctly this, we'll deploy correctly later our portal.

We'll use SSH to access to your server. For read more about SSH, read our wiki page [SSH for Beginners](https://github.com/AtlasOfLivingAustralia/documentation/wiki/SSH-for-Beginners).

If you have doubts or need to ask for some information, save this project and continue later filling this. Don't hesitate to ask us in our #slack channel.    
                         ''', margin: EdgeInsets.fromLTRB(0, 0, 0, 10)),
                    MessageItem(project, LAVariableDesc.get("ansible_user"),
                        (value) {
                      project.setVariable(
                          LAVariableDesc.get("ansible_user"), value);
                      vm.onSaveCurrentProject(project);
                    }).buildTitle(context),
                    const SizedBox(height: 20),
                    ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Advanced SSH options',
                        ),
                        trailing: Switch(
                            value: project.advancedEdit,
                            onChanged: (value) {
                              project.advancedEdit = value;
                              vm.onSaveCurrentProject(project);
                            })),
                    const SizedBox(height: 20),
                    ServersDetailsCardList(_focusNodes[_serversAdditional]!),
                  ]))));
          context.loaderOverlay.hide();
          return Title(
              title:
                  "${project.shortName}: ${vm.state.status.getTitle(project.isHub)}",
              color: LAColorTheme.laPalette,
              child: Scaffold(
                key: _scaffoldKey,
                appBar: LAAppBar(
                    context: context,
                    titleIcon: Icons.dns,
                    title: vm.state.status.getTitle(project.isHub),
                    showLaIcon: false,
                    actions: <Widget>[
                      Tooltip(
                          message: "Project configuration progress",
                          child: CircularPercentIndicator(
                            radius: 50.0,
                            lineWidth: 6.0,
                            percent: project.status.percent / 100,
                            center: Text("${project.status.percent}%",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12)),
                            progressColor: Colors.white,
                          )),
                      const SizedBox(width: 20),
                      if (_step != 0)
                        TextButton(
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.white),
                            onPressed: () => onStepCancel(vm, project),
                            child: const Text('PREVIOUS')),
                      if (_step != steps.length - 1)
                        TextButton(
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.white),
                            onPressed: () => onStepContinue(vm, project),
                            child: const Text('NEXT')),
                      Tooltip(
                        message: "Close without saving your changes",
                        child: TextButton(
                            child: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              vm.onFinish(project);
                            }),
                      ),
                      TapDebouncer(
                          onTap: () async => await vm.onFinish(project),
                          builder: (context, onTap) {
                            return IconButton(
                              icon: const Tooltip(
                                  message: "Save the current LA project",
                                  child: Icon(Icons.save, color: Colors.white)),
                              onPressed: onTap,
                            );
                          })
                    ]),
                body: AppSnackBar(ScrollPanel(
                    child: Column(children: [
                  Stepper(
                      steps: steps,
                      currentStep: _step,
                      type: stepperType,
                      onStepContinue: () {
                        // https://stackoverflow.com/questions/51231128/flutter-stepper-widget-validating-fields-in-individual-steps
                        onStepContinue(vm, project);
                      },
                      onStepTapped: (step) {
                        setState(() {
                          _step = step;
                        });
                      },
                      onStepCancel: () {
                        onStepCancel(vm, project);
                      },
                      // https://github.com/flutter/flutter/issues/11133
                      controlsBuilder:
                          (BuildContext context, ControlsDetails details) {
                        return const Row(
                          children: <Widget>[
                            // empty and custom in the AppBar
                            /* TextButton(
                              onPressed: details.onStepContinue,
                              child: const Text('NEXT'),
                            ),
                            TextButton(
                              onPressed: details.onStepCancel,
                              child: const Text('CANCEL'),
                            ), */
                          ],
                        );
                      }),
                  const LintProjectPanel(
                      showToolkitDeps: false, showLADeps: true)
                ]))),
                //     ])
              ));
        });
  }

  void onStepCancel(_ProjectPageViewModel vm, LAProject project) {
    setState(() {
      if (_step == 1) {
        _step -= 1;
      }
    });
  }

  void onStepContinue(_ProjectPageViewModel vm, LAProject project) {
    setState(() {
      if (_step == 0) {
        _step += 1;
      }
    });
  }

  void _addServer(String value, _ProjectPageViewModel vm) {
    vm.project.upsertServer(LAServer(name: value, projectId: vm.project.id));
    _serverTextFieldController.clear();
    _serverAdditionalTextFieldController.clear();
    _formKeys[_serversToServiceStep].currentState!.reset();
    _focusNodes[_serversToServiceStep]!.requestFocus();
    vm.onSaveCurrentProject(vm.project);
  }

  bool _setIsActive(currentStep, step) {
    return currentStep == step;
  }

  StepState _setSetStatus(currentStep, step) {
    return currentStep == step ? StepState.editing : StepState.complete;
  }
}

class _ProjectPageViewModel {
  final AppState state;
  final LAProject project;
  final bool advancedEdit;
  final Function(LAProject) onSaveCurrentProject;
  final Function(LAProject) onFinish;
  final Function(LAProject) onCancel;

  final Function(int) onGoto;

  _ProjectPageViewModel(
      {required this.state,
      required this.project,
      required this.onSaveCurrentProject,
      required this.onFinish,
      required this.onCancel,
      required this.advancedEdit,
      required this.onGoto});

  @override
  bool operator ==(Object other) {
    bool equals = identical(this, other) ||
        other is _ProjectPageViewModel &&
            runtimeType == other.runtimeType &&
            project == other.project &&
            advancedEdit == other.advancedEdit &&
            state.currentStep == other.state.currentStep;
    return equals;
  }

  @override
  int get hashCode {
    return state.currentProject.hashCode ^
        state.currentStep.hashCode ^
        project.hashCode ^
        advancedEdit.hashCode;
  }
}

class HostHeader extends StatelessWidget {
  final String title;
  final String? help;

  const HostHeader({Key? key, required this.title, this.help})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [Text(title), if (help != null) HelpIcon(wikipage: help!)],
    );
  }
}
