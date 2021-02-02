import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/serverCardList.dart';
import 'package:la_toolkit/components/themeSelector.dart';
import 'package:la_toolkit/maps/mapAreaSelector.dart';
import 'package:la_toolkit/redux/appActions.dart';
import 'package:la_toolkit/utils/regexp.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

import 'components/genericTextFormField.dart';
import 'components/helpIcon.dart';
import 'components/laAppBar.dart';
import 'components/laServiceWidget.dart';
import 'components/scrollPanel.dart';
import 'components/servicesInServerChooser.dart';
import 'laTheme.dart';
import 'models/appState.dart';
import 'models/laProject.dart';
import 'models/laProjectStatus.dart';
import 'models/laServer.dart';
import 'models/laServiceDesc.dart';
import 'utils/utils.dart';

class LAProjectEditPage extends StatefulWidget {
  static const routeName = "project";

  @override
  _LAProjectEditPageState createState() => _LAProjectEditPageState();
}

class _LAProjectEditPageState extends State<LAProjectEditPage> {
  int _currentStep;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>()
  ];
  List<FocusNode> _focusNodes = [
    FocusNode(),
    null,
    FocusNode(),
    FocusNode(),
    null,
    FocusNode(),
  ];
  var _steps;

  static const _markdownColor = LAColorTheme.inactive;
  static const _markdownStyle = const TextStyle(color: _markdownColor);
  static const _serverHint =
      "Something typically like 'vm1', 'vm2', 'vm3' or 'aws-ip-12-34-56-78', 'aws-ip-12-34-56-79', 'aws-ip-12-34-56-80'";
  var _serverAddController = TextEditingController();
  static const _basicStep = 0;
  static const _mapStep = 1;
  static const _serversStep = 2;
  static const _servicesStep = 3;
  static const _serverToServiceStep = 4;
  static const _serversAdditional = 5;

  next() {
    // print('next: $_currentStep');
    if (_currentStep + 1 != _steps.length) goTo(_currentStep + 1);
  }

  cancel() {
    // print('cancel: $_currentStep');
    if (_currentStep > 0) {
      goTo(_currentStep - 1);
    }
  }

  goTo(int step) {
    // print('goto $step');
    FocusScope.of(context).requestFocus(_focusNodes[step]);
    setState(() {
      _currentStep = step;
    });
  }

  static const StepperType stepperType = StepperType.vertical;

  _protocolToS(useSSL) {
    return useSSL ? "https://" : "http://";
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ProjectPageViewModel>(
        distinct: true,
        converter: (store) {
          return _ProjectPageViewModel(
            state: store.state,
            onFinish: (project) {
              print('On Finish');
              project.validateCreation();
              if (store.state.status == LAProjectViewStatus.create)
                store.dispatch(AddProject(project));
              if (store.state.status == LAProjectViewStatus.edit) {
                store.dispatch(UpdateProject(project));
                store.dispatch(OpenProjectTools(project));
              }
              dispose();
            },
            onCancel: (project) {
              store.dispatch(OpenProjectTools(project));
              dispose();
            },
            onSaveCurrentProject: (project) {
              print('On Save Current Project');
              project.validateCreation();
              store.dispatch(SaveCurrentProject(project, _currentStep));
            },
          );
        },
        builder: (BuildContext context, _ProjectPageViewModel vm) {
          // print('build project page');
          LAProject _project = vm.state.currentProject;
          if (_project.getVariable("pac4j_cookie_signing_key").value == null) {
            // Auto-generate CAS keys
            _project.init();
          }
          // Set default version of the project
          _project.alaInstallRelease =
              _project.alaInstallRelease ?? vm.state.alaInstallReleases[0];

          _currentStep = vm.state.currentStep ?? 0;
          print('Project edit currentStep: $_currentStep');
          _steps = [
            Step(
                title: const Text('Basic information'),
                subtitle: const Text(
                    'Define the main information of your portal, like name, ...'),
                isActive: _setIsActive(_basicStep),
                state: _setSetStatus(_basicStep),
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
                )),
            Step(
                isActive: _setIsActive(_mapStep),
                state: _setSetStatus(_mapStep),
                title: const Text('Location information'),
                subtitle:
                    const Text('Select the map area of your LA portal,...'),
                content: Column(children: [
                  _stepIntro(
                      text:
                          "Tap in two points to select the default map area of your LA portal. Drag them to modify the area. This area is used in services like collections, regions and spatial in their main page.",
                      helpPage: "Glossary#Services-default-map-area"),
                  SizedBox(height: 20),
                  MapAreaSelector()
                ])),
            Step(
                isActive: _setIsActive(_serversStep),
                state: _setSetStatus(_serversStep),
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
                        onFieldSubmitted: (value) => _addServer(
                            value, _project, vm.onSaveCurrentProject),
                        focusNode: _focusNodes[_serversStep],
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (String value) {
                          return !LARegExp.hostnameRegexp.hasMatch(value) //
                              ? 'Invalid server name.'
                              : null;
                        },
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                                icon: const Icon(Icons.add_circle),
                                onPressed: () {
                                  if (_formKeys[_serversStep]
                                      .currentState
                                      .validate()) {
                                    _addServer(_serverAddController.text,
                                        _project, vm.onSaveCurrentProject);
                                  }
                                },
                                color: LAColorTheme.inactive),
                            hintText: _serverHint,
                            labelText:
                                'Type the name of one of your servers (Press \'enter\' to add it)'),
                      ),
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3)),
                        margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
                        child: Markdown(
                            shrinkWrap: true,
                            styleSheet: MarkdownStyleSheet(
                              h2: _markdownStyle,
                              p: _markdownStyle,
                              a: const TextStyle(
                                  color: _markdownColor,
                                  decoration: TextDecoration.underline),
                            ),
                            onTapLink: (text, href, title) async =>
                                await launch(href),
                            data: """## Tips
See the [infrastructure requirements page](https://github.com/AtlasOfLivingAustralia/documentation/wiki/Infrastructure-Requirements) and other portals infrastructure in [our documentation wiki](https://github.com/AtlasOfLivingAustralia/documentation/wiki/) to dimension your LA portal. For a test portal a big server can host the main basic LA services.
If you are unsure type something like "server1, server2, server3".
"""),
                      ),
                    ],
                  ),
                )),
            Step(
                isActive: _setIsActive(_servicesStep),
                state: _setSetStatus(_servicesStep),
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
                    ))),
            Step(
                isActive: _setIsActive(_serverToServiceStep),
                state: _setSetStatus(_serverToServiceStep),
                title: const Text(
                    'Define which services will run in which servers'),
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
                          ])),
            Step(
              isActive: _setIsActive(_serversAdditional),
              state: _setSetStatus(_serversAdditional),
              title: const Text('Define better your servers'),
              subtitle: const Text(
                  "Information to know how to reach and access to your servers, like IP Addressing, names aliases, SSH keys"),
              content: Form(
                  key: _formKeys[5],
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1, // 10%
                        child: Container(),
                      ),
                      Expanded(
                          flex: 8, // 80%,
                          child: DataTable(
                            dataRowHeight: 65,
                            // sortAscending: sort,
                            // sortColumnIndex: 0,
                            showCheckboxColumn: false,
                            columns: [
                              const DataColumn(
                                label: const Text("NAME"),
                                numeric: false,
                                tooltip: "This is the server hostname",
                              ),
                              const DataColumn(
                                label: const Text("IP ADDRESS"),
                                numeric: false,
                                tooltip: "This is IPv4 address",
                              ),
                              const DataColumn(
                                label: const Text("NAME ALIASES"),
                                numeric: false,
                                tooltip:
                                    "Alternative hostnames space separated",
                              ),
                            ],
                            rows: _project.servers
                                .map(
                                  (server) => DataRow(cells: [
                                    DataCell(Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Text(server.name,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16)),
                                    )),
                                    DataCell(
                                      GenericTextFormField(
                                          // IPv4
                                          hint:
                                              "ex: '10.0.0.1' or '84.120.10.4'",
                                          error: 'Wrong IP address.',
                                          initialValue: server.ipv4,
                                          isDense: true,
                                          /* isCollapsed: true, */
                                          regexp: LARegExp.ipv4,
                                          allowEmpty: true,
                                          focusNode: server ==
                                                  _project.servers[0]
                                              ? _focusNodes[_serversAdditional]
                                              : null,
                                          onChanged: (value) {
                                            _project.servers.map((current) {
                                              if (server.name == current.name) {
                                                current.ipv4 = value;
                                                _project.upsert(current);
                                              }
                                              return current;
                                            }).toList();
                                            vm.onSaveCurrentProject(_project);
                                          }),
                                      // placeholder: true,
                                    ),
                                    DataCell(GenericTextFormField(
                                        // ALIASES
                                        hint:
                                            'e.g. \'${_project.getService('collectory')?.url(_project.domain)} ${_project.getService('ala_hub')?.url(_project.domain)} ${_project.getService('ala_bie')?.suburl}\' ',
                                        error: 'Wrong aliases.',
                                        initialValue: server.aliases.join(' '),
                                        isDense: true,
                                        /* isCollapsed: true, */
                                        regexp: LARegExp.aliasesRegexp,
                                        onChanged: (value) {
                                          _project.servers.map((current) {
                                            if (server.name == current.name) {
                                              current.aliases =
                                                  value.split(' ');
                                              _project.upsert(current);
                                            }
                                            return current;
                                          });

                                          vm.onSaveCurrentProject(_project);
                                        })),
                                  ]),
                                )
                                .toList(),
                          )),
                      Expanded(
                        flex: 1, // 10%
                        child: Container(),
                      )
                    ],
                  )),
            ),
          ];
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
                        radius: 45.0,
                        lineWidth: 6.0,
                        percent: _project.status.percent / 100,
                        center: new Text("${_project.status.percent}%",
                            style:
                                TextStyle(color: Colors.white, fontSize: 12)),
                        progressColor: Colors.white,
                      )),
                  _currentStep == 0
                      ? null
                      : FlatButton(
                          child: const Text('PREVIOUS'),
                          textColor: Colors.white,
                          onPressed: () => onStepCancel(vm, _project)),
                  _currentStep == _steps.length - 1
                      ? null
                      : FlatButton(
                          child: const Text('NEXT'),
                          textColor: Colors.white,
                          onPressed: () => onStepContinue(vm, _project)),
                  Tooltip(
                    message: "Close without saving your changes",
                    child: FlatButton(
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
                  currentStep: _currentStep,
                  type: stepperType,
                  onStepContinue: () {
                    // https://stackoverflow.com/questions/51231128/flutter-stepper-widget-validating-fields-in-individual-steps
                    onStepContinue(vm, _project);
                  },
                  onStepTapped: (step) {
                    goTo(step);
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

  void onStepCancel(_ProjectPageViewModel vm, LAProject project) {
    cancel();
    vm.onSaveCurrentProject(project);
  }

  void onStepContinue(_ProjectPageViewModel vm, LAProject project) {
    next();
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

  bool _setIsActive(step) {
    return _currentStep == step;
  }

  StepState _setSetStatus(step) {
    return _currentStep == step ? StepState.editing : StepState.complete;
  }

  Widget _stepIntro({String text, String helpPage}) {
    return ListTile(title: Text(text), trailing: HelpIcon(wikipage: helpPage));
  }
}

class _ProjectPageViewModel {
  final AppState state;
  final Function(LAProject) onSaveCurrentProject;
  final Function(LAProject) onFinish;
  final Function(LAProject) onCancel;

  _ProjectPageViewModel(
      {this.state, this.onSaveCurrentProject, this.onFinish, this.onCancel});

  @override
  bool operator ==(Object other) {
    bool equals = identical(this, other) ||
        other is _ProjectPageViewModel &&
            runtimeType == other.runtimeType &&
            state.currentProject == other.state.currentProject;
    /* if (other is _ProjectPageViewModel)
      print(
          '${state.currentProject.servers.length} and ${other.state.currentProject.servers.length}'); */
    return equals;
  }

  @override
  int get hashCode {
    return state.currentProject.hashCode ^ state.currentStep;
  }
}
