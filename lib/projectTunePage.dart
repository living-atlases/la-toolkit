import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/genericTextFormField.dart';
import 'package:la_toolkit/components/helpIcon.dart';
import 'package:la_toolkit/components/lintErrorPanel.dart';
import 'package:la_toolkit/laReleasesSelectors.dart';
import 'package:la_toolkit/laTheme.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/laProjectStatus.dart';
import 'package:la_toolkit/models/laVariableDesc.dart';
import 'package:la_toolkit/redux/appActions.dart';
import 'package:la_toolkit/routes.dart';
import 'package:la_toolkit/utils/StringUtils.dart';
import 'package:la_toolkit/utils/regexp.dart';
import 'package:la_toolkit/utils/utils.dart';

import 'components/appSnackBar.dart';
import 'components/laAppBar.dart';
import 'components/lintProject.dart';
import 'components/scrollPanel.dart';
import 'models/dependencies.dart';
import 'models/laReleases.dart';
import 'models/laServiceDesc.dart';
import 'models/laVariable.dart';

class LAProjectTunePage extends StatelessWidget {
  LAProjectTunePage({Key? key}) : super(key: key);

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
          softwareReleasesReady:
              AppUtils.isDev() && store.state.laReleases.isNotEmpty,
          laReleases: store.state.laReleases,
          status: store.state.currentProject.status,
          onSaveProject: (project) {
            store.dispatch(SaveCurrentProject(project));
          },
          onUpdateProject: (project) {
            store.dispatch(UpdateProject(project));
            BeamerCond.of(context, LAProjectViewLocation());
          },
          onCancel: (project) {
            store.dispatch(OpenProjectTools(project));
            BeamerCond.of(context, LAProjectViewLocation());
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
        bool isHub = project.isHub;
        LAVariableDesc.map.entries
            .where((laVar) =>
                laVar.value.inTunePage &&
                // add onlyHub vars if needed
                (!laVar.value.onlyHub || (isHub && laVar.value.onlyHub)) &&
                // Show var where depend service is in use
                (laVar.value.depends == null ||
                    (laVar.value.depends != null &&
                        (!isHub ||
                            isHub &&
                                LAServiceDesc.getE(laVar.value.depends!)
                                    .hubCapable) &&
                        project.getService(laVar.value.depends!.toS()).use)) &&
                /* This gets parent deps vars also like CAS
                        (isHub ? project.parent! : project)
                            .getService(laVar.value.depends!.toS())
                            .use)) && */
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
        String pageTitle =
            "${project.shortName}: ${LAProjectViewStatus.tune.getTitle(project.isHub)}";
        bool showSoftwareVersions =
            project.advancedTune && vm.softwareReleasesReady;
        return Title(
            title: pageTitle,
            color: LAColorTheme.laPalette,
            child: Scaffold(
                key: _scaffoldKey,
                appBar: LAAppBar(
                    context: context,
                    titleIcon: Icons.edit,
                    title: pageTitle,
                    showLaIcon: false,
                    actions: [
                      TextButton(
                          // icon: Icon(Icons.cancel),
                          style: TextButton.styleFrom(primary: Colors.white),
                          child: const Text(
                            "CANCEL",
                          ),
                          onPressed: () => vm.onCancel(project)),
                      IconButton(
                        icon: const Tooltip(
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
                              if (!AppUtils.isDemo() && project.advancedTune)
                                const SizedBox(height: 20),
                              if (!AppUtils.isDemo() && project.advancedTune)
                                ListTile(
                                    // contentPadding: EdgeInsets.zero,
                                    title: Text(
                                      'This ${project.portalName} is in Production',
                                    ),
                                    trailing: Switch(
                                        value: vm.status ==
                                            LAProjectStatus.inProduction,
                                        onChanged: (bool value) {
                                          if (value) {
                                            project.isCreated = true;
                                            project.fstDeployed = true;
                                            project.setProjectStatus(
                                                LAProjectStatus.inProduction);
                                            project.validateCreation(
                                                debug: true);
                                            vm.onSaveProject(project);
                                          } else {
                                            project.setProjectStatus(
                                                LAProjectStatus.firstDeploy);
                                            project.validateCreation(
                                                debug: true);
                                            vm.onSaveProject(project);
                                          }
                                        })),
                              if (showSoftwareVersions)
                                const SizedBox(height: 20),
                              if (showSoftwareVersions)
                                HeadingItem("Component versions")
                                    .buildTitle(context),
                              if (showSoftwareVersions)
                                const LAReleasesSelectors(),
                              if (showSoftwareVersions)
                                LintErrorPanel(Dependencies.verifyLAReleases(
                                    project.getServicesNameListInUse(),
                                    project.getServiceDeployReleases())),
                              const SizedBox(height: 20),
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
                              if (project.advancedTune)
                                const SizedBox(height: 20),
                              if (project.advancedTune)
                                HeadingItem("Other variables")
                                    .buildTitle(context),
                              if (project.advancedTune)
                                const SizedBox(height: 30),
                              if (project.advancedTune)
                                const Text(
                                  "Write here other extra ansible variables that are not configurable in the previous forms:",
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.black54),
                                ),
                              if (project.advancedTune)
                                const SizedBox(height: 20),
                              if (project.advancedTune)
                                // This breaks the newline enter key:
                                //ListTile(
                                //                        title:
                                GenericTextFormField(
                                    initialValue:
                                        project.additionalVariables.isNotEmpty
                                            ? utf8.decode(base64.decode(
                                                project.additionalVariables))
                                            : _initialExtraAnsibleVariables(
                                                project),
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
                              const SizedBox(height: 20),
                              const LintProjectPanel(),
                              if (_endNoteEnabled)
                                Row(children: [
                                  const Text(
                                      "Note: the colors of the variables values indicate if these values are "),
                                  Text("already deployed",
                                      style: LAColorTheme.deployedTextStyle),
                                  const Text(" in your servers or "),
                                  Text("they are not deployed yet",
                                      style: LAColorTheme.unDeployedTextStyle),
                                  const Text("."),
                                ]),
                            ]))))));
      },
    );
  }

  String _initialExtraAnsibleVariables(LAProject currentProject) {
    return '''
${_doTitle(" Other variables common to all services ")}
[${currentProject.isHub ? 'hub-' + currentProject.dirName! : 'all'}:vars]

# End of common variables
${_doLine()}
                                        
                                                                                                                                                                      
''' +
        currentProject.services.map((service) {
          String name = service.nameInt;
          LAServiceDesc serviceDesc = LAServiceDesc.get(name);
          final String title =
              " ${serviceDesc.name} ${serviceDesc.name != serviceDesc.nameInt ? '(' + serviceDesc.nameInt + ') ' : ''}extra variables ";
          return '''

${_doTitle(title)} 
${service.use ? '' : '# '}[${serviceDesc.group}${currentProject.isHub ? '-' + currentProject.dirName! : ''}:vars]${service.use ? '' : ' #uncomment this line if you enable this service to tune it'} 

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

  @override
  Widget buildTitle(BuildContext context) {
    return Text(heading,
        style: !subheading
            ? Theme.of(context).textTheme.headline5
            : Theme.of(context).textTheme.headline6!.copyWith(
                fontSize: 18, color: LAColorTheme.laThemeData.hintColor));
  }

  @override
  Widget buildSubtitle(BuildContext context) => const Text("");
}

// A ListItem that contains data to display a message.
class MessageItem implements ListItem {
  LAVariableDesc varDesc;
  LAProject project;
  ValueChanged<Object> onChanged;
  MessageItem(this.project, this.varDesc, this.onChanged);

  @override
  Widget buildTitle(BuildContext context) {
    final initialValue = project.getVariableValue(varDesc.nameInt);
    var laVariable = project.getVariable(varDesc.nameInt);
    final bool deployed = laVariable.status == LAVariableStatus.deployed;
    // ignore: prefer_typing_uninitialized_variables
    var defValue;
    if (varDesc.defValue != null) defValue = varDesc.defValue!(project);
    return ListTile(
        title: (varDesc.type == LAVariableType.bool)
            ? SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: initialValue ?? defValue ?? false,
                title: Text(varDesc.name,
                    style:
                        TextStyle(color: LAColorTheme.laThemeData.hintColor)),
                onChanged: (bool newValue) {
                  onChanged(newValue);
                })
            : GenericTextFormField(
                label: varDesc.name,
                hint: varDesc.hint,
                initialValue: initialValue ?? defValue,
                allowEmpty: varDesc.allowEmpty,
                enabledBorder: false,
                obscureText: varDesc.protected,
                deployed: deployed,
                regexp: varDesc.type == LAVariableType.int
                    ? LARegExp.int
                    : varDesc.type == LAVariableType.double
                        ? LARegExp.double
                        : varDesc.regExp,
                error: varDesc.error,
                onChanged: (newValue) {
                  onChanged(newValue);
                }),
        trailing:
            varDesc.help != null ? HelpIcon(wikipage: varDesc.help!) : null);
  }

  @override
  Widget buildSubtitle(BuildContext context) => const Text("");
}

class _ProjectTuneViewModel {
  final LAProject project;
  final LAProjectStatus status;
  final Map<String, LAReleases> laReleases;
  final void Function(LAProject) onUpdateProject;
  final void Function(LAProject) onSaveProject;
  final void Function(LAProject) onCancel;
  final bool softwareReleasesReady;

  _ProjectTuneViewModel({
    required this.project,
    required this.status,
    required this.laReleases,
    required this.onUpdateProject,
    required this.softwareReleasesReady,
    required this.onSaveProject,
    required this.onCancel,
  });
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ProjectTuneViewModel &&
          runtimeType == other.runtimeType &&
          project == other.project &&
          softwareReleasesReady == other.softwareReleasesReady &&
          const DeepCollectionEquality.unordered()
              .equals(laReleases, other.laReleases) &&
          status == other.status;

  @override
  int get hashCode =>
      project.hashCode ^
      status.hashCode ^
      softwareReleasesReady.hashCode ^
      const DeepCollectionEquality.unordered().hash(laReleases);
}
