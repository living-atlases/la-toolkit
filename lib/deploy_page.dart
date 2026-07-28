import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:redux/redux.dart';
import 'package:url_launcher/url_launcher.dart';

import 'components/alert_card.dart';
import 'components/def_divider.dart';
import 'components/deploy_btn.dart';
import 'components/la_app_bar.dart';
import 'components/manual_tags_input.dart';
import 'components/project_drawer.dart';
import 'components/scroll_panel.dart';
import 'components/server_selector.dart';
import 'components/services_chip_panel.dart';
import 'components/terms_drawer.dart';
import 'components/tips_card.dart';
import 'dependencies_manager.dart';
import 'la_theme.dart';
import 'models/app_state.dart';
import 'models/common_cmd.dart';
import 'models/deploy_cmd.dart';
import 'models/la_project.dart';
import 'models/la_server.dart';
import 'models/la_service.dart';
import 'models/migration_notes_desc.dart';
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

  // Hybrid portals deploy as two separate runs; this picks which one:
  // false = VM leg (ala-install), true = Docker leg (la-docker-compose).
  // Null until first build, then defaulted to the Docker leg when the project
  // has docker-compose services so compose portals land on Docker by default.
  bool? _hybridDockerMode;

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
          onSaveDeployCmd: (DeployCmd cmd) {
            store.dispatch(SaveCurrentCmd(cmd: cmd));
          },
          onDeployProject: (LAProject project, DeployCmd cmd) =>
              DeployUtils.deployActionLaunch(
                context: context,
                store: store,
                project: project,
                deployCmd: cmd,
              ),
          onCancel: (LAProject project) {
            store.dispatch(OpenProjectTools(project));
            BeamerCond.of(context, LAProjectViewLocation());
          },
        );
      },
      builder: (BuildContext context, _DeployViewModel vm) {
        const String execBtn = 'Deploy';
        late DeployCmd cmd;
        try {
          cmd = vm.cmd as DeployCmd;
        } catch (e) {
          cmd = DeployCmd();
        }
        // On pure docker-compose the deploy is monolithic (site.yml against the
        // docker_compose group): force the 'all' selection and flag the command
        // so the backend targets la-docker-compose (--ladocker) instead of the
        // per-service ala-install playbooks. Granularity is a skip-list.
        if (vm.project.isPureDockerCompose) {
          cmd = cmd.copyWith(
            dockerCompose: true,
            deployServices: cmd.deployServices.isEmpty
                ? <String>['all']
                : cmd.deployServices,
          );
        }
        // Default the hybrid leg selection on first build: land on the Docker
        // leg when docker-compose is enabled, otherwise the VM leg.
        _hybridDockerMode ??= vm.project.hasDockerComposeServices;
        final bool hybridDockerMode = _hybridDockerMode!;
        // On hybrid portals the deploy is run as two separate commands; the
        // user picks the VM leg (ala-install) or the Docker leg
        // (la-docker-compose, compose 'all' by default) and we build the
        // matching command at launch time.
        DeployCmd resolveDeployCmd() {
          if (vm.project.isHybrid) {
            return hybridDockerMode
                ? vm.project.buildDockerLegDeployCmd(cmd)
                : vm.project.buildVmLegDeployCmd(cmd);
          }
          return cmd;
        }
        // Docker leg is always deployable (compose 'all'); the VM leg / other
        // deploys need at least one selected service.
        final bool canDeploy =
            (vm.project.isHybrid && hybridDockerMode) ||
            cmd.deployServices.isNotEmpty;
        final VoidCallback? onTap = !canDeploy
            ? null
            : () => vm.onDeployProject(vm.project, resolveDeployCmd());
        final bool advanced =
            cmd.advanced ||
            cmd.tags.isNotEmpty ||
            cmd.limitToServers.isNotEmpty ||
            cmd.skipTags.isNotEmpty ||
            cmd.onlyProperties;
        final String pageTitle = '${vm.project.shortName} Deployment';
        final Map<String, String> selectedVersions = <String, String>{};
        selectedVersions.addAll(
          vm.project.getServiceDeployReleases(vm.project.isPureDockerCompose),
        );
        final List<MigrationNotesDesc> migrationNotes =
            DependenciesManager.getMigrationNotes(
              _servicesToDeploy,
              selectedVersions,
            );

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
                    child: Icon(Icons.close, color: Colors.white),
                  ),
                  onPressed: () => vm.onCancel(vm.project),
                ),
              ],
            ),
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
                        if (vm.project.isHybrid) ...<Widget>[
                          const ListTile(
                            title: Text(
                              'Hybrid portal — choose what to deploy:',
                              style: TextStyle(fontSize: 16),
                            ),
                            subtitle: Text(
                              'VM services deploy via ala-install and docker '
                              'services via la-docker-compose, as two separate '
                              'runs.',
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                            child: SegmentedButton<bool>(
                              segments: <ButtonSegment<bool>>[
                                ButtonSegment<bool>(
                                  value: false,
                                  icon: Icon(MdiIcons.server),
                                  label: const Text('VM deploy'),
                                ),
                                ButtonSegment<bool>(
                                  value: true,
                                  icon: Icon(MdiIcons.docker),
                                  label: const Text('Docker deploy'),
                                ),
                              ],
                              selected: <bool>{hybridDockerMode},
                              onSelectionChanged: (Set<bool> s) => setState(
                                () => _hybridDockerMode = s.first,
                              ),
                            ),
                          ),
                          if (hybridDockerMode)
                            const ListTile(
                              leading: Icon(Icons.rocket_launch_outlined),
                              title: Text(
                                'Deploying the full docker stack (all services)',
                                style: TextStyle(fontSize: 16),
                              ),
                              subtitle: Text(
                                'la-docker-compose deploys all its services. '
                                'Use Advanced → Skip services to exclude some.',
                              ),
                            )
                          else ...<Widget>[
                            const ListTile(
                              title: Text(
                                'Select which VM services to deploy:',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            ServicesChipPanel(
                              key: const ValueKey<String>('hybrid-vm'),
                              withAll: false,
                              initialValue: cmd.deployServices,
                              services:
                                  LAService.removeServicesDeployedTogether(
                                    vm.project.vmAssignedServices,
                                  ),
                              isHub: vm.project.isHub,
                              onChange: (List<String> s) => setState(() {
                                cmd = cmd.copyWith(deployServices: s);
                                vm.onSaveDeployCmd(cmd);
                                _servicesToDeploy = s;
                              }),
                            ),
                          ],
                        ] else if (!vm.project.isPureDockerCompose) ...<Widget>[
                          const ListTile(
                            title: Text(
                              'Select which services you want to deploy:',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          ServicesChipPanel(
                            initialValue: cmd.deployServices,
                            services: LAService.removeServicesDeployedTogether(
                              vm.project.getServicesAssigned(),
                            ),
                            isHub: vm.project.isHub,
                            onChange: (List<String> s) => setState(() {
                              cmd = cmd.copyWith(deployServices: s);
                              vm.onSaveDeployCmd(cmd);
                              _servicesToDeploy = s;
                            }),
                          ),
                        ] else
                          const ListTile(
                            leading: Icon(Icons.rocket_launch_outlined),
                            title: Text(
                              'Deploying the full stack (all services together)',
                              style: TextStyle(fontSize: 16),
                            ),
                            subtitle: Text(
                              'This is a docker-compose portal. Use Advanced '
                              'options below to redeploy specific services.',
                            ),
                          ),
                        ListTile(
                          title: const Text('Advanced options'),
                          trailing: Switch(
                            value: advanced,
                            onChanged: (bool value) => setState(() {
                              cmd = cmd.copyWith(advanced: value);
                              vm.onSaveDeployCmd(cmd);
                            }),
                          ),
                        ),
                        // Skip-services applies only to the docker leg (pure
                        // compose or a hybrid Docker deploy).
                        if (advanced &&
                            (vm.project.isPureDockerCompose ||
                                (vm.project.isHybrid &&
                                    hybridDockerMode))) ...<Widget>[
                          const ListTile(
                            title: Text('Skip services (optional):'),
                            subtitle: Text(
                              'Selected services are excluded from the docker '
                              'stack (passed as skip_services). Leave empty to '
                              'deploy everything.',
                            ),
                          ),
                          ServicesChipPanel(
                            withAll: false,
                            initialValue: cmd.skipServices,
                            services: LAService.removeServicesDeployedTogether(
                              vm.project.getServicesAssigned(true),
                            ),
                            isHub: vm.project.isHub,
                            onChange: (List<String> s) => setState(() {
                              cmd = cmd.copyWith(skipServices: s);
                              vm.onSaveDeployCmd(cmd);
                            }),
                          ),
                        ],
                        // Server limit doesn't apply to the docker leg (compose
                        // runs on its own hosts).
                        if (advanced &&
                            !vm.project.isPureDockerCompose &&
                            !(vm.project.isHybrid && hybridDockerMode))
                          ServerSelector(
                            selectorKey: GlobalKey<FormFieldState<dynamic>>(),
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
                            onChange: (List<String> limitToServers) =>
                                setState(() {
                                  cmd = cmd.copyWith(
                                    limitToServers: limitToServers,
                                  );
                                  vm.onSaveDeployCmd(cmd);
                                }),
                          ),
                        if (advanced)
                          ManualTagsInput(
                            initialValue: cmd.tags,
                            icon: MdiIcons.tagPlusOutline,
                            title: 'Tags:',
                            hint: 'Type an Ansible tag and press Enter',
                            onChange: (List<String> tags) => setState(() {
                              cmd = cmd.copyWith(tags: tags);
                              vm.onSaveDeployCmd(cmd);
                            }),
                          ),
                        if (advanced)
                          ManualTagsInput(
                            initialValue: cmd.skipTags,
                            icon: MdiIcons.tagOffOutline,
                            title: 'Skip tags:',
                            hint: 'Type a tag to skip and press Enter',
                            onChange: (List<String> skipTags) => setState(() {
                              cmd = cmd.copyWith(skipTags: skipTags);
                              vm.onSaveDeployCmd(cmd);
                            }),
                          ),
                        if (advanced)
                          const TipsCard(
                            text:
                                '''Ansible tasks are marked with tags, and then when you run it you can use `--tags` or `--skip-tags` to execute or skip a subset of these tasks.''',
                            margin: EdgeInsets.zero,
                          ),
                        if (advanced)
                          ListTile(
                            title: const Text(
                              'Only deploy properties (service configurations)',
                            ),
                            trailing: Switch(
                              value: cmd.onlyProperties,
                              onChanged: (bool value) => setState(() {
                                cmd = cmd.copyWith(onlyProperties: value);
                                vm.onSaveDeployCmd(cmd);
                              }),
                            ),
                          ),
                        if (advanced) const DefDivider(),
                        if (advanced)
                          ListTile(
                            title: const Text('Show extra debug info'),
                            trailing: Switch(
                              value: cmd.debug,
                              onChanged: (bool value) => setState(() {
                                cmd = cmd.copyWith(debug: value);
                                vm.onSaveDeployCmd(cmd);
                              }),
                            ),
                          ),
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
                                onChanged: (bool value) => setState(() {
                                  cmd = cmd.copyWith(dryRun: value);
                                  vm.onSaveDeployCmd(cmd);
                                }),
                              ),
                            ),
                        if (advanced)
                          TipsCard(
                            text:
                                "This project is generated in the '${vm.project.dirName}' directory.",
                          ),
                        Column(
                          children: migrationNotes
                              .map(
                                (MigrationNotesDesc m) => AlertCard(
                                  message: m.text,
                                  color: Colors.grey.shade100,
                                  action: () => <Future<bool>>{
                                    launchUrl(Uri.parse(m.url)),
                                  },
                                  actionText: 'READ MORE',
                                  icon: Icons.info_outline,
                                ),
                              )
                              .toList(),
                        ),
                        LaunchBtn(onTap: onTap, execBtn: execBtn),
                      ],
                    ),
                  ),
                  Expanded(
                    // flex: 1, // 10%
                    child: Container(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

@immutable
class _DeployViewModel {
  const _DeployViewModel({
    required this.project,
    required this.cmd,
    required this.onCancel,
    required this.onSaveDeployCmd,
    required this.onDeployProject,
  });

  final LAProject project;
  final CommonCmd cmd;
  final Function(LAProject) onCancel;
  final Function(DeployCmd) onSaveDeployCmd;
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
