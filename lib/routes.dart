import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

import 'branding_deploy_page.dart';
import 'cmdTermPage.dart';
import 'compare_data_page.dart';
import 'deployResultsPage.dart';
import 'deploy_page.dart';
import 'home_page.dart';
import 'logs_page.dart';
import 'main.dart';
import 'pipelines_page.dart';
import 'portalStatusPage.dart';
import 'postDeployPage.dart';
import 'preDeployPage.dart';
import 'projectServersPage.dart';
import 'projectTunePage.dart';
import 'project_edit_page.dart';
import 'project_view_page.dart';
import 'sandboxPage.dart';
import 'sshKeysPage.dart';

class Routes {
  factory Routes() {
    return _instance;
  }

  Routes._privateConstructor()
      : routerDelegate = BeamerDelegate(
            notFoundPage: notFoundPage,
            // Better show a NotFoundPage
            // notFoundRedirect: HomeLocation(),
            locationBuilder: BeamerLocationBuilder(beamLocations: <BeamLocation<
                RouteInformationSerializable<dynamic>>>[
              HomeLocation(),
              LAProjectEditLocation(),
              LAProjectServersLocation(),
              LAProjectViewLocation(),
              SandboxLocation(),
              LAProjectTuneLocation(),
              LogsHistoryLocation(),
              SshKeysLocation(),
              DeployLocation(),
              PreDeployLocation(),
              PostDeployLocation(),
              BrandingDeployLocation(),
              CmdResultsLocation(),
              PortalStatusLocation(),
              PipelinesLocation(),
              CompareDataLocation()
              // disabled for now CmdTermLocation()
            ]));
  static const BeamPage notFoundPage = BeamPage(
    child: Scaffold(
      body: Center(
        child: Text('Not found'),
      ),
    ),
  );

  BeamerDelegate routerDelegate;

  static final Routes _instance = Routes._privateConstructor();
}

abstract class NamedBeamLocation extends BeamLocation<BeamState> {
  String get route;

  @override
  List<String> get pathPatterns => <String>['/$route'];
}

class BeamerCond {
  static void of(BuildContext context, NamedBeamLocation loc) {
    Beamer.of(context).beamToNamed(loc.route);
  }
}

class HomeLocation extends NamedBeamLocation {
  @override
  List<String> get pathPatterns => <String>['/'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) =>
      <BeamPage>[
        BeamPage(
            key: const ValueKey('home'),
            child: const HomePage(),
            title: LaToolkitApp.appName)
      ];

  @override
  String get route => HomePage.routeName;
}

class LAProjectEditLocation extends NamedBeamLocation {
  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) =>
      <BeamPage>[
        BeamPage(
            key: ValueKey(route),
            child: LAProjectEditPage(),
            title: '${LaToolkitApp.appName}: Editing your project')
      ];

  @override
  String get route => LAProjectEditPage.routeName;
}

class LAProjectServersLocation extends NamedBeamLocation {
  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) =>
      <BeamPage>[
        BeamPage(
            key: ValueKey(route),
            child: const LAProjectServersPage(),
            title: '${LaToolkitApp.appName}: Servers of your project')
      ];

  @override
  String get route => LAProjectServersPage.routeName;
}

class LAProjectViewLocation extends NamedBeamLocation {
  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) =>
      <BeamPage>[
        BeamPage(
            key: ValueKey(route),
            popToNamed: '/',
            child: const LAProjectViewPage())
      ];

  @override
  String get route => LAProjectViewPage.routeName;
}

class SandboxLocation extends NamedBeamLocation {
  @override
  String get route => SandboxPage.routeName;

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) =>
      <BeamPage>[
        BeamPage(
            key: ValueKey(route),
            child: const SandboxPage(),
            title: '${LaToolkitApp.appName}: Sandbox')
      ];
}

class LAProjectTuneLocation extends NamedBeamLocation {
  @override
  String get route => LAProjectTunePage.routeName;

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) =>
      <BeamPage>[
        BeamPage(
            key: ValueKey(route),
            child: const LAProjectTunePage(),
            title: '${LaToolkitApp.appName}: Tune your project')
      ];
}

class PreDeployLocation extends NamedBeamLocation {
  @override
  String get route => PreDeployPage.routeName;

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) =>
      <BeamPage>[
        const BeamPage(
            key: ValueKey(PreDeployPage.routeName), child: PreDeployPage())
      ];
}

class BrandingDeployLocation extends NamedBeamLocation {
  @override
  String get route => BrandingDeployPage.routeName;

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) =>
      <BeamPage>[
        const BeamPage(
            key: ValueKey(BrandingDeployPage.routeName),
            child: BrandingDeployPage())
      ];
}

class PostDeployLocation extends NamedBeamLocation {
  @override
  String get route => PostDeployPage.routeName;

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) =>
      <BeamPage>[
        const BeamPage(
            key: ValueKey(PostDeployPage.routeName), child: PostDeployPage())
      ];
}

class LogsHistoryLocation extends NamedBeamLocation {
  @override
  String get route => LogsHistoryPage.routeName;

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) =>
      <BeamPage>[
        BeamPage(
            key: ValueKey(route),
            child: LogsHistoryPage(),
            title: '${LaToolkitApp.appName}: Logs History')
      ];
}

class SshKeysLocation extends NamedBeamLocation {
  @override
  String get route => SshKeyPage.routeName;

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) =>
      <BeamPage>[
        BeamPage(
            key: ValueKey(route),
            child: SshKeyPage(),
            title: '${LaToolkitApp.appName}: SSH Keys')
      ];
}

class DeployLocation extends NamedBeamLocation {
  @override
  String get route => DeployPage.routeName;

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) =>
      <BeamPage>[BeamPage(key: ValueKey(route), child: const DeployPage())];
}

class CmdTermLocation extends BeamLocation<BeamState> {
  @override
  List<String> get pathPatterns =>
      <String>['/${CmdTermPage.routeName}/:port/:pid'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) =>
      <BeamPage>[
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

class CmdResultsLocation extends NamedBeamLocation {
  @override
  String get route => CmdResultsPage.routeName;

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) =>
      <BeamPage>[BeamPage(key: ValueKey(route), child: const CmdResultsPage())];
}

class PortalStatusLocation extends NamedBeamLocation {
  @override
  String get route => PortalStatusPage.routeName;

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) =>
      <BeamPage>[
        BeamPage(key: ValueKey(route), child: const PortalStatusPage())
      ];
}

class PipelinesLocation extends NamedBeamLocation {
  @override
  String get route => PipelinesPage.routeName;

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) =>
      <BeamPage>[BeamPage(key: ValueKey(route), child: const PipelinesPage())];
}

class CompareDataLocation extends NamedBeamLocation {
  @override
  String get route => CompareDataPage.routeName;

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) =>
      <BeamPage>[
        BeamPage(key: ValueKey(route), child: const CompareDataPage())
      ];
}
