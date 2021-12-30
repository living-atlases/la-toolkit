import 'dart:convert';

import 'package:beamer/beamer.dart';
import 'package:cron/cron.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: library_prefixes
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:la_toolkit/redux/appActions.dart';
import 'package:la_toolkit/redux/appReducer.dart';
import 'package:la_toolkit/redux/appStateMiddleware.dart';
import 'package:la_toolkit/redux/loggingMiddleware.dart';
import 'package:la_toolkit/utils/debounce.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:redux/redux.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:sails_io/sails_io.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io_client;

import 'components/appSnackBarMessage.dart';
import 'laTheme.dart';
import 'models/appState.dart';
import 'routes.dart';

Future<void> main() async {
  AppStateMiddleware appStateMiddleware = AppStateMiddleware();

  await dotenv.load(
      fileName: kReleaseMode ? 'env.production.txt' : '.env.development');

  print("Uri base: ${Uri.base.toString()}");
  if (kReleaseMode && !AppUtils.isDemo()) {
    // Get the env from the server in production also
    Uri url = Uri(
        scheme: Uri.base.scheme,
        host: Uri.base.host,
        port: Uri.base.port,
        path: "/api/v1/get-env");
    print("Uri env: ${url.toString()}");
    Response response = await http.get(url);
    if (response.statusCode == 200) {
      Map<String, String> jsonResponse = jsonDecode(response.body);
      await dotenv.load(
          fileName: 'env.production.txt', mergeWith: jsonResponse);
    }
  }

  if (kReleaseMode) {
    // is Release Mode ??
    print('Running in release mode');
    print("Backend: ${dotenv.env['BACKEND']}");
  } else {
    print('Running in debug mode');
    print("Backend: ${dotenv.env['BACKEND']}");
  }

  var io = SailsIOClient(socket_io_client.io(
      "${AppUtils.scheme}://${dotenv.env['BACKEND']}?__sails_io_sdk_version=0.11.0",
      socket_io_client.OptionBuilder().setTransports(['websocket']).build()));

  io.socket.onConnect((_) {
    // print('sails websocket: Connected to backend');
  });

  io.socket.onError((e) {
    print('sails websocket: Error connecting to backend');
    print(e);
  });

  io.get(
      url: "${AppUtils.scheme}://${dotenv.env['BACKEND']}/api/v1/projects-subs",
      cb: (body, jwrResponse) {
        // print(body);
        // print(jwrResponse.toJson());
      });

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
    // Disable for now
    // print("On store change: $state");
    try {
      appStateMiddleware.saveAppState(state);
    } catch (e) {
      store.dispatch(ShowSnackBar(
        AppSnackBarMessage.ok(
            "Something failed when trying to save your configuration"),
      ));
    }
  });
  store.dispatch(ProjectsLoad());
  store.dispatch(OnFetchSoftwareDepsState());

  // https://sailsjs.com/documentation/reference/web-sockets/socket-client/io-socket-on
  final debouncer = Debouncer(milliseconds: 1000);
  io.socket.on('project', (projects) {
    debouncer.run(() {
      print('sails websocket: projects subs call');
      store.dispatch(OnProjectsLoad(projects));
    });
  });

  final cron = Cron();
  cron.schedule(Schedule.parse('0 */3 * * *'), () async {
    // Every 3 hours check for new versions
    store.dispatch(OnFetchSoftwareDepsState());
  });

  // https://github.com/slovnicki/beamer/tree/master/package#tips-and-common-issues
  // This does not work in production as /project is a sails blueprint path also
  // Beamer.setPathUrlStrategy();

  runApp(MyApp(store: store));
  /* runApp(BetterFeedback(
    // key: _mainKey,
    child: MyApp(store: store),
    /*  onFeedback: (
      BuildContext context,
      String feedbackText,
      Uint8List feedbackScreenshot,
    ) {
      // upload to server, share whatever
      // for example purposes just show it to the user

      // https://github.com/ueman/feedback#upload-feedback
      alertFeedbackFunction(context, feedbackText, feedbackScreenshot);
      return;
    }, */
  )); */

  if (initialState.failedLoad) {
    store.dispatch(OnFetchStateFailed());
    store.dispatch(ShowSnackBar(
        AppSnackBarMessage.ok("Failed to retrieve your configuration")));
  }
  /*
  Does not work because creates an additional new MaterialApp and this breaks the navigation */
}

// https://stackoverflow.com/questions/50303441/flutter-redux-navigator-globalkey-currentstate-returns-null
class MainKeys {
  static final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
}

class MyApp extends StatelessWidget {
  final Store<AppState> store;

  static String appName = 'Living Atlases Toolkit';
  MyApp({Key? key, required this.store}) : super(key: key);

  final _routerDelegate = Routes().routerDelegate;

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
        store: store,
        child: GlobalLoaderOverlay(
            useDefaultLoading: true,
            overlayOpacity: 0.5,
            overlayColor: Colors.black,
            child: MaterialApp.router(
              routerDelegate: _routerDelegate,
              routeInformationParser: BeamerParser(),
              backButtonDispatcher:
                  BeamerBackButtonDispatcher(delegate: Routes().routerDelegate),
              // navigatorKey: MainKeys.navKey,
              builder: (context, widget) => ResponsiveWrapper.builder(
                  BouncingScrollWrapper.builder(context, widget!),
                  maxWidth: 1200,
                  minWidth: 450,
                  defaultScale: true,
                  breakpoints: [
                    const ResponsiveBreakpoint.resize(450, name: MOBILE),
                    const ResponsiveBreakpoint.autoScale(800, name: TABLET),
                    const ResponsiveBreakpoint.autoScale(1000, name: TABLET),
                    const ResponsiveBreakpoint.resize(1200, name: DESKTOP),
                    const ResponsiveBreakpoint.autoScale(2460, name: "4K"),
                  ],
                  background: Container(color: const Color(0xFFF5F5F5))),
              title: appName,
              theme: LAColorTheme.laThemeData,
              debugShowCheckedModeBanner: AppUtils.isDev(),
            )));
  }
}
