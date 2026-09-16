import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_toolkit/components/servers_card_list.dart';
import 'package:la_toolkit/models/app_state.dart';
import 'package:la_toolkit/models/deployment_type.dart';
import 'package:la_toolkit/models/la_cluster.dart';
import 'package:la_toolkit/models/la_project.dart';
import 'package:la_toolkit/models/la_server.dart';
import 'package:la_toolkit/redux/app_actions.dart';
import 'package:objectid/objectid.dart';
import 'package:redux/redux.dart';

import 'pump_app.dart';

/// The servers page of a data hub: its own VMs are editable as ever, and the
/// portal's compose cluster shows up as a target it borrows, which it can
/// assign onto but neither delete nor rename.
void main() {
  setUp(setUpDemoEnv);

  LAProject composePortal() {
    final LAProject portal = LAProject(
      longName: 'Portal',
      shortName: 'portal',
      domain: 'l-a.site',
      alaInstallRelease: '1.0.0',
      generatorRelease: '1.0.0',
    );
    final LAServer server = LAServer(
      id: ObjectId().toString(),
      name: 'la-mh-1',
      ip: '10.0.0.1',
      projectId: portal.id,
    );
    portal.upsertServer(server);
    portal.serviceInUse('docker_compose', true);
    portal.serviceInUse('ala_hub', true);
    portal.serviceInUse('branding', true);
    portal.assign(server, const <String>['docker_compose']);
    portal.assignByType(
      server.id,
      DeploymentType.dockerCompose,
      const <String>['ala_hub', 'branding'],
    );
    return portal;
  }

  LAProject hubWithOwnVm(LAProject portal) {
    final LAProject hub = LAProject(
      longName: 'Hub',
      shortName: 'hub',
      domain: 'records-hub.l-a.site',
      alaInstallRelease: '1.0.0',
      generatorRelease: '1.0.0',
      isHub: true,
      parent: portal,
    );
    hub.serviceInUse('ala_hub', true);
    hub.serviceInUse('branding', true);
    hub.serviceInUse('ala_bie', false);
    hub.serviceInUse('regions', false);
    portal.hubs.add(hub);
    final LAServer own = LAServer(
      id: ObjectId().toString(),
      name: 'hub-gateway',
      ip: '10.0.0.50',
      projectId: hub.id,
    );
    hub.upsertServer(own);
    final LACluster? composeCluster = portal.clusters.firstWhereOrNull(
      (LACluster c) => c.type == DeploymentType.dockerCompose,
    );
    if (composeCluster != null) {
      hub.assignByType(
        composeCluster.id,
        DeploymentType.dockerCompose,
        const <String>['ala_hub', 'branding'],
      );
    }
    return hub;
  }

  Future<void> pumpList(WidgetTester tester, LAProject project) async {
    useDesktopWindow(tester);
    final Store<AppState> store = demoStore();
    store.dispatch(OpenProjectTools(project));
    await tester.pumpWidget(
      wrapWithApp(store, const SingleChildScrollView(child: ServersCardList())),
    );
    await tester.pump();
  }

  testWidgets('the portal cluster is shown as borrowed, next to the own VM',
      (WidgetTester tester) async {
    final LAProject hub = hubWithOwnVm(composePortal());
    await pumpList(tester, hub);

    expect(find.text('hub-gateway'), findsOneWidget);
    expect(
      find.text('Docker Compose on la-mh-1 (portal portal)'),
      findsOneWidget,
    );
    expect(find.textContaining('belong to the portal portal'), findsOneWidget);
    // Own VM and borrowed cluster: both expandable.
    expect(find.byTooltip('Expand to assign services'), findsNWidgets(2));
  });

  testWidgets('a borrowed cluster has no delete button', (
    WidgetTester tester,
  ) async {
    final LAProject hub = hubWithOwnVm(composePortal());
    await pumpList(tester, hub);

    await tester.tap(find.byTooltip('Expand to assign services').last);
    await tester.pumpAndSettle();

    expect(find.textContaining('(portal)'), findsOneWidget);
    expect(find.byTooltip('Delete this'), findsNothing);
    expect(find.byIcon(Icons.expand_less), findsOneWidget);
  });

  testWidgets('the portal keeps the delete button on its own cluster', (
    WidgetTester tester,
  ) async {
    final LAProject portal = composePortal();
    await pumpList(tester, portal);

    expect(find.textContaining('belong to the portal'), findsNothing);
    await tester.tap(find.byTooltip('Expand to assign services').last);
    await tester.pumpAndSettle();
    expect(find.byTooltip('Delete this'), findsOneWidget);
  });

  testWidgets('a hub of a VM portal sees only its own machines', (
    WidgetTester tester,
  ) async {
    final LAProject portal = LAProject(
      longName: 'VM Portal',
      shortName: 'vmportal',
      domain: 'example.org',
      alaInstallRelease: '1.0.0',
      generatorRelease: '1.0.0',
    );
    final LAServer server = LAServer(
      id: ObjectId().toString(),
      name: 'portal-vm',
      ip: '10.0.0.9',
      projectId: portal.id,
    );
    portal.upsertServer(server);
    portal.serviceInUse('ala_hub', true);
    portal.assign(server, const <String>['ala_hub']);
    final LAProject hub = hubWithOwnVm(portal);
    await pumpList(tester, hub);

    expect(find.text('hub-gateway'), findsOneWidget);
    expect(find.text('portal-vm'), findsNothing);
    expect(find.textContaining('belong to the portal'), findsNothing);
  });
}
