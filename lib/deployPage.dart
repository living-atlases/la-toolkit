import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/deployCmd.dart';
import 'package:la_toolkit/models/tagsConstants.dart';
import 'package:la_toolkit/redux/appActions.dart';
import 'package:la_toolkit/routes.dart';
import 'package:la_toolkit/utils/debounce.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:mdi/mdi.dart';

import 'components/defDivider.dart';
import 'components/deployBtn.dart';
import 'components/laAppBar.dart';
import 'components/projectDrawer.dart';
import 'components/scrollPanel.dart';
import 'components/serverSelector.dart';
import 'components/servicesChipPanel.dart';
import 'components/tagsSelector.dart';
import 'components/termsDrawer.dart';
import 'components/tipsCard.dart';
import 'laTheme.dart';
import 'models/laProject.dart';

class DeployPage extends StatefulWidget {
  static const routeName = "deploy";

  const DeployPage({Key? key}) : super(key: key);

  @override
  _DeployPageState createState() => _DeployPageState();
}

class _DeployPageState extends State<DeployPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // TODO do something with --skip-tags nameindex
  final debouncer = Debouncer(milliseconds: 300);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _DeployViewModel>(
      converter: (store) {
        return _DeployViewModel(
            project: store.state.currentProject,
            cmd: store.state.repeatCmd as DeployCmd,
            onDeployProject: (project, cmd) => DeployUtils.deployActionLaunch(
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
        final bool advanced = cmd.advanced ||
            cmd.tags.isNotEmpty ||
            cmd.limitToServers.isNotEmpty ||
            cmd.skipTags.isNotEmpty ||
            cmd.onlyProperties;
        return Title(
            title: "${vm.project.shortName} Deployment",
            color: LAColorTheme.laPalette,
            child: Scaffold(
                key: _scaffoldKey,
                drawer: const ProjectDrawer(),
                endDrawer: const TermsDrawer(),
                appBar: LAAppBar(
                    context: context,
                    titleIcon: Mdi.rocketLaunch,
                    title: "Deployment",
                    showLaIcon: false,
                    showBack: true,
                    leading: ProjectDrawer.appBarIcon(vm.project, _scaffoldKey),
                    actions: [
                      TermsDrawer.appBarIcon(vm.project, _scaffoldKey),
                      IconButton(
                          icon: const Tooltip(
                              child: Icon(Icons.close, color: Colors.white),
                              message: "Cancel the deploy"),
                          onPressed: () => vm.onCancel(vm.project)),
                    ]),
                body: NotificationListener(
                    onNotification:
                        (SizeChangedLayoutNotification notification) {
                      debouncer.run(() {
                        setState(() {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              duration: Duration(seconds: 5),
                              content: Text(
                                  "Resizing this window will break the ansible terminal. Please do not resize this window during deploying until we found a fix.")));
                        });
                      });
                      return true;
                    },
                    child: SizeChangedLayoutNotifier(
                        child: ScrollPanel(
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 20),
                                          const ListTile(
                                              title: Text(
                                                  "Select which services you want to deploy:",
                                                  style:
                                                      TextStyle(fontSize: 16))),
                                          ServicesChipPanel(
                                              initialValue: cmd.deployServices,
                                              services: vm.project
                                                  .getServicesAssignedToServers(),
                                              onChange: (s) => setState(() =>
                                                  cmd.deployServices = s)),
                                          ListTile(
                                              title: const Text(
                                                'Advanced options',
                                              ),
                                              trailing: Switch(
                                                  value: advanced,
                                                  onChanged: (value) =>
                                                      setState(() => cmd
                                                          .advanced = value))),
                                          if (advanced)
                                            ServerSelector(
                                                selectorKey:
                                                    GlobalKey<FormFieldState>(),
                                                title: "Deploy to servers:",
                                                modalTitle:
                                                    "Choose some servers if you want to limit the deploy to them",
                                                placeHolder: "All servers",
                                                initialValue:
                                                    cmd.limitToServers,
                                                hosts: vm.project
                                                    .serversWithServices()
                                                    .map((e) => e.name)
                                                    .toList(),
                                                icon: Mdi.server,
                                                onChange: (limitToServers) =>
                                                    setState(() =>
                                                        cmd.limitToServers =
                                                            limitToServers)),
                                          if (advanced)
                                            TagsSelector(
                                                initialValue: cmd.tags,
                                                selectorKey:
                                                    GlobalKey<FormFieldState>(),
                                                tags: TagsConstants.getTagsFor(
                                                    vm.project
                                                        .alaInstallRelease),
                                                icon: Mdi.tagPlusOutline,
                                                title: "Tags:",
                                                placeHolder: "All",
                                                modalTitle:
                                                    "Select the tags you want to limit to:",
                                                onChange: (tags) => setState(
                                                    () => cmd.tags = tags)),
                                          if (advanced)
                                            TagsSelector(
                                                initialValue: cmd.skipTags,
                                                selectorKey:
                                                    GlobalKey<FormFieldState>(),
                                                tags: TagsConstants.getTagsFor(
                                                    vm.project
                                                        .alaInstallRelease),
                                                icon: Mdi.tagOffOutline,
                                                title: "Skip tags:",
                                                placeHolder: "None",
                                                modalTitle:
                                                    "Select the tags you want to skip:",
                                                onChange: (skipTags) =>
                                                    setState(() => cmd
                                                        .skipTags = skipTags)),
                                          if (advanced)
                                            const TipsCard(
                                                text:
                                                    '''Ansible tasks are marked with tags, and then when you run it you can use `--tags` or `--skip-tags` to execute or skip a subset of these tasks.''',
                                                margin: EdgeInsets.zero),
                                          if (advanced)
                                            ListTile(
                                                title: const Text(
                                                  'Only deploy properties (service configurations)',
                                                ),
                                                trailing: Switch(
                                                    value: cmd.onlyProperties,
                                                    onChanged: (value) =>
                                                        setState(() =>
                                                            cmd.onlyProperties =
                                                                value))),
                                          if (advanced) const DefDivider(),
                                          if (advanced)
                                            ListTile(
                                                title: const Text(
                                                  'Show extra debug info',
                                                ),
                                                trailing: Switch(
                                                    value: cmd.debug,
                                                    onChanged: (value) =>
                                                        setState(() => cmd
                                                            .debug = value))),
                                          if (advanced)
                                            /*  Not necessary now
                              ListTile(
                                    title: const Text(
                                      'Continue even if some service deployment fails',
                                    ),
                                    trailing: Switch(
                                        value: cmd.continueEvenIfFails,
                                        onChanged: (value) => setState(() =>
                                            cmd.continueEvenIfFails = value))), */
                                            if (advanced)
                                              ListTile(
                                                  title: const Text(
                                                    'Dry run (only show the ansible command)',
                                                  ),
                                                  trailing: Switch(
                                                      value: cmd.dryRun,
                                                      onChanged: (value) =>
                                                          setState(() =>
                                                              cmd.dryRun =
                                                                  value))),
                                          if (advanced)
                                            TipsCard(
                                                text:
                                                    "This project is generated in the '${vm.project.dirName}' directory."),
                                          LaunchBtn(
                                              onTap: onTap, execBtn: execBtn),
                                        ])),
                                Expanded(
                                  flex: 1, // 10%
                                  child: Container(),
                                )
                              ],
                            ))))));
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
