import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:la_toolkit/components/laAppBar.dart';
import 'package:la_toolkit/deployResultsPage.dart';
import 'package:la_toolkit/logsPage.dart';
import 'package:la_toolkit/preDeployPage.dart';
import 'package:la_toolkit/projectEditPage.dart';
import 'package:la_toolkit/projectTunePage.dart';
import 'package:la_toolkit/projectViewPage.dart';
import 'package:la_toolkit/projectsListPage.dart';
import 'package:la_toolkit/redux/appActions.dart';
import 'package:la_toolkit/redux/appReducer.dart';
import 'package:la_toolkit/redux/appStateMiddleware.dart';
import 'package:la_toolkit/redux/loggingMiddleware.dart';
import 'package:la_toolkit/routes.dart';
import 'package:la_toolkit/utils/fileUtils.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:redux/redux.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'components/appSnackBar.dart';
import 'components/appSnackBarMessage.dart';
import 'components/mainDrawer.dart';
import 'deployPage.dart';
import 'intro.dart';
import 'laTheme.dart';
import 'models/appState.dart';

Future<void> main() async {
  AppStateMiddleware appStateMiddleware = AppStateMiddleware();

  await DotEnv.load(
      fileName: "${kReleaseMode ? 'env.production.txt' : '.env.development'}");
  if (kReleaseMode) {
    // is Release Mode ??
    print('Running in release mode');
    print("Backend: ${env['BACKEND']}");
  } else {
    print('Running in debug mode');
    print("Backend: ${env['BACKEND']}");
  }

  AppState initialState = await appStateMiddleware.getState();
  // print("Loaded prefs: $state");

  Store<AppState> store = Store<AppState>(
    appReducer,
    initialState: initialState,
    middleware: [
      customLogPrinter(),
      appStateMiddleware,
      NavigationMiddleware(),
    ],
  );
  store.onChange.listen((state) {
    print("On store change: $state");
    try {
      appStateMiddleware.saveAppState(state);
    } catch (e) {
      store.dispatch(ShowSnackBar(AppSnackBarMessage(
          message: "Something failed when tryin to save your configuration")));
    }
  });
  store.dispatch(OnFetchState());
  runApp(MyApp(store: store));

  if (initialState.failedLoad) {
    store.dispatch(OnFetchStateFailed());
    store.dispatch(ShowSnackBar(
        AppSnackBarMessage(message: "Failed to retrieve your configuration")));
  }
  /*
  Does not work because creates an additional new MaterialApp and this breaks the navigation
  runApp(BetterFeedback(
    key: _mainKey,
    child: MyApp(store: store),
    onFeedback: (
      BuildContext context,
      String feedbackText,
      Uint8List feedbackScreenshot,
    ) {
      // upload to server, share whatever
      // for example purposes just show it to the user

      // https://github.com/ueman/feedback#upload-feedback
      alertFeedbackFunction(context, feedbackText, feedbackScreenshot);
      return;
    },
  )); */
}

final String appName = 'Living Atlases Toolkit';

// https://stackoverflow.com/questions/50303441/flutter-redux-navigator-globalkey-currentstate-returns-null
class MainKeys {
  static final GlobalKey<NavigatorState> navKey =
      new GlobalKey<NavigatorState>();
}

class MyApp extends StatelessWidget {
  final Store<AppState> store;

  const MyApp({Key? key, required this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
        store: store,
        child: GlobalLoaderOverlay(
            useDefaultLoading: true,
            overlayOpacity: 0.5,
            overlayColor: Colors.black,
            child: MaterialApp(
              navigatorKey: MainKeys.navKey,
              builder: (context, widget) => ResponsiveWrapper.builder(
                  BouncingScrollWrapper.builder(context, widget!),
                  maxWidth: 1200,
                  minWidth: 450,
                  defaultScale: true,
                  breakpoints: [
                    ResponsiveBreakpoint.resize(450, name: MOBILE),
                    ResponsiveBreakpoint.autoScale(800, name: TABLET),
                    ResponsiveBreakpoint.autoScale(1000, name: TABLET),
                    ResponsiveBreakpoint.resize(1200, name: DESKTOP),
                    ResponsiveBreakpoint.autoScale(2460, name: "4K"),
                  ],
                  background: Container(color: Color(0xFFF5F5F5))),
              initialRoute: HomePage.routeName,
              onGenerateRoute: (RouteSettings settings) =>
                  Routes.onGenerateRoute(settings),
              title: appName,
              theme: LAColorTheme.laThemeData,
              debugShowCheckedModeBanner: false,
            )));
  }
}

class HomePage extends StatefulWidget {
  static const routeName = "/";

  HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
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
        converter: (store) {
          return _HomePageViewModel(
              state: store.state,
              onImportProject: (yoRc) {
                store.dispatch(ImportProject(yoRcJson: yoRc));
                context.hideLoaderOverlay();
              },
              onAddProject: () {
                store.dispatch(CreateProject());
              },
              onAddTemplates: (templates) {
                context.showLoaderOverlay();
                store.dispatch(AddTemplateProjects(
                    templates: templates,
                    onAdded: (num) {
                      context.hideLoaderOverlay();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Added $num sample LA Projects'),
                      ));
                    }));
              });
        },
        builder: (BuildContext context, _HomePageViewModel vm) {
          return !vm.state.firstUsage
              ? Scaffold(
                  key: _scaffoldKey,
                  drawer: MainDrawer(
                      currentRoute: HomePage.routeName,
                      appName: appName,
                      packageInfo: _packageInfo),
                  // Maybe:
                  // https://api.flutter.dev/flutter/material/SliverAppBar-class.html
                  // App bar with floating: true, pinned: true, snap: false:
                  appBar: LAAppBar(
                      context: context, title: appName, showLaIcon: true),
                  body: AppSnackBar(LAProjectsList()),
                  floatingActionButton:
                      /*
                          FloatingActionButton.extended(
                            onPressed: () {
                              vm.onAddProject();
                            },
                            label: Text('Create a new LA Project'),
                            icon: Icon(Icons.add_circle_outline),
                          ) */
                      _moreBtn(vm))
              : Intro();
        });
  }

  Widget _moreBtn(_HomePageViewModel vm) {
    return SpeedDial(

        /// both default to 16
        marginEnd: 18,
        marginBottom: 20,
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
        buttonSize: 56.0,
        visible: true,

        /// If true user is forced to close dial manually
        /// by tapping main button and overlay is not rendered.
        closeManually: false,

        /// If true overlay will render no matter what.
        renderOverlay: false,
        curve: Curves.bounceIn,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        // onOpen: () => print('OPENING DIAL'),
        // onClose: () => print('DIAL CLOSED'),
        tooltip: 'More options',
        heroTag: 'speed-dial-more-tag',
        backgroundColor: vm.state.projects.length > 0
            ? LAColorTheme.laPalette
            : Colors.white,
        foregroundColor:
            vm.state.projects.length > 0 ? Colors.white : Colors.black,
        elevation: 8.0,
        shape: CircleBorder(),
        // orientation: SpeedDialOrientation.Up,
        // childMarginBottom: 2,
        // childMarginTop: 2,
        children: [
          SpeedDialChild(
            child: Icon(Icons.copy_outlined),
            backgroundColor: LAColorTheme.laPalette,
            foregroundColor: Colors.white,
            label: 'Add some sample LA projects',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () async {
              // https://flutter.dev/docs/development/ui/assets-and-images#loading-text-assets

              String templatesS = await rootBundle.loadString(
                  AssetsUtils.pathWorkaround('la-toolkit-templates.json'));
              Map<String, dynamic> templates = jsonDecode(templatesS);
              vm.onAddTemplates(templates);
            },
            // onLongPress: () => print('FIRST CHILD LONG PRESS'),
          ),
          SpeedDialChild(
            child: Icon(Icons.upload_rounded),
            backgroundColor: LAColorTheme.laPalette,
            foregroundColor: Colors.white,
            label: 'Import previous generated inventories',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => showAlertDialog(context, vm),
            // onLongPress: () => print('SECOND CHILD LONG PRESS'),
          ),
          if (vm.state.projects.length > 0)
            SpeedDialChild(
              child: Icon(Icons.add),
              backgroundColor: LAColorTheme.laPalette,
              foregroundColor: Colors.white,
              label: 'Create a new LA Project',
              labelStyle: TextStyle(fontSize: 18.0),
              onTap: () => vm.onAddProject(),
              // onLongPress: () => print('SECOND CHILD LONG PRESS'),
            ),
        ]);
  }

  showAlertDialog(BuildContext context, _HomePageViewModel vm) {
    AlertDialog alert = AlertDialog(
      title: Text('Import of Inventories'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(
                'Please select a \'.yo-rc.json\' file of some previous generated inventories to import it. This file is located in the parent directory of your inventories (maybe you have to show hidden files).'),
            SizedBox(height: 20),
            Text('You will have later to:'),
            SizedBox(height: 10),
            Text(
                '  - tune your imported project with your local ansible variables,'),
            Text(
                '  - substitute the generated local-passwords.ini file with yours.'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
            child: Text('CANCEL'),
            onPressed: () async {
              onFinish(context, false);
            }),
        TextButton(
          child: Text('OK'),
          onPressed: () async {
            try {
              context.showLoaderOverlay();
              String? yoRcJson = await FileUtils.getYoRcJson();
              if (yoRcJson != null)
                vm.onImportProject(yoRcJson);
              else
                onFinish(context, true);
            } catch (e) {
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
    context.hideLoaderOverlay();
    Navigator.pop(context);
    if (withError) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Something goes wrong during the import. Be sure you are importing a ".yo-rc.json" file'),
      ));
    }
  }
}

class _HomePageViewModel {
  final AppState state;
  final void Function() onAddProject;
  final void Function(String) onImportProject;
  final void Function(Map<String, dynamic>) onAddTemplates;

  _HomePageViewModel(
      {required this.state,
      required this.onAddProject,
      required this.onImportProject,
      required this.onAddTemplates});

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
  // alaInstallReleases.hashCode;

}

class NavigationMiddleware implements MiddlewareClass<AppState> {
  @override
  call(Store<AppState> store, action, next) {
    /// The current state is null if (1) there is no widget in the tree that
    /// matches this global key, (2) that widget is not a [StatefulWidget], or the
    /// associated [State] object is not a subtype of `T`.
    NavigatorState? navigatorState = MainKeys.navKey.currentState;
    next(action);
    if (navigatorState != null) {
      if (action is CreateProject ||
          action is OpenProject ||
          action is ImportProject) {
        navigatorState.pushReplacementNamed(LAProjectEditPage.routeName);
      }
      if (action is TuneProject) {
        navigatorState.pushReplacementNamed(LAProjectTunePage.routeName);
      }
      if (action is OnPreDeployTasks) {
        navigatorState.pushReplacementNamed(PreDeployPage.routeName);
      }
      if (action is OnViewLogs) {
        navigatorState.pushReplacementNamed(LogsHistoryPage.routeName);
      }
      if (action is PrepareDeployProject) {
        navigatorState.pushNamed(DeployPage.routeName);
      }
      if (action is OpenProjectTools) {
        navigatorState.pushReplacementNamed(LAProjectViewPage.routeName);
      }
      if (action is DelProject) {
        navigatorState.pushReplacementNamed(HomePage.routeName);
      }
      if (action is AddProject) {
        // We open Tools instead of:
        navigatorState.pushReplacementNamed(HomePage.routeName);
      }
      if (action is UpdateProject) {
        // We open Tools instead of:
        // MyApp._navigatorKey.currentState.pushReplacementNamed(HomePage.routeName);
      }
      if (action is ShowDeployProjectResults) {
        navigatorState.pushNamed(DeployResultsPage.routeName);
      }
    }
  }
}
