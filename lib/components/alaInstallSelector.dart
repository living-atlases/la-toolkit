import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/redux/actions.dart';

class ALAInstallSelector extends StatefulWidget {
  ALAInstallSelector({Key key}) : super(key: key);

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
      List<DropdownMenuItem<String>> releases = [];
      var currentProject = vm.state.currentProject;
      vm.state.alaInstallReleases.forEach((element) =>
          releases.add(DropdownMenuItem(child: Text(element), value: element)));
      return Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          /* decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10)), */
          child: Tooltip(
              message: "Choose the latest release to update your portal",
              child: DropdownButtonFormField(
                  icon: Icon(Icons.arrow_drop_down),
                  iconSize: 32,
                  // hint: Text("Recommended a recent version"),
                  // underline: SizedBox(),
                  decoration: InputDecoration(
                    // filled: true,
                    // fillColor: Colors.grey[500],
                    labelText: 'Using ala-install release:',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    // border: new CustomBorderTextFieldSkin().getSkin(),
                  ),
                  value: currentProject.alaInstallRelease ??
                      vm.state.alaInstallReleases[0],
                  items: releases,
                  onChanged: (value) {
                    currentProject.alaInstallRelease = value;
                    vm.onUpdateProject(currentProject);
                  })));
    });
  }
}

class _ALAInstallSelectorViewModel {
  final AppState state;
  final void Function(LAProject project) onUpdateProject;

  _ALAInstallSelectorViewModel({this.state, this.onUpdateProject});
}
