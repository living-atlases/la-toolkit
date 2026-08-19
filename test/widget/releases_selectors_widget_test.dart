import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_toolkit/la_releases_selectors.dart';
import 'package:la_toolkit/models/app_state.dart';
import 'package:la_toolkit/models/deployment_type.dart';
import 'package:la_toolkit/models/la_project.dart';
import 'package:la_toolkit/models/la_releases.dart';
import 'package:la_toolkit/models/la_server.dart';
import 'package:la_toolkit/models/la_service_constants.dart';
import 'package:la_toolkit/redux/app_reducer.dart';
import 'package:redux/redux.dart';

import 'pump_app.dart';

// gh-22: an untouched version dropdown displayed a default the model never
// stored, so the deploy used a different version than the one on screen. The
// full page path: mount the selectors, touch nothing, and check that what they
// display is exactly what they hand over for persistence.
void main() {
  setUpAll(setUpDemoEnv);

  LAProject dockerComposeProject() {
    final LAProject project = LAProject(
      longName: 'NLPHH Atlas',
      shortName: 'NLPHH',
      domain: 'ala.example.org',
    );
    final LAServer server = LAServer(
      name: 'fatman',
      projectId: project.id,
      ip: '10.0.0.1',
    );
    project.upsertServer(server);
    project.serviceInUse(collectory, true);
    // Assigned before laReleases loads (real startup order), so the seed
    // stores no version for collectory.
    project.assignByType(
      server.id,
      DeploymentType.dockerCompose,
      <String>[collectory, dockerCompose],
    );
    return project;
  }

  Map<String, LAReleases> collectoryReleases() {
    return <String, LAReleases>{
      collectory: LAReleases(
        name: collectory,
        latest: '1.6.4',
        versions: const <String>['1.6.4', '1.3.12'],
        artifacts: 'collectory',
      ),
      '${collectory}_nexus': LAReleases(
        name: '${collectory}_nexus',
        latest: '6.0.0',
        versions: const <String>['6.0.0', '5.1.1'],
        artifacts: 'collectory',
      ),
    };
  }

  Widget selectorsUnderTest(
    Store<AppState> store,
    void Function(Map<String, String>) onPersist,
  ) {
    return wrapWithApp(
      store,
      Scaffold(
        body: SingleChildScrollView(
          child: LAReleasesSelectors(
            onSoftwareSelected: (String sw, String version, bool save) {},
            onInitialVersionsPersist: onPersist,
          ),
        ),
      ),
    );
  }

  testWidgets('untouched dropdowns hand their displayed versions over for '
      'persistence', (WidgetTester tester) async {
    useDesktopWindow(tester);
    final LAProject project = dockerComposeProject();
    expect(project.getServiceDeployRelease(collectory), isNull);

    final Store<AppState> store = Store<AppState>(
      appReducer,
      initialState: AppState(
        currentProject: project,
        laReleases: collectoryReleases(),
      ),
    );

    Map<String, String>? persisted;
    await tester.pumpWidget(
      selectorsUnderTest(store, (Map<String, String> versions) {
        persisted = versions;
        versions.forEach(project.setServiceDeployRelease);
      }),
    );
    // The persist batch runs in a post-frame callback.
    await tester.pump();

    expect(persisted, isNotNull, reason: 'The batch persist must have fired');
    expect(
      persisted![collectory],
      equals('6.0.0'),
      reason:
          'The displayed nexus default (docker-compose narrows to nexus '
          'versions) is what must be persisted',
    );
    expect(project.getServiceDeployRelease(collectory), equals('6.0.0'));
  });

  testWidgets('once the model stores the version nothing is re-persisted', (
    WidgetTester tester,
  ) async {
    useDesktopWindow(tester);
    final LAProject project = dockerComposeProject();
    project.setServiceDeployRelease(collectory, '5.1.1');

    final Store<AppState> store = Store<AppState>(
      appReducer,
      initialState: AppState(
        currentProject: project,
        laReleases: collectoryReleases(),
      ),
    );

    Map<String, String>? persisted;
    await tester.pumpWidget(
      selectorsUnderTest(store, (Map<String, String> versions) {
        persisted = versions;
      }),
    );
    await tester.pump();

    expect(
      persisted?[collectory],
      isNull,
      reason: 'A stored version must not be re-persisted',
    );
    // And the dropdown shows the stored version, not the list default.
    expect(find.text('5.1.1'), findsWidgets);
  });
}
