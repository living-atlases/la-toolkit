import 'package:beamer/beamer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/redux/appActions.dart';
import 'package:la_toolkit/redux/appReducer.dart';
import 'package:la_toolkit/redux/appStateMiddleware.dart';
import 'package:la_toolkit/redux/loggingMiddleware.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:redux/redux.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'components/appSnackBarMessage.dart';
import 'laTheme.dart';
import 'models/appState.dart';
import 'routes.dart';

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
    ],
  );
  store.onChange.listen((state) {
    print("On store change: $state");
    try {
      appStateMiddleware.saveAppState(state);
    } catch (e) {
      store.dispatch(ShowSnackBar(
        AppSnackBarMessage.ok(
            "Something failed when trying to save your configuration"),
      ));
    }
  });
  store.dispatch(OnFetchState());
  runApp(MyApp(store: store));

  if (initialState.failedLoad) {
    store.dispatch(OnFetchStateFailed());
    store.dispatch(ShowSnackBar(
        AppSnackBarMessage.ok("Failed to retrieve your configuration")));
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

// https://stackoverflow.com/questions/50303441/flutter-redux-navigator-globalkey-currentstate-returns-null
class MainKeys {
  static final GlobalKey<NavigatorState> navKey =
      new GlobalKey<NavigatorState>();
}

class MyApp extends StatelessWidget {
  final Store<AppState> store;

  static String appName = 'Living Atlases Toolkit';
  MyApp({Key? key, required this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
        store: store,
        child: GlobalLoaderOverlay(
            useDefaultLoading: true,
            overlayOpacity: 0.5,
            overlayColor: Colors.black,
            child: MaterialApp.router(
              routerDelegate: Routes().routerDelegate,
              routeInformationParser: BeamerRouteInformationParser(),
              backButtonDispatcher:
                  BeamerBackButtonDispatcher(delegate: Routes().routerDelegate),
              // navigatorKey: MainKeys.navKey,
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
              title: appName,
              theme: LAColorTheme.laThemeData,
              debugShowCheckedModeBanner: false,
            )));
  }
}
