import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/softwareSelector.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/redux/actions.dart';

class GeneratorSelector extends StatefulWidget {
  const GeneratorSelector({Key? key}) : super(key: key);

  @override
  _GeneratorSelectorState createState() => _GeneratorSelectorState();
}

class _GeneratorSelectorState extends State<GeneratorSelector> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _GeneratorSelectorViewModel>(
        converter: (store) {
      return _GeneratorSelectorViewModel(
          state: store.state,
          onUpdateProject:
              (project, bool updateCurrentProject, bool openProjectView) =>
                  store.dispatch(UpdateProject(
                      project, updateCurrentProject, openProjectView)));
    }, builder: (BuildContext context, _GeneratorSelectorViewModel vm) {
      LAProject currentProject = vm.state.currentProject;
      return SoftwareSelector(
          label: "Using la-generator release:",
          versions: vm.state.generatorReleases,
          initialValue: currentProject.generatorRelease,
          onChange: (String? value) {
            var version = value ?? vm.state.generatorReleases[0];
            currentProject.generatorRelease = version;
            vm.onUpdateProject(currentProject, true, false);
            for (LAProject hub in currentProject.hubs) {
              hub.generatorRelease = version;
              vm.onUpdateProject(hub, false, false);
            }
          });
    });
  }
}

class _GeneratorSelectorViewModel {
  final AppState state;
  final void Function(
          LAProject project, bool updateCurrentProject, bool openProjectView)
      onUpdateProject;

  _GeneratorSelectorViewModel(
      {required this.state, required this.onUpdateProject});
}
