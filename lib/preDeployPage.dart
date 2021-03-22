import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/helpIcon.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/projectViewPage.dart';

import 'components/deployBtn.dart';
import 'components/laAppBar.dart';
import 'components/scrollPanel.dart';
import 'laTheme.dart';
import 'models/laProject.dart';

class PreDeployPage extends StatefulWidget {
  static const routeName = "predeploy";

  @override
  _PreDeployPageState createState() => _PreDeployPageState();
}

class _PreDeployPageState extends State<PreDeployPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _addUbuntuUser = true;
  bool _giveSudo = true;
  bool _etcHost = true;
  bool _solrLimits = true;
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      distinct: true,
      converter: (store) {
        return _ViewModel(
            project: store.state.currentProject,
            onDoPreDeployTasks: (project) {});
      },
      builder: (BuildContext context, _ViewModel vm) {
        String execBtn = "Run tasks";
        VoidCallback? onTap =
            _addUbuntuUser || _giveSudo || _etcHost || _solrLimits
                ? () => vm.onDoPreDeployTasks(vm.project)
                : null;
        String defUser = vm.project.getVariableValue("ansible_user").toString();
        return Scaffold(
            key: _scaffoldKey,
            appBar: LAAppBar(
                context: context,
                titleIcon: Icons.foundation,
                showBack: true,
                title: "Pre-Deploy Tasks",
                backRoute: LAProjectViewPage.routeName,
                showLaIcon: false,
                actions: []),
            body: ScrollPanel(
                withPadding: true,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1, // 10%
                      child: Container(),
                    ),
                    Expanded(
                        flex: 8, // 80%,
                        child: Column(
                          children: [
                            PreDeployTask(
                                title:
                                    "Add the '$defUser' user to your servers",
                                initialValue: _addUbuntuUser,
                                help:
                                    "Before-Start-Your-LA-Installation#default-user-ubuntu",
                                onChanged: (newValue) =>
                                    setState(() => _addUbuntuUser = newValue)),
                            PreDeployTask(
                                title:
                                    "Give the 'ubuntu' user sudo permissions",
                                initialValue: _giveSudo,
                                help: "Before-Start-Your-LA-Installation#sudo",
                                onChanged: (newValue) =>
                                    setState(() => _giveSudo = newValue)),
                            PreDeployTask(
                                title:
                                    "Configure the '/etc/hosts' in your servers",
                                initialValue: _etcHost,
                                help:
                                    "Before-Start-Your-LA-Installation#fake-dns-calls",
                                onChanged: (newValue) =>
                                    setState(() => _etcHost = newValue)),
                            PreDeployTask(
                                title:
                                    "Adjust solr limits (increase the number of files and process allowed to create)",
                                initialValue: _solrLimits,
                                help:
                                    "Before-Start-Your-LA-Installation#solr-limits",
                                onChanged: (newValue) =>
                                    setState(() => _solrLimits = newValue)),
                            LaunchBtn(onTap: onTap, execBtn: execBtn),
                          ],
                        )),
                    Expanded(
                      flex: 1, // 10%
                      child: Container(),
                    )
                  ],
                )));
      },
    );
  }
}

class PreDeployTask extends StatelessWidget {
  final String title;
  final String? help;
  final bool initialValue;
  final Function(bool) onChanged;
  const PreDeployTask({
    Key? key,
    required this.title,
    this.help,
    required this.initialValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
        // contentPadding: EdgeInsets.zero,
        value: initialValue,
        title: Text(this.title,
            style: TextStyle(color: LAColorTheme.laThemeData.hintColor)),
        secondary: help != null ? HelpIcon(wikipage: help!) : null,
        onChanged: (bool newValue) {
          onChanged(newValue);
        });
  }
}

class _ViewModel {
  final LAProject project;
  final Function(LAProject) onDoPreDeployTasks;
  _ViewModel({required this.project, required this.onDoPreDeployTasks});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ViewModel &&
          runtimeType == other.runtimeType &&
          project == other.project;

  @override
  int get hashCode => project.hashCode;
}
