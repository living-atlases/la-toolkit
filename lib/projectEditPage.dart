import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/serverCardList.dart';
import 'package:la_toolkit/components/serverDetailsCardList.dart';
import 'package:la_toolkit/components/themeSelector.dart';
import 'package:la_toolkit/maps/mapAreaSelector.dart';
import 'package:la_toolkit/models/laVariableDesc.dart';
import 'package:la_toolkit/projectTunePage.dart';
import 'package:la_toolkit/redux/appActions.dart';
import 'package:la_toolkit/utils/regexp.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'components/genericTextFormField.dart';
import 'components/helpIcon.dart';
import 'components/laAppBar.dart';
import 'components/laServiceWidget.dart';
import 'components/scrollPanel.dart';
import 'components/servicesInServerChooser.dart';
import 'components/tipsCard.dart';
import 'laTheme.dart';
import 'models/appState.dart';
import 'models/laProject.dart';
import 'models/laProjectStatus.dart';
import 'models/laServer.dart';
import 'models/laServiceDesc.dart';
import 'utils/utils.dart';

class LAProjectEditPage extends StatelessWidget {
  static const routeName = "project";

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  static final int totalSteps = 6;

  final List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>()
  ];
  final List<FocusNode> _focusNodes = [
    FocusNode(),
    null,
    FocusNode(),
    FocusNode(),
    null,
    FocusNode(),
  ];
  final List<Step> _steps = []..length = totalSteps;

  static const _serverHint =
      "Something typically like 'vm1', 'vm2', 'vm3' or 'aws-ip-12-34-56-78', 'aws-ip-12-34-56-79', 'aws-ip-12-34-56-80'";
  final _serverAddController = TextEditingController();
  static const _basicStep = 0;
  static const _mapStep = 1;
  static const _serversStep = 2;
  static const _servicesStep = 3;
  static const _serverToServiceStep = 4;
  static const _serversAdditional = 5;

  static const StepperType stepperType = StepperType.vertical;

  _protocolToS(useSSL) {
    return useSSL ? "https://" : "http://";
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ProjectPageViewModel>(
        // with true fails ssl y ssh advanced
        distinct: true,
        converter: (store) {
          return _ProjectPageViewModel(
              state: store.state,
              ssl: store.state.currentProject.useSSL,
              advancedEdit: store.state.currentProject.advancedEdit,
              onFinish: (project) {
                print('On Finish');
                project.validateCreation();
                if (store.state.status == LAProjectViewStatus.create)
                  store.dispatch(AddProject(project));
                if (store.state.status == LAProjectViewStatus.edit) {
                  store.dispatch(UpdateProject(project));
                  store.dispatch(OpenProjectTools(project));
                }
              },
              onCancel: (project) {
                store.dispatch(OpenProjectTools(project));
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
          // print('build project page');
          LAProject _project = vm.state.currentProject;
          if (_project.getVariable("pac4j_cookie_signing_key").value == null ||
              _project.getVariable("pac4j_cookie_signing_key").value == '') {
            // Auto-generate CAS keys
            _project.init();
          }
          // Set default version of the project
          if (_project.alaInstallRelease == null ||
              _project.alaInstallRelease.isEmpty ||
              vm.state.alaInstallReleases.length > 0)
            _project.alaInstallRelease = vm.state.alaInstallReleases[0];
          if (_project.generatorRelease == null ||
              _project.generatorRelease.isEmpty ||
              vm.state.generatorReleases.length > 0)
            _project.generatorRelease = vm.state.generatorReleases[0];
          int _step = vm.state.currentStep ?? 0;
          print('Building project edit currentStep: $_step key: $_scaffoldKey');
          _steps[0] = Step(
              title: const Text('Basic information'),
              subtitle: const Text(
                  'Define the main information of your portal, like name, ...'),
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
                        label: 'Your LA Project Long Name',
                        hint:
                            "Similar to e.g: 'Atlas of Living Australia', 'BioAtlas Sweden', 'NBN Atlas', ...",
                        wikipage: "Glossary#Long-name",
                        error: 'Project name invalid.',
                        initialValue: _project.longName,
                        //vm: vm,
                        regexp: LARegExp.projectNameRegexp,
                        focusNode: _focusNodes[_basicStep],
                        onChanged: (value) {
                          _project.longName = value;
                          vm.onSaveCurrentProject(_project);
                        }),
                    GenericTextFormField(
                        // SHORT NAME
                        label: 'Short Name',
                        hint:
                            "Similar to for e.g.: 'ALA', 'GBIF.ES', 'NBN',...",
                        wikipage: "Glossary#Short-name",
                        error: 'Project short name invalid.',
                        initialValue: _project.shortName,
                        regexp: LARegExp.projectNameRegexp,
                        onChanged: (value) {
                          _project.shortName = value;
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
                    GenericTextFormField(
                        // DOMAIN
                        label: 'The domain of your LA node',
                        hint:
                            " Similar to for e.g. 'ala.org.au', 'bioatlas.se', 'gbif.es', ...",
                        prefixText: _protocolToS(_project.useSSL),
                        wikipage: "Glossary#Domain",
                        error: 'Project short name invalid.',
                        initialValue: _project.domain,
                        regexp: LARegExp.domainRegexp,
                        onChanged: (value) {
                          _project.domain = value;
                          vm.onSaveCurrentProject(_project);
                        }),
                    SizedBox(height: 20),
                    ThemeSelector()
                  ],
                ),
              ));
          _steps[1] = Step(
              isActive: _setIsActive(_step, _mapStep),
              state: _setSetStatus(_step, _mapStep),
              title: const Text('Location information'),
              subtitle: const Text('Select the map area of your LA portal,...'),
              content: Column(children: [
                _stepIntro(
                    text:
                        "Tap in two points to select the default map area of your LA portal. Drag them to modify the area. This area is used in services like collections, regions and spatial in their main page.",
                    helpPage: "Glossary#Services-map-area"),
                SizedBox(height: 20),
                MapAreaSelector(),
                // MAP AREA NAME
                MessageItem(_project, LAVariableDesc.get("map_zone_name"),
                    (value) {
                  _project.setVariable(
                      LAVariableDesc.get("map_zone_name"), value);
                  vm.onSaveCurrentProject(_project);
                }).buildTitle(context),
              ]));
          _steps[2] = Step(
              isActive: _setIsActive(_step, _serversStep),
              state: _setSetStatus(_step, _serversStep),
              title: const Text('Servers'),
              subtitle:
                  const Text('Inventory of the servers of your LA portal'),
              content: Form(
                key: _formKeys[_serversStep],
                child: Column(
                  // SERVERS
                  children: <Widget>[
                    ServersCardList(),
                    // https://stackoverflow.com/questions/54860198/detect-enter-key-press-in-flutter
                    TextFormField(
                      controller: _serverAddController,
                      showCursor: true,
                      cursorColor: Colors.orange,
                      // TODO: When deployed change this
                      style: LAColorTheme.unDeployedTextStyle,
                      initialValue: null,
                      onFieldSubmitted: (value) =>
                          serversNameSplit(value).forEach((server) {
                        _addServer(server.trim(), _project,
                            vm.onSaveCurrentProject(_project));
                      }),
                      focusNode: _focusNodes[_serversStep],
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (String value) {
                        return LARegExp.hostnameRegexp.hasMatch(value) ||
                                LARegExp.multiHostnameRegexp.hasMatch(value)
                            ? null
                            : 'Invalid server name.';
                      },
                      decoration: InputDecoration(
                          suffixIcon: IconButton(
                              icon: const Icon(Icons.add_circle),
                              onPressed: () {
                                if (_formKeys[_serversStep]
                                    .currentState
                                    .validate()) {
                                  serversNameSplit(
                                    _serverAddController.text,
                                  ).forEach((server) {
                                    _addServer(server, _project,
                                        vm.onSaveCurrentProject);
                                  });
                                }
                              },
                              color: LAColorTheme.inactive),
                          hintText: _serverHint,
                          labelText:
                              'Type the name of your servers, comma or space separated (Press \'enter\' to add it)'),
                    ),
                    TipsCard(text: """## Tips
See the [infrastructure requirements page](https://github.com/AtlasOfLivingAustralia/documentation/wiki/Infrastructure-Requirements) and other portals infrastructure in [our documentation wiki](https://github.com/AtlasOfLivingAustralia/documentation/wiki/) to dimension your LA portal. For a test portal a big server can host the main basic LA services.
If you are unsure type something like "server1, server2, server3".
"""),
                  ],
                ),
              ));
          _steps[3] = Step(
              isActive: _setIsActive(_step, _servicesStep),
              state: _setSetStatus(_step, _servicesStep),
              title: const Text('Services'),
              subtitle: const Text(
                  'Choose the services of your portal and how your services URLs will look like'),
              // subtitle: const Text("Error!"),
              content: Form(
                  key: _formKeys[_servicesStep],
                  child: Column(
                    children: [
                      _stepIntro(
                          text:
                              "Please select the services of your LA Portal. Some services are mandatory, and some services are optional and you can use them later.",
                          helpPage:
                              "Infrastructure-Requirements#core-components-for-a-living-atlas"),
                      ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: LAServiceDesc.map.length,
                          // itemCount: appStateProv.appState.projects.length,
                          itemBuilder: (BuildContext context, int index) =>
                              LaServiceWidget(
                                  serviceName: LAServiceDesc.list
                                      .elementAt(index)
                                      .nameInt,
                                  collectoryFocusNode:
                                      _focusNodes[_servicesStep]))
                    ],
                  )));
          _steps[4] = Step(
              isActive: _setIsActive(_step, _serverToServiceStep),
              state: _setSetStatus(_step, _serverToServiceStep),
              title:
                  const Text('Define which services will run in which servers'),
              // subtitle: const Text("Compatibilities"),
              content: Column(
                  children: (_project.numServers() > 0)
                      ? _project.servers
                          .map((s) => ServicesInServerChooser(server: s))
                          .toList()
                      : [
                          Container(
                              child: const Text(
                                  'You need to add some server before to this step...'))
                        ]));
          _steps[5] = Step(
              isActive: _setIsActive(_step, _serversAdditional),
              state: _setSetStatus(_step, _serversAdditional),
              title: const Text('Define better your servers'),
              subtitle: const Text(
                  "Information to know how to reach and access to your servers, like IP Addressing, names aliases, secure access information"),
              content: Form(
                  key: _formKeys[5],
                  child: Column(children: [
                    TipsCard(text: '''
Here we'll define how to connect to your server (thanks to the [IP address](https://en.wikipedia.org/wiki/IP_address)) and how to do it securely (thanks to [SSH](https://en.wikipedia.org/wiki/SSH_(Secure_Shell))).

This is the most difficult part of all this project definition. If we configure correctly this, we'll deploy correctly later our portal.

We'll use SSH to access to your server. For read more about SSH, read our wiki page [SSH for Beginners](https://github.com/AtlasOfLivingAustralia/documentation/wiki/SSH-for-Beginners).

If you have doubts or need to ask for some information, save this project and continue later filling this. Don't hesitate to ask us in our #slack channel.    
                         ''', margin: EdgeInsets.fromLTRB(0, 0, 0, 10)),
                    MessageItem(_project, LAVariableDesc.get("ansible_user"),
                        (value) {
                      _project.setVariable(
                          LAVariableDesc.get("ansible_user"), value);
                      vm.onSaveCurrentProject(_project);
                    }).buildTitle(context),
                    SizedBox(height: 20),
                    ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Advanced SSH options',
                        ),
                        trailing: Switch(
                            value: _project.advancedEdit,
                            onChanged: (value) {
                              _project.advancedEdit = value;
                              vm.onSaveCurrentProject(_project);
                            })),
                    SizedBox(height: 20),
                    ServersDetailsCardList(_focusNodes[_serversAdditional]),
                  ])));
          return Scaffold(
            key: _scaffoldKey,
            appBar: LAAppBar(
                context: context,
                titleIcon: Icons.edit,
                title: vm.state.status.title,
                showLaIcon: false,
                actions: ListUtils.listWithoutNulls([
                  Tooltip(
                      message: "Project configuration progress",
                      child: CircularPercentIndicator(
                        radius: 50.0,
                        lineWidth: 6.0,
                        percent: _project.status.percent / 100,
                        center: new Text("${_project.status.percent}%",
                            style:
                                TextStyle(color: Colors.white, fontSize: 12)),
                        progressColor: Colors.white,
                      )),
                  SizedBox(width: 20),
                  _step == 0
                      ? null
                      : TextButton(
                          child: const Text('PREVIOUS'),
                          style: TextButton.styleFrom(primary: Colors.white),
                          onPressed: () => onStepCancel(vm, _project)),
                  _step == _steps.length - 1
                      ? null
                      : TextButton(
                          child: const Text('NEXT'),
                          style: TextButton.styleFrom(primary: Colors.white),
                          onPressed: () => onStepContinue(vm, _project)),
                  Tooltip(
                    message: "Close without saving your changes",
                    child: TextButton(
                        child: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          vm.onFinish(_project);
                        }),
                  ),
                  IconButton(
                    icon: Tooltip(
                        child: const Icon(Icons.save, color: Colors.white),
                        message: "Save the current LA project"),
                    onPressed: () {
                      vm.onFinish(_project);
                    },
                  )
                ])),
            body: ScrollPanel(
              child: Stepper(
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
                  controlsBuilder: (BuildContext context,
                      {VoidCallback onStepContinue,
                      VoidCallback onStepCancel}) {
                    return ButtonBar(
                      alignment: MainAxisAlignment.start,
                      children: <Widget>[
                        // empty and custom in the AppBar
                      ],
                    );
                  }),
            ),
            //     ])
          );
        });
  }

  List<String> serversNameSplit(String value) =>
      value.split(new RegExp(r"[, ]+"));

  void onStepCancel(_ProjectPageViewModel vm, LAProject project) {
    vm.onPrevious();
    vm.onSaveCurrentProject(project);
  }

  void onStepContinue(_ProjectPageViewModel vm, LAProject project) {
    vm.onNext();
    vm.onSaveCurrentProject(project);
  }

  void _addServer(String value, LAProject project,
      void Function(LAProject) onSaveCurrentProject) {
    project.upsert(LAServer(name: value));
    _serverAddController.clear();
    _formKeys[_serversStep].currentState.reset();
    _focusNodes[_serversStep].requestFocus();
    onSaveCurrentProject(project);
  }

  bool _setIsActive(currentStep, step) {
    return currentStep == step;
  }

  StepState _setSetStatus(currentStep, step) {
    return currentStep == step ? StepState.editing : StepState.complete;
  }

  Widget _stepIntro({String text, String helpPage}) {
    return ListTile(title: Text(text), trailing: HelpIcon(wikipage: helpPage));
  }
}

class _ProjectPageViewModel {
  final AppState state;
  final bool ssl;
  final bool advancedEdit;
  final Function(LAProject) onSaveCurrentProject;
  final Function(LAProject) onFinish;
  final Function(LAProject) onCancel;
  final Function() onNext;
  final Function() onPrevious;
  final Function(int) onGoto;
  _ProjectPageViewModel(
      {this.state,
      this.onSaveCurrentProject,
      this.onFinish,
      this.onCancel,
      this.ssl,
      this.advancedEdit,
      this.onNext,
      this.onPrevious,
      this.onGoto});

  @override
  bool operator ==(Object other) {
    bool equals = identical(this, other) ||
        other is _ProjectPageViewModel &&
            runtimeType == other.runtimeType &&
            state.currentProject == other.state.currentProject &&
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
        ssl.hashCode ^
        advancedEdit.hashCode;
  }
}

class HostHeader extends StatelessWidget {
  final String title;
  final String help;

  HostHeader({this.title, this.help});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(this.title),
        if (this.help != null) HelpIcon(wikipage: this.help)
      ],
    );
  }
}
