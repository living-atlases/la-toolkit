import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/helpIcon.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/preDeployCmd.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:mdi/mdi.dart';

import 'components/deployBtn.dart';
import 'components/hostSelector.dart';
import 'components/laAppBar.dart';
import 'components/scrollPanel.dart';
import 'laTheme.dart';
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
      distinct: true,
      converter: (store) {
        return _ViewModel(
            project: store.state.currentProject,
            onCancel: (project) {},
            onDoPreDeployTasks: (project, cmd) =>
                DeployUtils.deployActionDispatch(
                    context: context, store: store, project: project, cmd: cmd),
            cmd: store.state.repeatCmd.runtimeType != PreDeployCmd
                ? PreDeployCmd()
                : store.state.repeatCmd as PreDeployCmd);
      },
      builder: (BuildContext context, _ViewModel vm) {
        String execBtn = "Run tasks";
        PreDeployCmd cmd = vm.cmd;
        VoidCallback? onTap =
            cmd.addUbuntuUser || cmd.giveSudo || cmd.etcHost || cmd.solrLimits
                ? () => vm.onDoPreDeployTasks(vm.project, cmd)
                : null;
        String defUser = vm.project.getVariableValue("ansible_user").toString();

        return Scaffold(
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
                            /* const SizedBox(height: 20),
                            const Text('Tasks:', style: DeployUtils.titleStyle), */
                            const SizedBox(height: 20),
                            PreDeployTask(
                                title:
                                    "Add the '$defUser' user to your servers",
                                initialValue: cmd.addUbuntuUser,
                                help:
                                    "Before-Start-Your-LA-Installation#default-user-ubuntu",
                                onChanged: (newValue) => setState(
                                    () => cmd.addUbuntuUser = newValue)),
                            PreDeployTask(
                                title:
                                    "Give the 'ubuntu' user sudo permissions",
                                initialValue: cmd.giveSudo,
                                help: "Before-Start-Your-LA-Installation#sudo",
                                onChanged: (newValue) =>
                                    setState(() => cmd.giveSudo = newValue)),
                            PreDeployTask(
                                title:
                                    "Configure the '/etc/hosts' in your servers",
                                initialValue: cmd.etcHost,
                                help:
                                    "Before-Start-Your-LA-Installation#fake-dns-calls",
                                onChanged: (newValue) =>
                                    setState(() => cmd.etcHost = newValue)),
                            PreDeployTask(
                                title:
                                    "Adjust solr limits (increase the number of files and process allowed to create)",
                                initialValue: cmd.solrLimits,
                                help:
                                    "Before-Start-Your-LA-Installation#solr-limits",
                                onChanged: (newValue) =>
                                    setState(() => cmd.solrLimits = newValue)),
                            const SizedBox(height: 20),
                            HostSelector(
                                title: "Do the pre-deploy in servers:",
                                modalTitle:
                                    "Choose some servers if you want to limit the pre-deploy to them",
                                emptyPlaceholder: "All servers",
                                initialValue: cmd.limitToServers,
                                serverList: vm.project
                                    .serversWithServices()
                                    .map((e) => e.name)
                                    .toList(),
                                icon: Mdi.server,
                                onChange: (limitToServers) => setState(
                                    () => cmd.limitToServers = limitToServers)),
                            const SizedBox(height: 20),
                            LaunchBtn(onTap: onTap, execBtn: execBtn),
                          ],
                        )),
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

class PreDeployTask extends StatelessWidget {
  final String title;
  final String? help;
  final bool initialValue;
  final Function(bool) onChanged;
  const PreDeployTask({
    Key? key,
    required this.title,
    this.help,
    required this.initialValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
        // contentPadding: EdgeInsets.zero,
        value: initialValue,
        title: Text(this.title,
            style: TextStyle(color: LAColorTheme.laThemeData.hintColor)),
        secondary: help != null ? HelpIcon(wikipage: help!) : null,
        onChanged: (bool newValue) {
          onChanged(newValue);
        });
  }
}

class _ViewModel {
  final LAProject project;
  final Function(LAProject, PreDeployCmd) onDoPreDeployTasks;
  final PreDeployCmd cmd;
  final Function(LAProject) onCancel;

  _ViewModel(
      {required this.project,
      required this.onDoPreDeployTasks,
      required this.cmd,
      required this.onCancel});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ViewModel &&
          runtimeType == other.runtimeType &&
          project == other.project;

  @override
  int get hashCode => project.hashCode;
}
