import 'dart:convert';

import 'package:la_toolkit_core/models/deployment_type.dart';
import 'package:la_toolkit_core/models/la_cluster.dart';
import 'package:la_toolkit_core/models/la_project.dart';
import 'package:la_toolkit_core/models/la_server.dart';
import 'package:la_toolkit_core/models/la_service.dart';
import 'package:la_toolkit_core/models/la_service_constants.dart';
import 'package:la_toolkit_core/models/la_service_deploy.dart';
import 'package:la_toolkit_core/placement/placement_changes.dart';
import 'package:test/test.dart';

/// A hybrid portal as it is stored: collectory and dashboard on the VM
/// `vm1`; compose clusters on `dc1` (ala_hub, cas, spatial pinned to 1.0.0)
/// and `dc2` (ala_hub); `new1` a server with nothing yet. Built, then read
/// back from JSON, so nothing survives that the backend would not keep.
LAProject portal() {
  final LAProject p = LAProject(
    longName: 'Hybrid portal',
    shortName: 'Hybrid',
    domain: 'example.org',
    alaInstallRelease: 'v2.4.2',
    dockerComposeRelease: 'v1.5.1',
    generatorRelease: '1.8.32',
  );
  for (final String n in <String>['vm1', 'dc1', 'dc2', 'new1']) {
    p.upsertServer(
      LAServer(name: n, ip: '10.0.0.${n.length}', projectId: p.id),
    );
  }
  String id(String n) => p.servers.firstWhere((LAServer s) => s.name == n).id;
  for (final String s in <String>[
    collectory,
    'dashboard',
    alaHub,
    cas,
    spatial,
    dockerCompose,
  ]) {
    p.serviceInUse(s, true);
  }
  p.assignByType(id('vm1'), DeploymentType.vm, <String>[
    collectory,
    'dashboard',
  ]);
  p.assignByType(id('dc1'), DeploymentType.vm, <String>[dockerCompose]);
  p.assignByType(id('dc2'), DeploymentType.vm, <String>[dockerCompose]);
  p.assignByType(id('dc1'), DeploymentType.dockerCompose, <String>[
    alaHub,
    cas,
    spatial,
  ]);
  p.assignByType(id('dc2'), DeploymentType.dockerCompose, <String>[alaHub]);
  for (final LAServiceDeploy sd in p.serviceDeploys) {
    for (final String k in sd.softwareVersions.keys.toList()) {
      sd.softwareVersions[k] = '1.0.0';
    }
  }
  return LAProject.fromJson(
    json.decode(json.encode(p.toApiJson())) as Map<String, dynamic>,
  );
}

LACluster clusterOn(LAProject p, String server) => p.clusters.firstWhere(
  (LACluster c) =>
      c.type == DeploymentType.dockerCompose &&
      c.serverId == p.getServerByName(server)!.id,
);

Matcher refusal(String text) => throwsA(
  isA<PlacementException>().having(
    (PlacementException e) => e.message,
    'message',
    contains(text),
  ),
);

void main() {
  test('moves spatial with its sub-services, keeping versions', () {
    final LAProject p = portal();
    final PlacementChange c = changePlacement(p, const <ServiceMove>[
      ServiceMove(service: 'spatial', to: 'dc2'),
    ]);
    expect(
      p.getClusterServices(clusterId: clusterOn(p, 'dc1').id),
      unorderedEquals(<String>[
        alaHub,
        cas,
        userdetails,
        apikey,
        casManagement,
      ]),
    );
    expect(
      p.getClusterServices(clusterId: clusterOn(p, 'dc2').id),
      containsAll(<String>[spatial, spatialService, geoserver]),
    );
    final MovedService m = c.moves.single;
    expect(m.from.toString(), 'dc1 (docker-compose)');
    expect(m.to.toString(), 'dc2 (docker-compose)');
    expect(m.carried, <String>[geoserver, spatialService]);
    expect(m.versions[spatial], '1.0.0');
    expect(c.clustersCreated, isEmpty);
    // Nothing left behind on dc1, nothing duplicated.
    expect(
      p.serviceDeploys.where(
        (LAServiceDeploy sd) =>
            sd.clusterId == clusterOn(p, 'dc1').id &&
            p.services.any(
              (LAService s) =>
                  s.id == sd.serviceId && s.nameInt.startsWith('spatial'),
            ),
      ),
      isEmpty,
    );
    expect(p.validateDataIntegrity(), isEmpty);
    expect(servicesByServer(p)['dc2']!['docker'], contains(spatial));
  });

  test('accepts the artifact or group name of a service', () {
    expect(resolveServiceName('spatial-hub'), spatial);
    expect(resolveServiceName(spatial), spatial);
    expect(() => resolveServiceName('nope'), refusal('No service'));
  });

  test('a compose cluster comes with docker_compose, as in the UI', () {
    final LAProject p = portal();
    expect(
      () => changePlacement(p, const <ServiceMove>[
        ServiceMove(service: 'spatial', to: 'new1'),
      ]),
      refusal('assign docker_compose'),
    );

    final LAProject q = portal();
    final PlacementChange c = changePlacement(q, const <ServiceMove>[
      ServiceMove(
        service: 'docker_compose',
        op: PlacementOp.assign,
        to: 'new1',
      ),
      ServiceMove(service: 'spatial', to: 'new1'),
    ]);
    expect(c.clustersCreated, <String>['new1']);
    final String new1 = q.getServerByName('new1')!.id;
    expect(q.getServerServices(serverId: new1), <String>[dockerCompose]);
    expect(q.dockerServers(), contains('new1'));
    expect(
      q.getClusterServices(clusterId: clusterOn(q, 'new1').id),
      containsAll(<String>[spatial, spatialService, geoserver]),
    );
    expect(c.moves.last.versions[spatial], '1.0.0');
    expect(q.validateDataIntegrity(), isEmpty);
  });

  test('unassigning docker_compose deletes its cluster, only when empty', () {
    final LAProject p = portal();
    expect(
      () => changePlacement(p, const <ServiceMove>[
        ServiceMove(
          service: 'docker_compose',
          op: PlacementOp.unassign,
          from: 'dc2',
        ),
      ]),
      refusal('still runs ala_hub'),
    );
    final PlacementChange c = changePlacement(p, const <ServiceMove>[
      ServiceMove(service: alaHubName, op: PlacementOp.unassign, from: 'dc2'),
      ServiceMove(
        service: 'docker_compose',
        op: PlacementOp.unassign,
        from: 'dc2',
      ),
    ]);
    expect(c.clustersDeleted, <String>['dc2']);
    final String dc2 = p.getServerByName('dc2')!.id;
    expect(p.clusters.where((LACluster c) => c.serverId == dc2), isEmpty);
    expect(p.getServerServices(serverId: dc2), isEmpty);
    expect(serviceLocations(p, alaHub).map((PlacementSlot s) => '$s'), <String>[
      'dc1 (docker-compose)',
    ]);
    expect(p.validateDataIntegrity(), isEmpty);
  });

  test('assign adds a place without taking the service off another', () {
    final LAProject p = portal();
    final PlacementChange c = changePlacement(p, const <ServiceMove>[
      ServiceMove(
        service: alaHubName,
        op: PlacementOp.assign,
        to: 'vm1',
        toLeg: PlacementLeg.vm,
      ),
    ]);
    expect(c.moves.single.from, isNull);
    expect(serviceLocations(p, alaHub), hasLength(3));
    // A single-deploy service is only offered where it does not run yet.
    expect(
      () => changePlacement(p, const <ServiceMove>[
        ServiceMove(
          service: 'spatial',
          op: PlacementOp.assign,
          to: 'dc2',
          toLeg: PlacementLeg.docker,
        ),
      ]),
      refusal('allows one deploy only'),
    );
    expect(
      () => changePlacement(p, const <ServiceMove>[
        ServiceMove(service: 'spatial', op: PlacementOp.unassign, to: 'dc2'),
      ]),
      refusal('unassign takes `from`'),
    );
    expect(p.validateDataIntegrity(), isEmpty);
  });

  test('a service on several places needs from', () {
    final LAProject p = portal();
    expect(
      () => changePlacement(p, const <ServiceMove>[
        ServiceMove(service: alaHubName, to: 'vm1', toLeg: PlacementLeg.vm),
      ]),
      refusal('say which one with `from`'),
    );
    final PlacementChange c = changePlacement(p, const <ServiceMove>[
      ServiceMove(
        service: alaHubName,
        from: 'dc2',
        to: 'vm1',
        toLeg: PlacementLeg.vm,
      ),
    ]);
    expect(c.moves.single.to.toString(), 'vm1');
    expect(
      p.getServerServices(serverId: p.getServerByName('vm1')!.id),
      contains(alaHub),
    );
    expect(p.getClusterServices(clusterId: clusterOn(p, 'dc2').id), isEmpty);
    expect(p.validateDataIntegrity(), isEmpty);
  });

  test('refuses what the UI does not offer', () {
    for (final (ServiceMove m, String why) in <(ServiceMove, String)>[
      (
        const ServiceMove(service: 'geoserver', to: 'dc2'),
        'moves with spatial',
      ),
      (
        const ServiceMove(service: 'spatial-service', to: 'dc2'),
        'moves with spatial',
      ),
      (
        const ServiceMove(service: 'docker_compose', to: 'dc2'),
        'not a workload',
      ),
      (
        const ServiceMove(
          service: 'docker_swarm',
          op: PlacementOp.assign,
          to: 'dc2',
        ),
        'not a workload',
      ),
      (
        const ServiceMove(
          service: 'docker_compose',
          op: PlacementOp.assign,
          to: 'dc1',
        ),
        'already a docker-compose host',
      ),
      (const ServiceMove(service: 'spatial', to: 'dc3'), 'No server "dc3"'),
      (const ServiceMove(service: 'spatial', to: 'dc1'), 'already on'),
      (
        const ServiceMove(service: 'spatial', from: 'vm1', to: 'dc2'),
        'is not on vm1',
      ),
      (
        const ServiceMove(
          service: 'dashboard',
          to: 'dc2',
          toLeg: PlacementLeg.docker,
        ),
        'no docker-compose support',
      ),
      (const ServiceMove(service: 'biocollect', to: 'dc2'), 'not in use'),
      (
        const ServiceMove(service: alaHubName, from: 'dc2', to: 'dc1'),
        'already runs on dc1 (docker-compose)',
      ),
    ]) {
      final LAProject p = portal();
      expect(
        () => changePlacement(p, <ServiceMove>[m]),
        refusal(why),
        reason: why,
      );
    }
  });

  test('a compose host needs toLeg when there is no source leg', () {
    final LAProject p = portal();
    p.serviceInUse('images', true);
    expect(
      () => changePlacement(p, const <ServiceMove>[
        ServiceMove(service: 'images', to: 'dc1'),
      ]),
      refusal('pass toLeg'),
    );
    changePlacement(p, const <ServiceMove>[
      ServiceMove(service: 'images', to: 'dc1', toLeg: PlacementLeg.docker),
    ]);
    expect(
      p.getClusterServices(clusterId: clusterOn(p, 'dc1').id),
      contains('images'),
    );
  });

  test('a hub moves between the portal clusters and never creates one', () {
    final LAProject p = portal();
    final LAProject hub = LAProject(
      longName: 'Hub',
      shortName: 'hub',
      domain: 'hub.example.org',
      alaInstallRelease: 'v2.4.2',
      generatorRelease: '1.8.32',
      isHub: true,
      parent: p,
    );
    hub.serviceInUse(alaHub, true);
    p.hubs.add(hub);
    hub.assignByType(
      clusterOn(p, 'dc1').id,
      DeploymentType.dockerCompose,
      <String>[alaHub],
    );

    expect(
      () => changePlacement(hub, const <ServiceMove>[
        ServiceMove(service: alaHubName, to: 'new1'),
      ]),
      refusal('a hub never creates'),
    );
    expect(
      () => changePlacement(hub, const <ServiceMove>[
        ServiceMove(
          service: 'docker_compose',
          op: PlacementOp.assign,
          to: 'new1',
        ),
      ]),
      refusal('A hub never creates'),
    );
    expect(
      () => changePlacement(hub, const <ServiceMove>[
        ServiceMove(service: alaHubName, to: 'vm1', toLeg: PlacementLeg.vm),
      ]),
      refusal('server of the portal'),
    );
    final PlacementChange c = changePlacement(hub, const <ServiceMove>[
      ServiceMove(service: alaHubName, to: 'dc2'),
    ]);
    expect(c.moves.single.to.toString(), 'dc2 (docker-compose)');
    expect(hub.clusters, isEmpty);
    expect(hub.getClusterServices(clusterId: clusterOn(p, 'dc2').id), <String>[
      alaHub,
    ]);
    expect(hub.validateDataIntegrity(), isEmpty);
  });
}

const String alaHubName = 'ala_hub';
