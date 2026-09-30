import 'package:la_toolkit_core/models/deployment_type.dart';
import 'package:la_toolkit_core/models/la_cluster.dart';
import 'package:la_toolkit_core/models/la_project.dart';
import 'package:la_toolkit_core/models/la_server.dart';
import 'package:la_toolkit_core/models/la_service_constants.dart';
import 'package:la_toolkit_core/models/la_service_deploy.dart';
import 'package:la_toolkit_core/models/ssh_key.dart';
import 'package:la_toolkit_core/placement/placement_changes.dart';
import 'package:la_toolkit_core/placement/server_changes.dart';
import 'package:test/test.dart';

import 'placement_changes_test.dart' show portal;

Matcher refusal(String text) => throwsA(
  isA<ServerChangeException>().having(
    (ServerChangeException e) => e.message,
    'message',
    contains(text),
  ),
);

void main() {
  test('adds a server as the servers page does', () {
    final LAProject p = portal();
    final ServerChange c = changeServers(
      p,
      add: <ServerSpec>[
        ServerSpec(
          name: 'spatial-2026',
          ip: '172.16.16.135',
          sshUser: 'ubuntu',
          sshPort: 2222,
          sshKey: SshKey(name: 'k1', desc: 'k1', encrypted: false),
          aliases: const <String>['espacial.example.org'],
          gateways: const <String>['vm1'],
        ),
      ],
    );
    expect(c.added, <String>['spatial-2026']);
    final LAServer s = p.getServerByName('spatial-2026')!;
    expect(s.ip, '172.16.16.135');
    expect(s.sshPort, 2222);
    expect(s.sshKey!.name, 'k1');
    expect(s.aliases, <String>['espacial.example.org']);
    expect(s.gateways, <String>[p.getServerByName('vm1')!.id]);
    expect(p.getServerServices(serverId: s.id), isEmpty);
    // A new server is then a place like any other.
    changePlacement(p, const <ServiceMove>[
      ServiceMove(
        service: 'docker_compose',
        op: PlacementOp.assign,
        to: 'spatial-2026',
      ),
      ServiceMove(service: 'spatial', to: 'spatial-2026'),
    ]);
    expect(p.validateDataIntegrity(), isEmpty);
  });

  test('updates only the fields given, and says which changed', () {
    final LAProject p = portal();
    final ServerChange c = changeServers(
      p,
      update: <ServerSpec>[
        const ServerSpec(name: 'dc1', ip: '10.9.9.9', sshPort: 22),
      ],
    );
    expect(c.updated, <String, List<String>>{
      'dc1': <String>['ip'],
    });
    expect(p.getServerByName('dc1')!.ip, '10.9.9.9');
    expect(
      () => changeServers(
        p,
        update: <ServerSpec>[const ServerSpec(name: 'dc1', ip: '10.9.9.9')],
      ),
      refusal('Nothing to change'),
    );
  });

  test('refuses invalid values explicitly (asserts are off in the binary)', () {
    for (final (ServerSpec s, String why) in <(ServerSpec, String)>[
      (
        const ServerSpec(name: 'bad name', ip: '10.0.0.1'),
        'not a valid server',
      ),
      (const ServerSpec(name: '-x', ip: '10.0.0.1'), 'not a valid server'),
      (const ServerSpec(name: 'x'), 'needs an ip'),
      (const ServerSpec(name: 'x', ip: '10.0.0.256'), 'not an IP'),
      (const ServerSpec(name: 'x', ip: '10.0.0.1; id'), 'not an IP'),
      (const ServerSpec(name: 'vm1', ip: '10.0.0.1'), 'already has'),
      (
        const ServerSpec(name: 'x', ip: '10.0.0.1', sshPort: 70000),
        'not a port',
      ),
      (
        const ServerSpec(name: 'x', ip: '10.0.0.1', sshUser: 'Root User'),
        'not an ssh user',
      ),
      (
        const ServerSpec(name: 'x', ip: '10.0.0.1', aliases: <String>['a b']),
        'not a host name',
      ),
      (
        const ServerSpec(name: 'x', ip: '10.0.0.1', gateways: <String>['nope']),
        'not a server of',
      ),
    ]) {
      expect(
        () => changeServers(portal(), add: <ServerSpec>[s]),
        refusal(why),
        reason: why,
      );
    }
    expect(
      changeServers(
        portal(),
        add: <ServerSpec>[const ServerSpec(name: 'v6', ip: 'fd00::1')],
      ).added,
      <String>['v6'],
    );
  });

  test('removes only empty servers, their empty cluster first', () {
    final LAProject p = portal();
    expect(
      () => changeServers(p, remove: <String>['vm1']),
      refusal('still runs collectory, dashboard'),
    );
    expect(
      () => changeServers(p, remove: <String>['dc2']),
      refusal('still runs ala_hub'),
    );
    expect(
      () => changeServers(p, remove: <String>['nope']),
      refusal('No server "nope"'),
    );

    final ServerChange empty = changeServers(p, remove: <String>['new1']);
    expect(empty.removed, <String>['new1']);
    expect(p.getServerByName('new1'), isNull);

    changePlacement(p, const <ServiceMove>[
      ServiceMove(service: alaHubName, op: PlacementOp.unassign, from: 'dc2'),
    ]);
    final String dc2 = p.getServerByName('dc2')!.id;
    final ServerChange c = changeServers(p, remove: <String>['dc2']);
    expect(c.removed, <String>['dc2']);
    expect(c.notes.single, contains('Docker Compose on dc2'));
    expect(p.clusters.where((LACluster cl) => cl.serverId == dc2), isEmpty);
    expect(p.validateDataIntegrity(), isEmpty);
  });

  test('a server a hub places services on stays', () {
    final LAProject p = portal();
    changePlacement(p, const <ServiceMove>[
      ServiceMove(service: alaHubName, op: PlacementOp.unassign, from: 'dc2'),
    ]);
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
    final LACluster onDc2 = p.clusters.firstWhere(
      (LACluster c) => c.serverId == p.getServerByName('dc2')!.id,
    );
    hub.assignByType(onDc2.id, DeploymentType.dockerCompose, <String>[alaHub]);
    expect(
      () => changeServers(p, remove: <String>['dc2']),
      refusal('services of hub hub'),
    );
  });

  // lademo has deploy rows pointing at clusters deleted long ago, and they
  // still decide where names resolve. Removing a server or its compose host
  // role must leave them alone; deleteCluster() drops them all.
  group('orphan deploy rows survive', () {
    LAProject withOrphan() {
      final LAProject p = portal();
      p.serviceDeploys.add(
        LAServiceDeploy(
          projectId: p.id,
          serviceId: p.getService(alaHub).id,
          serverId: p.getServerByName('dc1')!.id,
          clusterId: '0123456789abcdef01234567',
          type: DeploymentType.dockerCompose,
          softwareVersions: <String, String>{alaHub: '1.0.0'},
        ),
      );
      changePlacement(p, const <ServiceMove>[
        ServiceMove(service: alaHubName, op: PlacementOp.unassign, from: 'dc2'),
      ]);
      return p;
    }

    bool hasOrphan(LAProject p) => p.serviceDeploys.any(
      (LAServiceDeploy sd) => sd.clusterId == '0123456789abcdef01234567',
    );

    test('why: the UI cluster delete drops them', () {
      final LAProject p = withOrphan();
      p.deleteCluster(
        p.clusters.firstWhere(
          (LACluster c) => c.serverId == p.getServerByName('dc2')!.id,
        ),
      );
      expect(hasOrphan(p), isFalse);
    });

    test('unassigning docker_compose', () {
      final LAProject p = withOrphan();
      final int rows = p.serviceDeploys.length;
      changePlacement(p, const <ServiceMove>[
        ServiceMove(
          service: 'docker_compose',
          op: PlacementOp.unassign,
          from: 'dc2',
        ),
      ]);
      expect(hasOrphan(p), isTrue);
      // Only dc2's docker_compose row goes.
      expect(p.serviceDeploys.length, rows - 1);
      expect(
        p.clusters.where(
          (LACluster c) => c.serverId == p.getServerByName('dc2')!.id,
        ),
        isEmpty,
      );
    });

    test('removing the server', () {
      final LAProject p = withOrphan();
      final int rows = p.serviceDeploys.length;
      changeServers(p, remove: <String>['dc2']);
      expect(hasOrphan(p), isTrue);
      expect(p.serviceDeploys.length, rows - 1);
      expect(p.getServerByName('dc2'), isNull);
    });
  });
}

const String alaHubName = 'ala_hub';
