import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:redux/redux.dart';

import './models/app_state.dart';
import 'components/deploy_btn.dart';
import 'components/deploy_task_switch.dart';
import 'components/la_app_bar.dart';
import 'components/scroll_panel.dart';
import 'components/server_selector.dart';
import 'la_theme.dart';
import 'models/deploy_cmd.dart';
import 'models/la_project.dart';
import 'models/la_server.dart';
import 'models/pre_deploy_cmd.dart';
import 'redux/app_actions.dart';
import 'utils/utils.dart';

class PreDeployPage extends StatefulWidget {
  const PreDeployPage({super.key});

  static const String routeName = 'predeploy';

  @override
  State<PreDeployPage> createState() => _PreDeployPageState();
}

class _PreDeployPageState extends State<PreDeployPage> {
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
            onSaveDeployCmd: (DeployCmd cmd) {
              store.dispatch(SaveCurrentCmd(cmd: cmd));
            },
            onDoDeployTaskSwitchs: (LAProject project, PreDeployCmd cmd) =>
                DeployUtils.deployActionLaunch(
                    context: context,
                    store: store,
                    project: project,
                    deployCmd: cmd),
            cmd: store.state.repeatCmd.runtimeType != PreDeployCmd
                ? PreDeployCmd()
                : store.state.repeatCmd as PreDeployCmd);
      },
      builder: (BuildContext context, _ViewModel vm) {
        const String execBtn = 'Run tasks';
        final PreDeployCmd cmd = vm.cmd;
        final VoidCallback? onTap = cmd.addAnsibleUser ||
                cmd.giveSudo ||
                cmd.etcHosts ||
                cmd.solrLimits ||
                cmd.addSshKeys ||
                cmd.addAdditionalDeps
            ? () => vm.onDoDeployTaskSwitchs(vm.project, cmd)
            : null;
        final String defUser =
            vm.project.getVariableValue('ansible_user').toString();
        final String pageTitle = '${vm.project.shortName} Pre-Deploy Tasks';
        return Title(
            title: pageTitle,
            color: LAColorTheme.laPalette,
            child: Scaffold(
                key: _scaffoldKey,
                appBar: LAAppBar(
                    context: context,
                    titleIcon: Icons.foundation,
                    showBack: true,
                    title: pageTitle,
                    actions: const <Widget>[]),
                body: ScrollPanel(
                    withPadding: true,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(),
                        ),
                        Expanded(
                            flex: 8, // 80%,
                            child: Column(
                              children: <Widget>[
                                const SizedBox(height: 20),
                                const Text(
                                    'These are tasks that depending on the status of your servers can be helpful to setup them correctly.'),
                                const SizedBox(height: 20),
                                DeployTaskSwitch(
                                    title:
                                        "Add the '$defUser' user to your servers",
                                    initialValue: cmd.addAnsibleUser,
                                    help:
                                        'Before-Start-Your-LA-Installation#default-user-ubuntu',
                                    onChanged: (bool newValue) {
                                      cmd.addAnsibleUser = newValue;
                                      vm.onSaveDeployCmd(cmd);
                                    }),
                                DeployTaskSwitch(
                                    title:
                                        "Give the 'ubuntu' user sudo permissions",
                                    initialValue: cmd.giveSudo,
                                    help:
                                        'Before-Start-Your-LA-Installation#sudo',
                                    onChanged: (bool newValue) {
                                      cmd.giveSudo = newValue;
                                      vm.onSaveDeployCmd(cmd);
                                    }),
                                DeployTaskSwitch(
                                    title:
                                        "Add your public ssh keys to '$defUser' user (warning: right now we add all your ssh keys)",
                                    initialValue: cmd.addSshKeys,
                                    help:
                                        'SSH-for-Beginners#public-and-private-ip-addresses',
                                    onChanged: (bool newValue) {
                                      cmd.addSshKeys = newValue;
                                      vm.onSaveDeployCmd(cmd);
                                    }),
                                DeployTaskSwitch(
                                    title:
                                        "Configure the '/etc/hosts' in your servers",
                                    initialValue: cmd.etcHosts,
                                    help:
                                        'Before-Start-Your-LA-Installation#fake-dns-calls',
                                    onChanged: (bool newValue) {
                                      cmd.etcHosts = newValue;
                                      vm.onSaveDeployCmd(cmd);
                                    }),
                                if (!vm.project.isHub)
                                  DeployTaskSwitch(
                                      title:
                                          'Adjust solr limits (increase the number of files and process allowed to create)',
                                      initialValue: cmd.solrLimits,
                                      help:
                                          'Before-Start-Your-LA-Installation#solr-limits',
                                      onChanged: (bool newValue) => setState(
                                          () => cmd.solrLimits = newValue)),
                                DeployTaskSwitch(
                                    title:
                                        'Add additional package utils for monitoring and troubleshooting',
                                    initialValue: cmd.addAdditionalDeps,
                                    onChanged: (bool newValue) {
                                      cmd.addAdditionalDeps = newValue;
                                      vm.onSaveDeployCmd(cmd);
                                    }),
                                DeployTaskSwitch(
                                    title: "Try these tasks as 'root'",
                                    initialValue: cmd.rootBecome,
                                    onChanged: (bool newValue) {
                                      cmd.rootBecome = newValue;
                                      vm.onSaveDeployCmd(cmd);
                                    }),
                                const SizedBox(height: 20),
                                ServerSelector(
                                    selectorKey:
                                        GlobalKey<FormFieldState<dynamic>>(),
                                    title: 'Do the pre-deploy in servers:',
                                    modalTitle:
                                        'Choose some servers if you want to limit the pre-deploy to them',
                                    placeHolder: 'All servers',
                                    initialValue: cmd.limitToServers,
                                    hosts: vm.project
                                        .serversWithServices()
                                        .map((LAServer e) => e.name)
                                        .toList(),
                                    icon: MdiIcons.server,
                                    onChange: (List<String> limitToServers) =>
                                        setState(() => cmd.limitToServers =
                                            limitToServers)),
                                const SizedBox(height: 20),
                                LaunchBtn(onTap: onTap, execBtn: execBtn),
                              ],
                            )),
                        Expanded(
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
      required this.onDoDeployTaskSwitchs,
      required this.cmd,
      required this.onSaveDeployCmd,
      required this.onCancel});

  final LAProject project;
  final Function(LAProject, PreDeployCmd) onDoDeployTaskSwitchs;
  final PreDeployCmd cmd;
  final Function(LAProject) onCancel;
  final Function(DeployCmd) onSaveDeployCmd;
}
