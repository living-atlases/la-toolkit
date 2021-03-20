import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/genericTextFormField.dart';
import 'package:la_toolkit/components/helpIcon.dart';
import 'package:la_toolkit/laTheme.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/laVariableDesc.dart';
import 'package:la_toolkit/redux/appActions.dart';
import 'package:la_toolkit/utils/StringUtils.dart';
import 'package:la_toolkit/utils/regexp.dart';

import 'components/appSnackBar.dart';
import 'components/laAppBar.dart';
import 'components/scrollPanel.dart';
import 'models/laServiceDesc.dart';
import 'models/laVariable.dart';

class LAProjectTunePage extends StatelessWidget {
  static const routeName = "tune";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final bool _endNoteEnabled = false;
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ProjectTuneViewModel>(
      // Fails the switch distinct: true,
      converter: (store) {
        return _ProjectTuneViewModel(
          project: store.state.currentProject,
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
        LAProject project = vm.project;
        List<String> varCatName = project.getServicesNameListInUse();
        varCatName.add(LAServiceName.all.toS());
        List<ListItem> items = [];
        LAServiceName? lastCategory;
        LAVariableSubcategory? lastSubcategory;
        LAVariableDesc.map.entries
            .where((laVar) =>
                laVar.value.inTunePage &&
                // Show var where depend service is in use
                (laVar.value.depends == null ||
                    (laVar.value.depends != null &&
                        project.getService(laVar.value.depends!.toS()).use)) &&
                ((!project.advancedTune && !laVar.value.advanced) ||
                    project.advancedTune))
            .forEach((entry) {
          if (entry.value.service != lastCategory) {
            items.add(HeadingItem(entry.value.service == LAServiceName.all
                ? "Variables common to all services"
                : "${StringUtils.capitalize(LAServiceDesc.getE(entry.value.service).name)} variables"));

            lastCategory = entry.value.service;
          }
          if (entry.value.subcategory != lastSubcategory &&
              entry.value.subcategory != null) {
            items.add(HeadingItem(entry.value.subcategory!.title, true));
            lastSubcategory = entry.value.subcategory;
          }
          items.add(MessageItem(project, entry.value, (value) {
            project.setVariable(entry.value, value);
            vm.onSaveProject(project);
          }));
        });
        return Scaffold(
            key: _scaffoldKey,
            appBar: LAAppBar(
                context: context,
                titleIcon: Icons.edit,
                title: LAProjectViewStatus.tune.title,
                showLaIcon: false,
                actions: [
                  TextButton(
                      // icon: Icon(Icons.cancel),
                      style: TextButton.styleFrom(primary: Colors.white),
                      child: Text(
                        "CANCEL",
                      ),
                      onPressed: () => vm.onCancel(project)),
                  IconButton(
                    icon: Tooltip(
                        child: Icon(Icons.save, color: Colors.white),
                        message: "Save the current LA project variables"),
                    onPressed: () {
                      vm.onUpdateProject(project);
                    },
                  )
                ]),
            body: AppSnackBar(ScrollPanel(
                withPadding: true,
                child: Form(
                    key: _formKey,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          ListTile(
                              // contentPadding: EdgeInsets.zero,
                              title: const Text(
                                'Advanced options',
                              ),
                              trailing: Switch(
                                  value: project.advancedTune,
                                  onChanged: (value) {
                                    project.advancedTune = value;
                                    vm.onSaveProject(project);
                                  })),
                          SizedBox(height: 20),
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
                          if (project.advancedTune) SizedBox(height: 20),
                          if (project.advancedTune)
                            HeadingItem("Other variables").buildTitle(context),
                          if (project.advancedTune) SizedBox(height: 30),
                          if (project.advancedTune)
                            Text(
                              "Write here other extra ansible variables that are not configurable in the previous forms:",
                              style: TextStyle(
                                  fontSize: 18, color: Colors.black54),
                            ),
                          if (project.advancedTune) SizedBox(height: 20),
                          if (project.advancedTune)
                            // This breaks the newline enter key:
                            //ListTile(
                            //                        title:
                            GenericTextFormField(
                                initialValue: project
                                            .additionalVariables.length >
                                        0
                                    ? utf8.decode(base64
                                        .decode(project.additionalVariables))
                                    : _initialExtraAnsibleVariables(project),
                                minLines: 100,
                                maxLines: null,
                                fillColor: Colors.grey[100],
                                enabledBorder: true,
                                allowEmpty: true,
                                keyboardType: TextInputType.multiline,
                                monoSpaceFont: true,
                                error: "",
                                onChanged: (value) {
                                  project.additionalVariables =
                                      base64.encode(utf8.encode(value));
                                  vm.onSaveProject(project);
                                }),
                          /* trailing: HelpIcon(
                                    wikipage:
                                        "Version-control-of-your-configurations#about-maintaining-dataconfig")), */
                          SizedBox(height: 20),
                          if (_endNoteEnabled)
                            Row(children: [
                              Text(
                                  "Note: the colors of the variables values indicate if these values are "),
                              Text("already deployed",
                                  style: LAColorTheme.deployedTextStyle),
                              Text(" in your servers or "),
                              Text("they are not deployed yet",
                                  style: LAColorTheme.unDeployedTextStyle),
                              Text("."),
                            ]),
                        ])))));
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
        currentProject.services.values.map((service) {
          String name = service.nameInt;
          LAServiceDesc serviceDesc = LAServiceDesc.map[name]!;
          final String title =
              " ${serviceDesc.name} ${serviceDesc.name != serviceDesc.nameInt ? '(' + serviceDesc.nameInt + ') ' : ''}extra variables ";
          return '''

${_doTitle(title)} 
${service.use ? '' : '# '}[${serviceDesc.group}:vars]${service.use ? '' : ' #uncomment this line if you enable this service to tune it'} 

# End of ${StringUtils.capitalize(serviceDesc.name)} variables
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
  final bool subheading;

  HeadingItem(this.heading, [this.subheading = false]);

  Widget buildTitle(BuildContext context) {
    return Text(heading,
        style: !subheading
            ? Theme.of(context).textTheme.headline5
            : Theme.of(context).textTheme.headline6!.copyWith(
                fontSize: 18, color: LAColorTheme.laThemeData.hintColor));
  }

  Widget buildSubtitle(BuildContext context) => Text("");
}

// A ListItem that contains data to display a message.
class MessageItem implements ListItem {
  LAVariableDesc variable;
  LAProject project;
  ValueChanged<Object> onChanged;
  MessageItem(this.project, this.variable, this.onChanged);

  Widget buildTitle(BuildContext context) {
    final initialValue = project.getVariable(variable.nameInt).value;
    final bool deployed = project.getVariable(variable.nameInt).status ==
        LAVariableStatus.deployed;
    var defValue;
    if (variable.defValue != null) defValue = variable.defValue!(project);
    return ListTile(
        title: (variable.type == LAVariableType.bool)
            ? SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: initialValue ?? defValue ?? false,
                title: Text(variable.name,
                    style:
                        TextStyle(color: LAColorTheme.laThemeData.hintColor)),
                onChanged: (bool newValue) {
                  onChanged(newValue);
                })
            : GenericTextFormField(
                label: variable.name,
                hint: variable.hint,
                initialValue: initialValue ?? defValue,
                allowEmpty: true,
                enabledBorder: false,
                deployed: deployed,
                regexp: variable.type == LAVariableType.int
                    ? LARegExp.int
                    : variable.type == LAVariableType.double
                        ? LARegExp.double
                        : variable.regExp,
                error: variable.error,
                onChanged: (newValue) {
                  onChanged(newValue);
                }),
        trailing:
            variable.help != null ? HelpIcon(wikipage: variable.help!) : null);
  }

  Widget buildSubtitle(BuildContext context) => Text("");
}

class _ProjectTuneViewModel {
  final LAProject project;
  final void Function(LAProject) onUpdateProject;
  final void Function(LAProject) onSaveProject;
  final void Function(LAProject) onCancel;

  _ProjectTuneViewModel(
      {required this.project,
      required this.onUpdateProject,
      required this.onSaveProject,
      required this.onCancel});
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ProjectTuneViewModel &&
          runtimeType == other.runtimeType &&
          project == other.project;

  @override
  int get hashCode => project.hashCode;
}
