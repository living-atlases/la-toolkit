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
          onUpdateProject: (project, updateCurrentProject, openProjectView) =>
              store.dispatch(UpdateProject(
                  project, updateCurrentProject, openProjectView)));
    }, builder: (BuildContext context, _ALAInstallSelectorViewModel vm) {
      LAProject currentProject = vm.state.currentProject;
      return SoftwareSelector(
          label: "Using ala-install release:",
          initialValue: currentProject.alaInstallRelease,
          versions: vm.state.alaInstallReleases,
          onChange: (String? value) {
            String version = value ?? vm.state.alaInstallReleases[0];
            currentProject.alaInstallRelease = version;
            vm.onUpdateProject(currentProject, true, false);
            for (LAProject hub in currentProject.hubs) {
              hub.alaInstallRelease = version;
              vm.onUpdateProject(hub, false, false);
            }
          });
    });
  }
}

class _ALAInstallSelectorViewModel {
  final AppState state;
  final void Function(
          LAProject project, bool updateCurrentProject, bool openProjectView)
      onUpdateProject;

  _ALAInstallSelectorViewModel(
      {required this.state, required this.onUpdateProject});
}
