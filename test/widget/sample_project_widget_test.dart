import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_toolkit/home_page.dart';
import 'package:la_toolkit/models/app_state.dart';
import 'package:la_toolkit/models/deployment_type.dart';
import 'package:la_toolkit/models/la_cluster.dart';
import 'package:la_toolkit/models/la_project.dart';
import 'package:redux/redux.dart';

import 'pump_app.dart';

/// The sample project only helps if it is reachable from the UI: that is the
/// whole point of shipping it instead of documenting a .yo-rc.json living in
/// another repo. These tests drive the (+) menu like a user does.
void main() {
  setUp(setUpDemoEnv);

  /// Taps the (+) menu entry once on an already pumped home page.
  Future<void> tapAddSample(WidgetTester tester, Store<AppState> store) async {
    final int before = store.state.projects.length;
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // The speed dial keeps the labels of a previous opening in the tree, so on
    // a second add there is more than one match: the visible one comes first.
    final Finder sample = find
        .text('Add a sample LA project (docker-compose)')
        .first;
    expect(sample, findsOneWidget);
    // runAsync: loading the template asset is real async I/O, which the fake
    // async of pump() never lets finish.
    await tester.runAsync(() async {
      await tester.tap(sample);
      for (int i = 0; i < 50 && store.state.projects.length == before; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
    });
    // Not pumpAndSettle: adding shows the loader overlay, and its spinner never
    // stops animating.
    await tester.pump();
  }

  Future<void> addSample(WidgetTester tester, Store<AppState> store) async {
    useDesktopWindow(tester);
    await tester.pumpWidget(wrapWithApp(store, const HomePage()));
    await tester.pumpAndSettle();
    await tapAddSample(tester, store);
  }

  testWidgets('the sample project is offered in the (+) menu and added', (
    WidgetTester tester,
  ) async {
    final Store<AppState> store = demoStore();
    expect(store.state.projects, isEmpty);

    await addSample(tester, store);

    expect(store.state.projects.length, 1);
    expect(
      find.text(store.state.projects[0].longName),
      findsWidgets,
      reason: 'the added project should show up in the projects list',
    );
  });

  testWidgets('what the UI adds is a docker-compose project', (
    WidgetTester tester,
  ) async {
    final Store<AppState> store = demoStore(
      dockerComposeReleases: <String>['1.7.1'],
    );

    await addSample(tester, store);

    final LAProject p = store.state.projects[0];
    expect(p.isPureDockerCompose, true);
    // The CI layout is three hosts, one docker-compose cluster each.
    expect(p.clusters.length, 3);
    for (final LACluster cluster in p.clusters) {
      expect(cluster.type, DeploymentType.dockerCompose);
    }
    expect(p.validateDataIntegrity(), isEmpty);
    // Seeded so the sample is not born incomplete.
    expect(p.dockerComposeRelease, '1.7.1');
  });

  testWidgets('two samples never share a configuration directory', (
    WidgetTester tester,
  ) async {
    // 'LADemo' suggests 'lademo', so before this the sample landed on the
    // directory of any real demo portal, and on itself when added twice.
    final Store<AppState> store = demoStore();

    await addSample(tester, store);
    // Let the (+) menu finish closing, so it can be opened a second time.
    await tester.pump(const Duration(seconds: 1));
    await tapAddSample(tester, store);

    expect(store.state.projects.length, 2);
    expect(
      store.state.projects.map((LAProject p) => p.dirName).toSet(),
      <String>{'lademo-docker', 'lademo-docker-1'},
    );
  });

  testWidgets('it is added even when no la-docker-compose release is known', (
    WidgetTester tester,
  ) async {
    final Store<AppState> store = demoStore();

    await addSample(tester, store);

    final LAProject p = store.state.projects[0];
    expect(p.isPureDockerCompose, true);
    expect(p.dockerComposeRelease, isNull);
  });
}
