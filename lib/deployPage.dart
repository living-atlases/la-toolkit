import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/tags.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/redux/appActions.dart';
import 'package:mdi/mdi.dart';
import 'package:smart_select/smart_select.dart';

import 'components/hostSelector.dart';
import 'components/laAppBar.dart';
import 'components/scrollPanel.dart';
import 'components/selectUtils.dart';
import 'components/servicesChipPanel.dart';
import 'components/tipsCard.dart';
import 'laTheme.dart';
import 'models/laProject.dart';

class DeployPage extends StatefulWidget {
  static const routeName = "deploy";
  @override
  _DeployPageState createState() => _DeployPageState();
}

class _DeployPageState extends State<DeployPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<S2MultiState<String>> _skipTagsKey =
      GlobalKey<S2MultiState<String>>();
  final GlobalKey<S2MultiState<String>> _selectTagsKey =
      GlobalKey<S2MultiState<String>>();
  List<String> _deployServices = [];
  List<String> _limitToServers = [];
  List<String> _skipTags = [];
  List<String> _tags = [];

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _DeployViewModel>(
      converter: (store) {
        return _DeployViewModel(
            state: store.state,
            onCancel: (project) {
              store.dispatch(OpenProjectTools(project));
            });
      },
      builder: (BuildContext context, _DeployViewModel vm) {
        return Scaffold(
            key: _scaffoldKey,
            appBar: LAAppBar(
                context: context,
                titleIcon: Mdi.rocketLaunch,
                title: "Deployment",
                showLaIcon: false,
                actions: [
                  IconButton(
                      icon: Tooltip(
                          child: const Icon(Icons.close, color: Colors.white),
                          message: "Cancel the deploy"),
                      onPressed: () => vm.onCancel(vm.state.currentProject)),
                ]),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 20),
                              Text("Select which services you want to deploy:"),
                              ServicesChipPanel(
                                  onChange: (s) =>
                                      setState(() => _deployServices = s)),
                              HostSelector(
                                  title: "Deploy to servers:",
                                  modalTitle:
                                      "Choose some servers if you want to limit the deploy to them",
                                  emptyPlaceholder: "All servers",
                                  serverList: vm.state.currentProject
                                      .serversWithServices()
                                      .map((e) => e.name)
                                      .toList(),
                                  icon: Mdi.server,
                                  onChange: (limitToServers) => setState(
                                      () => _limitToServers = limitToServers)),
                              _tagsSelector(
                                  key: _selectTagsKey,
                                  tags: TagsConstants.all,
                                  icon: Mdi.tagPlusOutline,
                                  title: "Tags:",
                                  placeHolder: "All",
                                  modalTitle:
                                      "Select the tags you want to limit to",
                                  onChange: (tags) =>
                                      setState(() => _tags = tags)),
                              _tagsSelector(
                                  key: _skipTagsKey,
                                  tags: TagsConstants.all,
                                  icon: Mdi.tagOffOutline,
                                  title: "Skip tags:",
                                  placeHolder: "None",
                                  modalTitle:
                                      "Select the tags you want to skip",
                                  onChange: (skipTags) =>
                                      setState(() => _skipTags = skipTags)),
                              TipsCard(
                                  text:
                                      '''Ansible tasks are marked with tags, and then when you run it you can use `--tags` or `--skip-tags` to execute or skip a subset of these tasks.''',
                                  margin: EdgeInsets.zero),
                              SizedBox(height: 40),
                              Center(
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                    ButtonTheme(
                                        // minWidth: 200.0,
                                        height: 100.0,
                                        child: ElevatedButton.icon(
                                            onPressed: _deployServices.isEmpty
                                                ? null
                                                : () => {
                                                      // vm.onCreateProject()},
                                                    },
                                            style: TextButton.styleFrom(
                                                primary: Colors.white,
                                                minimumSize: Size(140, 50),
                                                // primary: LAColorTheme.laPalette,
                                                // padding: const EdgeInsets.all(8.0),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30.0),
                                                  // side: BorderSide(color: Colors.red)),
                                                )),
                                            icon: Icon(Mdi.rocketLaunch,
                                                size: 30),
                                            label: new Text("Deploy",
                                                style:
                                                    TextStyle(fontSize: 18))))
                                  ])),
                            ])),
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

Widget _tagsSelector(
    {GlobalKey<S2MultiState<String>> key,
    List<String> tags,
    IconData icon,
    String title,
    String placeHolder,
    String modalTitle,
    final Function(List<String>) onChange}) {
  return SmartSelect<String>.multiple(
      key: key,
      value: [],
      title: title,
      choiceItems: S2Choice.listFrom<String, String>(
          source: tags, value: (index, e) => e, title: (index, e) => e),
      placeholder: placeHolder,
      modalHeader: true,
      modalTitle: modalTitle,
      modalType: S2ModalType.popupDialog,
      choiceType: S2ChoiceType.chips,
      modalConfirm: true,
      modalConfirmBuilder: (context, state) =>
          SelectUtils.modalConfirmBuild(state),
      modalHeaderStyle: S2ModalHeaderStyle(
          backgroundColor: LAColorTheme.laPalette,
          textStyle: TextStyle(color: Colors.white)),
      tileBuilder: (context, state) {
        return S2Tile.fromState(state,
            // padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            leading: Icon(icon),
            dense: false,
            isTwoLine: true,
            trailing: const Icon(Icons.keyboard_arrow_down)
            // isTwoLine: true,
            );
      },
      onChange: (state) {
        onChange(state.value);
      });
}

class _DeployViewModel {
  final AppState state;
  final Function(LAProject) onCancel;

  _DeployViewModel({this.state, this.onCancel});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _DeployViewModel &&
          runtimeType == other.runtimeType &&
          state == other.state;

  @override
  int get hashCode => state.hashCode;
}
