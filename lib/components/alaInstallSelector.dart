import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/softwareSelector.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';

class ALAInstallSelector extends StatefulWidget {
  final Function(String?) onChange;

  const ALAInstallSelector({Key? key, required this.onChange})
      : super(key: key);

  @override
  State<ALAInstallSelector> createState() => _ALAInstallSelectorState();
}

class _ALAInstallSelectorState extends State<ALAInstallSelector> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ALAInstallSelectorViewModel>(
        converter: (store) {
      return _ALAInstallSelectorViewModel(state: store.state);
    }, builder: (BuildContext context, _ALAInstallSelectorViewModel vm) {
      LAProject currentProject = vm.state.currentProject;
      return SoftwareSelector(
          label: "ala-install release:",
          initialValue: currentProject.alaInstallRelease,
          versions: vm.state.alaInstallReleases,
          roundStyle: false,
          onChange: widget.onChange);
    });
  }
}

class _ALAInstallSelectorViewModel {
  final AppState state;

  _ALAInstallSelectorViewModel({required this.state});
}
