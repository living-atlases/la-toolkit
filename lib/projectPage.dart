import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/models/laServiceDescList.dart';
import 'package:la_toolkit/redux/appActions.dart';
import 'package:la_toolkit/utils/regexp.dart';
import 'package:url_launcher/url_launcher.dart';

import 'components/laAppBar.dart';
import 'laTheme.dart';
import 'models/appState.dart';
import 'models/laProject.dart';
import 'models/laServer.dart';
import 'models/laServiceDesc.dart';
import 'utils/debounce.dart';

class LAProjectPage extends StatefulWidget {
  static const routeName = "project";

  LAProjectPage({Key key}) : super(key: key);

  @override
  _LAProjectPageState createState() => new _LAProjectPageState();
}

class _LAProjectPageState extends State<LAProjectPage> {
  int _currentStep;
  final _debouncer = Debouncer(milliseconds: 1000);
  bool _complete = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>()
  ];
  var _steps;
  LAProject _project;
  static const _markdownColor = Colors.blueGrey;
  static const _markdownStyle = const TextStyle(color: _markdownColor);
  static const _serverHint =
      "Something typically like 'vm1', 'vm2', 'vm3' or 'aws-ip-12-34-56-78', 'aws-ip-12-34-56-79', 'aws-ip-12-34-56-80'";
  var _serverAddController = TextEditingController();
  var _serverFocus = FocusNode();

  next() {
    print('next: $_currentStep');
    _currentStep + 1 != _steps.length
        ? goTo(_currentStep + 1)
        : setState(() => _complete = true);
  }

  cancel() {
    print('cancel: $_currentStep');
    if (_currentStep > 0) {
      goTo(_currentStep - 1);
    }
  }

  goTo(int step) {
    print('goTo: $step/$_currentStep');
    // if (_formKeys[step - 1].currentState.validate()) {
    setState(() => _currentStep = step);
  }

  StepperType stepperType = StepperType.vertical;

  switchStepType() {
    setState(() => stepperType == StepperType.horizontal
        ? stepperType = StepperType.vertical
        : stepperType = StepperType.horizontal);
  }

  _protocolToS(useSSL) {
    return useSSL ? "https://" : "http://";
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ProjectPageViewModel>(converter: (store) {
      return _ProjectPageViewModel(
        state: store.state,
        onSaveCurrentProject: () =>
            store.dispatch(SaveCurrentProject(_project, _currentStep)),
      );
    }, builder: (BuildContext context, _ProjectPageViewModel vm) {
      print('build project page');
      _project = vm.state.currentProject;
      _currentStep = vm.state.currentStep ?? 0;
      _steps = [
        Step(
            title: const Text('Basic info'),
            isActive: _setIsActive(0),
            state: _setSetStatus(0),
            content: Form(
              key: _formKeys[0],
              child: Column(
                children: <Widget>[
                  TextFormField(
                      // LONG NAME
                      decoration: const InputDecoration(
                        // icon: Icon(Icons.language),
                        labelText: 'Your LA Project Long Name',
                        hintText: 'Living Atlas Of Wakanda',
                      ),
                      onChanged: (String value) => _debouncer.run(() {
                            _project.longName = value;
                            vm.onSaveCurrentProject();
                          }),
                      initialValue: _project.longName,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (String value) {
                        return !FieldValidators.projectNameRegexp
                                .hasMatch(value) //
                            ? 'Project name invalid.'
                            : null;
                      }),
                  TextFormField(
                      // SHORT NAME
                      decoration: InputDecoration(
                        // icon: Icon(Icons.language),
                        labelText: 'Short Name',
                        // isDense: true,
                        hintText: 'LA Wakanda',
                        suffixIcon: Padding(
                          padding: EdgeInsets.only(
                              top: 5), // add padding to adjust icon
                          child: IconButton(
                              onPressed: () => {},
                              icon: Icon(Icons.help_outline),
                              /*size: 24,*/ color: Colors.blueGrey),
                        ),
                      ),
                      initialValue: _project.shortName,
                      onChanged: (String value) => _debouncer.run(() {
                            _project.shortName = value;
                            vm.onSaveCurrentProject();
                          }),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (String value) {
                        return !FieldValidators.projectNameRegexp
                                .hasMatch(value) //
                            ? 'Project short name invalid.'
                            : null;
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
                  TextFormField(
                      // DOMAIN
                      decoration: InputDecoration(
                        prefixText: _protocolToS(_project.useSSL),
                        labelText: 'The domain of your LA node',
                        isDense: true,
                        hintText: 'your.l-a.site',
                      ),
                      initialValue: _project.domain,
                      onChanged: (String value) => _debouncer.run(() {
                            // setState(() {
                            _project.domain = value;
                            vm.onSaveCurrentProject();
                            // });
                          }),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (String value) {
                        return !FieldValidators.domainRegexp.hasMatch(value) //
                            ? 'You need to provide some-atlas-domain.org'
                            : null;
                      }),
                ],
              ),
            )),
        Step(
            isActive: _setIsActive(1),
            state: _setSetStatus(1),
            title: const Text('Servers'),
            content: Form(
              key: _formKeys[1],
              child: Column(
                // SERVERS
                children: <Widget>[
                  ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: _project.servers.length,
                      // itemCount: appStateProv.appState.projects.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          title: Text(_project.servers[index].name),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => setState(() {
                              _project.servers.removeAt(index);
                              vm.onSaveCurrentProject();
                            }),
                          ),
                        );
                      }),
                  // https://stackoverflow.com/questions/54860198/detect-enter-key-press-in-flutter
                  TextFormField(
                    controller: _serverAddController,
                    onFieldSubmitted: (value) =>
                        _addServer(value, vm.onSaveCurrentProject),
                    focusNode: _serverFocus,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (String value) {
                      return !FieldValidators.hostnameRegexp.hasMatch(value) //
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
                            color: Colors.blueGrey),
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
          title: const Text('Define how your services URLs will look like'),
          // subtitle: const Text("Error!"),
          content: Form(
              key: _formKeys[2],
              child: Column(children: [
                ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: serviceDescList.length,
                    // itemCount: appStateProv.appState.projects.length,
                    itemBuilder: (BuildContext context, int index) =>
                        _serviceForm(serviceDescList.values.elementAt(index)))
              ])),
        ),
        Step(
          isActive: _setIsActive(3),
          state: _setSetStatus(3),
          title: const Text('Define better your servers'),
          // subtitle: const Text("Error!"),
          content: Form(
              key: _formKeys[3],
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1, // 10%
                    child: Container(),
                  ),
                  Expanded(
                      flex: 8, // 80%,
                      child: DataTable(
                        // sortAscending: sort,
                        // sortColumnIndex: 0,
                        showCheckboxColumn: false,
                        columns: [
                          DataColumn(
                            label: Text("SERVER NAME"),
                            numeric: false,
                            tooltip: "This is the server hostname",
                          ),
                          DataColumn(
                            label: Text("IP"),
                            numeric: false,
                            tooltip: "This is IPv4 address",
                          ),
                          DataColumn(
                            label: Text("ALIASES"),
                            numeric: false,
                            tooltip:
                                "Alternative hostnames comma or space separated",
                          ),
                        ],
                        rows: _project.servers
                            .map(
                              (server) => DataRow(
                                  // selected: selectedUsers.contains(server),
                                  /* onSelectChanged: (b) {
                                print("Onselect");
                                // onSelectedRow(b, user);
                              }, */
                                  cells: [
                                    DataCell(
                                      //Text(user.firstName),
                                      Text(server.name),
                                    ),
                                    DataCell(TextFormField(
                                        initialValue: server.ipv4,
                                        onChanged: (String value) {
                                          setState(() {});
                                        },
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        validator: (String value) {
                                          return null;
                                        })),
                                    DataCell(TextFormField(
                                        initialValue: server.aliases.length > 0
                                            ? server.aliases.join(', ')
                                            : "",
                                        onChanged: (String value) {
                                          setState(() {});
                                        },
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        validator: (String value) {
                                          return null;
                                        }))
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
      return new Scaffold(
          key: _scaffoldKey,
          appBar: LAAppBar(title: vm.state.status.title, showLaIcon: true),
          body: Column(children: <Widget>[
            Expanded(
              child: Stepper(
                  steps: _steps,
                  currentStep: _currentStep,
                  type: stepperType,
                  onStepContinue: () {
                    // https://stackoverflow.com/questions/51231128/flutter-stepper-widget-validating-fields-in-individual-steps
                    // setState(() {
                    if (_formKeys[_currentStep].currentState.validate() ||
                        (_currentStep == 1 && _project.servers.length > 0)) {
                      next();
                    }
                    vm.onSaveCurrentProject();
                    // });
                  },
                  onStepTapped: (step) {
                    goTo(step);
                    vm.onSaveCurrentProject();
                  },
                  onStepCancel: () {
                    cancel();
                    vm.onSaveCurrentProject();
                  },

                  // https://github.com/flutter/flutter/issues/11133
                  controlsBuilder: (BuildContext context,
                      {VoidCallback onStepContinue,
                      VoidCallback onStepCancel}) {
                    return ButtonBar(
                      alignment: MainAxisAlignment.start,
                      // mainAxisSize: MainAxisSize.max,
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        RaisedButton(
                          onPressed: onStepContinue,
                          textColor: Colors.white,
                          color: LaColorTheme.laPalette,
                          child: const Text('NEXT'),
                        ),
                        _currentStep == 0
                            ? null
                            : OutlineButton(
                                onPressed: onStepCancel,
                                textColor: LaColorTheme.laPalette,
                                child: const Text('PREVIOUS'),
                              ),
                      ],
                    );
                  }),
            ),
          ]));
    });
  }

  void _addServer(String value, void Function() onSaveCurrentProject) {
    setState(() {
      _project.servers.add(new LAServer(name: value));
      _serverAddController.clear();
      _formKeys[1].currentState.reset();
      _serverFocus.requestFocus();
      onSaveCurrentProject();
    });
  }

  Widget _serviceForm(LaServiceDesc service) {
    return Text("${StringUtils.capitalize(service.desc)}:");
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

  _ProjectPageViewModel({this.state, this.onSaveCurrentProject});
}
