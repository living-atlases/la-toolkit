import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/preDeployCmd.dart';
import 'package:la_toolkit/redux/appActions.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:mdi/mdi.dart';

import 'components/deployBtn.dart';
import 'components/deployTaskSwitch.dart';
import 'components/laAppBar.dart';
import 'components/scrollPanel.dart';
import 'components/serverSelector.dart';
import 'laTheme.dart';
import 'models/deployCmd.dart';
import 'models/laProject.dart';

class PreDeployPage extends StatefulWidget {
  static const routeName = "predeploy";

  @override
  _PreDeployPageState createState() => _PreDeployPageState();
}

class _PreDeployPageState extends State<PreDeployPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      // The switch fails
      // distinct: true,
      converter: (store) {
        return _ViewModel(
            project: store.state.currentProject,
            onCancel: (project) {},
            onSaveDeployCmd: (cmd) {
              store.dispatch(SaveDeployCmd(deployCmd: cmd));
            },
            onDoDeployTaskSwitchs: (project, cmd) =>
                DeployUtils.deployActionDispatch(
                    context: context,
                    store: store,
                    project: project,
                    deployCmd: cmd),
            cmd: store.state.repeatCmd.runtimeType != PreDeployCmd
                ? PreDeployCmd()
                : store.state.repeatCmd as PreDeployCmd);
      },
      builder: (BuildContext context, _ViewModel vm) {
        String execBtn = "Run tasks";
        PreDeployCmd cmd = vm.cmd;
        VoidCallback? onTap = cmd.addAnsibleUser ||
                cmd.giveSudo ||
                cmd.etcHosts ||
                cmd.solrLimits ||
                cmd.addSshKeys ||
                cmd.addAdditionalDeps
            ? () => vm.onDoDeployTaskSwitchs(vm.project, cmd)
            : null;
        String defUser = vm.project.getVariableValue("ansible_user").toString();
        return Title(
            title: "${vm.project.shortName} Pre-Deploy Tasks",
            color: LAColorTheme.laPalette,
            child: Scaffold(
                key: _scaffoldKey,
                appBar: LAAppBar(
                    context: context,
                    titleIcon: Icons.foundation,
                    showBack: true,
                    title: "Pre-Deploy Tasks",
                    showLaIcon: false,
                    actions: []),
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
                              children: [
                                const SizedBox(height: 20),
                                const Text(
                                    'These are tasks that depending on the status of your servers can be helpful to setup them correctly.'),
                                const SizedBox(height: 20),
                                DeployTaskSwitch(
                                    title:
                                        "Add the '$defUser' user to your servers",
                                    initialValue: cmd.addAnsibleUser,
                                    help:
                                        "Before-Start-Your-LA-Installation#default-user-ubuntu",
                                    onChanged: (newValue) {
                                      cmd.addAnsibleUser = newValue;
                                      vm.onSaveDeployCmd(cmd);
                                    }),
                                DeployTaskSwitch(
                                    title:
                                        "Give the 'ubuntu' user sudo permissions",
                                    initialValue: cmd.giveSudo,
                                    help:
                                        "Before-Start-Your-LA-Installation#sudo",
                                    onChanged: (newValue) {
                                      cmd.giveSudo = newValue;
                                      vm.onSaveDeployCmd(cmd);
                                    }),
                                DeployTaskSwitch(
                                    title:
                                        "Add your public ssh keys to '$defUser' user (warning: right now we add all your ssh keys)",
                                    initialValue: cmd.addSshKeys,
                                    help:
                                        "SSH-for-Beginners#public-and-private-ip-addresses",
                                    onChanged: (newValue) {
                                      cmd.addSshKeys = newValue;
                                      vm.onSaveDeployCmd(cmd);
                                    }),
                                DeployTaskSwitch(
                                    title:
                                        "Configure the '/etc/hosts' in your servers",
                                    initialValue: cmd.etcHosts,
                                    help:
                                        "Before-Start-Your-LA-Installation#fake-dns-calls",
                                    onChanged: (newValue) {
                                      cmd.etcHosts = newValue;
                                      vm.onSaveDeployCmd(cmd);
                                    }),
                                DeployTaskSwitch(
                                    title:
                                        "Adjust solr limits (increase the number of files and process allowed to create)",
                                    initialValue: cmd.solrLimits,
                                    help:
                                        "Before-Start-Your-LA-Installation#solr-limits",
                                    onChanged: (newValue) => setState(
                                        () => cmd.solrLimits = newValue)),
                                DeployTaskSwitch(
                                    title:
                                        "Add additional package utils for monitoring and troubleshooting",
                                    initialValue: cmd.addAdditionalDeps,
                                    onChanged: (newValue) {
                                      cmd.addAdditionalDeps = newValue;
                                      vm.onSaveDeployCmd(cmd);
                                    }),
                                DeployTaskSwitch(
                                    title: "Try these tasks as 'root'",
                                    initialValue: cmd.rootBecome,
                                    onChanged: (newValue) {
                                      cmd.rootBecome = newValue;
                                      vm.onSaveDeployCmd(cmd);
                                    }),
                                const SizedBox(height: 20),
                                ServerSelector(
                                    selectorKey: GlobalKey<FormFieldState>(),
                                    title: "Do the pre-deploy in servers:",
                                    modalTitle:
                                        "Choose some servers if you want to limit the pre-deploy to them",
                                    placeHolder: "All servers",
                                    initialValue: cmd.limitToServers,
                                    hosts: vm.project
                                        .serversWithServices()
                                        .map((e) => e.name)
                                        .toList(),
                                    icon: Mdi.server,
                                    onChange: (limitToServers) => setState(() =>
                                        cmd.limitToServers = limitToServers)),
                                const SizedBox(height: 20),
                                LaunchBtn(onTap: onTap, execBtn: execBtn),
                              ],
                            )),
                        Expanded(
                          flex: 1, // 10%
                          child: Container(),
                        )
                      ],
                    ))));
      },
    );
  }
}

class _ViewModel {
  final LAProject project;
  final Function(LAProject, PreDeployCmd) onDoDeployTaskSwitchs;
  final PreDeployCmd cmd;
  final Function(LAProject) onCancel;
  final Function(DeployCmd) onSaveDeployCmd;

  _ViewModel(
      {required this.project,
      required this.onDoDeployTaskSwitchs,
      required this.cmd,
      required this.onSaveDeployCmd,
      required this.onCancel});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ViewModel &&
          runtimeType == other.runtimeType &&
          cmd == other.cmd &&
          project == other.project;

  @override
  int get hashCode => project.hashCode ^ project.hashCode ^ cmd.hashCode;
}
