import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/genericTextFormField.dart';
import 'package:la_toolkit/components/helpIcon.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/laVariableDesc.dart';
import 'package:la_toolkit/redux/appActions.dart';
import 'package:la_toolkit/utils/StringUtils.dart';

import 'components/laAppBar.dart';
import 'components/scrollPanel.dart';
import 'models/laServiceDesc.dart';

const _textFieldBorder = true;

class LAProjectTunePage extends StatelessWidget {
  static const routeName = "tune";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ProjectTuneViewModel>(
      distinct: true,
      converter: (store) {
        return _ProjectTuneViewModel(
          state: store.state,
          onSaveProject: (project) {
            store.dispatch(SaveCurrentProject(project));
          },
          onUpdateProject: (project) {
            store.dispatch(UpdateProject(project));
            store.dispatch(OpenProjectTools(project));
          },
          onCancel: (project) {
            store.dispatch(OpenProjectTools(project));
          },
        );
      },
      builder: (BuildContext context, _ProjectTuneViewModel vm) {
        var currentProject = vm.state.currentProject;
        var varCatName = currentProject.getServicesNameListInUse();
        varCatName.add(LAServiceName.all.toS());
        List<ListItem> items = [];
        var lastTitle;
        LAVariableDesc.map.entries.forEach((entry) {
          if (entry.value.service != lastTitle) {
            items.add(HeadingItem(entry.value.service == LAServiceName.all
                ? "Variables common to all services"
                : "${StringUtils.capitalize(LAServiceDesc.getE(entry.value.service).name)} variables"));

            lastTitle = entry.value.service;
          }
          items.add(MessageItem(currentProject, entry.value, (value) {
            currentProject.setVariable(entry.value, value);
            vm.onSaveProject(currentProject);
          }));
        });
        return Scaffold(
            key: _scaffoldKey,
            appBar: LAAppBar(
                context: context,
                title: vm.state.status.title,
                showLaIcon: true,
                actions: [
                  FlatButton(
                      // icon: Icon(Icons.cancel),
                      textColor: Colors.white,
                      child: Text(
                        "CANCEL",
                      ),
                      onPressed: () => vm.onCancel(vm.state.currentProject)),
                  IconButton(
                    icon: Tooltip(
                        child: Icon(Icons.save, color: Colors.white),
                        message: "Save the current LA project variables"),
                    onPressed: () {
                      vm.onUpdateProject(currentProject);
                    },
                  )
                ]),
            body: ScrollPanel(
                withPadding: true,
                child: Form(
                    key: _formKey,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                              "Note: This part is under development. Right now just testing validations,..."),
                          ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            // Let the ListView know how many items it needs to build.
                            itemCount: items.length,
                            // Provide a builder function. This is where the magic happens.
                            // Convert each item into a widget based on the type of item it is.
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return ListTile(
                                // contentPadding: EdgeInsets.zero,
                                title: item.buildTitle(context),
                                subtitle: item.buildSubtitle(context),
                              );
                            },
                          ),
                          SizedBox(height: 20),
                          HeadingItem("Other variables").buildTitle(context),
                          SizedBox(height: 30),
                          Text(
                            "Write here other extra ansible variables that are not configurable in the previous forms:",
                            style:
                                TextStyle(fontSize: 18, color: Colors.black54),
                          ),
                          SizedBox(height: 20),
                          ListTile(
                              title: GenericTextFormField(
                                  //label:
                                  //  ,
                                  hint: "",
                                  initialValue: _initialExtraAnsibleVariables(
                                      currentProject),
                                  maxLines: 100,
                                  fillColor: Colors.grey[100],
                                  //hintStyle: TextStyle(
                                  //    fontSize: 20, color: Colors.black54),
                                  enabledBorder: true,
                                  allowEmpty: true,
                                  monoSpaceFont: true,
                                  error: "",
                                  onChanged: (value) {}),
                              trailing: HelpIcon(
                                  wikipage:
                                      "Version-control-of-your-configurations#about-maintaining-dataconfig"))
                        ]))));
      },
    );
  }

  String _initialExtraAnsibleVariables(LAProject currentProject) {
    return '''
${_doTitle(" Other variables common to all services ")}
[all:vars]

# End of common variables
${_doLine()}
                                        
                                                                                                                                                                      
''' +
        currentProject.getServicesNameListInUse().map((s) {
          final String title =
              " ${LAServiceDesc.map[s].name} ${LAServiceDesc.map[s].name != LAServiceDesc.map[s].nameInt ? '(' + LAServiceDesc.map[s].nameInt + ') ' : ''}extra variables ";
          return '''

${_doTitle(title)} 
[${LAServiceDesc.map[s].group}:vars]

# End of ${StringUtils.capitalize(LAServiceDesc.map[s].name)} variables
${_doLine()}
''';
        }).join("\n\n");
  }

  String _doTitle(String title) =>
      ('#' * 70).replaceRange(5, title.length - 5, title);

  String _doLine() => '#' * 80;
}

/// The base class for the different types of items the list can contain.
abstract class ListItem {
  /// The title line to show in a list item.
  Widget buildTitle(BuildContext context);

  /// The subtitle line, if any, to show in a list item.
  Widget buildSubtitle(BuildContext context);
}

/// A ListItem that contains data to display a heading.
class HeadingItem implements ListItem {
  final String heading;

  HeadingItem(this.heading);

  Widget buildTitle(BuildContext context) {
    return Text(heading, style: Theme.of(context).textTheme.headline5);
  }

  Widget buildSubtitle(BuildContext context) => null;
}

/// A ListItem that contains data to display a message.
class MessageItem implements ListItem {
  LAVariableDesc variable;
  LAProject project;
  ValueChanged<String> onChanged;
  MessageItem(this.project, this.variable, this.onChanged);

  Widget buildTitle(BuildContext context) {
    if (variable.type == LAVariableType.String) {
      return ListTile(
          title: GenericTextFormField(
              label: variable.name,
              hint: variable.hint,
              initialValue: project.getVariable(variable.nameInt).value,
              allowEmpty: true,
              enabledBorder: false,
              regexp: variable.regExp,
              error: variable.error,
              onChanged: (value) {
                onChanged(value);
              }),
          trailing:
              variable.help != null ? HelpIcon(wikipage: variable.help) : null);
    } else
      return Text("Type ${variable.type} not yet ready");
  }

  Widget buildSubtitle(BuildContext context) => null; // Text("");
}

class _ProjectTuneViewModel {
  final AppState state;
  final void Function(LAProject) onUpdateProject;
  final void Function(LAProject) onSaveProject;
  final void Function(LAProject) onCancel;

  _ProjectTuneViewModel(
      {this.state, this.onUpdateProject, this.onSaveProject, this.onCancel});
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ProjectTuneViewModel &&
          runtimeType == other.runtimeType &&
          state.currentProject == other.state.currentProject;

  @override
  int get hashCode => state.currentProject.hashCode;
}