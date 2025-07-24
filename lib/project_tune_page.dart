import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:redux/redux.dart';

import 'components/GenericSelector.dart';
import 'components/alaInstallSelector.dart';
import 'components/app_snack_bar.dart';
import 'components/generatorSelector.dart';
import 'components/genericTextFormField.dart';
import 'components/help_icon.dart';
import 'components/laAppBar.dart';
import 'components/lintProjectPanel.dart';
import 'components/scrollPanel.dart';
import 'laTheme.dart';
import 'la_releases_selectors.dart';
import 'models/appState.dart';
import 'models/laProjectStatus.dart';
import 'models/laReleases.dart';
import 'models/laServiceDesc.dart';
import 'models/laServiceName.dart';
import 'models/laVariable.dart';
import 'models/laVariableDesc.dart';
import 'models/la_project.dart';
import 'models/la_service.dart';
import 'models/sshKey.dart';
import 'redux/app_actions.dart';
import 'routes.dart';
import 'utils/StringUtils.dart';
import 'utils/regexp.dart';
import 'utils/utils.dart';

class LAProjectTunePage extends StatefulWidget {
  const LAProjectTunePage({super.key});

  static const String routeName = 'tune';

  @override
  State<LAProjectTunePage> createState() => _LAProjectTunePageState();
}

class _LAProjectTunePageState extends State<LAProjectTunePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final bool _endNoteEnabled = false;
  int _tab = 0;
  final int _moreInfoTab = 0;
  final int _softwareTab = 1;
  final int _extraTab = 2;
  late bool _loading;

  @override
  void initState() {
    super.initState();
    _loading = false;
  }

  @override
  void dispose() {
    super.dispose();
    if (context.mounted) {
      context.loaderOverlay.hide();
    }
  }

  _onPressed(vm) {
    setState(() {
      _loading = true;
    });
    vm.refreshSWVersions();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ProjectTuneViewModel>(
      // Fails the switch distinct: true,
      converter: (Store<AppState> store) {
        return _ProjectTuneViewModel(
            project: store.state.currentProject,
            softwareReleasesReady: store.state.laReleases.isNotEmpty,
            laReleases: store.state.laReleases,
            currentTab: store.state.currentTuneTab,
            status: store.state.currentProject.status,
            depsLoading: store.state.depsLoading,
            alaInstallReleases: store.state.alaInstallReleases,
            generatorReleases: store.state.generatorReleases,
            backendVersion: store.state.backendVersion,
            sshKeys: store.state.sshKeys,
            onInitCasKeys: () {
              store.dispatch(OnInitCasKeys());
            },
            onInitCasOAuthKeys: () {
              store.dispatch(OnInitCasOAuthKeys());
            },
            refreshSWVersions: () => store.dispatch(OnFetchSoftwareDepsState(
                force: true,
                onReady: () => setState(() {
                      _loading = false;
                    }))),
            onSaveProject: (LAProject project) {
              store.dispatch(SaveCurrentProject(project));
            },
            onUpdateProject: (LAProject project) {
              store.dispatch(UpdateProject(project));
              BeamerCond.of(context, LAProjectViewLocation());
            },
            onCancel: (LAProject project) {
              store.dispatch(OpenProjectTools(project));
              BeamerCond.of(context, LAProjectViewLocation());
            },
            onSelectTuneTab: (int tab) =>
                store.dispatch(OnSelectTuneTab(currentTab: tab)));
      },
      builder: (BuildContext context, _ProjectTuneViewModel vm) {
        final LAProject project = vm.project;
        _tab = vm.currentTab;

        if (!project.isHub &&
            (project.isStringVariableNullOrEmpty('pac4j_cookie_signing_key') ||
                project.isStringVariableNullOrEmpty(
                    'pac4j_cookie_encryption_key') ||
                project
                    .isStringVariableNullOrEmpty('cas_webflow_signing_key') ||
                project.isStringVariableNullOrEmpty(
                    'cas_webflow_encryption_key'))) {
          // Auto-generate CAS keys
          vm.onInitCasKeys();
        }
        if (!project.isHub &&
            (project.isStringVariableNullOrEmpty('cas_oauth_signing_key') ||
                project
                    .isStringVariableNullOrEmpty('cas_oauth_encryption_key') ||
                project.isStringVariableNullOrEmpty(
                    'cas_oauth_access_token_signing_key') ||
                project.isStringVariableNullOrEmpty(
                    'cas_oauth_access_token_encryption_key'))) {
          // Auto-generate CAS OAuth keys
          vm.onInitCasOAuthKeys();
        }
        final List<String> varCatName = project.getServicesNameListInUse();
        varCatName.add(LAServiceName.all.toS());
        final List<ListItem> items = <ListItem>[];
        LAServiceName? lastCategory;
        LAVariableSubcategory? lastSubcategory;
        final bool isHub = project.isHub;
        LAVariableDesc.map.entries
            .where((MapEntry<String, LAVariableDesc> laVar) =>
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
            .forEach((MapEntry<String, LAVariableDesc> entry) {
          if (entry.value.service != lastCategory) {
            items.add(HeadingItem(entry.value.service == LAServiceName.all
                ? 'Variables common to all services'
                : '${StringUtils.capitalize(LAServiceDesc.getE(entry.value.service).name)} variables'));

            lastCategory = entry.value.service;
          }
          if (entry.value.subcategory != lastSubcategory &&
              entry.value.subcategory != null) {
            items.add(HeadingItem(entry.value.subcategory!.title, true));
            lastSubcategory = entry.value.subcategory;
          }
          items.add(MessageItem(project, entry.value, (Object value) {
            project.setVariable(entry.value, value);
            vm.onSaveProject(project);
          }));
        });
        final String pageTitle =
            '${project.shortName}: ${LAProjectViewStatus.tune.getTitle(project.isHub)}';
        final bool showSoftwareVersions =
            project.showSoftwareVersions && vm.softwareReleasesReady;
        final bool showToolkitDeps = project.showToolkitDeps;
        if (context.mounted) {
          context.loaderOverlay.hide();
        }
        return Title(
            title: pageTitle,
            color: LAColorTheme.laPalette,
            child: Scaffold(
                key: _scaffoldKey,
                appBar: LAAppBar(
                    context: context,
                    titleIcon: Icons.edit,
                    title: pageTitle,
                    // showLaIcon: false,
                    actions: <Widget>[
                      TextButton(
                          // icon: Icon(Icons.cancel),
                          style: TextButton.styleFrom(
                              foregroundColor: Colors.white),
                          child: const Text(
                            'CANCEL',
                          ),
                          onPressed: () => vm.onCancel(project)),
                      IconButton(
                        icon: const Tooltip(
                            message: 'Save the current LA project variables',
                            child: Icon(Icons.save, color: Colors.white)),
                        onPressed: () {
                          vm.onUpdateProject(project);
                        },
                      )
                    ]),
                bottomNavigationBar: ConvexAppBar(
                  backgroundColor: LAColorTheme.laPalette.shade300,
                  color: Colors.black,
                  activeColor: Colors.black,
                  style: TabStyle.react,
                  items: <TabItem<dynamic>>[
                    TabItem<dynamic>(
                        icon: MdiIcons.formatListGroup, title: 'Variables'),
                    TabItem<dynamic>(
                        icon: MdiIcons.autorenew, title: 'Software versions'),
                    TabItem<dynamic>(
                        icon: MdiIcons.formTextbox, title: 'Ansible Extras')
                  ],
                  initialActiveIndex: vm.currentTab,
                  //optional, default as 0
                  onTap: (int i) => setState(() {
                    _tab = i;
                    vm.onSelectTuneTab(i);
                  }),
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
                body: AppSnackBar(ScrollPanel(
                    withPadding: true,
                    child: Form(
                        key: _formKey,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              if (_tab == _moreInfoTab)
                                ListTile(
                                    // contentPadding: EdgeInsets.zero,
                                    title: const Text(
                                      'Advanced options',
                                    ),
                                    trailing: Switch(
                                        value: project.advancedTune,
                                        onChanged: (bool value) {
                                          project.advancedTune = value;
                                          vm.onSaveProject(project);
                                        })),
                              if (_tab == _moreInfoTab &&
                                  !AppUtils.isDemo() &&
                                  project.advancedTune)
                                const SizedBox(height: 20),
                              if (_tab == _moreInfoTab &&
                                  !AppUtils.isDemo() &&
                                  project.advancedTune)
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
                                            project.status =
                                                LAProjectStatus.inProduction;
                                            project.validateCreation();
                                            vm.onSaveProject(project);
                                          } else {
                                            project.status =
                                                LAProjectStatus.firstDeploy;
                                            project.validateCreation();
                                            vm.onSaveProject(project);
                                          }
                                        })),
                              if (_tab == _moreInfoTab)
                                const SizedBox(height: 20),
                              if (_tab == _moreInfoTab)
                                ListView.builder(
                                  // scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  // Let the ListView know how many items it needs to build.
                                  itemCount: items.length,
                                  // Provide a builder function. This is where the magic happens.
                                  // Convert each item into a widget based on the type of item it is.
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final ListItem item = items[index];
                                    return ListTile(
                                      // contentPadding: EdgeInsets.zero,
                                      title: item.buildTitle(context),
                                      subtitle: item.buildSubtitle(context),
                                    );
                                  },
                                ),
                              if (_tab == _softwareTab)
                                if (showToolkitDeps) const SizedBox(height: 20),
                              if (_tab == _softwareTab)
                                if (showToolkitDeps)
                                  HeadingItem('LA Toolkit dependencies')
                                      .buildTitle(context),
                              if (_tab == _softwareTab)
                                if (showToolkitDeps) const SizedBox(height: 20),
                              if (_tab == _softwareTab)
                                if (showToolkitDeps)
                                  Row(
/*                                      mainAxisAlignment:
                                          MainAxisAlignment.start,*/
                                      children: <Widget>[
                                        SizedBox(
                                            width: 250,
                                            child: ALAInstallSelector(
                                                onChange: (String? value) {
                                              final String version = value ??
                                                  vm.alaInstallReleases[0];
                                              project.alaInstallRelease =
                                                  version;
                                              vm.onSaveProject(project);
                                            })),
                                        SizedBox(
                                            width: 250,
                                            child: GeneratorSelector(
                                                onChange: (String? value) {
                                              final String version = value ??
                                                  vm.generatorReleases[0];
                                              project.generatorRelease =
                                                  version;
                                              vm.onSaveProject(project);
                                            }))
                                      ]),
                              if (_tab == _softwareTab)
                                if (showSoftwareVersions)
                                  const SizedBox(height: 20),
                              if (_tab == _softwareTab)
                                if (showSoftwareVersions)
                                  HeadingItem('LA Component versions')
                                      .buildTitle(context),
                              if (_tab == _softwareTab)
                                if (showSoftwareVersions)
                                  LAReleasesSelectors(onSoftwareSelected:
                                      (String sw, String version, bool save) {
                                    project.setServiceDeployRelease(
                                        sw, version);
                                    if (save) {
                                      vm.onSaveProject(project);
                                    }
                                  }),
                              if (_tab == _softwareTab)
                                Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 20, 0, 20),
                                    child: Align(
                                        // alignment: Alignment.center,
                                        child: ElevatedButton.icon(
                                            onPressed: _loading
                                                ? null
                                                : () => _onPressed(vm),
                                            label: const Text('Refresh'),
                                            icon: const Icon(Icons.refresh)))),
                              if (_tab == _softwareTab)
                                if (showSoftwareVersions || showToolkitDeps)
                                  LintProjectPanel(
                                      showLADeps: showSoftwareVersions,
                                      showToolkitDeps: showToolkitDeps,
                                      showOthers: false),
                              if (_tab == _extraTab)
                                if (project.advancedTune)
                                  const SizedBox(height: 20),
                              if (_tab == _extraTab)
                                if (project.advancedTune)
                                  HeadingItem('Other variables')
                                      .buildTitle(context),
                              if (_tab == _extraTab)
                                if (project.advancedTune)
                                  const SizedBox(height: 30),
                              if (_tab == _extraTab)
                                if (project.advancedTune)
                                  const Text(
                                    'Write here other extra ansible variables that are not configurable in the previous forms:',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.black54),
                                  ),
                              if (_tab == _extraTab)
                                if (project.advancedTune)
                                  const SizedBox(height: 20),
                              if (_tab == _extraTab)
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
                                      error: '',
                                      selected: false,
                                      onChanged: (String value) {
                                        project.additionalVariables =
                                            base64.encode(utf8.encode(value));
                                        vm.onSaveProject(project);
                                      }),
                              /* trailing: HelpIcon(
                                    wikipage:
                                        "Version-control-of-your-configurations#about-maintaining-dataconfig")), */
                              if (_tab == _extraTab) const SizedBox(height: 20),
                              if (_tab == _extraTab)
                                if (_endNoteEnabled)
                                  Row(children: <Widget>[
                                    const Text(
                                        'Note: the colors of the variables values indicate if these values are '),
                                    const Text('already deployed',
                                        style: LAColorTheme.deployedTextStyle),
                                    const Text(' in your servers or '),
                                    Text('they are not deployed yet',
                                        style:
                                            LAColorTheme.unDeployedTextStyle),
                                    const Text('.'),
                                  ]),
                            ]))))));
      },
    );
  }

  String _initialExtraAnsibleVariables(LAProject currentProject) {
    return '''
${_doTitle(" Other variables common to all services ")}
[${currentProject.isHub ? 'hub-${currentProject.dirName!}' : 'all'}:vars]

# End of common variables
${_doLine()}
                                        
                                                                                                                                                                      
${currentProject.services.map((LAService service) {
      final String name = service.nameInt;
      final LAServiceDesc serviceDesc = LAServiceDesc.get(name);
      final String title =
          " ${serviceDesc.name} ${serviceDesc.name != serviceDesc.nameInt ? '(${serviceDesc.nameInt}) ' : ''}extra variables ";
      return '''

${_doTitle(title)} 
${service.use ? '' : '# '}[${serviceDesc.group}${currentProject.isHub ? '-${currentProject.dirName!}' : ''}:vars]${service.use ? '' : ' #uncomment this line if you enable this service to tune it'} 

# End of ${StringUtils.capitalize(serviceDesc.name)} variables
${_doLine()}
''';
    }).join("\n\n")}''';
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
  HeadingItem(this.heading, [this.subheading = false]);

  final String heading;
  final bool subheading;

  @override
  Widget buildTitle(BuildContext context) {
    return Text(heading,
        style: !subheading
            ? Theme.of(context).textTheme.headlineSmall
            : Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(fontSize: 18, color: Theme.of(context).hintColor));
  }

  @override
  Widget buildSubtitle(BuildContext context) => const Text('');
}

// A ListItem that contains data to display a message.
class MessageItem implements ListItem {
  MessageItem(this.project, this.varDesc, this.onChanged);

  LAVariableDesc varDesc;
  LAProject project;

  ValueChanged<Object> onChanged;

  @override
  Widget buildTitle(BuildContext context) {
    final Object? initialValue = project.getVariableValue(varDesc.nameInt);
    final LAVariable laVariable = project.getVariable(varDesc.nameInt);
    final bool deployed = laVariable.status == LAVariableStatus.deployed;
    // ignore: prefer_typing_uninitialized_variables
    dynamic defValue;
    if (varDesc.defValue != null) {
      defValue = varDesc.defValue!(project);
    }
    return ListTile(
        title: (varDesc.type == LAVariableType.bool)
            ? SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: initialValue as bool? ?? defValue as bool? ?? false,
                title: Text(varDesc.name,
                    style: TextStyle(color: Theme.of(context).hintColor)),
                onChanged: (bool newValue) {
                  onChanged(newValue);
                })
            : varDesc.type == LAVariableType.select
                ? Row(children: <Widget>[
                    Text('${varDesc.name}: '),
                    const SizedBox(width: 20),
                    GenericSelector<String>(
                        values: varDesc.defValue!(project) as List<String>,
                        currentValue: '$initialValue',
                        onChange: (String newValue) =>
                            <void>{onChanged(newValue)})
                  ])
                : GenericTextFormField(
                    label: varDesc.name,
                    hint: varDesc.hint,
                    initialValue:
                        initialValue as String? ?? defValue as String?,
                    allowEmpty: varDesc.allowEmpty,
                    obscureText: varDesc.protected,
                    deployed: deployed,
                    regexp: varDesc.type == LAVariableType.int
                        ? LARegExp.int
                        : varDesc.type == LAVariableType.double
                            ? LARegExp.double
                            : varDesc.regExp,
                    error: varDesc.error,
                    onChanged: (String newValue) {
                      onChanged(newValue);
                    }),
        trailing: varDesc.help != null ? HelpIcon.from(varDesc.help!) : null);
  }

  @override
  Widget buildSubtitle(BuildContext context) => const Text('');
}

class _ProjectTuneViewModel {
  _ProjectTuneViewModel(
      {required this.project,
      required this.status,
      required this.laReleases,
      required this.currentTab,
      required this.onUpdateProject,
      required this.softwareReleasesReady,
      required this.onSaveProject,
      required this.onInitCasKeys,
      required this.onInitCasOAuthKeys,
      required this.onSelectTuneTab,
      required this.onCancel,
      required this.depsLoading,
      required this.refreshSWVersions,
      required this.alaInstallReleases,
      required this.generatorReleases,
      required this.backendVersion,
      required this.sshKeys});

  final LAProject project;
  final LAProjectStatus status;
  final Map<String, LAReleases> laReleases;
  final void Function(LAProject) onUpdateProject;
  final void Function(LAProject) onSaveProject;
  final void Function(LAProject) onCancel;
  final void Function(int) onSelectTuneTab;
  final void Function() onInitCasKeys;
  final void Function() onInitCasOAuthKeys;
  final Function() refreshSWVersions;
  final bool softwareReleasesReady;
  final bool depsLoading;
  final int currentTab;

  final List<String> alaInstallReleases;
  final List<String> generatorReleases;
  final String? backendVersion;
  final List<SshKey> sshKeys;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ProjectTuneViewModel &&
          runtimeType == other.runtimeType &&
          project == other.project &&
          depsLoading == other.depsLoading &&
          currentTab == other.currentTab &&
          softwareReleasesReady == other.softwareReleasesReady &&
          const DeepCollectionEquality.unordered()
              .equals(laReleases, other.laReleases) &&
          const ListEquality()
              .equals(generatorReleases, other.generatorReleases) &&
          const ListEquality()
              .equals(alaInstallReleases, other.alaInstallReleases) &&
          const ListEquality().equals(sshKeys, other.sshKeys) &&
          status == other.status;

  @override
  int get hashCode =>
      project.hashCode ^
      status.hashCode ^
      currentTab.hashCode ^
      depsLoading.hashCode ^
      softwareReleasesReady.hashCode ^
      const ListEquality().hash(sshKeys) ^
      const ListEquality().hash(generatorReleases) ^
      const ListEquality().hash(alaInstallReleases) ^
      const DeepCollectionEquality.unordered().hash(laReleases);
}
