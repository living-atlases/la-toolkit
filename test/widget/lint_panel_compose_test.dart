import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_toolkit/components/lint_project_panel.dart';
import 'package:la_toolkit/models/app_state.dart';
import 'package:la_toolkit/redux/app_actions.dart';
import 'package:la_toolkit_core/models/deployment_type.dart';
import 'package:la_toolkit_core/models/la_cluster.dart';
import 'package:la_toolkit_core/models/la_project.dart';
import 'package:la_toolkit_core/models/la_project_status.dart';
import 'package:la_toolkit_core/models/la_server.dart';
import 'package:objectid/objectid.dart';
import 'package:redux/redux.dart';

import 'pump_app.dart';

/// The docker-compose lints of the project panel. The old "include at least
/// one VM with docker-compose" rule read the docker_compose service's deploy
/// rows, which a data hub never has, so it fired on every compose hub right
/// next to the compose cluster card.
void main() {
  setUp(setUpDemoEnv);

  const String carrierMsg = 'no VM carries the compose stack';

  LAProject composePortal({bool carrier = true}) {
    final LAProject portal = LAProject(
      longName: 'Portal',
      shortName: 'portal',
      domain: 'l-a.site',
      alaInstallRelease: '1.0.0',
      generatorRelease: '1.0.0',
    );
    portal.serviceInUse('docker_compose', true);
    portal.serviceInUse('ala_hub', true);
    portal.serviceInUse('ala_bie', true);
    portal.serviceInUse('branding', true);
    if (carrier) {
      final LAServer server = LAServer(
        id: ObjectId().toString(),
        name: 'la-mh-1',
        ip: '10.0.0.1',
        projectId: portal.id,
      );
      portal.upsertServer(server);
      portal.assign(server, const <String>['docker_compose']);
      portal.assignByType(
        server.id,
        DeploymentType.dockerCompose,
        const <String>['ala_hub', 'ala_bie', 'branding'],
      );
    }
    portal.status = LAProjectStatus.basicDefined;
    return portal;
  }

  LAProject hubOf(LAProject portal) {
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
    hub.serviceInUse('ala_bie', true);
    hub.serviceInUse('branding', true);
    hub.serviceInUse('regions', false);
    portal.hubs.add(hub);
    final LACluster? cluster = portal.clusters.firstWhereOrNull(
      (LACluster c) => c.type == DeploymentType.dockerCompose,
    );
    if (cluster != null) {
      hub.assignByType(
        cluster.id,
        DeploymentType.dockerCompose,
        const <String>['ala_hub', 'ala_bie', 'branding'],
      );
    }
    hub.status = LAProjectStatus.basicDefined;
    return hub;
  }

  Future<void> pumpPanel(WidgetTester tester, LAProject project) async {
    final Store<AppState> store = demoStore();
    store.dispatch(OpenProjectTools(project));
    await tester.pumpWidget(wrapWithApp(store, const LintProjectPanel()));
    await tester.pump();
  }

  testWidgets('a hub placed on the portal cluster gets no compose warning',
      (WidgetTester tester) async {
    final LAProject hub = hubOf(composePortal());
    await pumpPanel(tester, hub);
    expect(find.textContaining(carrierMsg), findsNothing);
    expect(find.textContaining('la-docker-compose'), findsNothing);
  });

  testWidgets('a compose portal with a carrier VM gets no warning',
      (WidgetTester tester) async {
    await pumpPanel(tester, composePortal());
    expect(find.textContaining(carrierMsg), findsNothing);
  });

  testWidgets('a compose portal without a carrier is told what to do',
      (WidgetTester tester) async {
    await pumpPanel(tester, composePortal(carrier: false));
    expect(find.textContaining(carrierMsg), findsOneWidget);
    expect(find.textContaining('Tick "docker compose"'), findsOneWidget);
  });

  testWidgets(
      "a hub spread over two of the portal's compose clusters is fine "
      '(living-atlases/la-docker-compose#14)', (WidgetTester tester) async {
    final LAProject portal = composePortal();
    final LAServer second = LAServer(
      id: ObjectId().toString(),
      name: 'la-mh-2',
      ip: '10.0.0.2',
      projectId: portal.id,
    );
    portal.upsertServer(second);
    portal.assign(second, const <String>['docker_compose']);
    portal.assignByType(
      second.id,
      DeploymentType.dockerCompose,
      const <String>['ala_bie'],
    );
    final LAProject hub = hubOf(portal);
    final LACluster first = portal.clusters.firstWhere(
      (LACluster c) => c.serverId != second.id,
    );
    final LACluster secondCluster = portal.clusters.firstWhere(
      (LACluster c) => c.serverId == second.id,
    );
    hub.unAssignByType(first.id, DeploymentType.dockerCompose, 'ala_bie');
    hub.assignByType(
      secondCluster.id,
      DeploymentType.dockerCompose,
      <String>['ala_bie'],
    );

    await pumpPanel(tester, hub);
    expect(find.textContaining('single host'), findsNothing);
    expect(find.textContaining(carrierMsg), findsNothing);
  });

  testWidgets(
      'a hub with no server of its own is told to deploy the portal instead',
      (WidgetTester tester) async {
    final LAProject portal = composePortal();
    final LAProject hub = hubOf(portal);
    final Store<AppState> store = demoStore();
    store.dispatch(OpenProjectTools(hub));
    await tester.pumpWidget(wrapWithApp(store, const LintProjectPanel()));
    await tester.pump();

    expect(find.textContaining('deploys as part of'), findsOneWidget);
    expect(find.text('GO TO PORTAL'), findsOneWidget);

    await tester.tap(find.text('GO TO PORTAL'));
    await tester.pump();
    expect(store.state.currentProject.id, portal.id);
  });

  testWidgets(
      'a hub with its own server is not told to deploy the portal instead',
      (WidgetTester tester) async {
    final LAProject portal = composePortal();
    final LAProject hub = hubOf(portal);
    final LAServer ownVm = LAServer(
      id: ObjectId().toString(),
      name: 'hub-gateway',
      ip: '10.0.0.50',
      projectId: hub.id,
    );
    hub.upsertServer(ownVm);

    await pumpPanel(tester, hub);
    expect(find.textContaining('deploys as part of'), findsNothing);
  });

  testWidgets('a non-hub compose portal is never told to deploy itself',
      (WidgetTester tester) async {
    await pumpPanel(tester, composePortal());
    expect(find.textContaining('deploys as part of'), findsNothing);
  });
}
