import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/serviceStatusCard.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';

class ServicesStatusPanel extends StatefulWidget {
  ServicesStatusPanel({Key? key}) : super(key: key);

  @override
  _ServicesStatusPanelState createState() => _ServicesStatusPanelState();
}

class _ServicesStatusPanelState extends State<ServicesStatusPanel> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ServicesStatusPanelViewModel>(
        distinct: true,
        converter: (store) {
          return _ServicesStatusPanelViewModel(
            project: store.state.currentProject,
          );
        },
        builder: (BuildContext context, _ServicesStatusPanelViewModel vm) {
          return Wrap(children: [
            for (var service in vm.project.linkList) ServiceStatusCard(service)
          ]);
        });
  }
}

class _ServicesStatusPanelViewModel {
  final LAProject project;

  _ServicesStatusPanelViewModel({required this.project});
}
