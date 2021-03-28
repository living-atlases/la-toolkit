import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:la_toolkit/deployResultsPage.dart';
import 'package:la_toolkit/logsPage.dart';
import 'package:la_toolkit/postDeployPage.dart';
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
      : routerDelegate = BeamerRouterDelegate(notFoundPage: notFoundPage,
            // Better show a NotFoundPage
            // notFoundRedirect: HomeLocation(),
            navigatorObservers: [
              if (AppUtils.isDev()) devNavObserver
            ], beamLocations: [
          HomeLocation(),
          LAProjectEditLocation(),
          LAProjectViewLocation(),
          SandboxLocation(),
          LAProjectTuneLocation(),
          LogsHistoryLocation(),
          SshKeysLocation(),
          DeployLocation(),
          PreDeployLocation(),
          PostDeployLocation(),
          DeployResultsLocation()
        ]);

  static final Routes _instance = Routes._privateConstructor();
  factory Routes() {
    return _instance;
  }
}

abstract class NamedBeamLocation extends BeamLocation {
  String get route;
  @override
  List<String> get pathBlueprints => ['/' + route];
}

class BeamerCond {
  static of(BuildContext context, NamedBeamLocation loc) {
    if (AppUtils.isDev())
      Beamer.of(context).beamToNamed(loc.route);
    else
      Beamer.of(context).beamTo(loc);
  }
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
  List<BeamPage> pagesBuilder(BuildContext context) => [
        BeamPage(
          key: ValueKey(route),
          child: LAProjectEditPage(),
        )
      ];
  @override
  String get route => LAProjectEditPage.routeName;
}

class LAProjectViewLocation extends NamedBeamLocation {
  List<BeamPage> pagesBuilder(BuildContext context) => [
        BeamPage(
          key: ValueKey(route),
          child: LAProjectViewPage(),
        )
      ];

  @override
  String get route => LAProjectViewPage.routeName;
}

class SandboxLocation extends NamedBeamLocation {
  @override
  String get route => SandboxPage.routeName;
  @override
  List<BeamPage> pagesBuilder(BuildContext context) => [
        BeamPage(
          key: ValueKey(route),
          child: SandboxPage(),
        )
      ];
}

class LAProjectTuneLocation extends NamedBeamLocation {
  @override
  String get route => LAProjectTunePage.routeName;
  @override
  List<BeamPage> pagesBuilder(BuildContext context) => [
        BeamPage(
          key: ValueKey(route),
          child: LAProjectTunePage(),
        )
      ];
}

class PreDeployLocation extends NamedBeamLocation {
  @override
  String get route => PreDeployPage.routeName;

  @override
  List<BeamPage> pagesBuilder(BuildContext context) => [
        BeamPage(
          key: ValueKey(PreDeployPage.routeName),
          child: PreDeployPage(),
        )
      ];
}

class PostDeployLocation extends NamedBeamLocation {
  @override
  String get route => PostDeployPage.routeName;

  @override
  List<BeamPage> pagesBuilder(BuildContext context) => [
        BeamPage(
          key: ValueKey(PostDeployPage.routeName),
          child: PostDeployPage(),
        )
      ];
}

class LogsHistoryLocation extends NamedBeamLocation {
  @override
  String get route => LogsHistoryPage.routeName;

  @override
  List<BeamPage> pagesBuilder(BuildContext context) => [
        BeamPage(
          key: ValueKey(route),
          child: LogsHistoryPage(),
        )
      ];
}

class SshKeysLocation extends NamedBeamLocation {
  @override
  String get route => SshKeyPage.routeName;
  @override
  List<BeamPage> pagesBuilder(BuildContext context) => [
        BeamPage(
          key: ValueKey(route),
          child: SshKeyPage(),
        )
      ];
}

class DeployLocation extends NamedBeamLocation {
  @override
  String get route => DeployPage.routeName;

  @override
  List<BeamPage> pagesBuilder(BuildContext context) => [
        BeamPage(
          key: ValueKey(route),
          child: DeployPage(),
        )
      ];
}

class DeployResultsLocation extends NamedBeamLocation {
  @override
  String get route => DeployResultsPage.routeName;

  @override
  List<BeamPage> pagesBuilder(BuildContext context) => [
        BeamPage(
          key: ValueKey(route),
          child: DeployResultsPage(),
        )
      ];
}
