import 'package:collection/collection.dart';
import 'package:cron/cron.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/alaInstallSelector.dart';
import 'package:la_toolkit/components/tool.dart';
import 'package:la_toolkit/components/toolShortcut.dart';
import 'package:la_toolkit/models/laProjectStatus.dart';
import 'package:la_toolkit/sshKeysPage.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:mdi/mdi.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'components/alertCard.dart';
import 'components/generatorSelector.dart';
import 'components/laAppBar.dart';
import 'components/laProjectTimeline.dart';
import 'components/projectDrawer.dart';
import 'components/scrollPanel.dart';
import 'components/serverDiagram.dart';
import 'laTheme.dart';
import 'models/appState.dart';
import 'models/laProject.dart';
import 'models/laProjectStatus.dart';
import 'models/sshKey.dart';
import 'redux/actions.dart';

class LAProjectViewPage extends StatelessWidget {
  static const routeName = "tools";
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ProjectPageViewModel>(
        distinct: true,
        rebuildOnChange: false,
        converter: (store) {
          return _ProjectPageViewModel(
              project: store.state.currentProject,
              sshKeys: store.state.sshKeys,
              status: store.state.currentProject.status,
              onOpenProject: (project) => store.dispatch(OpenProject(project)),
              onTuneProject: (project) => store.dispatch(TuneProject(project)),
              onDeployProject: (project) {
                context.showLoaderOverlay();
                store.dispatch(PrepareDeployProject(
                    project: project,
                    onReady: () => context.hideLoaderOverlay(),
                    onError: (e) {
                      context.hideLoaderOverlay();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(e),
                        duration: Duration(days: 365),
                        action: SnackBarAction(
                          label: 'OK',
                          onPressed: () {},
                        ),
                      ));
                    }));
              },
              onDelProject: (project) => store.dispatch(DelProject(project)),
              onGenInvProject: (project) =>
                  store.dispatch(GenerateInvProject(project)),
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
          final bool basicDefined =
              vm.status.value >= LAProjectStatus.basicDefined.value;
          LAProjectStatus.advancedDefined.value;
          final cron = Cron();
          const minutes = 10;
          cron.schedule(Schedule.parse('*/$minutes * * * *'), () async {
            if (project.isCreated && !AppUtils.isDemo()) {
              print(
                  "Testing connectivity with each server $minutes min --------------");
              vm.onTestConnProject(project, true);
            }
          });
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
            Tool(icon: const Icon(Icons.foundation), title: "Pre-Deploy Tasks"),
            Tool(
                icon: const Icon(Icons.format_paint), title: "Branding Deploy"),
            Tool(
                icon: const Icon(Mdi.rocketLaunch),
                title: "Deploy",
                tooltip: "Install/update your LA Portal or some services",
                grid: 12,
                enabled: project.allServersWithServicesReady(),
                action: () => vm.onDeployProject(project)),
            Tool(
                icon: const Icon(Icons.house_siding),
                title: "Post-Deploy Tasks"),

            Tool(icon: const Icon(Icons.fact_check), title: "Test Services"),
            Tool(icon: const Icon(Icons.pie_chart), title: "Stats"),
            Tool(
                icon: const Icon(Icons.file_download),
                tooltip: AppUtils.isDemo()
                    ? "This is just a web demo without deployment capabilities. Anyway you can generate & download your inventories."
                    : "Download your inventories to share it.\n\nNote: this is a copy or your inventories with autogenerated different passwords.\nYou can share it without security problems.",
                title: "Download inventories",
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
            // To think about:
            // - Data generation
            // - Inventories download
          ];
          final projectIconUrl = project.getVariable("favicon_url").value;
          return Scaffold(
              key: _scaffoldKey,
              backgroundColor: Colors.white,
              drawer: ProjectDrawer(),
              appBar: LAAppBar(
                  leading: IconButton(
                    color: Colors.white,
                    icon: const Icon(Mdi.vectorLink),
                    tooltip: "${project.shortName} links drawer",
                    onPressed: () => _scaffoldKey.currentState.openDrawer(),
                  ),
                  context: context,
                  showLaIcon: false,
                  showBack: true,
                  projectIcon: projectIconUrl,
                  title: "Toolkit of ${project.shortName} Portal"),
              body: new ScrollPanel(
                  child: Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                      child: Column(children: [
                        Container(
                            padding: EdgeInsets.only(top: 80, bottom: 50),
                            child: LAProjectTimeline(uuid: project.uuid)),
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
                        if (vm.sshKeys.isEmpty)
                          AlertCard(
                              message: "You don't have any SSH key",
                              actionText: "SOLVE",
                              action: () => Navigator.popAndPushNamed(
                                  context, SshKeyPage.routeName)),
                        if (project.allServersWithServicesReady() &&
                            !project.allServersWithOs('Ubuntu', '18.04'))
                          AlertCard(
                              message:
                                  "The current supported OS version in Ubuntu 18.04"),
                        if (basicDefined &&
                            !project.allServicesAssignedToServers())
                          AlertCard(
                              message:
                                  "Some service is not assigned to a server"),
                        if (basicDefined && !project.allServersWithIPs())
                          AlertCard(
                              message:
                                  "All servers should have configured their IP address"),
                        if (basicDefined && !project.allServersWithSshKeys())
                          AlertCard(
                              message:
                                  "All servers should have configured their SSH keys"),
                        if (!project.collectoryAndBiocacheDifferentServers())
                          AlertCard(
                              message:
                                  "The collections and the occurrences front-end (bioache-hub) services are in the same server. This can cause start-up problems when caches are enabled")
                      ]))));
        });
  }

  void _showServersStatus(BuildContext context, LAProject currentProject) {
    List<Widget> serversWidgets = currentProject
        .serversWithServices()
        .map((server) => ServerDiagram(server))
        .toList();
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
          Wrap(children: serversWidgets)
        ])
            //..addAll(),
            ),
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
  List<String> alaInstallReleases;
  List<String> generatorReleases;
  List<SshKey> sshKeys;
  final void Function(LAProject project) onOpenProject;
  final void Function(LAProject project) onTuneProject;
  final void Function(LAProject project) onEditProject;
  final void Function(LAProject project) onDeployProject;
  final void Function(LAProject project) onDelProject;
  final void Function(LAProject project) onGenInvProject;
  final void Function(LAProject project, bool) onTestConnProject;
  final LAProjectStatus status;

  _ProjectPageViewModel(
      {this.project,
      this.alaInstallReleases,
      this.generatorReleases,
      this.sshKeys,
      this.status,
      this.onOpenProject,
      this.onTuneProject,
      this.onDelProject,
      this.onEditProject,
      this.onDeployProject,
      this.onGenInvProject,
      this.onTestConnProject});

  @override
  bool operator ==(Object other) {
    bool result = identical(this, other) ||
        other is _ProjectPageViewModel &&
            runtimeType == other.runtimeType &&
            project == other.project &&
            status.value == other.status.value &&
            ListEquality().equals(generatorReleases, other.generatorReleases) &&
            ListEquality()
                .equals(alaInstallReleases, other.alaInstallReleases) &&
            ListEquality().equals(sshKeys, other.sshKeys);
    print("############################ Is different project $result");
    return result;
  }

  @override
  int get hashCode =>
      project.hashCode ^
      status.value.hashCode ^
      ListEquality().hash(sshKeys) ^
      ListEquality().hash(generatorReleases) ^
      ListEquality().hash(alaInstallReleases);
}
