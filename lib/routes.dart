import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:la_toolkit/deployResultsPage.dart';
import 'package:la_toolkit/logsPage.dart';
import 'package:la_toolkit/preDeployPage.dart';
import 'package:la_toolkit/projectEditPage.dart';
import 'package:la_toolkit/projectTunePage.dart';
import 'package:la_toolkit/projectViewPage.dart';
import 'package:la_toolkit/sandboxPage.dart';
import 'package:la_toolkit/sshKeysPage.dart';

import 'deployPage.dart';
import 'homePage.dart';

class Routes {
  static final notFoundPage = BeamPage(
    child: Scaffold(
      body: Center(
        child: Text('Not found'),
      ),
    ),
  );

  BeamerRouterDelegate routerDelegate;

  Routes._privateConstructor()
      : routerDelegate =
            BeamerRouterDelegate(notFoundPage: notFoundPage, beamLocations: [
          HomeLocation(),
          LAProjectEditLocation(),
          LAProjectViewLocation(),
          SandboxLocation(),
          LAProjectTuneLocation(),
          PreDeployLocation(),
          LogsHistoryLocation(),
          SshKeysLocation(),
          DeployLocation(),
          DeployResultsLocation()
        ]);

  static final Routes _instance = Routes._privateConstructor();
  factory Routes() {
    return _instance;
  }
}

class HomeLocation extends BeamLocation {
  @override
  List<String> get pathBlueprints => ['/'];

  @override
  List<BeamPage> pagesBuilder(BuildContext context) => [
        BeamPage(
          key: ValueKey('home'),
          child: HomePage(),
        )
      ];
}

class LAProjectEditLocation extends BeamLocation {
  @override
  List<String> get pathBlueprints => ['/edit'];

  @override
  List<BeamPage> pagesBuilder(BuildContext context) => [
        BeamPage(
          key: ValueKey('edit'),
          child: LAProjectEditPage(),
        )
      ];
}

class LAProjectViewLocation extends BeamLocation {
  @override
  List<String> get pathBlueprints => ['/tools'];

  List<BeamPage> pagesBuilder(BuildContext context) => [
        BeamPage(
          key: ValueKey('tools'),
          child: LAProjectViewPage(),
        )
      ];
}

class SandboxLocation extends BeamLocation {
  @override
  List<String> get pathBlueprints => ['/sandbox'];

  @override
  List<BeamPage> pagesBuilder(BuildContext context) => [
        BeamPage(
          key: ValueKey('sandbox'),
          child: SandboxPage(),
        )
      ];
}

class LAProjectTuneLocation extends BeamLocation {
  @override
  List<String> get pathBlueprints => ['/tune'];

  @override
  List<BeamPage> pagesBuilder(BuildContext context) => [
        BeamPage(
          key: ValueKey('tune'),
          child: LAProjectTunePage(),
        )
      ];
}

class PreDeployLocation extends BeamLocation {
  @override
  List<String> get pathBlueprints => ['/predeploy'];

  @override
  List<BeamPage> pagesBuilder(BuildContext context) => [
        BeamPage(
          key: ValueKey('predeploy'),
          child: PreDeployPage(),
        )
      ];
}

class LogsHistoryLocation extends BeamLocation {
  @override
  List<String> get pathBlueprints => ['/logs'];

  @override
  List<BeamPage> pagesBuilder(BuildContext context) => [
        BeamPage(
          key: ValueKey('logs'),
          child: LogsHistoryPage(),
        )
      ];
}

class SshKeysLocation extends BeamLocation {
  @override
  List<String> get pathBlueprints => ['/ssh-keys'];

  @override
  List<BeamPage> pagesBuilder(BuildContext context) => [
        BeamPage(
          key: ValueKey('ssh-keys'),
          child: SshKeyPage(),
        )
      ];
}

class DeployLocation extends BeamLocation {
  @override
  List<String> get pathBlueprints => ['/deploy'];

  @override
  List<BeamPage> pagesBuilder(BuildContext context) => [
        BeamPage(
          key: ValueKey('deploy'),
          child: DeployPage(),
        )
      ];
}

class DeployResultsLocation extends BeamLocation {
  @override
  List<String> get pathBlueprints => ['/deploy-results'];

  @override
  List<BeamPage> pagesBuilder(BuildContext context) => [
        BeamPage(
          key: ValueKey('deploy-results'),
          child: DeployResultsPage(),
        )
      ];
}

/*
static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case ROUTE_HOME:
        final page = HomeScreen(settings.arguments);
        return MaterialPageRoute(builder: (context) => page);

      case ROUTE_SEARCH:
        final page = SearchScreen();
        return MaterialPageRoute(builder: (context) => page);

      default:
         return MaterialPageRoute(builder: (context) => LoginScreen());
    }
  }

}
*/
