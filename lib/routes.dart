import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:la_toolkit/cmdTermPage.dart';
import 'package:la_toolkit/deployResultsPage.dart';
import 'package:la_toolkit/logsPage.dart';
import 'package:la_toolkit/portalStatusPage.dart';
import 'package:la_toolkit/postDeployPage.dart';
import 'package:la_toolkit/preDeployPage.dart';
import 'package:la_toolkit/projectEditPage.dart';
import 'package:la_toolkit/projectTunePage.dart';
import 'package:la_toolkit/projectViewPage.dart';
import 'package:la_toolkit/sandboxPage.dart';
import 'package:la_toolkit/sshKeysPage.dart';

import 'deployPage.dart';
import 'homePage.dart';
import 'main.dart';

class Routes {
  static final notFoundPage = BeamPage(
    child: Scaffold(
      body: Center(
        child: Text('Not found'),
      ),
    ),
  );

  BeamerDelegate routerDelegate;

  Routes._privateConstructor()
      : routerDelegate = BeamerDelegate(
            notFoundPage: notFoundPage,
            // Better show a NotFoundPage
            // notFoundRedirect: HomeLocation(),
            locationBuilder: BeamerLocationBuilder(beamLocations: [
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
              DeployResultsLocation(),
              PortalStatusLocation(),
              // disabled for now CmdTermLocation()
            ]));

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
    Beamer.of(context).beamToNamed(loc.route);
  }
}

class HomeLocation extends NamedBeamLocation {
  @override
  List<String> get pathBlueprints => ['/'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(key: ValueKey('home'), child: HomePage(), title: MyApp.appName)
      ];

  @override
  String get route => HomePage.routeName;
}

class LAProjectEditLocation extends NamedBeamLocation {
  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
            key: ValueKey(route),
            child: LAProjectEditPage(),
            title: "${MyApp.appName}: Editing your project")
      ];
  @override
  String get route => LAProjectEditPage.routeName;
}

class LAProjectViewLocation extends NamedBeamLocation {
  List<BeamPage> buildPages(BuildContext context, BeamState state) =>
      [BeamPage(key: ValueKey(route), child: LAProjectViewPage())];

  @override
  String get route => LAProjectViewPage.routeName;
}

class SandboxLocation extends NamedBeamLocation {
  @override
  String get route => SandboxPage.routeName;
  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
            key: ValueKey(route),
            child: SandboxPage(),
            title: "${MyApp.appName}: Sandbox")
      ];
}

class LAProjectTuneLocation extends NamedBeamLocation {
  @override
  String get route => LAProjectTunePage.routeName;
  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
            key: ValueKey(route),
            child: LAProjectTunePage(),
            title: "${MyApp.appName}: Tune your project")
      ];
}

class PreDeployLocation extends NamedBeamLocation {
  @override
  String get route => PreDeployPage.routeName;

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(key: ValueKey(PreDeployPage.routeName), child: PreDeployPage())
      ];
}

class PostDeployLocation extends NamedBeamLocation {
  @override
  String get route => PostDeployPage.routeName;

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
            key: ValueKey(PostDeployPage.routeName), child: PostDeployPage())
      ];
}

class LogsHistoryLocation extends NamedBeamLocation {
  @override
  String get route => LogsHistoryPage.routeName;

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
            key: ValueKey(route),
            child: LogsHistoryPage(),
            title: "${MyApp.appName}: Logs History")
      ];
}

class SshKeysLocation extends NamedBeamLocation {
  @override
  String get route => SshKeyPage.routeName;
  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
            key: ValueKey(route),
            child: SshKeyPage(),
            title: "${MyApp.appName}: SSH Keys")
      ];
}

class DeployLocation extends NamedBeamLocation {
  @override
  String get route => DeployPage.routeName;

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) =>
      [BeamPage(key: ValueKey(route), child: DeployPage())];
}

class CmdTermLocation extends BeamLocation {
  @override
  List<String> get pathBlueprints => ['/${CmdTermPage.routeName}/:port/:pid'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
            key: ValueKey(
                '${CmdTermPage.routeName}-${state.pathParameters['port']}-${state.pathParameters['pid']}'),
            child:

                //if (state.uri.pathSegments.contains('books'))
                CmdTermPage(
                    port: int.parse(state.pathParameters['port']!),
                    ttydPid: int.parse(state.pathParameters['pid']!)))
      ];
}

class DeployResultsLocation extends NamedBeamLocation {
  @override
  String get route => DeployResultsPage.routeName;

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) =>
      [BeamPage(key: ValueKey(route), child: DeployResultsPage())];
}

class PortalStatusLocation extends NamedBeamLocation {
  @override
  String get route => PortalStatusPage.routeName;

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) =>
      [BeamPage(key: ValueKey(route), child: PortalStatusPage())];
}
