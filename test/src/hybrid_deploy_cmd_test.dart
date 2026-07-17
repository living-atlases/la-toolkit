import 'package:flutter_test/flutter_test.dart';
import 'package:la_toolkit/models/deploy_cmd.dart';
import 'package:la_toolkit/models/deployment_type.dart';
import 'package:la_toolkit/models/la_project.dart';
import 'package:la_toolkit/models/la_server.dart';
import 'package:la_toolkit/models/la_service_constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  LAProject hybridProject({
    List<String> vmServicesOnComposeHost = const <String>[],
  }) {
    final LAProject p = LAProject(
      longName: 'Living Atlas of Wakanda',
      shortName: 'LAW',
      domain: 'l-a.site',
      alaInstallRelease: '2.2.5',
      dockerComposeRelease: 'v1.0.0',
      generatorRelease: '1.8.33',
    );
    p.upsertServer(LAServer(name: 'vm1', ip: '10.0.0.1', projectId: p.id));
    p.upsertServer(LAServer(name: 'vm2', ip: '10.0.0.2', projectId: p.id));
    final LAServer vm1 = p.servers.firstWhere((LAServer s) => s.name == 'vm1');
    final LAServer vm2 = p.servers.firstWhere((LAServer s) => s.name == 'vm2');
    // VM leg on vm1
    p.assignByType(vm1.id, DeploymentType.vm, <String>[collectory, branding]);
    // Docker-compose cluster hosted on vm2 (plus optionally some VM services
    // co-located on the same physical server)
    p.assignByType(vm2.id, DeploymentType.vm, <String>[
      dockerCompose,
      ...vmServicesOnComposeHost,
    ]);
    p.assignByType(vm2.id, DeploymentType.dockerCompose, <String>[
      alaHub,
      biocacheService,
      cas,
    ]);
    for (final String s in <String>[
      collectory,
      branding,
      alaHub,
      biocacheService,
      cas,
      dockerCompose,
      ...vmServicesOnComposeHost,
    ]) {
      p.getService(s).use = true;
    }
    return p;
  }

  test('Hybrid detection of the fixture', () {
    final LAProject p = hybridProject();
    expect(p.hasVmServices, equals(true));
    expect(p.hasDockerComposeServices, equals(true));
    expect(p.isHybrid, equals(true));
    expect(p.isPureDockerCompose, equals(false));
    expect(
      p.dockerComposeAssignedServices,
      containsAll(<String>[alaHub, biocacheService, cas]),
    );
    expect(p.vmAssignedServices, containsAll(<String>[collectory, branding]));
  });

  // --- VM leg (ala-install) -------------------------------------------------

  test('VM leg: keeps the selected VM services, no --ladocker', () {
    final LAProject p = hybridProject();
    final DeployCmd wire = p.buildVmLegDeployCmd(
      DeployCmd(deployServices: <String>[branding]),
    );
    expect(wire.dockerCompose, equals(false));
    expect(wire.deployServices, equals(<String>[branding]));
  });

  test('VM leg: empty or "all" selection expands to every VM service', () {
    final LAProject p = hybridProject();
    for (final DeployCmd cmd in <DeployCmd>[
      DeployCmd(),
      DeployCmd(deployServices: <String>['all']),
    ]) {
      final DeployCmd wire = p.buildVmLegDeployCmd(cmd);
      expect(wire.dockerCompose, equals(false));
      expect(wire.deployServices, unorderedEquals(<String>[collectory, branding]));
      // Never 'all' nor docker services, so ala-install can't look for the
      // missing docker-compose.yml playbook.
      expect(wire.deployServices, isNot(contains('all')));
      expect(wire.deployServices, isNot(contains(alaHub)));
    }
  });

  test('VM leg: docker services in the selection are dropped', () {
    final LAProject p = hybridProject();
    final DeployCmd wire = p.buildVmLegDeployCmd(
      DeployCmd(deployServices: <String>[collectory, alaHub, cas]),
    );
    expect(wire.deployServices, equals(<String>[collectory]));
  });

  // --- Docker leg (la-docker-compose) ---------------------------------------

  test('Docker leg: full compose stack with no skips', () {
    final LAProject p = hybridProject();
    final DeployCmd wire = p.buildDockerLegDeployCmd(DeployCmd());
    expect(wire.dockerCompose, equals(true));
    expect(wire.deployServices, equals(<String>['all']));
    expect(wire.skipServices, isEmpty);
  });

  test('Docker leg: user skips are expanded to sub-services', () {
    final LAProject p = hybridProject();
    final DeployCmd wire = p.buildDockerLegDeployCmd(
      DeployCmd(skipServices: <String>[cas]),
    );
    expect(wire.dockerCompose, equals(true));
    expect(wire.deployServices, equals(<String>['all']));
    expect(wire.skipServices, contains(cas));
    // Skipping a parent skips its sub-services (skip_services matches
    // individual service keys).
    expect(wire.skipServices, contains(userdetails));
    expect(wire.skipServices, contains(apikey));
    expect(wire.skipServices, contains(casManagement));
  });

  test('Docker leg: VM services co-located on the compose host are skipped', () {
    final LAProject p = hybridProject(
      vmServicesOnComposeHost: <String>[speciesLists],
    );
    final DeployCmd wire = p.buildDockerLegDeployCmd(DeployCmd());
    // species_lists is a VM service on the compose physical server, so it must
    // be skipped or la-docker-compose would enable it in docker too.
    expect(wire.skipServices, contains(speciesLists));
  });

  // --- desc -----------------------------------------------------------------

  test('Deploy cmd desc for the docker leg', () {
    final DeployCmd cmd = DeployCmd();
    cmd.dockerCompose = true;
    expect(cmd.desc, equals('Deploy of the docker stack'));
    cmd.deployServices = <String>[collectory];
    expect(
      cmd.desc,
      equals('Deploy of collections service and the docker stack'),
    );
    cmd.deployServices = <String>['all'];
    expect(cmd.desc, equals('Full deploy'));
  });
}
