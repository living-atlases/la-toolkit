import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/models/MigrationNotesDesc.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/deployCmd.dart';
import 'package:la_toolkit/models/tagsConstants.dart';
import 'package:la_toolkit/redux/appActions.dart';
import 'package:la_toolkit/routes.dart';
import 'package:la_toolkit/utils/debounce.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'components/alertCard.dart';
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
import 'models/commonCmd.dart';
import 'models/dependencies.dart';
import 'models/laProject.dart';
import 'models/laService.dart';

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
  late List<String> _servicesToDeploy = [];

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _DeployViewModel>(
      converter: (store) {
        if (AppUtils.isDev()) {
          print(store.state.repeatCmd);
        }
        return _DeployViewModel(
            project: store.state.currentProject,
            cmd: store.state.repeatCmd,
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
        late DeployCmd cmd;
        try {
          cmd = vm.cmd as DeployCmd;
        } catch (e) {
          cmd = DeployCmd();
        }
        VoidCallback? onTap = cmd.deployServices.isEmpty
            ? null
            : () => vm.onDeployProject(vm.project, cmd);
        final bool advanced = cmd.advanced ||
            cmd.tags.isNotEmpty ||
            cmd.limitToServers.isNotEmpty ||
            cmd.skipTags.isNotEmpty ||
            cmd.onlyProperties;
        String pageTitle = "${vm.project.shortName} Deployment";
        Map<String, String> selectedVersions = {};
        selectedVersions.addAll(vm.project.getServiceDeployReleases());
        List<MigrationNotesDesc> migrationNotes =
            Dependencies.getMigrationNotes(_servicesToDeploy, selectedVersions);
        return Title(
            title: pageTitle,
            color: LAColorTheme.laPalette,
            child: Scaffold(
                key: _scaffoldKey,
                drawer: const ProjectDrawer(),
                endDrawer: const TermsDrawer(),
                appBar: LAAppBar(
                    context: context,
                    titleIcon: MdiIcons.rocketLaunch,
                    title: pageTitle,
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
                                  const SizedBox(height: 20),
                                  const ListTile(
                                      title: Text(
                                          "Select which services you want to deploy:",
                                          style: TextStyle(fontSize: 16))),
                                  ServicesChipPanel(
                                      initialValue: cmd.deployServices,
                                      services: LAService
                                          .removeServicesDeployedTogether(vm
                                              .project
                                              .getServicesAssignedToServers()),
                                      isHub: vm.project.isHub,
                                      onChange: (s) => setState(() {
                                            cmd.deployServices = s;
                                            _servicesToDeploy = s;
                                          })),
                                  ListTile(
                                      title: const Text(
                                        'Advanced options',
                                      ),
                                      trailing: Switch(
                                          value: advanced,
                                          onChanged: (value) => setState(
                                              () => cmd.advanced = value))),
                                  if (advanced)
                                    ServerSelector(
                                        selectorKey:
                                            GlobalKey<FormFieldState>(),
                                        title: "Deploy to servers:",
                                        modalTitle:
                                            "Choose some servers if you want to limit the deploy to them",
                                        placeHolder: "All servers",
                                        initialValue: cmd.limitToServers,
                                        hosts: vm.project
                                            .serversWithServices()
                                            .map((e) => e.name)
                                            .toList(),
                                        icon: MdiIcons.server,
                                        onChange: (limitToServers) => setState(
                                            () => cmd.limitToServers =
                                                limitToServers)),
                                  if (advanced)
                                    TagsSelector(
                                        initialValue: cmd.tags,
                                        selectorKey:
                                            GlobalKey<FormFieldState>(),
                                        tags: TagsConstants.getTagsFor(
                                            vm.project.alaInstallRelease),
                                        icon: MdiIcons.tagPlusOutline,
                                        title: "Tags:",
                                        placeHolder: "All",
                                        modalTitle:
                                            "Select the tags you want to limit to:",
                                        onChange: (tags) =>
                                            setState(() => cmd.tags = tags)),
                                  if (advanced)
                                    TagsSelector(
                                        initialValue: cmd.skipTags,
                                        selectorKey:
                                            GlobalKey<FormFieldState>(),
                                        tags: TagsConstants.getTagsFor(
                                            vm.project.alaInstallRelease),
                                        icon: MdiIcons.tagOffOutline,
                                        title: "Skip tags:",
                                        placeHolder: "None",
                                        modalTitle:
                                            "Select the tags you want to skip:",
                                        onChange: (skipTags) => setState(
                                            () => cmd.skipTags = skipTags)),
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
                                            onChanged: (value) => setState(() =>
                                                cmd.onlyProperties = value))),
                                  if (advanced) const DefDivider(),
                                  if (advanced)
                                    ListTile(
                                        title: const Text(
                                          'Show extra debug info',
                                        ),
                                        trailing: Switch(
                                            value: cmd.debug,
                                            onChanged: (value) => setState(
                                                () => cmd.debug = value))),
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
                                              onChanged: (value) => setState(
                                                  () => cmd.dryRun = value))),
                                  if (advanced)
                                    TipsCard(
                                        text:
                                            "This project is generated in the '${vm.project.dirName}' directory."),
                                  Column(
                                      children: migrationNotes
                                          .map((m) => AlertCard(
                                              message: m.text,
                                              color: Colors.grey.shade100,
                                              action: () => {launch(m.url)},
                                              actionText: "READ MORE",
                                              icon: Icons.info_outline))
                                          .toList()),
                                  LaunchBtn(onTap: onTap, execBtn: execBtn),
                                ])),
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

class _DeployViewModel {
  final LAProject project;
  final CommonCmd cmd;
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
