import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/softwareSelector.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/redux/actions.dart';

class GeneratorSelector extends StatefulWidget {
  GeneratorSelector({Key key}) : super(key: key);

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
          onUpdateProject: (project) => store.dispatch(UpdateProject(project)));
    }, builder: (BuildContext context, _GeneratorSelectorViewModel vm) {
      var currentProject = vm.state.currentProject;
      return SoftwareSelector(
          label: "Using generator-la release:",
          tooltip: "Choose the latest release to update your portal",
          initialValue:
              currentProject.generatorRelease ?? vm.state.generatorReleases[0],
          versions: vm.state.generatorReleases,
          onChange: (value) {
            currentProject.generatorRelease = value;
            vm.onUpdateProject(currentProject);
          });
    });
  }
}

class _GeneratorSelectorViewModel {
  final AppState state;
  final void Function(LAProject project) onUpdateProject;

  _GeneratorSelectorViewModel({this.state, this.onUpdateProject});
}
