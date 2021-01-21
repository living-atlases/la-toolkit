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
const _textFieldFilled = false;

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
        var current = "";
        LAVariableDesc.map.entries.forEach((entry) {
          if (entry.key != current) {
            items.add(HeadingItem(entry.key == "all"
                ? "Variables common to all services"
                : "${StringUtils.capitalize(LAServiceDesc.map[entry.key].name)} variables"));
            current = entry.key;
          }
          entry.value.forEach((serviceVar) {
            items.add(MessageItem(serviceVar));
          });
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
                        message: "Save the current LA project"),
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
                          ListTile(
                              title: GenericTextFormField(
                                  label:
                                      "Write here other extra ansible variables that are not configurable in the previous forms",
                                  hint: "",
                                  initialValue:
                                      "\n# ----- Other variables common to all services -----\n[all:vars]\n\n" +
                                          currentProject
                                              .getServicesNameListInUse()
                                              .map((s) =>
                                                  "# ----- ${StringUtils.capitalize(LAServiceDesc.map[s].desc)} extra variables -----\n[$s:vars]\n")
                                              .join("\n\n"),
                                  maxLines: 50,
                                  filled: _textFieldFilled,
                                  enabledBorder: _textFieldBorder,
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
  MessageItem(this.variable);

  Widget buildTitle(BuildContext context) {
    if (variable.type == LAVariableType.String) {
      return ListTile(
          title: GenericTextFormField(
              label: variable.name,
              hint: variable.hint,
              initialValue: null,
              allowEmpty: true,
              filled: _textFieldFilled,
              enabledBorder: false,
              regexp: variable.regExp,
              error: variable.error,
              onChanged: (value) {}),
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
  final void Function(LAProject) onCancel;

  _ProjectTuneViewModel({this.state, this.onUpdateProject, this.onCancel});
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ProjectTuneViewModel &&
          runtimeType == other.runtimeType &&
          state.currentProject == other.state.currentProject;

  @override
  int get hashCode => state.currentProject.hashCode;
}
