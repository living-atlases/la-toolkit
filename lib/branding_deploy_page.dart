import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'components/deployBtn.dart';
import 'components/laAppBar.dart';
import 'components/scrollPanel.dart';
import 'components/tipsCard.dart';
import 'laTheme.dart';
import 'models/appState.dart';
import 'models/brandingDeployCmd.dart';
import 'models/deployCmd.dart';
import 'models/la_project.dart';
import 'redux/app_actions.dart';
import 'utils/utils.dart';

class BrandingDeployPage extends StatefulWidget {
  const BrandingDeployPage({super.key});

  static const String routeName = 'branding-deploy';

  @override
  State<BrandingDeployPage> createState() => _BrandingDeployPageState();
}

class _BrandingDeployPageState extends State<BrandingDeployPage> {
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
            onDoDeployTaskSwitchs: (LAProject project, BrandingDeployCmd cmd) =>
                DeployUtils.brandingDeployActionLaunch(
                    context: context,
                    store: store,
                    project: project,
                    deployCmd: cmd),
            cmd: store.state.repeatCmd.runtimeType != BrandingDeployCmd
                ? BrandingDeployCmd()
                : store.state.repeatCmd as BrandingDeployCmd);
      },
      builder: (BuildContext context, _ViewModel vm) {
        const String execBtn = 'Deploy branding';
        final BrandingDeployCmd cmd = vm.cmd;
        dynamic onTap() => vm.onDoDeployTaskSwitchs(vm.project, cmd);
        final String pageTitle = 'Branding Deploy of ${vm.project.shortName} ';
        return Title(
            title: pageTitle,
            color: LAColorTheme.laPalette,
            child: Scaffold(
                key: _scaffoldKey,
                appBar: LAAppBar(
                    context: context,
                    titleIcon: Icons.format_paint,
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
                                    'This task will build and deploy your branding.'),
                                const SizedBox(height: 10),
                                LaunchBtn(onTap: onTap, execBtn: execBtn),
                                const SizedBox(height: 10),
                                const TipsCard(text: '''
This branding is based in the [base-branding](https://github.com/living-atlases/base-branding/) repository, a recommended way to develop a LA theme compatible with the LA software.

Anyway this is only a start, you’ll need some [development environment](https://github.com/living-atlases/base-branding/#development) to customize and tune this branding for your portal needs. Take also into account [this issue](https://github.com/living-atlases/la-toolkit/issues/6) and the workaround: to deploy the branding outside of this la-toolkit docker container.

Also take into account that under the `Deploy` tool you can run the `branding` step to deploy the nginx vhost that finally serves your branding in your server. 
                                '''),
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
  final Function(LAProject, BrandingDeployCmd) onDoDeployTaskSwitchs;
  final BrandingDeployCmd cmd;
  final Function(LAProject) onCancel;
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
