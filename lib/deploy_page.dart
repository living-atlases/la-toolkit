import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:redux/redux.dart';
import 'package:url_launcher/url_launcher.dart';

import 'components/alertCard.dart';
import 'components/defDivider.dart';
import 'components/deployBtn.dart';
import 'components/laAppBar.dart';
import 'components/project_drawer.dart';
import 'components/scrollPanel.dart';
import 'components/serverSelector.dart';
import 'components/services_chip_panel.dart';
import 'components/tagsSelector.dart';
import 'components/terms_drawer.dart';
import 'components/tipsCard.dart';
import 'dependencies_manager.dart';
import 'laTheme.dart';
import 'models/MigrationNotesDesc.dart';
import 'models/appState.dart';
import 'models/commonCmd.dart';
import 'models/deployCmd.dart';
import 'models/laServer.dart';
import 'models/la_project.dart';
import 'models/la_service.dart';
import 'models/tagsConstants.dart';
import 'redux/app_actions.dart';
import 'routes.dart';
import 'utils/debounce.dart';
import 'utils/utils.dart';

class DeployPage extends StatefulWidget {
  const DeployPage({super.key});

  static const String routeName = 'deploy';

  @override
  State<DeployPage> createState() => _DeployPageState();
}

class _DeployPageState extends State<DeployPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final Debouncer debouncer = Debouncer(milliseconds: 300);
  late List<String> _servicesToDeploy = <String>[];

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _DeployViewModel>(
      converter: (Store<AppState> store) {
        if (AppUtils.isDev()) {
          log(store.state.repeatCmd.toString());
        }
        return _DeployViewModel(
            project: store.state.currentProject,
            cmd: store.state.repeatCmd,
            onDeployProject: (LAProject project, DeployCmd cmd) =>
                DeployUtils.deployActionLaunch(
                    context: context,
                    store: store,
                    project: project,
                    deployCmd: cmd),
            onCancel: (LAProject project) {
              store.dispatch(OpenProjectTools(project));
              BeamerCond.of(context, LAProjectViewLocation());
            });
      },
      builder: (BuildContext context, _DeployViewModel vm) {
        const String execBtn = 'Deploy';
        late DeployCmd cmd;
        try {
          cmd = vm.cmd as DeployCmd;
        } catch (e) {
          cmd = DeployCmd();
        }
        final VoidCallback? onTap = cmd.deployServices.isEmpty
            ? null
            : () => vm.onDeployProject(vm.project, cmd);
        final bool advanced = cmd.advanced ||
            cmd.tags.isNotEmpty ||
            cmd.limitToServers.isNotEmpty ||
            cmd.skipTags.isNotEmpty ||
            cmd.onlyProperties;
        final String pageTitle = '${vm.project.shortName} Deployment';
        final Map<String, String> selectedVersions = <String, String>{};
        final List<String> dockerServers = vm.project.dockerServers();
        final bool onlyDocker = vm.project.isDockerClusterConfigured() &&
            const ListEquality<String>()
                .equals(cmd.limitToServers, dockerServers);
        selectedVersions
            .addAll(vm.project.getServiceDeployReleases(onlyDocker));
        final List<MigrationNotesDesc> migrationNotes =
            DependenciesManager.getMigrationNotes(
                _servicesToDeploy, selectedVersions);

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
                    // showLaIcon: false,
                    showBack: true,
                    leading: ProjectDrawer.appBarIcon(vm.project, _scaffoldKey),
                    actions: <Widget>[
                      TermsDrawer.appBarIcon(vm.project, _scaffoldKey),
                      IconButton(
                          icon: const Tooltip(
                              message: 'Cancel the deploy',
                              child: Icon(Icons.close, color: Colors.white)),
                          onPressed: () => vm.onCancel(vm.project)),
                    ]),
                body: ScrollPanel(
                    withPadding: true,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          // flex: 1, // 10%
                          child: Container(),
                        ),
                        Expanded(
                            flex: 8, // 80%,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  const SizedBox(height: 20),
                                  const ListTile(
                                      title: Text(
                                          'Select which services you want to deploy:',
                                          style: TextStyle(fontSize: 16))),
                                  ServicesChipPanel(
                                      initialValue: cmd.deployServices,
                                      services: LAService
                                          .removeServicesDeployedTogether(vm
                                              .project
                                              .getServicesAssigned(onlyDocker)),
                                      isHub: vm.project.isHub,
                                      onChange: (List<String> s) =>
                                          setState(() {
                                            cmd.deployServices = s;
                                            _servicesToDeploy = s;
                                          })),
                                  if (vm.project.isDockerClusterConfigured())
                                    ListTile(
                                        title: const Text(
                                          'Only deploy to docker cluster',
                                        ),
                                        trailing: Switch(
                                            value: onlyDocker,
                                            onChanged: (bool value) =>
                                                setState(() {
                                                  if (value) {
                                                    cmd.limitToServers =
                                                        dockerServers;
                                                  } else {
                                                    cmd.limitToServers
                                                        .removeWhere(
                                                            (String s) =>
                                                                dockerServers
                                                                    .contains(
                                                                        s));
                                                  }
                                                }))),
                                  ListTile(
                                      title: const Text(
                                        'Advanced options',
                                      ),
                                      trailing: Switch(
                                          value: advanced,
                                          // This does not work after hot reload
                                          // during development, so exit and enter
                                          // again in deploy
                                          onChanged: (bool value) => setState(
                                              () => cmd.advanced = value))),
                                  if (advanced)
                                    ServerSelector(
                                        selectorKey: GlobalKey<
                                            FormFieldState<dynamic>>(),
                                        title: 'Deploy to servers:',
                                        modalTitle:
                                            'Choose some servers if you want to limit the deploy to them',
                                        placeHolder: 'All servers',
                                        initialValue: cmd.limitToServers,
                                        hosts: vm.project
                                            .serversWithServices()
                                            .map((LAServer e) => e.name)
                                            .toList(),
                                        icon: MdiIcons.server,
                                        onChange:
                                            (List<String> limitToServers) =>
                                                setState(() =>
                                                    cmd.limitToServers =
                                                        limitToServers)),
                                  if (advanced)
                                    TagsSelector(
                                        initialValue: cmd.tags,
                                        selectorKey: GlobalKey<
                                            FormFieldState<dynamic>>(),
                                        tags: TagsConstants.getTagsFor(
                                            vm.project.alaInstallRelease),
                                        icon: MdiIcons.tagPlusOutline,
                                        title: 'Tags:',
                                        placeHolder: 'All',
                                        modalTitle:
                                            'Select the tags you want to limit to:',
                                        onChange: (List<String> tags) =>
                                            setState(() => cmd.tags = tags)),
                                  if (advanced)
                                    TagsSelector(
                                        initialValue: cmd.skipTags,
                                        selectorKey: GlobalKey<
                                            FormFieldState<dynamic>>(),
                                        tags: TagsConstants.getTagsFor(
                                            vm.project.alaInstallRelease),
                                        icon: MdiIcons.tagOffOutline,
                                        title: 'Skip tags:',
                                        placeHolder: 'None',
                                        modalTitle:
                                            'Select the tags you want to skip:',
                                        onChange: (List<String> skipTags) =>
                                            setState(
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
                                            onChanged: (bool value) => setState(
                                                () => cmd.onlyProperties =
                                                    value))),
                                  if (advanced) const DefDivider(),
                                  if (advanced)
                                    ListTile(
                                        title: const Text(
                                          'Show extra debug info',
                                        ),
                                        trailing: Switch(
                                            value: cmd.debug,
                                            onChanged: (bool value) => setState(
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
                                              onChanged: (bool value) =>
                                                  setState(() =>
                                                      cmd.dryRun = value))),
                                  if (advanced)
                                    TipsCard(
                                        text:
                                            "This project is generated in the '${vm.project.dirName}' directory."),
                                  Column(
                                      children: migrationNotes
                                          .map((MigrationNotesDesc m) =>
                                              AlertCard(
                                                  message: m.text,
                                                  color: Colors.grey.shade100,
                                                  action: () => <Future<bool>>{
                                                        launchUrl(
                                                            Uri.parse(m.url))
                                                      },
                                                  actionText: 'READ MORE',
                                                  icon: Icons.info_outline))
                                          .toList()),
                                  LaunchBtn(onTap: onTap, execBtn: execBtn),
                                ])),
                        Expanded(
                          // flex: 1, // 10%
                          child: Container(),
                        )
                      ],
                    ))));
      },
    );
  }
}

@immutable
class _DeployViewModel {
  const _DeployViewModel(
      {required this.project,
      required this.cmd,
      required this.onCancel,
      required this.onDeployProject});

  final LAProject project;
  final CommonCmd cmd;
  final Function(LAProject) onCancel;
  final Function(LAProject, DeployCmd) onDeployProject;

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
