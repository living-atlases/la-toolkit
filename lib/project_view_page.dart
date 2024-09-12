import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:redux/redux.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';

import 'components/LoadingTextOverlay.dart';
import 'components/hubButton.dart';
import 'components/laAppBar.dart';
import 'components/laProjectTimeline.dart';
import 'components/lintProjectPanel.dart';
import 'components/project_drawer.dart';
import 'components/scrollPanel.dart';
import 'components/servers_status_panel.dart';
import 'components/terms_drawer.dart';
import 'components/tool.dart';
import 'components/toolShortcut.dart';
import 'laTheme.dart';
import 'models/appState.dart';
import 'models/brandingDeployCmd.dart';
import 'models/deployCmd.dart';
import 'models/laProjectStatus.dart';
import 'models/la_project.dart';
import 'models/postDeployCmd.dart';
import 'models/preDeployCmd.dart';
import 'redux/actions.dart';
import 'routes.dart';
import 'utils/utils.dart';

class LAProjectViewPage extends StatefulWidget {
  const LAProjectViewPage({super.key});

  // It's StatefulWidget to retrieve _scaffoldKey.currentState
  static const String routeName = 'tools';

  @override
  State<LAProjectViewPage> createState() => _LAProjectViewPageState();
}

class _LAProjectViewPageState extends State<LAProjectViewPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    if (mounted) {
      // context.loaderOverlay.hide();
    }
    super.dispose();
  }

  Future<void> showOverlay(BuildContext context) async {
    context.loaderOverlay.show(widgetBuilder: (progress) {
      return const LoadingTextOverlay();
    });
    await Future<void>.delayed(const Duration(milliseconds: 1000));
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ProjectPageViewModel>(
        distinct: true,
        converter: (Store<AppState> store) {
          return _ProjectPageViewModel(
              project: store.state.currentProject,
              status: store.state.currentProject.status,
              loading: store.state.loading,
              softwareReleasesReady: store.state.laReleases.isNotEmpty,
              onOpenProject: (LAProject project) async {
                showOverlay(context);
                store.dispatch(OpenProject(project));
                BeamerCond.of(context, LAProjectEditLocation());
              },
              onOpenServersProject: (LAProject project) async {
                showOverlay(context);
                store.dispatch(OpenServersProject(project));
                BeamerCond.of(context, LAProjectServersLocation());
              },
              onTuneProject: (LAProject project) async {
                showOverlay(context);
                store.dispatch(TuneProject(project));
                BeamerCond.of(context, LAProjectTuneLocation());
              },
              onPreDeployTasks: (LAProject project) {
                DeployUtils.doDeploy(
                    context: context,
                    store: store,
                    project: project,
                    commonCmd: PreDeployCmd());
              },
              onPostDeployTasks: (LAProject project) {
                DeployUtils.doDeploy(
                    context: context,
                    store: store,
                    project: project,
                    commonCmd: PostDeployCmd());
              },
              onViewLogs: (LAProject project) {
                store.dispatch(OnViewLogs(project));
                BeamerCond.of(context, LogsHistoryLocation());
              },
              onDeployProject: (LAProject project) {
                DeployUtils.doDeploy(
                    context: context,
                    store: store,
                    project: project,
                    commonCmd: DeployCmd());
              },
              onDataCompare: (LAProject project) {
                BeamerCond.of(context, CompareDataLocation());
              },
              onDelProject: (LAProject project) {
                store.dispatch(DelProject(project));
                BeamerCond.of(context, HomeLocation());
              },
              onGenInvProject: (LAProject project) =>
                  store.dispatch(GenerateInvProject(project)),
              onPortalStatus: (LAProject project) {
                /* store.dispatch(
                    ShowSnackBar(AppSnackBarMessage("Under development"))); */
                store.dispatch(TestServicesProject(
                    project,
                    project.serverServicesToMonitor().item2,
                    () => store.dispatch(TestConnectivityProject(
                        store.state.currentProject, () {}, () {})),
                    () {}));
                BeamerCond.of(context, PortalStatusLocation());
              },
              onPipelinesTasks: (LAProject project) {
                BeamerCond.of(context, PipelinesLocation());
              },
              onTestConnProject: (LAProject project, bool silence) {
                if (!silence) {
                  context.loaderOverlay.show();
                }
                store.dispatch(TestConnectivityProject(project, () {
                  if (!silence) {
                    _showServersStatus(context, store.state.currentProject);
                  }
                }, () {
                  if (!silence) {
                    context.loaderOverlay.hide();
                  }
                }));
              },
              onDeployBranding: (LAProject project) {
                DeployUtils.doDeploy(
                    context: context,
                    store: store,
                    project: project,
                    commonCmd: BrandingDeployCmd());
              },
              onCreateHub: (LAProject project) {
                store.dispatch(CreateProject(isHub: true, parent: project));
                BeamerCond.of(context, LAProjectEditLocation());
              },
              onOpenHub: (LAProject project, LAProject hub) {
                hub.parent = project; // if not is null
                store.dispatch(OpenProjectTools(hub));
                BeamerCond.of(context, LAProjectViewLocation());
              },
              onOpenParent: (LAProject hub) {
                // debugPrint(hub.parent);
                store.dispatch(OpenProjectTools(hub.parent!));
              });
        },
        builder: (BuildContext context, _ProjectPageViewModel vm) {
          final LAProject project = vm.project;
          log('Building ProjectViewPage $_scaffoldKey, ala-install: ${project.alaInstallRelease}, gen: ${project.generatorRelease}');

          if (project.isCreated && !AppUtils.isDemo()) {
            html.Notification.requestPermission();
          }

          final String portal = project.portalName;
          // ignore: non_constant_identifier_names
          final String Portal = project.PortalName;
          final bool isCreatedAndAccessibleOrInProduction =
              (project.isCreated && project.allServersWithServicesReady() ||
                      project.allServersWithSshReady()) ||
                  project.inProduction;
          final List<Tool> tools = <Tool>[
            Tool(
                icon: const Icon(Icons.edit),
                title: 'Edit',
                tooltip: 'Edit the basic configuration',
                enabled: true,
                action: () {
                  context.loaderOverlay.show();
                  vm.onOpenProject(project);
                }),
            Tool(
                icon: const Icon(Icons.dns),
                title: 'Servers',
                tooltip: 'Project servers configuration',
                enabled: true,
                action: () {
                  context.loaderOverlay.show();
                  vm.onOpenServersProject(project);
                }),
            Tool(
                icon: const Icon(Icons.tune),
                title: 'Tune your\nConfiguration',
                tooltip:
                    'Fine tune the $portal configuration with other options different than the basic ones.',
                enabled: vm.status.value >= LAProjectStatus.basicDefined.value,
                action: () => vm.onTuneProject(project)),
            Tool(
                icon: const Icon(Icons.settings_ethernet),
                tooltip: 'Test if your servers are reachable from here',
                title: 'Test Connectivity',
                enabled: project.isCreated || project.inProduction,
                action: () {
                  /*ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        "Ok! Testing the connectivity with your servers..."),
                  )); */
                  vm.onTestConnProject(project, false);
                }),
            Tool(
                icon: const Icon(Icons.foundation),
                title: 'Pre-Deploy Tasks',
                enabled: isCreatedAndAccessibleOrInProduction,
                action: () => vm.onPreDeployTasks(project)),
            Tool(
                icon: const Icon(Icons.format_paint),
                title: 'Branding Deploy',
                enabled: isCreatedAndAccessibleOrInProduction,
                action: () => vm.onDeployBranding(project)),
            Tool(
                icon: Icon(MdiIcons.rocketLaunch),
                title: 'Deploy',
                tooltip: 'Install/update your LA $Portal or some services',
                grid: 12,
                enabled: isCreatedAndAccessibleOrInProduction,
                action: () => vm.onDeployProject(project)),
            Tool(
                icon: const Icon(Icons.receipt_long),
                title: 'Logs History',
                tooltip: 'Show deploy logs history',
                enabled: isCreatedAndAccessibleOrInProduction &&
                    project.cmdHistoryEntries.isNotEmpty,
                action: () => vm.onViewLogs(project)),
            if (!project.isHub)
              Tool(
                  icon: const Icon(Icons.house_siding),
                  title: 'Post-Deploy Tasks',
                  enabled: isCreatedAndAccessibleOrInProduction,
                  action: () => vm.onPostDeployTasks(project)),
            Tool(
                icon: const Icon(Icons.fact_check),
                title: '$Portal Status',
                tooltip: 'Check your $portal servers and services status',
                enabled: isCreatedAndAccessibleOrInProduction,
                action: () => vm.onPortalStatus(vm.project)),
            /* Tool(
                icon: const Icon(Icons.pie_chart),
                title: "Stats",
                action: () => {}), */
            Tool(
                icon: const Icon(Icons.compare),
                title: 'Compare',
                tooltip:
                    'This tool allows you, for instance, to compare some records between your LA portal and your GBIF data',
                enabled: isCreatedAndAccessibleOrInProduction,
                action: () => vm.onDataCompare(vm.project)),
            if (!project.isHub)
              Tool(
                  icon: const Icon(Icons.file_download),
                  tooltip: AppUtils.isDemo()
                      ? 'This is just a web demo without deployment capabilities. Anyway you can generate & download your inventories.'
                      : 'Download your inventories to share it.\n\nNote: this is a copy or your inventories with autogenerated different passwords.\nYou can share it without security problems.',
                  title: 'Download Inventories',
                  enabled: project.isCreated,
                  action: () => vm.onGenInvProject(project)),
            /*     action: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("In Development: come back soon!"),
                ))), */
            Tool(
                icon: const Icon(Icons.delete),
                title: 'Delete',
                tooltip: 'Delete this LA project',
                enabled: true,
                askConfirmation: true,
                action: () => vm.onDelProject(project)),
            if (!project.isHub && project.getPipelinesMaster() != null)
              Tool(
                  icon: Icon(MdiIcons.pipe),
                  title: 'Pipelines Data Processing',
                  // tooltip: "Pipelines for data processing",
                  enabled: isCreatedAndAccessibleOrInProduction,
                  grid: 12,
                  action: () => vm.onPipelinesTasks(project)),
          ];
          final String projectIconUrl =
              project.getVariableValue('favicon_url').toString();
          final String pageTitle = '${project.shortName} Toolkit';
          final bool showSoftwareVersions =
              project.showSoftwareVersions && vm.softwareReleasesReady;
          final bool showToolkitDeps = project.showToolkitDeps;
          return Title(
              title: pageTitle,
              color: LAColorTheme.laPalette,
              child: Scaffold(
                  key: _scaffoldKey,
                  backgroundColor: Colors.white,
                  drawer: const ProjectDrawer(),
                  endDrawer: const TermsDrawer(),
                  appBar: LAAppBar(
                      leading: ProjectDrawer.appBarIcon(project, _scaffoldKey),
                      context: context,
                      // showLaIcon: false,
                      loading: vm.loading,
                      // this does not work as with back after editing
                      backLocation: !project.isHub
                          ? HomeLocation()
                          : LAProjectViewLocation(),
                      beforeBack: () {
                        if (vm.project.isHub) {
                          vm.onOpenParent(project);
                        }
                      },
                      showBack: true,
                      // backRoute: HomePage.routeName,
                      projectIcon: projectIconUrl,
                      actions: <Widget>[
                        if (project.isCreated)
                          TermsDrawer.appBarIcon(vm.project, _scaffoldKey)
                      ],
                      title: pageTitle),
                  body: ScrollPanel(
                      child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 80, vertical: 20),
                          child: Column(children: <Widget>[
                            Container(
                                padding:
                                    const EdgeInsets.only(top: 80, bottom: 50),
                                child: LAProjectTimeline(project: project)),
                            // Disabled for now
                            // ServicesChipPanel(),
                            ResponsiveGridRow(
                                // desiredItemWidth: 120,
                                // minSpacing: 20,
                                children: tools.map((Tool tool) {
                              return ResponsiveGridCol(
                                  lg: tool.grid,
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    height: 120,
                                    alignment: Alignment.center,
                                    color: Colors.white,
                                    // color: LAColorTheme.laPalette.shade50,
                                    child: ToolShortcut(tool: tool),
                                  ));
                            }).toList()),
                            const SizedBox(height: 10),
                            if (!project.isHub)
                              createHubWidget(context, vm, project),
                            LintProjectPanel(
                                showLADeps: showSoftwareVersions,
                                showToolkitDeps: showToolkitDeps)
                          ])))));
        });
  }

  Stack createHubWidget(
      BuildContext context, _ProjectPageViewModel vm, LAProject project) {
    return Stack(children: <Widget>[
      Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: const BorderRadius.all(
                Radius.circular(10.0) //                 <--- border radius here
                ),
          ),
          child: ResponsiveGridRow(
              children: project.hubs
                      .map((LAProject hub) => ResponsiveGridCol(
                          lg: 2,
                          child: HubButton(
                              text: hub.shortName,
                              icon: Icons.data_saver_off,
                              onPressed: () => vm.onOpenHub(project, hub),
                              tooltip: 'Open this Hub',
                              isActionBtn: false)))
                      .toList() +
                  <ResponsiveGridCol>[
                    ResponsiveGridCol(
                      lg: 2,
                      child: HubButton(
                          text: 'Add a Data Hub',
                          icon: Icons.data_saver_on,
                          onPressed: () {
                            showAlertDialog(context, vm);
                          },
                          tooltip: 'Add a new Data Hub to this portal',
                          isActionBtn: true),
                    )
                  ])),
      Positioned(
        top: 5.0,
        left: 30.0,
        right: 0.0,
        child: Row(
          children: <Widget>[
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: const Text(
                  'Hubs',
                  style: TextStyle(
                      color: Colors.black45,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      )
    ]);
  }

  void _showServersStatus(BuildContext context, LAProject currentProject) {
    final bool allReady = currentProject.allServersWithServicesReady();
    context.loaderOverlay.hide();
    Alert(
        context: context,
        closeIcon: const Icon(Icons.close),
        image: Icon(
            allReady ? MdiIcons.checkboxMarkedCircleOutline : Icons.remove_done,
            size: 60,
            color: allReady ? LAColorTheme.up : LAColorTheme.down),
        title: 'Servers Status',
        style: const AlertStyle(
            constraints: BoxConstraints.expand(height: 600, width: 800)),
        content: Column(
            children: List<Widget>.from(<Widget>[
          const SizedBox(height: 20),
          Text(
              allReady
                  ? 'Congrats! All the servers are ready'
                  : 'Uuppps! It seems that some servers are not yet ready',
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
          const SizedBox(height: 20),
          const ServersStatusPanel(
              extendedStatus: false, results: <String, List<dynamic>>{})
        ])),
        buttons: <DialogButton>[
          DialogButton(
            width: 450,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  void onFinish(BuildContext context, bool withError) {
    context.loaderOverlay.hide();
    Navigator.pop(context);
    if (withError) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Something goes wrong'),
      ));
    }
  }

  void showAlertDialog(BuildContext context, _ProjectPageViewModel vm) {
    final AlertDialog alert = AlertDialog(
      title: const Text('Data Hub Creation'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            const Text(
                'A Data Hub is a front end of a LA portal showing a subset of the whole data.'),
            const Text(
                'This subset can be split by region, taxonomy, basisofrecord (specimen only), temporal lapse or by any other query.'),
            const SizedBox(height: 20),
            const Text('More info:'),
            const SizedBox(height: 20),
            SelectableLinkify(
                linkStyle: TextStyle(color: LAColorTheme.laPalette),
                options: const LinkifyOptions(humanize: false),
                text:
                    'https://github.com/AtlasOfLivingAustralia/documentation/wiki/Data-Hub',
                onOpen: (LinkableElement link) async =>
                    launchUrl(Uri.parse(link.url))),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
            child: const Text('CANCEL'),
            onPressed: () async {
              onFinish(context, false);
            }),
        TextButton(
          child: const Text('CONTINUE'),
          onPressed: () async {
            vm.onCreateHub(vm.project);
          },
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

class _ProjectPageViewModel {
  _ProjectPageViewModel(
      {required this.project,
      required this.status,
      required this.loading,
      required this.softwareReleasesReady,
      required this.onOpenProject,
      required this.onOpenServersProject,
      required this.onOpenHub,
      required this.onOpenParent,
      required this.onTuneProject,
      required this.onDelProject,
      required this.onPreDeployTasks,
      required this.onPostDeployTasks,
      required this.onDeployBranding,
      required this.onViewLogs,
      required this.onDeployProject,
      required this.onPipelinesTasks,
      required this.onGenInvProject,
      required this.onTestConnProject,
      required this.onPortalStatus,
      required this.onDataCompare,
      required this.onCreateHub});

  final LAProject project;
  final LAProjectStatus status;
  final bool loading;
  final bool softwareReleasesReady;
  final void Function(LAProject project) onOpenProject;
  final void Function(LAProject project) onOpenServersProject;
  final void Function(LAProject project) onOpenParent;
  final void Function(LAProject project) onTuneProject;
  final void Function(LAProject project) onDeployProject;
  final void Function(LAProject project) onDelProject;
  final void Function(LAProject project) onDeployBranding;
  final void Function(LAProject project) onGenInvProject;
  final void Function(LAProject project) onViewLogs;
  final void Function(LAProject project, bool) onTestConnProject;
  final void Function(LAProject project) onPreDeployTasks;
  final void Function(LAProject project) onPostDeployTasks;
  final void Function(LAProject project) onPortalStatus;
  final void Function(LAProject project) onPipelinesTasks;
  final void Function(LAProject project) onDataCompare;
  final void Function(LAProject project) onCreateHub;
  final void Function(LAProject project, LAProject hub) onOpenHub;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ProjectPageViewModel &&
          runtimeType == other.runtimeType &&
          project == other.project &&
          status.value == other.status.value &&
          softwareReleasesReady &&
          other.softwareReleasesReady &&
          loading == other.loading;

  @override
  int get hashCode =>
      project.hashCode ^
      status.value.hashCode ^
      loading.hashCode ^
      softwareReleasesReady.hashCode;
}
