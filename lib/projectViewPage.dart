import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/alaInstallSelector.dart';
import 'package:la_toolkit/components/tool.dart';
import 'package:la_toolkit/components/toolShortcut.dart';
import 'package:mdi/mdi.dart';
import 'package:responsive_grid/responsive_grid.dart';

import 'components/laAppBar.dart';
import 'components/laProjectTimeline.dart';
import 'components/projectDrawer.dart';
import 'components/scrollPanel.dart';
import 'models/appState.dart';
import 'models/laProject.dart';
import 'models/laProjectStatus.dart';
import 'redux/actions.dart';

class LAProjectViewPage extends StatelessWidget {
  static const routeName = "tools";
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ProjectPageViewModel>(
        distinct: true,
        converter: (store) {
          return _ProjectPageViewModel(
            state: store.state,
            onOpenProject: (project) => store.dispatch(OpenProject(project)),
            onTuneProject: (project) => store.dispatch(TuneProject(project)),
            onDelProject: (project) => store.dispatch(DelProject(project)),
            onGenInvProject: (project) =>
                store.dispatch(GenerateInvProject(project)),
          );
        },
        builder: (BuildContext context, _ProjectPageViewModel vm) {
          final LAProject _currentProject = vm.state.currentProject;
          final bool basicDefined =
              _currentProject.status.value > LAProjectStatus.basicDefined.value;
          List<Tool> tools = [
            Tool(
                icon: const Icon(Icons.edit),
                title: "Edit",
                tooltip: "Edit the basic configuration",
                enabled: true,
                action: () => vm.onOpenProject(_currentProject)),
            Tool(
                icon: const Icon(Icons.tune),
                title: "Tune Configuration",
                tooltip:
                    "Fine tune the portal configuration with other options different than the basic ones.",
                enabled: _currentProject.status.value >=
                    LAProjectStatus.basicDefined.value,
                action: () => vm.onTuneProject(_currentProject)),
            Tool(
                icon: const Icon(Icons.file_download),
                tooltip:
                    "This is just a web demo without deployment capabilities. Anyway you can generate & download your inventories.",
                title: "Generate inventories",
                enabled: basicDefined,
                action: () => vm.onGenInvProject(_currentProject)),
            /*     action: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("In Development: come back soon!"),
                ))), */
            Tool(
                icon: const Icon(Icons.settings_ethernet),
                tooltip: "Test if your servers are reachable from here",
                title: "Test Connectivity",
                enabled: basicDefined,
                action: () =>
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("In Development: come back soon!"),
                    ))),

            Tool(icon: const Icon(Icons.foundation), title: "Pre-Deploy Tasks"),
            Tool(
                icon: const Icon(Mdi.rocketLaunch),
                title: "Deploy",
                tooltip: "Install/update your LA Portal or some services",
                grid: 12),
            Tool(
                icon: const Icon(Icons.house_siding),
                title: "Post-Deploy Tasks"),

            Tool(
                icon: const Icon(Icons.format_paint), title: "Branding Deploy"),
            Tool(icon: const Icon(Icons.fact_check), title: "Test Services"),
            Tool(icon: const Icon(Icons.pie_chart), title: "Stats"),
            Tool(
                icon: const Icon(Icons.delete),
                title: "Delete",
                tooltip: "Delete this LA project",
                enabled: true,
                askConfirmation: true,
                action: () => vm.onDelProject(_currentProject)),
            // To think about:
            // - Data generation
            // - Inventories download
          ];
          final projectIconUrl =
              _currentProject.getVariable("favicon_url").value;
          return Scaffold(
              key: _scaffoldKey,
              backgroundColor: Colors.white,
              drawer: ProjectDrawer(),
              appBar: LAAppBar(
                  leading: IconButton(
                    color: Colors.white,
                    icon: const Icon(Mdi.vectorLink),
                    tooltip: "${_currentProject.shortName} links drawer",
                    onPressed: () => _scaffoldKey.currentState.openDrawer(),
                  ),
                  context: context,
                  showLaIcon: false,
                  showBack: true,
                  projectIcon: projectIconUrl,
                  title: "Toolkit of ${_currentProject.shortName} Portal"),
              body: new ScrollPanel(
                  child: Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                      child: Column(children: [
                        Container(
                            padding: EdgeInsets.only(top: 80, bottom: 50),
                            child: LAProjectTimeline(project: _currentProject)),
                        // Disabled for now
                        // ServicesChipPanel(),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(width: 250, child: ALAInstallSelector())
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
                        }).toList())
                      ]))));
        });
  }
}

class _ProjectPageViewModel {
  final AppState state;
  final void Function(LAProject project) onOpenProject;
  final void Function(LAProject project) onTuneProject;
  final void Function(LAProject project) onEditProject;
  final void Function(LAProject project) onDelProject;
  final void Function(LAProject project) onGenInvProject;

  _ProjectPageViewModel(
      {this.state,
      this.onOpenProject,
      this.onTuneProject,
      this.onDelProject,
      this.onEditProject,
      this.onGenInvProject});
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ProjectPageViewModel &&
          runtimeType == other.runtimeType &&
          state.currentProject == other.state.currentProject &&
          state.alaInstallReleases == other.state.alaInstallReleases;

  @override
  int get hashCode =>
      state.currentProject.hashCode ^ state.alaInstallReleases.hashCode;
}
