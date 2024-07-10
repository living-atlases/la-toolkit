import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:beamer/beamer.dart';
import 'package:cron/cron.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:json_theme/json_theme.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:redux/redux.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:sails_io/sails_io.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io_client;
import 'package:stack_trace/stack_trace.dart';

import 'components/appSnackBarMessage.dart';
import 'models/appState.dart';
import 'redux/appStateMiddleware.dart';
import 'redux/app_actions.dart';
import 'redux/app_reducer.dart';
import 'redux/loggingMiddleware.dart';
import 'routes.dart';
import 'utils/debounce.dart';
import 'utils/utils.dart';

Future<void> main() async {
  //Chain.capture(() async {
  final AppStateMiddleware appStateMiddleware = AppStateMiddleware();
  WidgetsFlutterBinding.ensureInitialized();
  final String themeStr =
      await rootBundle.loadString('assets/appainter_theme.json');
  final dynamic themeJson = jsonDecode(themeStr);
  final ThemeData theme = ThemeDecoder.decodeThemeData(themeJson)!;

  const String dotFile =
      kReleaseMode ? 'env.production.txt' : 'env.development.txt';
  await dotenv.load(fileName: dotFile);

  /*
  // Disabled because of Zone mismatch errors
  await SentryFlutter.init((options) {
    options.dsn = "${dotenv.env['SENTRY_DSN']}";
  }, appRunner: () async { */
  log('Uri base: ${Uri.base}');
  if (kReleaseMode && !AppUtils.isDemo()) {
    // Get the env from the server in production also
    final Uri url = Uri(
        scheme: Uri.base.scheme,
        host: Uri.base.host,
        port: Uri.base.port,
        path: '/api/v1/get-env');
    log('Uri env: $url');
    final Response response = await http.get(url);
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse =
          jsonDecode(response.body) as Map<String, dynamic>;
      final Map<String, String> serverEnvStringMap =
          jsonResponse.map((String key, dynamic value) {
        return MapEntry<String, String>(key, value.toString());
      });
      await dotenv.load(fileName: dotFile, mergeWith: serverEnvStringMap);
    }
  }

  if (kReleaseMode) {
    // is Release Mode ??
    log('Running in release mode');
    log("Backend: ${dotenv.env['BACKEND']}");
  } else {
    log('Running in debug mode');
    log("Backend: ${dotenv.env['BACKEND']}");
  }

  final AppState initialState = await appStateMiddleware.getState();
  // log("Loaded prefs: $state");

  final Store<AppState> store = Store<AppState>(
    appReducer,
    initialState: initialState,
    middleware: <Middleware<AppState>>[
      customLogPrinter(),
      appStateMiddleware,
    ],
  );
  store.onChange.listen((AppState state) {
    // Disable for now
    log('On store change: ${state.debugPrintShort()}');
    try {
      appStateMiddleware.saveAppState(state);
    } catch (e) {
      store.dispatch(ShowSnackBar(
        AppSnackBarMessage.ok(
            'Something failed when trying to save your configuration'),
      ));
    }
  });
  store.dispatch(ProjectsLoad());
  store.dispatch(OnFetchSoftwareDepsState());

  if (!AppUtils.isDemo()) {
    final SailsIOClient io = SailsIOClient(socket_io_client.io(
        "${AppUtils.scheme}://${dotenv.env['BACKEND']}?__sails_io_sdk_version=0.11.0",
        socket_io_client.OptionBuilder()
            .setTransports(<String>['websocket']).build()));

    io.socket.onConnect((_) {
      // log('sails websocket: Connected to backend');
    });

    io.socket.onError((dynamic e) {
      log('sails websocket: Error connecting to backend');
      log(e.toString());
    });

    io.get(
        url:
            "${AppUtils.scheme}://${dotenv.env['BACKEND']}/api/v1/projects-subs",
        cb: (dynamic body, JWR jwrResponse) {
          // log(body);
          // log(jwrResponse.toJson());
        });

    // https://sailsjs.com/documentation/reference/web-sockets/socket-client/io-socket-on
    final Debouncer debouncer = Debouncer(milliseconds: 1000);
    io.socket.on('project', (dynamic projects) {
      debouncer.run(() {
        if (kDebugMode) {
          log('sails websocket: projects subs call');
        }
        store.dispatch(OnProjectsLoad(projects as List<dynamic>, false));
      });
    });
  }

  final Cron cron = Cron();
  cron.schedule(Schedule.parse('0 */3 * * *'), () async {
    // Every 3 hours check for new versions
    store.dispatch(OnFetchSoftwareDepsState());
  });

  // https://github.com/slovnicki/beamer/tree/master/package#tips-and-common-issues
  // This does not work in production as /project is a sails bluedebugPrint path also
  // Beamer.setPathUrlStrategy();

  if (initialState.failedLoad) {
    store.dispatch(OnFetchStateFailed());
    store.dispatch(ShowSnackBar(
        AppSnackBarMessage.ok('Failed to retrieve your configuration')));
  }

  runApp(LaToolkitApp(store: store, theme: theme));

  // });
}

class LaToolkitApp extends StatelessWidget {
  LaToolkitApp({super.key, required this.store, required this.theme});

  final Store<AppState> store;
  final ThemeData theme;
  static String appName = 'Living Atlases Toolkit';

  final BeamerDelegate _routerDelegate = Routes().routerDelegate;

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
        store: store,
        child: GlobalLoaderOverlay(
            // useDefaultLoading: true,
            overlayColor: Colors.grey.withOpacity(0.5),
            child: MaterialApp.router(
              routerDelegate: _routerDelegate,
              routeInformationParser: BeamerParser(),
              backButtonDispatcher:
                  BeamerBackButtonDispatcher(delegate: Routes().routerDelegate),
              // navigatorKey: MainKeys.navKey,
              builder: (BuildContext context, Widget? widget) =>
                  ResponsiveWrapper.builder(
                      BouncingScrollWrapper.builder(context, widget!),
                      maxWidth: 1200,
                      // minWidth: 450,
                      defaultScale: true,
                      breakpoints: <ResponsiveBreakpoint>[
                        const ResponsiveBreakpoint.resize(450, name: MOBILE),
                        const ResponsiveBreakpoint.autoScale(800, name: TABLET),
                        const ResponsiveBreakpoint.autoScale(1000,
                            name: TABLET),
                        const ResponsiveBreakpoint.resize(1200, name: DESKTOP),
                        const ResponsiveBreakpoint.resize(2460, name: '4K'),
                      ],
                      background: Container(color: const Color(0xFFF5F5F5))),
              title: appName,
              theme: theme,
              debugShowCheckedModeBanner: AppUtils.isDev(),
            )));
  }
}
