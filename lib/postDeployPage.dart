import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/projectTunePage.dart';
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
import 'models/laVariableDesc.dart';
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
      // Fails the switch distinct: true,
      converter: (store) {
        return _ViewModel(
            project: store.state.currentProject,
            onCancel: (project) {},
            onSaveDeployCmd: (cmd) {
              store.dispatch(SaveDeployCmd(deployCmd: cmd));
            },
            onUpdateProject: (project) {
              store.dispatch(UpdateProject(project));
            },
            onDoPostDeployTasks: (project, cmd) =>
                DeployUtils.deployActionDispatch(
                    context: context,
                    store: store,
                    project: project,
                    deployCmd: cmd),
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
        return Title(
            title: "${vm.project.shortName} Post-Deploy Tasks",
            color: LAColorTheme.laPalette,
            child: Scaffold(
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
                                DeployTaskSwitch(
                                    title: "Configure postfix email service",
                                    initialValue: cmd.configurePostfix,
                                    help: "Postfix-configuration",
                                    onChanged: (newValue) {
                                      cmd.configurePostfix = newValue;
                                      vm.onSaveDeployCmd(cmd);
                                    }),
                                if (cmd.configurePostfix) PostDeployFields(),
                                const SizedBox(height: 20),
                                ServerSelector(
                                    selectorKey: GlobalKey<FormFieldState>(),
                                    title: "Do the Post-deploy in servers:",
                                    modalTitle:
                                        "Choose some servers if you want to limit the Post-deploy to them",
                                    placeHolder: "All servers",
                                    initialValue: cmd.limitToServers,
                                    hosts: vm.project
                                        .serversWithServices()
                                        .map((e) => e.name)
                                        .toList(),
                                    icon: Mdi.server,
                                    onChange: (limitToServers) {
                                      cmd.limitToServers = limitToServers;
                                      vm.onSaveDeployCmd(cmd);
                                    }),
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

class PostDeployFields extends StatelessWidget {
  PostDeployFields({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _PostDeployFieldsViewModel>(
        converter: (store) {
      return _PostDeployFieldsViewModel(
          project: store.state.currentProject,
          onUpdateProject: (project) => store.dispatch(UpdateProject(project)));
    }, builder: (BuildContext context, _PostDeployFieldsViewModel vm) {
      List<Widget> items = [];
      PostDeployCmd.postDeployVariables.forEach((varName) {
        items.add(const SizedBox(height: 20));
        items.add(MessageItem(vm.project, LAVariableDesc.get(varName), (value) {
          vm.project.setVariable(LAVariableDesc.get(varName), value);
          vm.onUpdateProject(vm.project);
        }).buildTitle(context));
      });
      return Column(children: items);
    });
  }
}

class _PostDeployFieldsViewModel {
  final LAProject project;
  final void Function(LAProject project) onUpdateProject;

  _PostDeployFieldsViewModel(
      {required this.project, required this.onUpdateProject});
}

class _ViewModel {
  final LAProject project;
  final PostDeployCmd cmd;
  final Function(LAProject, PostDeployCmd) onDoPostDeployTasks;
  final Function(LAProject) onCancel;
  final Function(LAProject) onUpdateProject;
  final Function(DeployCmd) onSaveDeployCmd;

  _ViewModel(
      {required this.project,
      required this.onDoPostDeployTasks,
      required this.cmd,
      required this.onUpdateProject,
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
