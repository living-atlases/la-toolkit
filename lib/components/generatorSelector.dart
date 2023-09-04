import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/softwareSelector.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';

class GeneratorSelector extends StatefulWidget {
  final Function(String?) onChange;

  const GeneratorSelector({Key? key, required this.onChange}) : super(key: key);

  @override
  State<GeneratorSelector> createState() => _GeneratorSelectorState();
}

class _GeneratorSelectorState extends State<GeneratorSelector> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _GeneratorSelectorViewModel>(
        converter: (store) {
      return _GeneratorSelectorViewModel(state: store.state);
    }, builder: (BuildContext context, _GeneratorSelectorViewModel vm) {
      LAProject currentProject = vm.state.currentProject;
      return SoftwareSelector(
          label: "la-generator release:",
          versions: vm.state.generatorReleases,
          initialValue: currentProject.generatorRelease,
          roundStyle: false,
          onChange: widget.onChange);
    });
  }
}

class _GeneratorSelectorViewModel {
  final AppState state;

  _GeneratorSelectorViewModel({required this.state});
}
