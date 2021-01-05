import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/laAppBar.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/projectPage.dart';
import 'package:la_toolkit/projectsListPage.dart';
import 'package:la_toolkit/redux/appActions.dart';
import 'package:la_toolkit/redux/appReducer.dart';
import 'package:la_toolkit/redux/appStateMiddleware.dart';
import 'package:la_toolkit/redux/loggingMiddleware.dart';
import 'package:la_toolkit/routes.dart';
import 'package:la_toolkit/sandboxPage.dart';
import 'package:redux/redux.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'intro.dart';
import 'laTheme.dart';
import 'models/appState.dart';

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

void main() {
  var appStateMiddleware = AppStateMiddleware();
  final store = Store<AppState>(
    appReducer,
    initialState:
        AppState(projects: List<LAProject>.empty(), firstUsage: false),
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
  store.dispatch(FetchProjects());

  runApp(MyApp(store: store));
}

final String appName = 'Living Atlases Toolkit';

class MyApp extends StatelessWidget {
  final Store<AppState> store;

  const MyApp({Key key, this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
        store: store,
        child: MaterialApp(
          navigatorKey: navigatorKey,
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
          onGenerateRoute: (RouteSettings settings) {
            return Routes.fadeThrough(settings, (context) {
              switch (settings.name) {
                case HomePage.routeName:
                  return HomePage(title: appName);
                  break;
                case LAProjectPage.routeName:
                  return LAProjectPage();
                  break;
                case SandboxPage.routeName:
                  return SandboxPage();
                  break;
                default:
                  return HomePage(title: appName);
                  break;
              }
            });
          },
          title: appName,
          /*  routes: {
            HomePage.routeName: (context) => HomePage(title: appName),
            LAProjectPage.routeName: (context) => LAProjectPage(),
          }, */

          theme: LAColorTheme.laThemeData,
          debugShowCheckedModeBanner: false,
        ));
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

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _HomePageViewModel>(converter: (store) {
      return _HomePageViewModel(
        state: store.state,
        onAddProject: () {
          store.dispatch(CreateProject());
          // Navigator.pushNamed(context, LAProjectPage.routeName);
        },
      );
    }, builder: (BuildContext context, _HomePageViewModel vm) {
      return !vm.state.firstUsage
          ? Scaffold(
              key: _scaffoldKey,
              // Maybe:
              // https://api.flutter.dev/flutter/material/SliverAppBar-class.html
              // App bar with floating: true, pinned: true, snap: false:
              appBar: LAAppBar(title: appName, showLaIcon: true),
              body: LAProjectsListPage(),
              floatingActionButton: vm.state.projects.length > 0
                  ? FloatingActionButton.extended(
                      onPressed: () {
                        // Navigator.pushNamed(context, LAProjectPage.routeName);
                        vm.onAddProject();
                      },
                      label: Text('Create a new LA Project'),
                      icon: Icon(Icons.add_circle_outline),
                      // backgroundColor: Colors.pink,
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
}

class NavigationMiddleware implements MiddlewareClass<AppState> {
  @override
  call(Store<AppState> store, action, next) {
    if (action is CreateProject || action is OpenProject) {
      navigatorKey.currentState.pushNamed(LAProjectPage.routeName);
    }
    if (action is AddProject || action is UpdateProject) {
      navigatorKey.currentState.pushNamed(HomePage.routeName);
    }
    next(action);
  }
}
