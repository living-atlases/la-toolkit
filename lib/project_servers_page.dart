import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:redux/redux.dart';
import 'package:tap_debouncer/tap_debouncer.dart';

import './models/app_state.dart';
import './models/la_project_status.dart';
import './models/la_server.dart';
import './models/la_variable_desc.dart';
import 'components/app_snack_bar.dart';
import 'components/help_icon.dart';
import 'components/la_app_bar.dart';
import 'components/lint_project_panel.dart';
import 'components/scroll_panel.dart';
import 'components/server_details_card_list.dart';
import 'components/servers_card_list.dart';
import 'components/tips_card.dart';
import 'la_theme.dart';
import 'models/la_project.dart';
import 'project_tune_page.dart';
import 'redux/app_actions.dart';
import 'routes.dart';
import 'server_text_field.dart';

class LAProjectServersPage extends StatefulWidget {
  const LAProjectServersPage({super.key});

  static const String routeName = 'servers';

  @override
  State<LAProjectServersPage> createState() => _LAProjectServersPageState();
}

class _LAProjectServersPageState extends State<LAProjectServersPage> {
  int _step = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<GlobalKey<FormState>> _formKeys = <GlobalKey<FormState>>[
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];
  final List<FocusNode?> _focusNodes = <FocusNode?>[FocusNode(), FocusNode()];

  final TextEditingController _serverTextFieldController =
      TextEditingController();
  final TextEditingController _serverAdditionalTextFieldController =
      TextEditingController();
  static const int _serversToServiceStep = 0;
  static const int _serversAdditional = 1;

  @override
  void dispose() {
    /* if (mounted) {
      context.loaderOverlay.hide();
    } */
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ProjectPageViewModel>(
      onInitialBuild: (_) {
        if (context.mounted) {
          context.loaderOverlay.hide();
        }
      },
      converter: (Store<AppState> store) {
        return _ProjectPageViewModel(
          state: store.state,
          project: store.state.currentProject,
          advancedEdit: store.state.currentProject.advancedEdit,
          onFinish: (LAProject project) {
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
          onCancel: (LAProject project) {
            store.dispatch(OpenProjectTools(project));
            BeamerCond.of(context, LAProjectViewLocation());
          },
          onSaveCurrentProject: (LAProject project) {
            debugPrint('On Save Current Project');
            project.validateCreation();
            store.dispatch(SaveCurrentProject(project));
          },
          onGoto: (int step) {
            FocusScope.of(context).requestFocus(_focusNodes[step]);
            store.dispatch(GotoStepEditProject(step));
          },
        );
      },
      builder: (BuildContext context, _ProjectPageViewModel vm) {
        debugPrint('build project servers page');
        final LAProject project = vm.project;

        debugPrint(
          'Building project servers currentStep: $_step key: $_scaffoldKey',
        );
        final List<Step> steps = <Step>[];
        steps.add(
          Step(
            isActive: _setIsActive(_step, _serversToServiceStep),
            state: _setSetStatus(_step, _serversToServiceStep),
            title: const Text(
              'Servers & define which services will run in which servers',
            ),
            subtitle: const Text(
              'Some service can be deployed in several servers for web redundancy or to conform a cluster. Note: the la-toolkit does not configure load balancing in redundant web services.',
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const ServersCardList(),
                // const ServersServicesEditPanel(),
                const SizedBox(height: 10),
                const Text('Add servers:', style: TextStyle(fontSize: 18)),
                ServerTextField(
                  controller: _serverAdditionalTextFieldController,
                  focusNode: _focusNodes[_serversToServiceStep]!,
                  formKey: _formKeys[_serversToServiceStep],
                  onAddServer: (String name) => _addServer(name.trim(), vm),
                ),
              ],
            ),
          ),
        );
        steps.add(
          Step(
            isActive: _setIsActive(_step, _serversAdditional),
            state: _setSetStatus(_step, _serversAdditional),
            title: const Text('Define better your servers'),
            subtitle: const Text(
              'Information to know how to reach and access to your servers, like IP Addressing, names aliases, secure access information',
            ),
            content: Form(
              key: _formKeys[_serversAdditional],
              child: Column(
                children: <Widget>[
                  const TipsCard(
                    text: '''
Here we'll define how to connect to your server (thanks to the [IP address](https://en.wikipedia.org/wiki/IP_address)) and how to do it securely (thanks to [SSH](https://en.wikipedia.org/wiki/SSH_(Secure_Shell))).

This is the most difficult part of all this project definition. If we configure correctly this, we'll deploy correctly later our portal.

We'll use SSH to access to your server. For read more about SSH, read our wiki page [SSH for Beginners](https://github.com/AtlasOfLivingAustralia/documentation/wiki/SSH-for-Beginners).

If you have doubts or need to ask for some information, save this project and continue later filling this. Don't hesitate to ask us in our #slack channel.
                         ''',
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                  ),
                  MessageItem(project, LAVariableDesc.get('ansible_user'), (
                    Object value,
                  ) {
                    project.setVariable(
                      LAVariableDesc.get('ansible_user'),
                      value,
                    );
                    vm.onSaveCurrentProject(project);
                  }).buildTitle(context),
                  const SizedBox(height: 20),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Advanced SSH options'),
                    trailing: Switch(
                      value: project.advancedEdit,
                      onChanged: (bool value) {
                        project.advancedEdit = value;
                        vm.onSaveCurrentProject(project);
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  ServersDetailsCardList(_focusNodes[_serversAdditional]!),
                ],
              ),
            ),
          ),
        );
        if (context.mounted) {
          context.loaderOverlay.hide();
        }
        return Title(
          title:
              '${project.shortName}: ${vm.state.status.getTitle(project.isHub)}',
          color: LAColorTheme.laPalette,
          child: Scaffold(
            key: _scaffoldKey,
            appBar: LAAppBar(
              context: context,
              titleIcon: Icons.dns,
              title: vm.state.status.getTitle(project.isHub),
              actions: <Widget>[
                Tooltip(
                  message: 'Project configuration progress',
                  child: CircularPercentIndicator(
                    radius: 25.0,
                    lineWidth: 6.0,
                    percent: project.status.percent / 100,
                    center: Text(
                      '${project.status.percent}%',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    progressColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
                if (_step != 0)
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                    onPressed: () => onStepCancel(vm, project),
                    child: const Text('PREVIOUS'),
                  ),
                if (_step != steps.length - 1)
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                    onPressed: () => onStepContinue(vm, project),
                    child: const Text('NEXT'),
                  ),
                Tooltip(
                  message: 'Close without saving your changes',
                  child: TextButton(
                    child: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      vm.onFinish(project);
                    },
                  ),
                ),
                TapDebouncer(
                  onTap: () async => await vm.onFinish(project),
                  builder: (BuildContext context, Function()? onTap) {
                    return IconButton(
                      icon: const Tooltip(
                        message: 'Save the current LA project',
                        child: Icon(Icons.save, color: Colors.white),
                      ),
                      onPressed: onTap,
                    );
                  },
                ),
              ],
            ),
            body: AppSnackBar(
              ScrollPanel(
                child: Column(
                  children: <Widget>[
                    Stepper(
                      steps: steps,
                      currentStep: _step,
                      onStepContinue: () {
                        // https://stackoverflow.com/questions/51231128/flutter-stepper-widget-validating-fields-in-individual-steps
                        onStepContinue(vm, project);
                      },
                      onStepTapped: (int step) {
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
                            return const Row();
                          },
                    ),
                    const LintProjectPanel(showToolkitDeps: false),
                  ],
                ),
              ),
            ),
            //     ])
          ),
        );
      },
    );
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

  bool _setIsActive(int currentStep, int step) {
    return currentStep == step;
  }

  StepState _setSetStatus(int currentStep, int step) {
    return currentStep == step ? StepState.editing : StepState.complete;
  }
}

class _ProjectPageViewModel {
  _ProjectPageViewModel({
    required this.state,
    required this.project,
    required this.onSaveCurrentProject,
    required this.onFinish,
    required this.onCancel,
    required this.advancedEdit,
    required this.onGoto,
  });

  final AppState state;
  final LAProject project;
  final bool advancedEdit;
  final Function(LAProject) onSaveCurrentProject;
  final Function(LAProject) onFinish;
  final Function(LAProject) onCancel;

  final Function(int) onGoto;

  @override
  bool operator ==(Object other) {
    final bool equals =
        identical(this, other) ||
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
  const HostHeader({super.key, required this.title, this.help});

  final String title;
  final String? help;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(title),
        if (help != null) HelpIcon(wikipage: help!),
      ],
    );
  }
}
