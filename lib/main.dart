import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/laAppBar.dart';
import 'package:la_toolkit/deployResultsPage.dart';
import 'package:la_toolkit/projectEditPage.dart';
import 'package:la_toolkit/projectTunePage.dart';
import 'package:la_toolkit/projectViewPage.dart';
import 'package:la_toolkit/projectsListPage.dart';
import 'package:la_toolkit/redux/appActions.dart';
import 'package:la_toolkit/redux/appReducer.dart';
import 'package:la_toolkit/redux/appStateMiddleware.dart';
import 'package:la_toolkit/redux/loggingMiddleware.dart';
import 'package:la_toolkit/routes.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:redux/redux.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'components/mainDrawer.dart';
import 'deployPage.dart';
import 'intro.dart';
import 'laTheme.dart';
import 'models/appState.dart';

Future<void> main() async {
  var appStateMiddleware = AppStateMiddleware();

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

  var initialState = await appStateMiddleware.getState();
  // print("Loaded prefs: $state");

  var store = Store<AppState>(
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
    appStateMiddleware.saveAppState(state);
  });
  store.dispatch(OnFetchState());

  runApp(MyApp(store: store));

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

class MyApp extends StatelessWidget {
  final Store<AppState> store;
  static final GlobalKey<NavigatorState> _navigatorKey =
      new GlobalKey<NavigatorState>();

  const MyApp({Key key, this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
        store: store,
        child: GlobalLoaderOverlay(
            useDefaultLoading: true,
            overlayOpacity: 0.5,
            overlayColor: Colors.black,
            child: MaterialApp(
              navigatorKey: _navigatorKey,
              builder: (context, widget) => ResponsiveWrapper.builder(
                  BouncingScrollWrapper.builder(context, widget),
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

  HomePage({Key key, this.title}) : super(key: key);

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
            onAddProject: () {
              store.dispatch(CreateProject());
              // Navigator.pushNamed(context, LAProjectPage.routeName);
            },
          );
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
                  body: LAProjectsListPage(),
                  floatingActionButton: vm.state.projects.length > 0
                      ? FloatingActionButton.extended(
                          onPressed: () {
                            vm.onAddProject();
                          },
                          label: Text('Create a new LA Project'),
                          icon: Icon(Icons.add_circle_outline),
                        )
                      : null)
              : Intro();
        });
  }
}

class _HomePageViewModel {
  final AppState state;
  final void Function() onAddProject;

  _HomePageViewModel({this.state, this.onAddProject});

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
    if (action is CreateProject || action is OpenProject) {
      MyApp._navigatorKey.currentState.pushNamed(LAProjectEditPage.routeName);
    }
    if (action is TuneProject) {
      MyApp._navigatorKey.currentState.pushNamed(LAProjectTunePage.routeName);
    }
    if (action is PrepareDeployProject) {
      MyApp._navigatorKey.currentState.pushNamed(DeployPage.routeName);
    }
    if (action is OpenProjectTools) {
      MyApp._navigatorKey.currentState.pushNamed(LAProjectViewPage.routeName);
    }
    if (action is DelProject) {
      MyApp._navigatorKey.currentState.pushNamed(HomePage.routeName);
    }
    if (action is AddProject) {
      // We open Tools instead of:
      MyApp._navigatorKey.currentState.pushNamed(HomePage.routeName);
    }
    if (action is UpdateProject) {
      // We open Tools instead of:
      // MyApp._navigatorKey.currentState.pushNamed(HomePage.routeName);
    }
    if (action is ShowDeployProjectResults) {
      MyApp._navigatorKey.currentState.pushNamed(DeployResultsPage.routeName);
    }
    next(action);
  }
}
