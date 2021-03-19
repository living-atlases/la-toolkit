import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/redux/actions.dart';
import 'package:la_toolkit/utils/StringUtils.dart';
import 'package:smart_select/smart_select.dart';

class ThemeSelector extends StatefulWidget {
  ThemeSelector({Key? key}) : super(key: key);

  @override
  _ThemeSelectorState createState() => _ThemeSelectorState();
}

List<Map<String, String>> themes = [
  {'value': 'clean', 'desc': 'Clean Bootstrap compatible theme'},
  {'value': 'cosmo', 'desc': ''},
  {'value': 'darkly', 'desc': 'Flatly night mode theme'},
  {'value': 'flatly', 'desc': 'Flat and modern theme'},
  {'value': 'material', 'desc': 'Material-Bootstrap experimental theme'},
  {'value': 'paper', 'desc': 'Material inspired theme'},
  {'value': 'sandstone', 'desc': ''},
  {'value': 'simplex', 'desc': 'Minimalist theme that works great'},
  {'value': 'slate', 'desc': ''},
  {'value': 'superhero', 'desc': ''},
  {'value': 'yeti', 'desc': ''},
  {'value': 'custom', 'desc': 'None of them. We\'ll use a self made theme'},
];

class _ThemeSelectorState extends State<ThemeSelector> {
  GlobalKey<S2MultiState<String>> _selectKey =
      GlobalKey<S2MultiState<String>>();
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ThemeSelectorViewModel>(
        distinct: true,
        converter: (store) {
          return _ThemeSelectorViewModel(
              project: store.state.currentProject,
              onSaveProject: (project) =>
                  store.dispatch(SaveCurrentProject(project)));
        },
        builder: (BuildContext context, _ThemeSelectorViewModel vm) {
          LAProject currentProject = vm.project;
          return SmartSelect<String>.single(
              key: _selectKey,
              value: currentProject.theme,
              title: "Select your branding theme",
              choiceItems: S2Choice.listFrom<String, Map<String, String>>(
                  source: themes,
                  value: (index, e) => e['value'],
                  title: (index, e) => e['value'],
                  subtitle: (index, e) => e['desc']),
              // placeholder: "",
              modalType: S2ModalType.fullPage,
              choiceType: S2ChoiceType.chips,
              choiceStyle: S2ChoiceStyle(
                  activeColor: Colors.black12,
                  borderOpacity: 0,
                  // spacing: 20,
                  activeBrightness: Brightness.dark,
                  activeBorderOpacity: 1),
              tileBuilder: (context, state) {
                return S2Tile.fromState(
                  state,
                  // padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  leading: const Icon(Icons.format_paint),
                  // trailing:
                  // isTwoLine: true,
                );
              },
              choiceTitleBuilder: (context, item, filter) {
                return Padding(
                    padding: EdgeInsets.all(40),
                    child: Container(
                        // color: Colors.white,
                        child: Column(children: [
                      SizedBox(height: 10),
                      Text(StringUtils.capitalize(item.title),
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black54)),
                      Text(item.subtitle,
                          style:
                              TextStyle(fontSize: 14, color: Colors.black54)),
                      SizedBox(height: 10),
                      if (item.title != "custom")
                        Container(
                            height: 300,
                            child: Image.asset(
                                "assets/images/themes/${item.title}.png"))
                    ])));
              },
              onChange: (state) {
                currentProject.theme = state.value;
                vm.onSaveProject(currentProject);
              });
        });
  }
}

class _ThemeSelectorViewModel {
  final LAProject project;
  final void Function(LAProject project) onSaveProject;

  _ThemeSelectorViewModel({required this.project, required this.onSaveProject});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ThemeSelectorViewModel &&
          runtimeType == other.runtimeType &&
          project == other.project;

  @override
  int get hashCode => project.hashCode;
}
