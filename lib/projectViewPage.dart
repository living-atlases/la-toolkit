import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/alaInstallSelector.dart';
import 'package:la_toolkit/components/lintProject.dart';
import 'package:la_toolkit/components/tool.dart';
import 'package:la_toolkit/components/toolShortcut.dart';
import 'package:la_toolkit/models/deployCmd.dart';
import 'package:la_toolkit/models/laProjectStatus.dart';
import 'package:la_toolkit/models/preDeployCmd.dart';
import 'package:la_toolkit/routes.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:mdi/mdi.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'components/appSnackBarMessage.dart';
import 'components/generatorSelector.dart';
import 'components/laAppBar.dart';
import 'components/laProjectTimeline.dart';
import 'components/projectDrawer.dart';
import 'components/scrollPanel.dart';
import 'components/serversStatusPanel.dart';
import 'laTheme.dart';
import 'models/appState.dart';
import 'models/laProject.dart';
import 'models/laProjectStatus.dart';
import 'models/postDeployCmd.dart';
import 'redux/actions.dart';

class LAProjectViewPage extends StatefulWidget {
  // It's StatefulWidget to retrieve _scaffoldKey.currentState
  static const routeName = "tools";

  @override
  _LAProjectViewPageState createState() => _LAProjectViewPageState();
}

class _LAProjectViewPageState extends State<LAProjectViewPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ProjectPageViewModel>(
        distinct: true,
        converter: (store) {
          return _ProjectPageViewModel(
              project: store.state.currentProject,
              /* sshKeys: store.state.sshKeys, -*/
              status: store.state.currentProject.status,
              alaInstallReleases: store.state.alaInstallReleases,
              generatorReleases: store.state.generatorReleases,
              onOpenProject: (project) {
                store.dispatch(OpenProject(project));
                BeamerCond.of(context, LAProjectEditLocation());
              },
              onTuneProject: (project) {
                store.dispatch(TuneProject(project));
                BeamerCond.of(context, LAProjectTuneLocation());
              },
              onPreDeployTasks: (project) {
                DeployUtils.doDeploy(
                    context: context,
                    store: store,
                    project: project,
                    deployCmd: PreDeployCmd());
              },
              onPostDeployTasks: (project) {
                DeployUtils.doDeploy(
                    context: context,
                    store: store,
                    project: project,
                    deployCmd: PostDeployCmd());
              },
              onViewLogs: (project) {
                store.dispatch(OnViewLogs(project));
                BeamerCond.of(context, LogsHistoryLocation());
              },
              onDeployProject: (project) {
                DeployUtils.doDeploy(
                    context: context,
                    store: store,
                    project: project,
                    deployCmd: DeployCmd());
              },
              onDelProject: (project) {
                store.dispatch(DelProject(project));
                BeamerCond.of(context, HomeLocation());
              },
              onGenInvProject: (project) =>
                  store.dispatch(GenerateInvProject(project)),
              onPortalStatus: (project) {
                store.dispatch(
                    ShowSnackBar(AppSnackBarMessage("Under development")));
                store.dispatch(TestConnectivityProject(project, () {}));
                BeamerCond.of(context, PortalStatusLocation());
              },
              onTestConnProject: (project, silence) {
                if (!silence) context.showLoaderOverlay();
                store.dispatch(TestConnectivityProject(project, () {
                  if (!silence)
                    _showServersStatus(context, store.state.currentProject);
                }));
              });
        },
        builder: (BuildContext context, _ProjectPageViewModel vm) {
          print("Building ProjectViewPage $_scaffoldKey");
          final LAProject project = vm.project;
          List<Tool> tools = [
            Tool(
                icon: const Icon(Icons.edit),
                title: "Edit",
                tooltip: "Edit the basic configuration",
                enabled: true,
                action: () => vm.onOpenProject(project)),
            Tool(
                icon: const Icon(Icons.tune),
                title: "Tune Configuration",
                tooltip:
                    "Fine tune the portal configuration with other options different than the basic ones.",
                enabled: vm.status.value >= LAProjectStatus.basicDefined.value,
                action: () => vm.onTuneProject(project)),
            Tool(
                icon: const Icon(Icons.settings_ethernet),
                tooltip: "Test if your servers are reachable from here",
                title: "Test Connectivity",
                enabled: project.isCreated,
                action: () {
                  /*ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        "Ok! Testing the connectivity with your servers..."),
                  )); */
                  vm.onTestConnProject(project, false);
                }),
            Tool(
                icon: const Icon(Icons.foundation),
                title: "Pre-Deploy Tasks",
                enabled: project.allServersWithServicesReady(),
                action: () => vm.onPreDeployTasks(project)),
            Tool(
                icon: const Icon(Icons.format_paint),
                title: "Branding Deploy",
                action: () => {}),
            Tool(
                icon: const Icon(Mdi.rocketLaunch),
                title: "Deploy",
                tooltip: "Install/update your LA Portal or some services",
                grid: 12,
                enabled: project.allServersWithServicesReady(),
                action: () => vm.onDeployProject(project)),
            Tool(
                icon: const Icon(Icons.receipt_long),
                title: "Logs History",
                tooltip: "Show deploy logs history",
                enabled: project.allServersWithServicesReady() &&
                    project.cmdHistory.length > 0,
                action: () => vm.onViewLogs(project)),
            Tool(
                icon: const Icon(Icons.house_siding),
                title: "Post-Deploy Tasks",
                enabled: project.fstDeployed,
                action: () => vm.onPostDeployTasks(project)),
            Tool(
                icon: const Icon(Icons.fact_check),
                title: "Portal Status",
                tooltip: "Check your portal servers and services status",
                enabled: project.allServersWithServicesReady(),
                action: () => vm.onPortalStatus(vm.project)),
            /* Tool(
                icon: const Icon(Icons.pie_chart),
                title: "Stats",
                action: () => {}), */
            Tool(
                icon: const Icon(Icons.file_download),
                tooltip: AppUtils.isDemo()
                    ? "This is just a web demo without deployment capabilities. Anyway you can generate & download your inventories."
                    : "Download your inventories to share it.\n\nNote: this is a copy or your inventories with autogenerated different passwords.\nYou can share it without security problems.",
                title: "Download Inventories",
                enabled: project.isCreated,
                action: () => vm.onGenInvProject(project)),
            /*     action: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("In Development: come back soon!"),
                ))), */
            Tool(
                icon: const Icon(Icons.delete),
                title: "Delete",
                tooltip: "Delete this LA project",
                enabled: true,
                askConfirmation: true,
                action: () => vm.onDelProject(project)),
            Tool(
                icon: const Icon(Mdi.pipe),
                title: "Data Processing Pipelines",
                tooltip: "Pipelines for data processing (Not yet developed)",
                enabled: false,
                grid: 12,
                action: () => {}),
            // To think about:
            // - Data generation
            // - Inventories download
          ];
          String projectIconUrl =
              project.getVariableValue("favicon_url").toString();
          return Scaffold(
              key: _scaffoldKey,
              backgroundColor: Colors.white,
              drawer: ProjectDrawer(),
              appBar: LAAppBar(
                  leading: IconButton(
                    color: Colors.white,
                    icon: const Icon(Mdi.vectorLink),
                    tooltip: "${project.shortName} links drawer",
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                  context: context,
                  showLaIcon: false,
                  backLocation: HomeLocation(),
                  showBack: true,
                  // backRoute: HomePage.routeName,
                  projectIcon: projectIconUrl,
                  title: "Toolkit of ${project.shortName} Portal"),
              body: new ScrollPanel(
                  child: Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                      child: Column(children: [
                        Container(
                            padding: EdgeInsets.only(top: 80, bottom: 50),
                            child: LAProjectTimeline(id: project.id)),
                        // Disabled for now
                        // ServicesChipPanel(),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(width: 250, child: ALAInstallSelector()),
                              SizedBox(width: 250, child: GeneratorSelector())
                            ]),
                        SizedBox(height: 20),
                        ResponsiveGridRow(
                            // desiredItemWidth: 120,
                            // minSpacing: 20,
                            children: tools.map((tool) {
                          return ResponsiveGridCol(
                              lg: tool.grid,
                              child: Container(
                                padding: EdgeInsets.all(10),
                                height: 120,
                                alignment: Alignment(0, 0),
                                color: Colors.white,
                                // color: LAColorTheme.laPalette.shade50,
                                child: ToolShortcut(tool: tool),
                              ));
                        }).toList()),
                        LintProjectPanel()
                      ]))));
        });
  }

  void _showServersStatus(BuildContext context, LAProject currentProject) {
    bool allReady = currentProject.allServersWithServicesReady();
    context.hideLoaderOverlay();
    Alert(
        context: context,
        closeIcon: Icon(Icons.close),
        image: Icon(
            allReady ? Mdi.checkboxMarkedCircleOutline : Icons.remove_done,
            size: 60,
            color: allReady ? LAColorTheme.up : LAColorTheme.down),
        title: "Servers Status",
        style: AlertStyle(
            constraints: BoxConstraints.expand(height: 600, width: 600)),
        content: Column(
            children: new List.from([
          SizedBox(height: 20),
          Text(
              allReady
                  ? "Congrats! All the servers are ready"
                  : "Uuppps! It seems that some servers are not yet ready",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
          SizedBox(height: 20),
          ServersStatusPanel(extendedStatus: false)
        ])),
        buttons: [
          DialogButton(
            width: 500,
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }
}

class _ProjectPageViewModel {
  final LAProject project;
  final LAProjectStatus status;
  List<String> alaInstallReleases;
  List<String> generatorReleases;
  final void Function(LAProject project) onOpenProject;
  final void Function(LAProject project) onTuneProject;
  final void Function(LAProject project) onDeployProject;
  final void Function(LAProject project) onDelProject;
  final void Function(LAProject project) onGenInvProject;
  final void Function(LAProject project) onViewLogs;
  final void Function(LAProject project, bool) onTestConnProject;
  final void Function(LAProject project) onPreDeployTasks;
  final void Function(LAProject project) onPostDeployTasks;
  final void Function(LAProject project) onPortalStatus;

  _ProjectPageViewModel(
      {required this.project,
      required this.alaInstallReleases,
      required this.generatorReleases,
      required this.status,
      required this.onOpenProject,
      required this.onTuneProject,
      required this.onDelProject,
      required this.onPreDeployTasks,
      required this.onPostDeployTasks,
      required this.onViewLogs,
      required this.onDeployProject,
      required this.onGenInvProject,
      required this.onTestConnProject,
      required this.onPortalStatus});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ProjectPageViewModel &&
          runtimeType == other.runtimeType &&
          project == other.project &&
          status.value == other.status.value &&
          ListEquality().equals(generatorReleases, other.generatorReleases) &&
          ListEquality().equals(alaInstallReleases, other.alaInstallReleases);

  @override
  int get hashCode =>
      project.hashCode ^
      status.value.hashCode ^
      ListEquality().hash(generatorReleases) ^
      ListEquality().hash(alaInstallReleases);
}
