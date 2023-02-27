import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/brandingSelector.dart';
import 'package:la_toolkit/maps/mapAreaSelector.dart';
import 'package:la_toolkit/models/laVariableDesc.dart';
import 'package:la_toolkit/projectTunePage.dart';
import 'package:la_toolkit/redux/appActions.dart';
import 'package:la_toolkit/routes.dart';
import 'package:la_toolkit/utils/regexp.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:tap_debouncer/tap_debouncer.dart';

import 'components/appSnackBar.dart';
import 'components/genericTextFormField.dart';
import 'components/helpIcon.dart';
import 'components/laAppBar.dart';
import 'components/lintProjectPanel.dart';
import 'components/scrollPanel.dart';
import 'components/serviceWidget.dart';
import 'laTheme.dart';
import 'models/appState.dart';
import 'models/laProject.dart';
import 'models/laProjectStatus.dart';
import 'models/laServiceDesc.dart';

class LAProjectEditPage extends StatelessWidget {
  static const routeName = "project";
  final int permissiveDirNamesDate =
      DateTime(2021, 8, 25).microsecondsSinceEpoch;

  LAProjectEditPage({Key? key}) : super(key: key);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  static List<String> serversNameSplit(String value) =>
      value.split(RegExp(r"[, ]+"));
  static const int totalSteps = 4;

  final List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];
  final List<FocusNode?> _focusNodes = [
    FocusNode(),
    null,
    FocusNode(),
  ];

  static const _basicStep = 0;
  static const _mapStep = 1;
  static const _servicesStep = 2;

  static const StepperType stepperType = StepperType.vertical;

  _protocolToS(useSSL) {
    return useSSL ? "https://" : "http://";
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ProjectPageViewModel>(
        // with true fails ssl y ssh advanced, and delete
        distinct: false,
        onInitialBuild: (_) {
          context.loaderOverlay.hide();
        },
        converter: (store) {
          return _ProjectPageViewModel(
              state: store.state,
              project: store.state.currentProject,
              ssl: store.state.currentProject.useSSL,
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
              onNext: () => store.dispatch(NextStepEditProject()),
              onPrevious: () => store.dispatch(PreviousStepEditProject()),
              onGoto: (step) {
                FocusScope.of(context).requestFocus(_focusNodes[step]);
                store.dispatch(GotoStepEditProject(step));
              });
        },
        builder: (BuildContext context, _ProjectPageViewModel vm) {
          print('build project edit page');
          final LAProject _project = vm.project;
          // Set default version of the project
          if (_project.alaInstallRelease == null &&
              vm.state.alaInstallReleases.isNotEmpty) {
            _project.alaInstallRelease = _project.isHub
                ? _project.parent!.alaInstallRelease
                : vm.state.alaInstallReleases[0];
          }
          if (_project.generatorRelease == null &&
              vm.state.generatorReleases.isNotEmpty) {
            _project.generatorRelease = _project.isHub
                ? _project.parent!.generatorRelease
                : vm.state.generatorReleases[0];
          }
          final int _step = vm.state.currentStep;
          print('Building project edit currentStep: $_step key: $_scaffoldKey');
          final List<Step> _steps = [];
          String projectName = _project.projectName;
          String portal = _project.portalName;
          // ignore: non_constant_identifier_names
          String Portal = _project.PortalName;
          if (_project.isHub) _project.domain = _project.parent!.domain;

          _steps.add(Step(
              title: const Text('Basic information'),
              subtitle: Text(
                  'Define the main information of your $portal, like name, ...'),
              isActive: _setIsActive(_step, _basicStep),
              state: _setSetStatus(_step, _basicStep),
              content: Form(
                key: _formKeys[_basicStep],
                child: Column(
                  children: <Widget>[
                    GenericTextFormField(
                        //_createTextField(
                        // LONG NAME
                        //  key: _formKeys[0],
                        label: 'Your LA $projectName Long Name',
                        hint: _project.isHub
                            ? "Similar to e.g: 'The Australasian Virtual Herbarium', 'NBN Atlas Scotland', 'GBIF Togo', ..."
                            : "Similar to e.g: 'Atlas of Living Australia', 'BioAtlas Sweden', 'NBN Atlas', ...",
                        wikipage: "Glossary#Long-name",
                        error: '$projectName name invalid.',
                        initialValue: _project.longName,
                        regexp: LARegExp.projectNameRegexp,
                        focusNode: _focusNodes[_basicStep],
                        onChanged: (value) {
                          _project.longName = value;
                          vm.onSaveCurrentProject(_project);
                        }),
                    GenericTextFormField(
                        // SHORT NAME
                        label: 'Short Name',
                        hint: _project.isHub
                            ? "Similar to for e.g.: 'AVH', 'NBN Scotland', ..."
                            : "Similar to for e.g.: 'ALA', 'GBIF.ES', 'NBN',...",
                        wikipage: "Glossary#Short-name",
                        error: 'Project short name invalid.',
                        initialValue: _project.shortName,
                        regexp: LARegExp.projectNameRegexp,
                        onChanged: (value) {
                          _project.shortName = value;
                          vm.onSaveCurrentProject(_project);
                        }),
                    const SizedBox(height: 10),
                    if (_project.isHub)
                      GenericTextFormField(
                          // DIR NAME
                          label:
                              'Directory Name to store the generated directories and files',
                          hint: _project.isHub
                              ? "Similar to for e.g.: 'avh', 'nbn_scotland', ..."
                              : "Similar to for e.g.: 'ala', 'gbif_es', 'nbn',...",
                          wikipage: "Glossary#Directory-name",
                          error:
                              'Directory name invalid. Should be start by lowercase and should contain only lowercase characters, numbers and/or underscores',
                          initialValue: _project.dirName,
                          regexp: _project.createdAt < permissiveDirNamesDate
                              ? LARegExp.ansibleDirnameRegexpPermissive
                              : LARegExp.ansibleDirnameRegexp,
                          onChanged: (value) {
                            _project.dirName = value;
                            vm.onSaveCurrentProject(_project);
                          }),
                    Tooltip(
                        // SSL
                        message: "Quite recommended",
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Use SSL?',
                          ),
                          trailing: Switch(
                            value: _project.useSSL,
                            // activeColor: Color(0xFF6200EE),
                            onChanged: (bool newValue) {
                              _project.useSSL = newValue;
                              vm.onSaveCurrentProject(_project);
                            },
                          ),
                        )),
                    if (!_project.isHub)
                      GenericTextFormField(
                          // DOMAIN
                          label:
                              'The ${_project.isHub ? 'sub' : ''}domain of your LA $Portal',
                          hint:
                              "Similar to for e.g. 'ala.org.au', 'bioatlas.se', 'gbif.es', ...",
                          prefixText: _protocolToS(_project.useSSL),
                          wikipage: "Glossary#Domain",
                          error: '$projectName short name invalid.',
                          initialValue: _project.domain,
                          regexp: LARegExp.domainRegexp,
                          onChanged: (value) {
                            _project.domain = value;
                            vm.onSaveCurrentProject(_project);
                          }),
                    if (!_project.isHub) const SizedBox(height: 20),
                    BrandingTile(
                        initialValue: _project.theme,
                        portalName: Portal,
                        onChange: (String newTheme) =>
                            _project.theme = newTheme)
                  ],
                ),
              )));
          _steps.add(Step(
              isActive: _setIsActive(_step, _mapStep),
              state: _setSetStatus(_step, _mapStep),
              title: const Text('Location information'),
              subtitle: Text('Select the map area of your LA $Portal,...'),
              content: Column(children: [
                _stepIntro(
                    text:
                        "Tap in two points to select the default map area of your LA $portal. Drag them to modify the area. This area is used in services like collections, regions and spatial in their main page.",
                    helpPage: "Glossary#Services-map-area"),
                const SizedBox(height: 20),
                const MapAreaSelector(),
                // MAP AREA NAME
                MessageItem(_project, LAVariableDesc.get("map_zone_name"),
                    (value) {
                  _project.setVariable(
                      LAVariableDesc.get("map_zone_name"), value);
                  vm.onSaveCurrentProject(_project);
                }).buildTitle(context),
              ])));
          /*  _steps.add(Step(
              isActive: _setIsActive(_step, _serversStep),
              state: _setSetStatus(_step, _serversStep),
              title: const Text('Servers'),
              subtitle: Text('Inventory of the servers of your LA $Portal'),
              content: Form(
                key: _formKeys[_serversStep],
                child: Column(
                  // SERVERS
                  children: <Widget>[
                    // with const, does not changes
                    // ignore: prefer_const_constructors
                    ServersCardList(),
                    // https://stackoverflow.com/questions/54860198/detect-enter-key-press-in-flutter
                    ServerTextField(
                        controller: _serverTextFieldController,
                        focusNode: _focusNodes[_serversStep]!,
                        formKey: _formKeys[_serversStep],
                        onAddServer: (name) => _addServer(name.trim(), vm)),
                    const TipsCard(text: """## Tips
See the [infrastructure requirements page](https://github.com/AtlasOfLivingAustralia/documentation/wiki/Infrastructure-Requirements) and other portals infrastructure in [our documentation wiki](https://github.com/AtlasOfLivingAustralia/documentation/wiki/) to dimension your LA portal. For a test portal a big server can host the main basic LA services.
If you are unsure type something like "server1, server2, server3".
"""),
                  ],
                ),
              ))); */
          final Iterable<LAServiceDesc> availableServices =
              LAServiceDesc.listNoSub(_project.isHub)
                  .where((LAServiceDesc s) => s.isSubService == false);
          _steps.add(Step(
              isActive: _setIsActive(_step, _servicesStep),
              state: _setSetStatus(_step, _servicesStep),
              title: const Text('Services'),
              subtitle: Text(
                  'Choose the services of your $Portal and how your services URLs will look like'),
              // subtitle: const Text("Error!"),
              content: Form(
                  key: _formKeys[_servicesStep],
                  child: Column(
                    children: [
                      _stepIntro(
                          text:
                              "Please select the services of your LA $Portal. Some services are mandatory, and some services are optional and you can use them later.",
                          helpPage:
                              "Infrastructure-Requirements#core-components-for-a-living-atlas"),
                      ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: availableServices.length,
                          // itemCount: appStateProv.appState.projects.length,
                          itemBuilder: (BuildContext context, int index) =>
                              ServiceWidget(
                                  serviceName: availableServices
                                      .elementAt(index)
                                      .nameInt,
                                  collectoryFocusNode:
                                      _focusNodes[_servicesStep]))
                    ],
                  ))));
          context.loaderOverlay.hide();
          return Title(
              title:
                  "${_project.shortName}: ${vm.state.status.getTitle(_project.isHub)}",
              color: LAColorTheme.laPalette,
              child: Scaffold(
                key: _scaffoldKey,
                appBar: LAAppBar(
                    context: context,
                    titleIcon: Icons.edit,
                    title: vm.state.status.getTitle(_project.isHub),
                    showLaIcon: false,
                    actions: <Widget>[
                      Tooltip(
                          message: "Project configuration progress",
                          child: CircularPercentIndicator(
                            radius: 50.0,
                            lineWidth: 6.0,
                            percent: _project.status.percent / 100,
                            center: Text("${_project.status.percent}%",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12)),
                            progressColor: Colors.white,
                          )),
                      const SizedBox(width: 20),
                      if (_step != 0)
                        TextButton(
                            child: const Text('PREVIOUS'),
                            style: TextButton.styleFrom(foregroundColor: Colors.white),
                            onPressed: () => onStepCancel(vm, _project)),
                      if (_step != _steps.length - 1)
                        TextButton(
                            child: const Text('NEXT'),
                            style: TextButton.styleFrom(foregroundColor: Colors.white),
                            onPressed: () => onStepContinue(vm, _project)),
                      Tooltip(
                        message: "Close without saving your changes",
                        child: TextButton(
                            child: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              vm.onFinish(_project);
                            }),
                      ),
                      TapDebouncer(
                          onTap: () async => await vm.onFinish(_project),
                          builder: (context, onTap) {
                            return IconButton(
                              icon: const Tooltip(
                                  child: Icon(Icons.save, color: Colors.white),
                                  message: "Save the current LA project"),
                              onPressed: onTap,
                            );
                          })
                    ]),
                body: AppSnackBar(ScrollPanel(
                    child: Column(children: [
                  Stepper(
                      steps: _steps,
                      currentStep: _step,
                      type: stepperType,
                      onStepContinue: () {
                        // https://stackoverflow.com/questions/51231128/flutter-stepper-widget-validating-fields-in-individual-steps
                        onStepContinue(vm, _project);
                      },
                      onStepTapped: (step) {
                        vm.onGoto(step);
                        vm.onSaveCurrentProject(_project);
                      },
                      onStepCancel: () {
                        onStepCancel(vm, _project);
                      },
                      // https://github.com/flutter/flutter/issues/11133
                      controlsBuilder:
                          (BuildContext context, ControlsDetails details) {
                        return Row(
                          children: const <Widget>[
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
                  const LintProjectPanel(showOthers: false,
                      showToolkitDeps: false, showLADeps: false)
                ]))),
                //     ])
              ));
        });
  }

  void onStepCancel(_ProjectPageViewModel vm, LAProject project) {
    vm.onPrevious();
    vm.onSaveCurrentProject(project);
  }

  void onStepContinue(_ProjectPageViewModel vm, LAProject project) {
    vm.onNext();
    vm.onSaveCurrentProject(project);
  }

  bool _setIsActive(currentStep, step) {
    return currentStep == step;
  }

  StepState _setSetStatus(currentStep, step) {
    return currentStep == step ? StepState.editing : StepState.complete;
  }

  Widget _stepIntro({required String text, required String helpPage}) {
    return ListTile(title: Text(text), trailing: HelpIcon(wikipage: helpPage));
  }
}

class _ProjectPageViewModel {
  final AppState state;
  final LAProject project;
  final bool ssl;
  final bool advancedEdit;
  final Function(LAProject) onSaveCurrentProject;
  final Function(LAProject) onFinish;
  final Function(LAProject) onCancel;
  final Function() onNext;
  final Function() onPrevious;
  final Function(int) onGoto;
  _ProjectPageViewModel(
      {required this.state,
      required this.project,
      required this.onSaveCurrentProject,
      required this.onFinish,
      required this.onCancel,
      required this.ssl,
      required this.advancedEdit,
      required this.onNext,
      required this.onPrevious,
      required this.onGoto});

  @override
  bool operator ==(Object other) {
    bool equals = identical(this, other) ||
        other is _ProjectPageViewModel &&
            runtimeType == other.runtimeType &&
            project == other.project &&
            ssl == other.ssl &&
            advancedEdit == other.advancedEdit &&
            state.currentStep == other.state.currentStep;
    /* if (other is _ProjectPageViewModel)
      print(
          '${state.currentProject.servers.length} and ${other.state.currentProject.servers.length}'); */
    return equals;
  }

  @override
  int get hashCode {
    return state.currentProject.hashCode ^
        state.currentStep.hashCode ^
        project.hashCode ^
        ssl.hashCode ^
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
