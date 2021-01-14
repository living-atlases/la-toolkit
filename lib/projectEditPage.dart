import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/redux/appActions.dart';
import 'package:la_toolkit/utils/regexp.dart';
import 'package:url_launcher/url_launcher.dart';

import 'components/genericTextFormField.dart';
import 'components/laAppBar.dart';
import 'components/laServiceWidget.dart';
import 'components/scrollPanel.dart';
import 'components/servicesInServerChooser.dart';
import 'laTheme.dart';
import 'models/appState.dart';
import 'models/laProject.dart';
import 'models/laServer.dart';
import 'models/laServiceDesc.dart';
import 'utils/utils.dart';

class LAProjectEditPage extends StatefulWidget {
  static const routeName = "project";
  static final projectTextStyle =
      TextStyle(color: LAColorTheme.laPalette.shade700);

  @override
  _LAProjectEditPageState createState() => _LAProjectEditPageState();
}

class _LAProjectEditPageState extends State<LAProjectEditPage> {
  int _currentStep;
  bool _complete = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>()
  ];
  List<FocusNode> _focusNodes = [
    FocusNode(),
    FocusNode(),
    FocusNode(),
    null,
    FocusNode(),
  ];
  var _steps;
  LAProject _project;
  static const _markdownColor = LAColorTheme.inactive;
  static const _markdownStyle = const TextStyle(color: _markdownColor);
  static const _serverHint =
      "Something typically like 'vm1', 'vm2', 'vm3' or 'aws-ip-12-34-56-78', 'aws-ip-12-34-56-79', 'aws-ip-12-34-56-80'";
  var _serverAddController = TextEditingController();

  next() {
    // print('next: $_currentStep');
    _currentStep + 1 != _steps.length
        ? goTo(_currentStep + 1)
        : _complete = true;
  }

  cancel() {
    // print('cancel: $_currentStep');
    if (_currentStep > 0) {
      goTo(_currentStep - 1);
    }
  }

  goTo(int step) {
    print('goto $step');
    FocusScope.of(context).requestFocus(_focusNodes[step]);
    _currentStep = step;
  }

  StepperType stepperType = StepperType.vertical;

  /*
  _switchStepType() {
    setState(() => stepperType == StepperType.horizontal
        ? stepperType = StepperType.vertical
        : stepperType = StepperType.horizontal);
  } */

  _protocolToS(useSSL) {
    return useSSL ? "https://" : "http://";
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ProjectPageViewModel>(converter: (store) {
      return _ProjectPageViewModel(
        state: store.state,
        onAddServicesToServer: (server, assignedServices) {
          _project.services = _project.services.map((nameInt, service) {
            _project.assign(nameInt, server);
            /*
            // Remove previous service in server assignments
            if (service.getServersNameList().contains(server.name)) {
              service.servers.clear();
            }
            if (assignedServices.contains(service.nameInt)) {
              service.assign(server);
              // Clear view lists to force recalculation
              service.initView();
            } */
            return MapEntry(nameInt, service);
          });
          _project.initViews();
          _project.validateCreation();
          store.dispatch(UpdateProject(_project));
        },
        onFinish: () {
          _project.initViews();
          _project.validateCreation();
          if (store.state.status == LAProjectViewStatus.create)
            store.dispatch(AddProject(_project));
          if (store.state.status == LAProjectViewStatus.edit) {
            store.dispatch(UpdateProject(_project));
            // Clear view lists to force recalculation
          }
          store.dispatch(OpenProjectTools(_project));
        },
        onSaveCurrentProject: () {
          _project.initViews();
          _project.validateCreation();

          store.dispatch(SaveCurrentProject(_project, _currentStep));
        },
      );
    }, builder: (BuildContext context, _ProjectPageViewModel vm) {
      // print('build project page');
      _project = vm.state.currentProject;
      _currentStep = vm.state.currentStep ?? 0;

      _steps = [
        Step(
            title: const Text('Basic information'),
            subtitle: const Text(
                'Define the main information of your portal, like name, ...'),
            isActive: _setIsActive(0),
            state: _setSetStatus(0),
            content: Form(
              key: _formKeys[0],
              child: Column(
                children: <Widget>[
                  GenericTextFormField(
                      //_createTextField(
                      // LONG NAME
                      //  key: _formKeys[0],
                      label: 'Your LA Project Long Name',
                      hint:
                          "Similar to e.g: 'Atlas of Living Australia', 'BioAtlas Sweden', 'NBN Atlas', ...",
                      wikipage: "Glosary#Long-name",
                      error: 'Project name invalid.',
                      initialValue: _project.longName,
                      //vm: vm,
                      regexp: LARegExp.projectNameRegexp,
                      focusNode: _focusNodes[0],
                      onChanged: (value) {
                        _project.longName = value;
                        vm.onSaveCurrentProject();
                      }),
                  GenericTextFormField(
                      // SHORT NAME
                      label: 'Short Name',
                      hint: "Similar to for e.g.: 'ALA', 'GBIF.ES', 'NBN',...",
                      wikipage: "Glosary#Short-name",
                      error: 'Project short name invalid.',
                      initialValue: _project.shortName,
                      regexp: LARegExp.projectNameRegexp,
                      onChanged: (value) {
                        _project.shortName = value;
                        vm.onSaveCurrentProject();
                      }),
                  Tooltip(
                      // SSL
                      message: "Quite recommended",
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Use SSL?',
                        ),
                        trailing: Switch(
                          value: _project.useSSL,
                          // activeColor: Color(0xFF6200EE),
                          onChanged: (bool newValue) {
                            //    setState(() {
                            _project.useSSL = newValue;
                            vm.onSaveCurrentProject();
                            // }),
                          },
                        ),
                      )),
                  GenericTextFormField(
                      // DOMAIN
                      label: 'The domain of your LA node',
                      hint:
                          " Similar to for e.g. 'ala.org.au', 'bioatlas.se', 'gbif.es', ...",
                      prefixText: _protocolToS(_project.useSSL),
                      wikipage: "Glosary#Domain",
                      error: 'Project short name invalid.',
                      initialValue: _project.domain,
                      regexp: LARegExp.domainRegexp,
                      onChanged: (value) {
                        _project.domain = value;
                        vm.onSaveCurrentProject();
                      }),
                ],
              ),
            )),
        Step(
            isActive: _setIsActive(1),
            state: _setSetStatus(1),
            title: const Text('Servers'),
            subtitle: const Text('Inventory of the servers of your LA portal'),
            content: Form(
              key: _formKeys[1],
              child: Column(
                // SERVERS
                children: <Widget>[
                  ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: _project.numServers(),
                      // itemCount: appStateProv.appState.projects.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                            elevation: 1,
                            child: Container(
                                margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: ListTile(
                                  contentPadding:
                                      EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  title: Text(_project.servers[index].name),
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      _project.delete(_project.servers[index]);
                                      vm.onSaveCurrentProject();
                                    },
                                  ),
                                )));
                      }),
                  // https://stackoverflow.com/questions/54860198/detect-enter-key-press-in-flutter

                  TextFormField(
                    controller: _serverAddController,
                    showCursor: true,
                    cursorColor: Colors.orange,
                    style: LAProjectEditPage.projectTextStyle,
                    onFieldSubmitted: (value) =>
                        _addServer(value, vm.onSaveCurrentProject),
                    focusNode: _focusNodes[1],
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (String value) {
                      return !LARegExp.hostnameRegexp.hasMatch(value) //
                          ? 'Invalid server name.'
                          : null;
                    },
                    decoration: InputDecoration(
                        suffixIcon: IconButton(
                            icon: Icon(Icons.add_circle),
                            onPressed: () {
                              if (_formKeys[1].currentState.validate()) {
                                _addServer(_serverAddController.text,
                                    vm.onSaveCurrentProject);
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
            isActive: _setIsActive(2),
            state: _setSetStatus(2),
            title: const Text('Services'),
            subtitle: const Text(
                'Choose the services of your portal and how your services URLs will look like'),
            // subtitle: const Text("Error!"),
            content: Form(
                key: _formKeys[2],
                child: Column(
                  children: [
                    ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: LAServiceDesc.map.length,
                        // itemCount: appStateProv.appState.projects.length,
                        itemBuilder: (BuildContext context, int index) =>
                            LaServiceWidget(
                                service: _project.getService(LAServiceDesc.list
                                    .elementAt(index)
                                    .nameInt),
                                dependsOn: _project.getService(LAServiceDesc
                                    .list
                                    .elementAt(index)
                                    .depends),
                                collectoryFocusNode: _focusNodes[2]))
                  ],
                ))),
        Step(
            isActive: _setIsActive(3),
            state: _setSetStatus(3),
            title:
                const Text('Define which services will run in which servers'),
            // subtitle: const Text("Compatibilities"),
            content: Column(
                children: (_project.numServers() > 0)
                    ? _project.servers
                        .map((s) => ServicesInServerChooser(
                            server: s,
                            servicesSelected:
                                _project.getServicesNameListSelected(),
                            servicesInUse: _project.getServicesNameListInUse(),
                            servicesNotInUse:
                                _project.getServicesNameListNotInUse(),
                            servicesInServer:
                                _project.getServicesNameListInServer(s.name),
                            onChange: (servicesList) =>
                                vm.onAddServicesToServer(s, servicesList)))
                        .toList()
                    : [Container()])),
        Step(
          isActive: _setIsActive(4),
          state: _setSetStatus(4),
          title: const Text('Define better your servers'),
          subtitle: const Text(
              "Information to know how to reach and access to your servers, like IP Addressing, names aliases, SSH keys"),
          content: Form(
              key: _formKeys[4],
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
                          DataColumn(
                            label: Text("NAME"),
                            numeric: false,
                            tooltip: "This is the server hostname",
                          ),
                          DataColumn(
                            label: Text("IP ADDRESS"),
                            numeric: false,
                            tooltip: "This is IPv4 address",
                          ),
                          DataColumn(
                            label: Text("NAME ALIASES"),
                            numeric: false,
                            tooltip: "Alternative hostnames space separated",
                          ),
                        ],
                        rows: _project.servers
                            .map(
                              (server) => DataRow(cells: [
                                DataCell(Padding(
                                  padding: EdgeInsets.only(bottom: 10),
                                  child: Text(server.name,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16)),
                                )),
                                DataCell(
                                  GenericTextFormField(
                                      // IPv4
                                      hint: "ex: '10.0.0.1' or '84.120.10.4'",
                                      error: 'Wrong IP address.',
                                      initialValue: server.ipv4,
                                      isDense: true,
                                      /* isCollapsed: true, */
                                      regexp: LARegExp.ipv4,
                                      allowEmpty: true,
                                      focusNode: server == _project.servers[0]
                                          ? _focusNodes[4]
                                          : null,
                                      onChanged: (value) {
                                        _project.servers.map((current) {
                                          if (server.name == current.name) {
                                            current.ipv4 = value;
                                            _project.upsert(current);
                                          }
                                          return current;
                                        }).toList();
                                        vm.onSaveCurrentProject();
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
                                          current.aliases = value.split(' ');
                                          _project.upsert(current);
                                        }
                                        return current;
                                      });

                                      vm.onSaveCurrentProject();
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
            title: vm.state.status.title,
            showLaIcon: true,
            actions: ListUtils.listWithoutNulls([
              _currentStep == 0
                  ? null
                  : FlatButton(
                      child: Text('PREVIOUS'),
                      textColor: Colors.white,
                      onPressed: () => onStepCancel(vm)),
              _currentStep == _steps.length - 1
                  ? null
                  : FlatButton(
                      child: Text('NEXT'),
                      textColor: Colors.white,
                      onPressed: () => onStepContinue(vm)),
              IconButton(
                icon: Tooltip(
                    child: Icon(Icons.save, color: Colors.white),
                    message: "Save the current LA project"),
                onPressed: () {
                  vm.onFinish();
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
                onStepContinue(vm);
              },
              onStepTapped: (step) {
                goTo(step);
                vm.onSaveCurrentProject();
              },
              onStepCancel: () {
                onStepCancel(vm);
              },
              // https://github.com/flutter/flutter/issues/11133
              controlsBuilder: (BuildContext context,
                  {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
                return ButtonBar(
                  alignment: MainAxisAlignment.start,
                  // mainAxisSize: MainAxisSize.max,
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    /*  RaisedButton(
                      onPressed: onStepContinue,
                      textColor: Colors.white,
                      color: LAColorTheme.laPalette,
                      child: const Text('NEXT'),
                    ),
                    _currentStep == 0
                        ? null
                        : OutlineButton(
                            onPressed: onStepCancel,
                            textColor: LAColorTheme.laPalette,
                            child: const Text('PREVIOUS'),
                          ), */
                  ],
                );
              }),
        ),
        //     ])
      );
    });
  }

  void onStepCancel(_ProjectPageViewModel vm) {
    cancel();
    vm.onSaveCurrentProject();
  }

  void onStepContinue(_ProjectPageViewModel vm) {
    next();
    vm.onSaveCurrentProject();
  }

  void _addServer(String value, void Function() onSaveCurrentProject) {
    _project.upsert(LAServer(name: value));
    _serverAddController.clear();
    _formKeys[1].currentState.reset();
    _focusNodes[1].requestFocus();
    onSaveCurrentProject();
  }

  bool _setIsActive(step) {
    return _currentStep == step;
  }

  StepState _setSetStatus(step) {
    return _currentStep == step ? StepState.editing : StepState.complete;
  }
}

class _ProjectPageViewModel {
  final AppState state;
  final Function onSaveCurrentProject;
  final Function onFinish;
  final Function(LAServer, List<String>) onAddServicesToServer;

  _ProjectPageViewModel(
      {this.state,
      this.onSaveCurrentProject,
      this.onFinish,
      this.onAddServicesToServer});
}
