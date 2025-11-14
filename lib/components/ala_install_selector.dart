import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../models/appState.dart';
import '../models/la_project.dart';
import 'software_selector.dart';

class ALAInstallSelector extends StatefulWidget {
  const ALAInstallSelector({super.key, required this.onChange});

  final Function(String?) onChange;

  @override
  State<ALAInstallSelector> createState() => _ALAInstallSelectorState();
}

class _ALAInstallSelectorState extends State<ALAInstallSelector> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ALAInstallSelectorViewModel>(
        converter: (Store<AppState> store) {
      return _ALAInstallSelectorViewModel(state: store.state);
    }, builder: (BuildContext context, _ALAInstallSelectorViewModel vm) {
      final LAProject currentProject = vm.state.currentProject;
      return SoftwareSelector(
          label: 'ala-install release:',
          initialValue: currentProject.alaInstallRelease,
          versions: vm.state.alaInstallReleases,
          roundStyle: false,
          onChange: widget.onChange);
    });
  }
}

class _ALAInstallSelectorViewModel {
  _ALAInstallSelectorViewModel({required this.state});

  final AppState state;
}
