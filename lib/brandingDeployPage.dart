import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/brandingDeployCmd.dart';
import 'package:la_toolkit/redux/appActions.dart';
import 'package:la_toolkit/utils/utils.dart';

import 'components/deployBtn.dart';
import 'components/laAppBar.dart';
import 'components/scrollPanel.dart';
import 'laTheme.dart';
import 'models/deployCmd.dart';
import 'models/laProject.dart';

class BrandingDeployPage extends StatefulWidget {
  static const routeName = "branding-deploy";

  const BrandingDeployPage({Key? key}) : super(key: key);

  @override
  _BrandingDeployPageState createState() => _BrandingDeployPageState();
}

class _BrandingDeployPageState extends State<BrandingDeployPage> {
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
        String execBtn = "Deploy branding";
        BrandingDeployCmd cmd = vm.cmd;
        VoidCallback? onTap() => vm.onDoDeployTaskSwitchs(vm.project, cmd);

        var title2 = "Branding Deploy of ${vm.project.shortName} ";
        return Title(
            title: title2,
            color: LAColorTheme.laPalette,
            child: Scaffold(
                key: _scaffoldKey,
                appBar: LAAppBar(
                    context: context,
                    titleIcon: Icons.format_paint,
                    showBack: true,
                    title: title2,
                    showLaIcon: false,
                    actions: const []),
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
                                    'This task will build and deploy your branding.'),
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
  final Function(LAProject, BrandingDeployCmd) onDoDeployTaskSwitchs;
  final BrandingDeployCmd cmd;
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
