import 'package:flutter_test/flutter_test.dart';
import 'package:la_toolkit/models/deploy_cmd.dart';
import 'package:la_toolkit/models/deployment_type.dart';
import 'package:la_toolkit/models/la_project.dart';
import 'package:la_toolkit/models/la_server.dart';
import 'package:la_toolkit/models/la_service_constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  LAProject hybridProject({List<String> vmServicesOnComposeHost = const <String>[]}) {
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
  });

  test('Hybrid split: VM-only selection keeps ala-install-only deploy', () {
    final LAProject p = hybridProject();
    final DeployCmd cmd = DeployCmd(deployServices: <String>[branding]);
    final DeployCmd wire = p.buildHybridDeployCmd(cmd);
    expect(wire.dockerCompose, equals(false));
    expect(wire.deployServices, equals(<String>[branding]));
    expect(wire.skipServices, isEmpty);
  });

  test('Hybrid split: docker-only selection deploys only the docker leg', () {
    final LAProject p = hybridProject();
    final DeployCmd cmd = DeployCmd(deployServices: <String>[alaHub]);
    final DeployCmd wire = p.buildHybridDeployCmd(cmd);
    expect(wire.dockerCompose, equals(true));
    expect(wire.deployServices, isEmpty);
    // Not selected docker services are skipped...
    expect(wire.skipServices, contains(biocacheService));
    expect(wire.skipServices, contains(cas));
    // ...including the sub-services of skipped parents (skip_services matches
    // individual service keys)
    expect(wire.skipServices, contains(userdetails));
    expect(wire.skipServices, contains(apikey));
    expect(wire.skipServices, contains(casManagement));
    // But never the selected ones
    expect(wire.skipServices, isNot(contains(alaHub)));
  });

  test('Hybrid split: mixed selection runs both legs', () {
    final LAProject p = hybridProject();
    final DeployCmd cmd = DeployCmd(
      deployServices: <String>[collectory, alaHub],
    );
    final DeployCmd wire = p.buildHybridDeployCmd(cmd);
    expect(wire.dockerCompose, equals(true));
    expect(wire.deployServices, equals(<String>[collectory]));
    expect(wire.skipServices, contains(biocacheService));
    expect(wire.skipServices, contains(cas));
    expect(wire.skipServices, isNot(contains(alaHub)));
    expect(wire.skipServices, isNot(contains(collectory)));
  });

  test("Hybrid split: 'all' expands the VM leg and deploys the full docker stack", () {
    final LAProject p = hybridProject();
    final DeployCmd cmd = DeployCmd(deployServices: <String>['all']);
    final DeployCmd wire = p.buildHybridDeployCmd(cmd);
    expect(wire.dockerCompose, equals(true));
    // 'all' is expanded to the explicit VM services so ansiblew doesn't run
    // the ala-install playbooks of the docker services
    expect(
      wire.deployServices,
      unorderedEquals(<String>[collectory, branding]),
    );
    expect(wire.deployServices, isNot(contains('all')));
    // No docker service is skipped: full stack
    expect(wire.skipServices, isNot(contains(alaHub)));
    expect(wire.skipServices, isNot(contains(biocacheService)));
    expect(wire.skipServices, isNot(contains(cas)));
  });

  test('Hybrid split: VM services co-located on the compose host are skipped', () {
    final LAProject p = hybridProject(
      vmServicesOnComposeHost: <String>[speciesLists],
    );
    final DeployCmd cmd = DeployCmd(deployServices: <String>[alaHub]);
    final DeployCmd wire = p.buildHybridDeployCmd(cmd);
    expect(wire.dockerCompose, equals(true));
    // species_lists is a VM service on the compose physical server, so it must
    // be skipped or la-docker-compose would enable it in docker too
    expect(wire.skipServices, contains(speciesLists));
    // And also with 'all'
    final DeployCmd wireAll = p.buildHybridDeployCmd(
      DeployCmd(deployServices: <String>['all']),
    );
    expect(wireAll.skipServices, contains(speciesLists));
    expect(wireAll.deployServices, contains(speciesLists));
  });

  test('Hybrid split: manual --limit keeps the compose hosts in', () {
    final LAProject p = hybridProject();
    final DeployCmd cmd = DeployCmd(
      deployServices: <String>[collectory, alaHub],
      limitToServers: <String>['vm1'],
    );
    final DeployCmd wire = p.buildHybridDeployCmd(cmd);
    expect(wire.limitToServers, containsAll(<String>['vm1', 'vm2']));
  });

  test('Non-hybrid projects get the command back untouched', () {
    final LAProject p = LAProject(
      longName: 'Living Atlas of Wakanda',
      shortName: 'LAW',
      domain: 'l-a.site',
      alaInstallRelease: '2.2.5',
      generatorRelease: '1.8.33',
    );
    p.upsertServer(LAServer(name: 'vm1', ip: '10.0.0.1', projectId: p.id));
    final LAServer vm1 = p.servers.first;
    p.assignByType(vm1.id, DeploymentType.vm, <String>[collectory]);
    p.getService(collectory).use = true;
    final DeployCmd cmd = DeployCmd(
      deployServices: <String>[collectory],
      skipServices: <String>[branding],
    );
    final DeployCmd wire = p.buildHybridDeployCmd(cmd);
    expect(wire, equals(cmd));
  });

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
