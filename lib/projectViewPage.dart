import 'package:flutter/material.dart' as projectViewPage;
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/tool.dart';
import 'package:la_toolkit/components/toolShortcut.dart';
import 'package:mdi/mdi.dart';
import 'package:responsive_grid/responsive_grid.dart';

import 'components/laAppBar.dart';
import 'components/laProjectTimeline.dart';
import 'models/appState.dart';
import 'models/laProject.dart';
import 'redux/actions.dart';

class LAProjectViewPage extends projectViewPage.StatelessWidget {
  static const routeName = "tools";
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  projectViewPage.Widget build(projectViewPage.BuildContext context) {
    return StoreConnector<AppState, _ProjectPageViewModel>(converter: (store) {
      return _ProjectPageViewModel(
        state: store.state,
        onOpenProject: (project) => store.dispatch(OpenProject(project)),
        onDelProject: (project) => store.dispatch(DelProject(project)),
      );
    }, builder: (BuildContext context, _ProjectPageViewModel vm) {
      // TODO: Move this to constants and use the same in timeline
      List<Tool> tools = [
        Tool(
            icon: Icon(Icons.edit),
            title: "Edit",
            tooltip: "Edit the basic configuration",
            enabled: true,
            action: () => vm.onOpenProject(vm.state.currentProject)),
        Tool(
            icon: Icon(Icons.settings_ethernet),
            tooltip: "Test if your servers are reachable from here",
            title: "Test Connectivity"),
        Tool(
            icon: Icon(Icons.tune),
            title: "Tune Configuration",
            tooltip: "Fine tune the configuration",
            enabled: false),
        Tool(icon: Icon(Icons.foundation), title: "Pre-Deploy Tasks"),
        Tool(
            icon: Icon(Mdi.rocketLaunch),
            title: "Deploy",
            tooltip: "Install/update your LA Portal or some services",
            grid: 12),
        Tool(icon: Icon(Icons.house_siding), title: "Post-Deploy Tasks"),

        Tool(icon: Icon(Icons.format_paint), title: "Branding Deploy"),
        Tool(icon: Icon(Icons.fact_check), title: "Test Services"),
        Tool(icon: Icon(Icons.pie_chart), title: "Stats"),
        Tool(
            icon: Icon(Icons.delete),
            title: "Delete",
            tooltip: "Delete this LA project",
            enabled: true,
            askConfirmation: true,
            action: () => vm.onDelProject(vm.state.currentProject)),
        // To think about:
        // - Data generation
        // - Inventories download
      ];
      return Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white,
          appBar: LAAppBar(
              context: context,
              showLaIcon: true,
              title: "Toolkit of ${vm.state.currentProject.shortName} Portal"),
          body: Container(
              margin: EdgeInsets.symmetric(horizontal: 80, vertical: 20),
              child: Column(children: [
                Container(
                    padding: EdgeInsets.only(top: 80, bottom: 50),
                    child: LAProjectTimeline()),
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
              ])));
    });
  }
}

class _ProjectPageViewModel {
  final AppState state;
  final void Function(LAProject project) onOpenProject;
  final void Function(LAProject project) onDelProject;

  _ProjectPageViewModel({this.state, this.onOpenProject, this.onDelProject});
}
