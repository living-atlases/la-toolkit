import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:redux/redux.dart';

import './models/app_state.dart';
import 'components/app_snack_bar.dart';
import 'components/la_app_bar.dart';
import 'components/main_drawer.dart';
import 'intro.dart';
import 'la_theme.dart';
import 'main.dart';
import 'projects_list_page.dart';
import 'redux/app_actions.dart';
import 'routes.dart';
import 'utils/file_utils.dart';
import 'utils/utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const String routeName = '/';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  static const String unknown = 'Unknown';
  PackageInfo _packageInfo = PackageInfo(
    appName: unknown,
    packageName: unknown,
    version: unknown,
    buildNumber: unknown,
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  @override
  void dispose() {
    super.dispose();
    // context.loaderOverlay.hide();
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _HomePageViewModel>(
      distinct: true,
      converter: (Store<AppState> store) {
        return _HomePageViewModel(
          state: store.state,
          onImportProject: (String yoRc) {
            store.dispatch(ImportProject(yoRcJson: yoRc));
            if (mounted) {
              context.loaderOverlay.hide();
            }
            BeamerCond.of(context, LAProjectEditLocation());
          },
          onAddProject: () {
            store.dispatch(CreateProject());
            BeamerCond.of(context, LAProjectEditLocation());
          },
          onAppPackageInfo: (PackageInfo pkgInfo) =>
              store.dispatch(OnAppPackageInfo(pkgInfo)),
          projectsReload: () => store.dispatch(ProjectsLoad()),
          onAddTemplates: () {
            context.loaderOverlay.show();
            store.dispatch(
              AddTemplateProjects(
                onAdded: (int numA) {
                  if (mounted) {
                    context.loaderOverlay.hide();
                  }
                  /* ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Added $num sample LA Projects'),
                      )); */
                },
              ),
            );
          },
        );
      },
      builder: (BuildContext context, _HomePageViewModel vm) {
        if (_packageInfo != vm.state.pkgInfo &&
            _packageInfo.version != unknown) {
          log(
            '------------------------------------------------------------${_packageInfo.version} ------------------------------',
          );
          vm.onAppPackageInfo(_packageInfo);
        }
        if (vm.state.loading) {
          context.loaderOverlay.show();
        } else {
          if (mounted) {
            context.loaderOverlay.hide();
          }
        }
        final bool notFirstUse = !vm.state.firstUsage;
        return notFirstUse || !kReleaseMode
            ? Scaffold(
                key: _scaffoldKey,
                drawer: MainDrawer(
                  currentRoute: HomePage.routeName,
                  appName: LaToolkitApp.appName,
                  packageInfo: _packageInfo,
                ),
                // Maybe:
                // https://api.flutter.dev/flutter/material/SliverAppBar-class.html
                // App bar with floating: true, pinned: true, snap: false:
                appBar: LAAppBar(
                  context: context,
                  title: LaToolkitApp.appName,
                  tooltip: _packageInfo.version,
                  showLaIcon: true,
                  loading: vm.state.loading,
                  actions: <Widget>[
                    if (AppUtils.isDev())
                      IconButton(
                        icon: const Tooltip(
                          message: 'Refresh projects',
                          child: Icon(Icons.refresh, color: Colors.white),
                        ),
                        onPressed: () {
                          vm.projectsReload();
                        },
                      ),
                  ],
                ),
                body: const Column(
                  children: <Widget>[
                    Expanded(child: AppSnackBar(LAProjectsList())),
                  ],
                ),
                floatingActionButton: vm.state.loading ? null : _moreBtn(vm),
              )
            : const Intro();
      },
    );
  }

  Widget _moreBtn(_HomePageViewModel vm) {
    return SpeedDial(
      /// both default to 16
      childMargin: const EdgeInsets.fromLTRB(0, 18, 0, 20),
      //marginEnd: 18,
      //marginBottom: 20,
      // animatedIcon: AnimatedIcons.menu_close,
      // animatedIconTheme: IconThemeData(size: 22.0),
      /// This is ignored if animatedIcon is non null
      icon: Icons.add,
      activeIcon: Icons.close,

      // iconTheme: IconThemeData(color: Colors.grey[50], size: 30),
      /// The label of the main button.
      // label: Text("Open Speed Dial"),
      /// The active label of the main button, Defaults to label if not specified.
      // activeLabel: Text("Close Speed Dial"),
      /// Transition Builder between label and activeLabel, defaults to FadeTransition.
      // labelTransitionBuilder: (widget, animation) => ScaleTransition(scale: animation,child: widget),
      /// The below button size defaults to 56 itself, its the FAB size + It also affects relative padding and other elements
      // buttonSize: const Size(56.0, 56.0),
      // visible: true,

      /// If true user is forced to close dial manually
      /// by tapping main button and overlay is not rendered.
      // closeManually: false,

      /// If true overlay will render no matter what.
      renderOverlay: false,
      curve: Curves.bounceIn,
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
      // onOpen: () => debugPrint('OPENING DIAL'),
      // onClose: () => debugPrint('DIAL CLOSED'),
      tooltip: 'More options',
      heroTag: 'speed-dial-more-tag',
      backgroundColor: LAColorTheme.laPalette,
      foregroundColor: Colors.white,
      elevation: 8.0,
      shape: const CircleBorder(),
      // orientation: SpeedDialOrientation.Up,
      // childMarginBottom: 2,
      // childMarginTop: 2,
      children: <SpeedDialChild>[
        SpeedDialChild(
          child: const Icon(Icons.copy_outlined),
          backgroundColor: LAColorTheme.laPalette,
          foregroundColor: Colors.white,
          label: 'Add some sample LA projects',
          labelStyle: const TextStyle(fontSize: 18.0),
          onTap: () async {
            vm.onAddTemplates();
          },
          // onLongPress: () => debugPrint('FIRST CHILD LONG PRESS'),
        ),
        SpeedDialChild(
          child: const Icon(Icons.upload_rounded),
          backgroundColor: LAColorTheme.laPalette,
          foregroundColor: Colors.white,
          label: 'Import previous generated inventories',
          labelStyle: const TextStyle(fontSize: 18.0),
          onTap: () => showAlertDialog(context, vm),
          // onLongPress: () => debugPrint('SECOND CHILD LONG PRESS'),
        ),
        if (vm.state.projects.isNotEmpty)
          SpeedDialChild(
            child: const Icon(Icons.add),
            backgroundColor: LAColorTheme.laPalette,
            foregroundColor: Colors.white,
            label: 'Create a new LA Project',
            labelStyle: const TextStyle(fontSize: 18.0),
            onTap: () => vm.onAddProject(),
            // onLongPress: () => debugPrint('SECOND CHILD LONG PRESS'),
          ),
      ],
    );
  }

  void showAlertDialog(BuildContext context, _HomePageViewModel vm) {
    final AlertDialog alert = AlertDialog(
      title: const Text('Import of Inventories'),
      content: const SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(
              "Please select a '.yo-rc.json' file of some previous generated inventories to import it. This file is located in the parent directory of your inventories (maybe you have to show hidden files).",
            ),
            SizedBox(height: 20),
            Text('You will have later to:'),
            SizedBox(height: 10),
            Text(
              '  - tune your imported project with your local ansible variables,',
            ),
            Text(
              '  - substitute the generated local-passwords.ini file with yours.',
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('CANCEL'),
          onPressed: () async {
            onFinish(context, false);
          },
        ),
        TextButton(
          child: const Text('OK'),
          onPressed: () async {
            try {
              context.loaderOverlay.show();
              final String? yoRcJson = await FileUtils.getYoRcJson();
              if (yoRcJson != null) {
                vm.onImportProject(yoRcJson);
              } else {
                if (!mounted) {
                  return;
                }
                if (!context.mounted) {
                  return;
                }
                onFinish(context, true);
              }
            } catch (e) {
              if (!mounted) {
                return;
              }
              if (!context.mounted) {
                return;
              }
              onFinish(context, true);
            }
          },
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void onFinish(BuildContext context, bool withError) {
    if (mounted) {
      context.loaderOverlay.hide();
      Navigator.pop(context);
    }
    if (withError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Something goes wrong during the import. Be sure you are importing a ".yo-rc.json" file',
          ),
        ),
      );
    }
  }
}

@immutable
class _HomePageViewModel {
  const _HomePageViewModel({
    required this.state,
    required this.onAddProject,
    required this.onImportProject,
    required this.onAddTemplates,
    required this.onAppPackageInfo,
    required this.projectsReload,
  });

  final AppState state;
  final void Function() onAddProject;
  final void Function(String) onImportProject;
  final void Function(PackageInfo) onAppPackageInfo;
  final void Function() onAddTemplates;
  final void Function() projectsReload;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppState &&
          runtimeType == other.runtimeType &&
          state.firstUsage == other.firstUsage &&
          //  state.currentProject == other.currentProject &&
          // status == other.status &&
          // currentStep == other.currentStep &&
          state.projects == other.projects;

  // alaInstallReleases == other.alaInstallReleases;

  @override
  int get hashCode =>
      state.firstUsage.hashCode ^
      // state.currentProject.hashCode ^
      // status.hashCode ^
      // currentStep.hashCode ^
      state.projects.hashCode;
}
