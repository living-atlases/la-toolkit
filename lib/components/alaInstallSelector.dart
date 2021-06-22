import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/softwareSelector.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/redux/actions.dart';

class ALAInstallSelector extends StatefulWidget {
  const ALAInstallSelector({Key? key}) : super(key: key);

  @override
  _ALAInstallSelectorState createState() => _ALAInstallSelectorState();
}

class _ALAInstallSelectorState extends State<ALAInstallSelector> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ALAInstallSelectorViewModel>(
        converter: (store) {
      return _ALAInstallSelectorViewModel(
          state: store.state,
          onUpdateProject: (project) => store.dispatch(UpdateProject(project)));
    }, builder: (BuildContext context, _ALAInstallSelectorViewModel vm) {
      LAProject currentProject = vm.state.currentProject;
      return SoftwareSelector(
          label: "Using ala-install release:",
          initialValue: currentProject.alaInstallRelease,
          versions: vm.state.alaInstallReleases,
          onChange: (String? value) {
            print(value);
            currentProject.alaInstallRelease =
                value ?? vm.state.alaInstallReleases[0];
            vm.onUpdateProject(currentProject);
          });
    });
  }
}

class _ALAInstallSelectorViewModel {
  final AppState state;
  final void Function(LAProject project) onUpdateProject;

  _ALAInstallSelectorViewModel(
      {required this.state, required this.onUpdateProject});
}
