import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_toolkit/models/app_state.dart';
import 'package:la_toolkit/redux/app_reducer.dart';
import 'package:la_toolkit/redux/app_state_middleware.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:redux/redux.dart';

/// Test harness for the widgets that need the real store.
///
/// Runs the app in demo mode (`DEMO=true`), which is what keeps these tests
/// offline: every Api call short-circuits and the middleware puts the projects
/// straight in the store instead of POSTing them to the backend.
Store<AppState> demoStore({List<String> dockerComposeReleases = const <String>[]}) {
  return Store<AppState>(
    appReducer,
    initialState: AppState(
      dockerComposeReleases: List<String>.from(dockerComposeReleases),
    ),
    middleware: <Middleware<AppState>>[AppStateMiddleware()],
  );
}

void setUpDemoEnv() {
  TestWidgetsFlutterBinding.ensureInitialized();
  dotenv.testLoad(fileInput: 'DEMO=true\nBACKEND=localhost:1337\nHTTPS=false');
  PackageInfo.setMockInitialValues(
    appName: 'la_toolkit',
    packageName: 'la_toolkit',
    version: '0.0.0-test',
    buildNumber: '0',
    buildSignature: '',
  );
  // The app asks the bundle for 'la-toolkit-templates.json' (AssetsUtils
  // .pathWorkaround drops the 'assets/' prefix outside release builds), a key
  // the test bundle does not know. Serve assets from the directory flutter test
  // stages them in, falling back to the package root, so the sample template
  // loads under either spelling and everything else (AssetManifest, fonts)
  // still resolves.
  const String staged = 'build/unit_test_assets';
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', (ByteData? message) async {
        final String key = utf8.decode(message!.buffer.asUint8List());
        for (final String candidate in <String>[
          '$staged/$key',
          '$staged/assets/$key',
          key,
          'assets/$key',
        ]) {
          final File file = File(candidate);
          if (file.existsSync()) {
            final Uint8List bytes = file.readAsBytesSync();
            return ByteData.view(bytes.buffer);
          }
        }
        return null;
      });
}

/// The toolkit is a desktop web app: its project cards and speed dial labels do
/// not fit the 800x600 the test binding defaults to. Size the surface like a
/// real window, and restore it afterwards.
void useDesktopWindow(WidgetTester tester) {
  tester.view.physicalSize = const Size(1440, 1024);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

/// Wraps [child] with everything the pages take from their ancestors: the redux
/// store, a MaterialApp and the loader overlay used while projects are saved.
Widget wrapWithApp(Store<AppState> store, Widget child) {
  return StoreProvider<AppState>(
    store: store,
    child: MaterialApp(
      home: GlobalLoaderOverlay(child: child),
    ),
  );
}
