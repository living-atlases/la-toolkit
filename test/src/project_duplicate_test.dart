import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:la_toolkit/models/deployment_type.dart';
import 'package:la_toolkit/models/la_cluster.dart';
import 'package:la_toolkit/models/la_project.dart';
import 'package:la_toolkit/models/la_server.dart';
import 'package:la_toolkit/models/la_service.dart';
import 'package:la_toolkit/models/la_service_constants.dart';
import 'package:la_toolkit/models/la_service_deploy.dart';
import 'package:la_toolkit/models/la_variable.dart';
import 'package:la_toolkit/models/la_variable_desc.dart';
import 'package:la_toolkit/models/ssh_key.dart';
import 'package:la_toolkit/utils/regexp.dart';

LAProject buildSourceProject() {
  final LAProject p = LAProject(
    longName: 'Living Atlas of Wakanda',
    shortName: 'LAW',
    domain: 'l-a.wakanda.site',
  );
  final LAServer vm1 = LAServer(
    name: 'vm1',
    ip: '10.0.0.1',
    projectId: p.id,
    sshKey: SshKey(name: 'mykey', desc: '', encrypted: false),
  );
  final LAServer vm2 = LAServer(name: 'vm2', ip: '10.0.0.2', projectId: p.id);
  p.upsertServer(vm1);
  p.upsertServer(vm2);
  // vm2 is reached through vm1 as ssh gateway
  vm2.gateways = <String>[vm1.id];
  vm2.aliases = <String>['collections'];
  p.assign(vm1, <String>[collectory, alaHub]);
  p.assign(vm2, <String>[speciesLists]);
  // A docker-compose cluster in vm2
  p.assignByType(vm2.id, DeploymentType.dockerCompose, <String>[gatus]);
  p.setVariable(LAVariableDesc.get('support_email'), 'soporte@example.org');
  return p;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('duplicate regenerates all ids and remaps references', () {
    final LAProject p = buildSourceProject();
    final String sourceJsonBefore = json.encode(p.toJson());

    final LAProject clone = LAProject.duplicate(
      p,
      newShortName: 'LAW2',
      newLongName: 'Living Atlas of Wakanda 2',
      newDomain: 'l-a2.wakanda.site',
      newDirName: 'law2',
    );

    // The source project is untouched
    expect(json.encode(p.toJson()), equals(sourceJsonBefore));

    // Project basics
    expect(clone.id, isNot(equals(p.id)));
    expect(clone.shortName, equals('LAW2'));
    expect(clone.longName, equals('Living Atlas of Wakanda 2'));
    expect(clone.domain, equals('l-a2.wakanda.site'));
    expect(clone.dirName, isNot(equals(p.dirName)));
    expect(clone.fstDeployed, equals(false));
    expect(clone.cmdHistoryEntries, isEmpty);
    expect(clone.lastCmdEntry, isNull);

    // No id of any entity is shared between source and clone
    Set<String> ids(LAProject pr) => <String>{
      pr.id,
      ...pr.servers.map((LAServer s) => s.id),
      ...pr.clusters.map((LACluster c) => c.id),
      ...pr.services.map((LAService s) => s.id),
      ...pr.serviceDeploys.map((LAServiceDeploy sd) => sd.id),
      ...pr.variables.map((LAVariable v) => v.id),
    };
    expect(ids(p).intersection(ids(clone)), isEmpty);

    // Servers: renamed with suffix, ips/sshKey kept, statuses reset
    expect(clone.servers.length, equals(2));
    final LAServer cVm1 = clone.servers.firstWhere(
      (LAServer s) => s.name == 'vm1-law2',
    );
    final LAServer cVm2 = clone.servers.firstWhere(
      (LAServer s) => s.name == 'vm2-law2',
    );
    for (final LAServer s in clone.servers) {
      expect(LARegExp.hostnameRegexp.hasMatch(s.name), equals(true));
      expect(s.projectId, equals(clone.id));
      expect(s.reachable, equals(ServiceStatus.unknown));
      expect(s.sshReachable, equals(ServiceStatus.unknown));
      expect(s.sudoEnabled, equals(ServiceStatus.unknown));
    }
    expect(cVm1.ip, equals('10.0.0.1'));
    expect(cVm2.ip, equals('10.0.0.2'));
    expect(cVm1.sshKey!.name, equals('mykey'));
    // Gateways remapped to the new server ids
    expect(cVm2.gateways, equals(<String>[cVm1.id]));
    // Aliases also suffixed (they are ssh aliases too)
    expect(cVm2.aliases, equals(<String>['collections-law2']));

    // Clusters remapped
    expect(clone.clusters.length, equals(p.clusters.length));
    for (final LACluster c in clone.clusters) {
      expect(c.projectId, equals(clone.id));
      expect(c.serverId, equals(cVm2.id));
    }

    // Services and variables remapped
    for (final LAService s in clone.services) {
      expect(s.projectId, equals(clone.id));
    }
    expect(clone.variables.length, equals(1));
    expect(clone.variables.first.projectId, equals(clone.id));
    expect(clone.variables.first.value, equals('soporte@example.org'));

    // ServiceDeploys remapped and reset
    final Set<String> cloneServiceIds = clone.services
        .map((LAService s) => s.id)
        .toSet();
    final Set<String> cloneServerIds = clone.servers
        .map((LAServer s) => s.id)
        .toSet();
    final Set<String> cloneClusterIds = clone.clusters
        .map((LACluster c) => c.id)
        .toSet();
    expect(clone.serviceDeploys.length, equals(p.serviceDeploys.length));
    for (final LAServiceDeploy sd in clone.serviceDeploys) {
      expect(sd.projectId, equals(clone.id));
      expect(cloneServiceIds.contains(sd.serviceId), equals(true));
      if (sd.serverId != null) {
        expect(cloneServerIds.contains(sd.serverId), equals(true));
      }
      if (sd.clusterId != null) {
        expect(cloneClusterIds.contains(sd.clusterId), equals(true));
      }
      expect(sd.status, equals(ServiceStatus.unknown));
      expect(sd.checkedAt, isNull);
      expect(sd.softwareVersions, isEmpty);
    }

    // Assignment maps rekeyed with the new ids and same service names
    expect(clone.serverServices.keys.toSet(), equals(cloneServerIds));
    expect(clone.clusterServices.keys.toSet(), equals(cloneClusterIds));
    expect(
      clone.serverServices[cVm1.id],
      equals(p.getServerServicesForTest()[p.servers
          .firstWhere((LAServer s) => s.name == 'vm1')
          .id]),
    );
    expect(clone.clusterServices.values.first, equals(<String>[gatus]));

    // Data integrity
    expect(clone.validateDataIntegrity(), isEmpty);
  });

  test('duplicate clones hubs and re-parents them', () {
    final LAProject p = buildSourceProject();
    final LAProject hub = LAProject(
      isHub: true,
      parent: p,
      shortName: 'hubby',
      longName: 'Wakanda Hub',
      domain: 'hub.l-a.wakanda.site',
    );
    final LAServer hubVm = LAServer(name: 'hubvm', projectId: hub.id);
    hub.upsertServer(hubVm);
    p.hubs = <LAProject>[hub];

    final LAProject clone = LAProject.duplicate(
      p,
      newShortName: 'LAW2',
      newLongName: 'Living Atlas of Wakanda 2',
      newDomain: 'l-a2.wakanda.site',
      newDirName: 'law2',
    );

    expect(clone.hubs.length, equals(1));
    final LAProject cloneHub = clone.hubs.first;
    expect(cloneHub.id, isNot(equals(hub.id)));
    expect(cloneHub.parent, same(clone));
    expect(cloneHub.isHub, equals(true));
    expect(cloneHub.shortName, isNot(equals(hub.shortName)));
    expect(cloneHub.domain, equals('hub.l-a2.wakanda.site'));
    expect(cloneHub.servers.length, equals(1));
    expect(cloneHub.servers.first.id, isNot(equals(hubVm.id)));
    expect(cloneHub.servers.first.name, equals('hubvm-law2'));
    expect(cloneHub.servers.first.projectId, equals(cloneHub.id));
    // Source hub untouched
    expect(hub.servers.first.name, equals('hubvm'));
  });

  test('duplicate sanitizes the server name suffix from the dirName', () {
    final LAProject p = buildSourceProject();
    final LAProject clone = LAProject.duplicate(
      p,
      newShortName: 'LAW',
      newLongName: 'My Portal',
      newDomain: 'my-portal.example.org',
      newDirName: 'My Pórtal  2026',
    );
    for (final LAServer s in clone.servers) {
      expect(LARegExp.hostnameRegexp.hasMatch(s.name), equals(true));
    }
    expect(
      clone.servers.map((LAServer s) => s.name).toSet(),
      equals(<String>{'vm1-my-prtal-2026', 'vm2-my-prtal-2026'}),
    );
  });

  test(
    'duplicate keeps portal identity, differing only by dirName, and '
    'preserves passwords and local extras',
    () {
      final LAProject p = buildSourceProject();
      // A secret-like variable and project-level local extras.
      p.setVariable(
        LAVariableDesc.get('email_sender_password'),
        's3cr3t-pass',
      );
      p.additionalVariables = base64.encode(
        utf8.encode('my_custom_var: 42\n'),
      );

      // Same shortName, longName and domain: only the dirName differs.
      final LAProject clone = LAProject.duplicate(
        p,
        newShortName: p.shortName,
        newLongName: p.longName,
        newDomain: p.domain,
        newDirName: 'law_copy',
      );

      expect(clone.shortName, equals(p.shortName));
      expect(clone.longName, equals(p.longName));
      expect(clone.domain, equals(p.domain));
      expect(clone.dirName, equals('law_copy'));
      expect(clone.dirName, isNot(equals(p.dirName)));

      // Server names are suffixed by the dirName (unique differentiator) and do
      // not collide with the original's.
      final Set<String> cloneNames = clone.servers
          .map((LAServer s) => s.name)
          .toSet();
      final Set<String> sourceNames = p.servers
          .map((LAServer s) => s.name)
          .toSet();
      expect(cloneNames.intersection(sourceNames), isEmpty);
      for (final LAServer s in clone.servers) {
        expect(s.name.endsWith('-law_copy'), equals(true));
      }

      // Passwords and local extras are preserved verbatim in the clone.
      final LAVariable clonePass = clone.variables.firstWhere(
        (LAVariable v) => v.nameInt == 'email_sender_password',
      );
      expect(clonePass.value, equals('s3cr3t-pass'));
      expect(clone.additionalVariables, equals(p.additionalVariables));

      expect(clone.validateDataIntegrity(), isEmpty);
    },
  );
}
