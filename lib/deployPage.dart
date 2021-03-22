import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/tagsConstants.dart';
import 'package:la_toolkit/redux/appActions.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:mdi/mdi.dart';
import 'package:smart_select/smart_select.dart';

import 'components/deployBtn.dart';
import 'components/hostSelector.dart';
import 'components/laAppBar.dart';
import 'components/scrollPanel.dart';
import 'components/selectUtils.dart';
import 'components/servicesChipPanel.dart';
import 'components/termDialog.dart';
import 'components/tipsCard.dart';
import 'laTheme.dart';
import 'models/cmdHistoryEntry.dart';
import 'models/laProject.dart';

class DeployPage extends StatefulWidget {
  static const routeName = "deploy";
  @override
  _DeployPageState createState() => _DeployPageState();
}

class _DeployPageState extends State<DeployPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<S2MultiState<String>> _skipTagsKey =
      GlobalKey<S2MultiState<String>>();
  final GlobalKey<S2MultiState<String>> _selectTagsKey =
      GlobalKey<S2MultiState<String>>();
  List<String> _deployServices = [];
  List<String> _limitToServers = [];
  List<String> _skipTags = [];
  List<String> _tags = [];
  bool _advanced = false;
  bool _onlyProperties = false;
  bool _continueEvenIfFails = false;
  bool _debug = false;
  bool _dryRun = false;
  late String logsSuffix;
  // TODO do something with --skip-tags nameindex

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _DeployViewModel>(
      converter: (store) {
        return _DeployViewModel(
            state: store.state,
            onDeployProject: (project) {
              context.showLoaderOverlay();
              store.dispatch(DeployProject(
                  project: project,
                  deployServices: _deployServices,
                  limitToServers: _limitToServers,
                  tags: _tags,
                  skipTags: _skipTags,
                  onlyProperties: _onlyProperties,
                  continueEvenIfFails: _continueEvenIfFails,
                  debug: _debug,
                  dryRun: _dryRun,
                  onStart: (cmd, logsPrefix, logsSuffix) {
                    // print("Logs suffix: $l");
                    context.hideLoaderOverlay();
                    TermDialog.show(context, title: "Ansible console",
                        onClose: () async {
                      // Show the results
                      context.showLoaderOverlay();
                      CmdHistoryEntry cmdHistory = CmdHistoryEntry(
                          title:
                              "Deploy of ${_deployServices.join(', ')}${_limitToServers.length > 0 ? ' in ' : ''}${_limitToServers.length > 0 ? _limitToServers.join(',') : ''}",
                          cmd: cmd,
                          logsPrefix: logsPrefix,
                          logsSuffix: logsSuffix);
                      store.dispatch(
                          CmdUtils.getCmdResults(context, cmdHistory, true));
                      // context.hideLoaderOverlay();
                    });
                  },
                  onError: (error) => ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(
                          action: SnackBarAction(
                            label: 'OK',
                            onPressed: () {
                              // Some code to undo the change.
                            },
                          ),
                          content: Text(
                              'Oooopss, some problem have arisen trying to start the deploy: $error')))));
            },
            onCancel: (project) => store.dispatch(OpenProjectTools(project)));
      },
      builder: (BuildContext context, _DeployViewModel vm) {
        String execBtn = "Deploy";
        VoidCallback? onTap = _deployServices.isEmpty
            ? null
            : () => vm.onDeployProject(vm.state.currentProject);
        return Scaffold(
            key: _scaffoldKey,
            appBar: LAAppBar(
                context: context,
                titleIcon: Mdi.rocketLaunch,
                title: "Deployment",
                showLaIcon: false,
                actions: [
                  IconButton(
                      icon: Tooltip(
                          child: const Icon(Icons.close, color: Colors.white),
                          message: "Cancel the deploy"),
                      onPressed: () => vm.onCancel(vm.state.currentProject)),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 20),
                              Text("Select which services you want to deploy:",
                                  style: TextStyle(fontSize: 16)),
                              // TODO: limit to real selected services
                              ServicesChipPanel(
                                  services: vm.state.currentProject
                                      .getServicesNameListSelected(),
                                  onChange: (s) =>
                                      setState(() => _deployServices = s)),
                              HostSelector(
                                  title: "Deploy to servers:",
                                  modalTitle:
                                      "Choose some servers if you want to limit the deploy to them",
                                  emptyPlaceholder: "All servers",
                                  serverList: vm.state.currentProject
                                      .serversWithServices()
                                      .map((e) => e.name)
                                      .toList(),
                                  icon: Mdi.server,
                                  onChange: (limitToServers) => setState(
                                      () => _limitToServers = limitToServers)),
                              TagsSelector(
                                  selectorKey: _selectTagsKey,
                                  tags: TagsConstants.getTagsFor(vm
                                      .state.currentProject.alaInstallRelease),
                                  icon: Mdi.tagPlusOutline,
                                  title: "Tags:",
                                  placeHolder: "All",
                                  modalTitle:
                                      "Select the tags you want to limit to",
                                  onChange: (tags) =>
                                      setState(() => _tags = tags)),
                              TagsSelector(
                                  selectorKey: _skipTagsKey,
                                  tags: TagsConstants.getTagsFor(vm
                                      .state.currentProject.alaInstallRelease),
                                  icon: Mdi.tagOffOutline,
                                  title: "Skip tags:",
                                  placeHolder: "None",
                                  modalTitle:
                                      "Select the tags you want to skip",
                                  onChange: (skipTags) =>
                                      setState(() => _skipTags = skipTags)),
                              TipsCard(
                                  text:
                                      '''Ansible tasks are marked with tags, and then when you run it you can use `--tags` or `--skip-tags` to execute or skip a subset of these tasks.''',
                                  margin: EdgeInsets.zero),
                              ListTile(
                                  title: const Text(
                                    'Only deploy properties (service configurations)',
                                  ),
                                  trailing: Switch(
                                      value: _onlyProperties,
                                      onChanged: (value) => setState(
                                          () => _onlyProperties = value))),
                              ListTile(
                                  title: const Text(
                                    'Advanced options',
                                  ),
                                  trailing: Switch(
                                      value: _advanced,
                                      onChanged: (value) =>
                                          setState(() => _advanced = value))),
                              if (_advanced)
                                ListTile(
                                    title: const Text(
                                      'Show extra debug info',
                                    ),
                                    trailing: Switch(
                                        value: _debug,
                                        onChanged: (value) =>
                                            setState(() => _debug = value))),
                              if (_advanced)
                                ListTile(
                                    title: const Text(
                                      'Continue even if some service deployment fails',
                                    ),
                                    trailing: Switch(
                                        value: _continueEvenIfFails,
                                        onChanged: (value) => setState(() =>
                                            _continueEvenIfFails = value))),
                              if (_advanced)
                                ListTile(
                                    title: const Text(
                                      'Dry run (only show the ansible command)',
                                    ),
                                    trailing: Switch(
                                        value: _dryRun,
                                        onChanged: (value) =>
                                            setState(() => _dryRun = value))),

                              LaunchBtn(onTap: onTap, execBtn: execBtn),
                            ])),
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

class TagsSelector extends StatelessWidget {
  final GlobalKey<S2MultiState<String>> selectorKey;
  final List<String> tags;
  final IconData icon;
  final String title;
  final String placeHolder;
  final String modalTitle;
  final Function(List<String>) onChange;

  TagsSelector(
      {required this.selectorKey,
      required this.tags,
      required this.icon,
      required this.title,
      required this.placeHolder,
      required this.modalTitle,
      required this.onChange});

  @override
  Widget build(BuildContext context) {
    return SmartSelect<String>.multiple(
        key: selectorKey,
        value: [],
        title: title,
        choiceItems: S2Choice.listFrom<String, String>(
            source: tags, value: (index, e) => e, title: (index, e) => e),
        placeholder: placeHolder,
        modalHeader: true,
        modalTitle: modalTitle,
        modalType: S2ModalType.popupDialog,
        choiceType: S2ChoiceType.chips,
        modalConfirm: true,
        modalConfirmBuilder: (context, state) =>
            SelectUtils.modalConfirmBuild(state),
        modalHeaderStyle: S2ModalHeaderStyle(
            backgroundColor: LAColorTheme.laPalette,
            textStyle: TextStyle(color: Colors.white)),
        tileBuilder: (context, state) {
          return S2Tile.fromState(state,
              // padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              leading: Icon(icon),
              dense: false,
              isTwoLine: true,
              trailing: const Icon(Icons.keyboard_arrow_down)
              // isTwoLine: true,
              );
        },
        onChange: (state) {
          onChange(state.value);
        });
  }
}

class _DeployViewModel {
  final AppState state;
  final Function(LAProject) onCancel;
  final Function(LAProject) onDeployProject;

  _DeployViewModel(
      {required this.state,
      required this.onCancel,
      required this.onDeployProject});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _DeployViewModel &&
          runtimeType == other.runtimeType &&
          state == other.state;

  @override
  int get hashCode => state.hashCode;
}

class CmdUtils {
  static AppActions getCmdResults(
      BuildContext context, CmdHistoryEntry cmdHistory, bool fstRetrieved) {
    return GetDeployProjectResults(cmdHistory, fstRetrieved, () {
      context.hideLoaderOverlay();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('There was some problem retrieving the results'),
        duration: Duration(days: 365),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ));
    });
  }
}
