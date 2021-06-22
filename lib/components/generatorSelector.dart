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
          onUpdateProject: (project) => store.dispatch(UpdateProject(project)));
    }, builder: (BuildContext context, _GeneratorSelectorViewModel vm) {
      LAProject currentProject = vm.state.currentProject;
      return SoftwareSelector(
          label: "Using la-generator release:",
          versions: vm.state.generatorReleases,
          initialValue: currentProject.generatorRelease,
          onChange: (String? value) {
            currentProject.generatorRelease =
                value ?? vm.state.generatorReleases[0];
            vm.onUpdateProject(currentProject);
          });
    });
  }
}

class _GeneratorSelectorViewModel {
  final AppState state;
  final void Function(LAProject project) onUpdateProject;

  _GeneratorSelectorViewModel(
      {required this.state, required this.onUpdateProject});
}
