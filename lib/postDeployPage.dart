import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/helpIcon.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:mdi/mdi.dart';

import 'components/deployBtn.dart';
import 'components/hostSelector.dart';
import 'components/laAppBar.dart';
import 'components/scrollPanel.dart';
import 'laTheme.dart';
import 'models/laProject.dart';
import 'models/postDeployCmd.dart';

class PostDeployPage extends StatefulWidget {
  static const routeName = "postdeploy";

  @override
  _PostDeployPageState createState() => _PostDeployPageState();
}

class _PostDeployPageState extends State<PostDeployPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      distinct: true,
      converter: (store) {
        return _ViewModel(
            project: store.state.currentProject,
            onCancel: (project) {},
            onDoPostDeployTasks: (project, cmd) =>
                DeployUtils.deployActionDispatch(
                    context: context, store: store, project: project, cmd: cmd),
            cmd: store.state.repeatCmd.runtimeType != PostDeployCmd
                ? PostDeployCmd()
                : store.state.repeatCmd as PostDeployCmd);
      },
      builder: (BuildContext context, _ViewModel vm) {
        String execBtn = "Run tasks";
        PostDeployCmd cmd = vm.cmd;
        VoidCallback? onTap = cmd.configurePostfix
            ? () => vm.onDoPostDeployTasks(vm.project, cmd)
            : null;

        return Scaffold(
            key: _scaffoldKey,
            appBar: LAAppBar(
                context: context,
                titleIcon: Icons.foundation,
                showBack: true,
                title: "Post-Deploy Tasks",
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
                            PostDeployTask(
                                title: "Configure postfix email service",
                                initialValue: cmd.configurePostfix,
                                help: "Postfix-configuration",
                                onChanged: (newValue) => setState(
                                    () => cmd.configurePostfix = newValue)),
                            const SizedBox(height: 20),
                            HostSelector(
                                title: "Do the Post-deploy in servers:",
                                modalTitle:
                                    "Choose some servers if you want to limit the Post-deploy to them",
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

class PostDeployTask extends StatelessWidget {
  final String title;
  final String? help;
  final bool initialValue;
  final Function(bool) onChanged;
  const PostDeployTask({
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
  final Function(LAProject, PostDeployCmd) onDoPostDeployTasks;
  final PostDeployCmd cmd;
  final Function(LAProject) onCancel;

  _ViewModel(
      {required this.project,
      required this.onDoPostDeployTasks,
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
