import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import '../models/app_state.dart';
import '../models/la_project.dart';
import 'software_selector.dart';

class GeneratorSelector extends StatefulWidget {
  const GeneratorSelector({super.key, required this.onChange});

  final Function(String?) onChange;

  @override
  State<GeneratorSelector> createState() => _GeneratorSelectorState();
}

class _GeneratorSelectorState extends State<GeneratorSelector> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _GeneratorSelectorViewModel>(converter: (Store<AppState> store) {
      return _GeneratorSelectorViewModel(state: store.state);
    }, builder: (BuildContext context, _GeneratorSelectorViewModel vm) {
      final LAProject currentProject = vm.state.currentProject;
      return SoftwareSelector(
          label: 'la-generator release:',
          versions: vm.state.generatorReleases,
          initialValue: currentProject.generatorRelease,
          roundStyle: false,
          onChange: widget.onChange);
    });
  }
}

class _GeneratorSelectorViewModel {
  _GeneratorSelectorViewModel({required this.state});

  final AppState state;
}
