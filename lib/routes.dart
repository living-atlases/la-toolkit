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
import 'package:la_toolkit/utils/utils.dart';

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
  static final NavigatorObserver devNavObserver = NavigatorObserver();

  Routes._privateConstructor()
      : routerDelegate = BeamerRouterDelegate(
            notFoundPage: notFoundPage,
            notFoundRedirect: HomeLocation(),
            navigatorObservers: [
              if (AppUtils.isDev()) devNavObserver
            ],
            beamLocations: [
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

abstract class NamedBeamLocation extends BeamLocation {
  String get route;
}

class HomeLocation extends NamedBeamLocation {
  @override
  List<String> get pathBlueprints => ['/'];

  @override
  List<BeamPage> pagesBuilder(BuildContext context) => [
        BeamPage(
          key: ValueKey('home'),
          child: HomePage(),
        )
      ];

  @override
  String get route => HomePage.routeName;
}

class LAProjectEditLocation extends NamedBeamLocation {
  @override
  List<String> get pathBlueprints => ['/edit'];

  @override
  List<BeamPage> pagesBuilder(BuildContext context) => [
        BeamPage(
          key: ValueKey('edit'),
          child: LAProjectEditPage(),
        )
      ];
  @override
  String get route => LAProjectEditPage.routeName;
}

class LAProjectViewLocation extends NamedBeamLocation {
  @override
  List<String> get pathBlueprints => ['/tools'];

  List<BeamPage> pagesBuilder(BuildContext context) => [
        BeamPage(
          key: ValueKey('tools'),
          child: LAProjectViewPage(),
        )
      ];

  @override
  String get route => LAProjectViewPage.routeName;
}

class SandboxLocation extends NamedBeamLocation {
  @override
  List<String> get pathBlueprints => ['/sandbox'];
  @override
  String get route => SandboxPage.routeName;
  @override
  List<BeamPage> pagesBuilder(BuildContext context) => [
        BeamPage(
          key: ValueKey('sandbox'),
          child: SandboxPage(),
        )
      ];
}

class BeamerCond {
  static of(BuildContext context, NamedBeamLocation loc) {
    if (AppUtils.isDev())
      Beamer.of(context).beamToNamed(loc.route);
    else
      Beamer.of(context).beamTo(loc);
  }
}

class LAProjectTuneLocation extends NamedBeamLocation {
  @override
  List<String> get pathBlueprints => ['/tune'];
  @override
  String get route => LAProjectTunePage.routeName;
  @override
  List<BeamPage> pagesBuilder(BuildContext context) => [
        BeamPage(
          key: ValueKey('tune'),
          child: LAProjectTunePage(),
        )
      ];
}

class PreDeployLocation extends NamedBeamLocation {
  @override
  List<String> get pathBlueprints => ['/predeploy'];

  @override
  String get route => PreDeployPage.routeName;

  @override
  List<BeamPage> pagesBuilder(BuildContext context) => [
        BeamPage(
          key: ValueKey('predeploy'),
          child: PreDeployPage(),
        )
      ];
}

class LogsHistoryLocation extends NamedBeamLocation {
  @override
  List<String> get pathBlueprints => ['/logs'];
  @override
  String get route => LogsHistoryPage.routeName;

  @override
  List<BeamPage> pagesBuilder(BuildContext context) => [
        BeamPage(
          key: ValueKey('logs'),
          child: LogsHistoryPage(),
        )
      ];
}

class SshKeysLocation extends NamedBeamLocation {
  @override
  List<String> get pathBlueprints => ['/ssh-keys'];
  @override
  String get route => SshKeyPage.routeName;
  @override
  List<BeamPage> pagesBuilder(BuildContext context) => [
        BeamPage(
          key: ValueKey('ssh-keys'),
          child: SshKeyPage(),
        )
      ];
}

class DeployLocation extends NamedBeamLocation {
  @override
  List<String> get pathBlueprints => ['/deploy'];

  @override
  String get route => DeployPage.routeName;

  @override
  List<BeamPage> pagesBuilder(BuildContext context) => [
        BeamPage(
          key: ValueKey('deploy'),
          child: DeployPage(),
        )
      ];
}

class DeployResultsLocation extends NamedBeamLocation {
  @override
  List<String> get pathBlueprints => ['/deploy-results'];

  @override
  String get route => DeployResultsPage.routeName;

  @override
  List<BeamPage> pagesBuilder(BuildContext context) => [
        BeamPage(
          key: ValueKey('deploy-results'),
          child: DeployResultsPage(),
        )
      ];
}
