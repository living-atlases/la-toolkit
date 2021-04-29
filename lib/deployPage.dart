import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/deployCmd.dart';
import 'package:la_toolkit/models/tagsConstants.dart';
import 'package:la_toolkit/redux/appActions.dart';
import 'package:la_toolkit/routes.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:mdi/mdi.dart';
import 'package:smart_select/smart_select.dart';

import 'components/deployBtn.dart';
import 'components/hostSelector.dart';
import 'components/laAppBar.dart';
import 'components/scrollPanel.dart';
import 'components/servicesChipPanel.dart';
import 'components/tagsSelector.dart';
import 'components/tipsCard.dart';
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
  // TODO do something with --skip-tags nameindex

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _DeployViewModel>(
      converter: (store) {
        return _DeployViewModel(
            project: store.state.currentProject,
            cmd: store.state.repeatCmd,
            onDeployProject: (project, cmd) => DeployUtils.deployActionDispatch(
                context: context,
                store: store,
                project: project,
                deployCmd: cmd),
            onCancel: (project) {
              store.dispatch(OpenProjectTools(project));
              BeamerCond.of(context, LAProjectViewLocation());
            });
      },
      builder: (BuildContext context, _DeployViewModel vm) {
        String execBtn = "Deploy";
        DeployCmd cmd = vm.cmd;
        VoidCallback? onTap = cmd.deployServices.isEmpty
            ? null
            : () => vm.onDeployProject(vm.project, cmd);
        return Scaffold(
            key: _scaffoldKey,
            appBar: LAAppBar(
                context: context,
                titleIcon: Mdi.rocketLaunch,
                title: "Deployment",
                showLaIcon: false,
                showBack: true,
                actions: [
                  IconButton(
                      icon: Tooltip(
                          child: const Icon(Icons.close, color: Colors.white),
                          message: "Cancel the deploy"),
                      onPressed: () => vm.onCancel(vm.project)),
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
                                  initialValue: cmd.deployServices,
                                  services:
                                      vm.project.getServicesNameListSelected(),
                                  onChange: (s) =>
                                      setState(() => cmd.deployServices = s)),
                              HostSelector(
                                  title: "Deploy to servers:",
                                  modalTitle:
                                      "Choose some servers if you want to limit the deploy to them",
                                  emptyPlaceholder: "All servers",
                                  initialValue: cmd.limitToServers,
                                  serverList: vm.project
                                      .serversWithServices()
                                      .map((e) => e.name)
                                      .toList(),
                                  icon: Mdi.server,
                                  onChange: (limitToServers) => setState(() =>
                                      cmd.limitToServers = limitToServers)),
                              TagsSelector(
                                  initialValue: cmd.tags,
                                  selectorKey: GlobalKey<FormFieldState>(),
                                  tags: TagsConstants.getTagsFor(
                                      vm.project.alaInstallRelease),
                                  icon: Mdi.tagPlusOutline,
                                  title: "Tags:",
                                  placeHolder: "All",
                                  modalTitle:
                                      "Select the tags you want to limit to:",
                                  onChange: (tags) =>
                                      setState(() => cmd.tags = tags)),
                              TagsSelector(
                                  initialValue: cmd.skipTags,
                                  selectorKey: GlobalKey<FormFieldState>(),
                                  tags: TagsConstants.getTagsFor(
                                      vm.project.alaInstallRelease),
                                  icon: Mdi.tagOffOutline,
                                  title: "Skip tags:",
                                  placeHolder: "None",
                                  modalTitle:
                                      "Select the tags you want to skip",
                                  onChange: (skipTags) =>
                                      setState(() => cmd.skipTags = skipTags)),
                              TipsCard(
                                  text:
                                      '''Ansible tasks are marked with tags, and then when you run it you can use `--tags` or `--skip-tags` to execute or skip a subset of these tasks.''',
                                  margin: EdgeInsets.zero),
                              ListTile(
                                  title: const Text(
                                    'Only deploy properties (service configurations)',
                                  ),
                                  trailing: Switch(
                                      value: cmd.onlyProperties,
                                      onChanged: (value) => setState(
                                          () => cmd.onlyProperties = value))),
                              ListTile(
                                  title: const Text(
                                    'Advanced options',
                                  ),
                                  trailing: Switch(
                                      value: cmd.advanced,
                                      onChanged: (value) => setState(
                                          () => cmd.advanced = value))),
                              if (cmd.advanced)
                                ListTile(
                                    title: const Text(
                                      'Show extra debug info',
                                    ),
                                    trailing: Switch(
                                        value: cmd.debug,
                                        onChanged: (value) =>
                                            setState(() => cmd.debug = value))),
                              if (cmd.advanced)
                                ListTile(
                                    title: const Text(
                                      'Continue even if some service deployment fails',
                                    ),
                                    trailing: Switch(
                                        value: cmd.continueEvenIfFails,
                                        onChanged: (value) => setState(() =>
                                            cmd.continueEvenIfFails = value))),
                              if (cmd.advanced)
                                ListTile(
                                    title: const Text(
                                      'Dry run (only show the ansible command)',
                                    ),
                                    trailing: Switch(
                                        value: cmd.dryRun,
                                        onChanged: (value) => setState(
                                            () => cmd.dryRun = value))),
                              TipsCard(
                                  text:
                                      "This project is generated in the '${vm.project.dirName}' directory."),
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

class _DeployViewModel {
  final LAProject project;
  final DeployCmd cmd;
  final Function(LAProject) onCancel;
  final Function(LAProject, DeployCmd) onDeployProject;

  _DeployViewModel(
      {required this.project,
      required this.cmd,
      required this.onCancel,
      required this.onDeployProject});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _DeployViewModel &&
          runtimeType == other.runtimeType &&
          project == other.project &&
          cmd == other.cmd;

  @override
  int get hashCode => project.hashCode ^ cmd.hashCode;
}
