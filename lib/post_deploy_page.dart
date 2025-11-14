import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:redux/redux.dart';


import 'components/deploy_btn.dart';
import 'components/deploy_task_switch.dart';
import 'components/la_app_bar.dart';
import 'components/scroll_panel.dart';
import 'components/server_selector.dart';
import 'la_theme.dart';
import 'models/appState.dart';
import 'models/deployCmd.dart';
import 'models/laServer.dart';
import 'models/laVariableDesc.dart';
import 'models/la_project.dart';
import 'models/postDeployCmd.dart';
import 'project_tune_page.dart';
import 'redux/app_actions.dart';
import 'utils/utils.dart';

class PostDeployPage extends StatefulWidget {
  const PostDeployPage({super.key});

  static const String routeName = 'postdeploy';

  @override
  State<PostDeployPage> createState() => _PostDeployPageState();
}

class _PostDeployPageState extends State<PostDeployPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      // Fails the switch distinct: true,
      converter: (Store<AppState> store) {
        return _ViewModel(
            project: store.state.currentProject,
            onCancel: (LAProject project) {},
            onSaveDeployCmd: (DeployCmd cmd) {
              store.dispatch(SaveCurrentCmd(cmd: cmd));
            },
            onUpdateProject: (LAProject project) {
              store.dispatch(UpdateProject(project));
            },
            onDoPostDeployTasks: (LAProject project, PostDeployCmd cmd) =>
                DeployUtils.deployActionLaunch(
                    context: context,
                    store: store,
                    project: project,
                    deployCmd: cmd),
            cmd: store.state.repeatCmd.runtimeType != PostDeployCmd
                ? PostDeployCmd()
                : store.state.repeatCmd as PostDeployCmd);
      },
      builder: (BuildContext context, _ViewModel vm) {
        const String execBtn = 'Run tasks';
        final PostDeployCmd cmd = vm.cmd;
        final VoidCallback? onTap = cmd.configurePostfix
            ? () => vm.onDoPostDeployTasks(vm.project, cmd)
            : null;
        final String pageTitle = '${vm.project.shortName} Post-Deploy Tasks';
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
                                /* const SizedBox(height: 20),
                            const Text('Tasks:', style: DeployUtils.titleStyle), */
                                const SizedBox(height: 20),
                                DeployTaskSwitch(
                                    title: 'Configure postfix email service',
                                    initialValue: cmd.configurePostfix,
                                    help: 'Postfix-configuration',
                                    onChanged: (bool newValue) {
                                      cmd.configurePostfix = newValue;
                                      vm.onSaveDeployCmd(cmd);
                                    }),
                                if (cmd.configurePostfix)
                                  const PostDeployFields(),
                                const SizedBox(height: 20),
                                ServerSelector(
                                    selectorKey:
                                        GlobalKey<FormFieldState<dynamic>>(),
                                    title: 'Do the Post-deploy in servers:',
                                    modalTitle:
                                        'Choose some servers if you want to limit the Post-deploy to them',
                                    placeHolder: 'All servers',
                                    initialValue: cmd.limitToServers,
                                    hosts: vm.project
                                        .serversWithServices()
                                        .map((LAServer e) => e.name)
                                        .toList(),
                                    icon: MdiIcons.server,
                                    onChange: (List<String> limitToServers) {
                                      cmd.limitToServers = limitToServers;
                                      vm.onSaveDeployCmd(cmd);
                                    }),
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

class PostDeployFields extends StatelessWidget {
  const PostDeployFields({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _PostDeployFieldsViewModel>(
        converter: (Store<AppState> store) {
      return _PostDeployFieldsViewModel(
          project: store.state.currentProject,
          onUpdateProject: (LAProject project) =>
              store.dispatch(UpdateProject(project)));
    }, builder: (BuildContext context, _PostDeployFieldsViewModel vm) {
      final List<Widget> items = <Widget>[];
      for (final String varName in PostDeployCmd.postDeployVariables) {
        items.add(const SizedBox(height: 20));
        items.add(MessageItem(vm.project, LAVariableDesc.get(varName),
            (Object value) {
          vm.project.setVariable(LAVariableDesc.get(varName), value);
          vm.onUpdateProject(vm.project);
        }).buildTitle(context));
      }
      return Column(children: items);
    });
  }
}

class _PostDeployFieldsViewModel {
  _PostDeployFieldsViewModel(
      {required this.project, required this.onUpdateProject});

  final LAProject project;
  final void Function(LAProject project) onUpdateProject;
}

class _ViewModel {
  _ViewModel(
      {required this.project,
      required this.onDoPostDeployTasks,
      required this.cmd,
      required this.onUpdateProject,
      required this.onSaveDeployCmd,
      required this.onCancel});

  final LAProject project;
  final PostDeployCmd cmd;
  final Function(LAProject, PostDeployCmd) onDoPostDeployTasks;
  final Function(LAProject) onCancel;
  final Function(LAProject) onUpdateProject;
  final Function(DeployCmd) onSaveDeployCmd;

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
