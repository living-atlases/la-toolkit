import 'package:collection/collection.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/laProjectStatus.dart';
import 'package:la_toolkit/models/laServer.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:la_toolkit/models/sshKey.dart';
import 'package:latlong/latlong.dart';
import 'package:test/test.dart';

void main() {
  test('Test step 0 of creation, longname', () {
    LAProject testProject = LAProject(longName: "");
    expect(testProject.isCreated, equals(false));
    expect(testProject.status, equals(LAProjectStatus.created));
  });

  test('Test step 0 of creation, shortname', () {
    LAProject testProject =
        LAProject(longName: "Living Atlas of Wakanda", shortName: "");
    expect(testProject.isCreated, equals(false));
    expect(testProject.status, equals(LAProjectStatus.created));
  });

  test('Test step 0 of creation, invalid domain', () {
    LAProject testProject = LAProject(
        longName: "Living Atlas of Wakanda", shortName: "kk", domain: "kk");
    expect(testProject.isCreated, equals(false));
    expect(testProject.status, equals(LAProjectStatus.created));
  });

  test('Test step 0 of creation, valid domain, valid step 1', () {
    LAProject testProject = LAProject(
        longName: "Living Atlas of Wakanda",
        shortName: "LAW",
        domain: "l-a.site");
    expect(testProject.validateCreation(), equals(false));
    expect(testProject.isCreated, equals(false));
    expect(testProject.status, equals(LAProjectStatus.basicDefined));
  });

  test('Test step 1 of creation, valid server', () {
    LAProject testProject = LAProject(
        longName: "Living Atlas of Wakanda",
        shortName: "LAW",
        domain: "l-a.site");
    testProject.upsert(LAServer(name: "vm1"));
    expect(testProject.isCreated, equals(false));
    expect(testProject.numServers(), equals(1));
    expect(testProject.validateCreation(), equals(false));
    expect(testProject.status, equals(LAProjectStatus.basicDefined));
  });

  test('Test step 1 of creation, valid servers', () {
    LAProject testProject = LAProject(
        longName: "Living Atlas of Wakanda",
        shortName: "LAW",
        domain: "l-a.site");
    testProject.upsert(LAServer(name: "vm1"));
    testProject.upsert(LAServer(name: "vm2", ip: "10.0.0.1"));
    testProject.upsert(LAServer(name: "vm2", ip: "10.0.0.2"));
    expect(testProject.isCreated, equals(false));
    expect(testProject.numServers(), equals(2));
    expect(testProject.validateCreation(), equals(false));
    expect(
        testProject.servers.where((element) => element.name == "vm2").first.ip,
        equals("10.0.0.2"));
    expect(testProject.status, equals(LAProjectStatus.basicDefined));
  });

  test('Servers equals', () {
    LAServer vm1 = LAServer(name: 'vm2', ip: '10.0.0.1');
    LAServer vm1bis = LAServer(name: 'vm2', ip: '10.0.0.1');
    expect(vm1 == vm1bis, equals(true));
  });

  test('Servers not equals', () {
    LAServer vm1 = LAServer(name: 'vm1');
    LAServer vm1bis = LAServer(name: 'vm2');
    expect(vm1 == vm1bis, equals(false));
    vm1 = LAServer(name: 'vm1');
    vm1bis = LAServer(name: 'vm1', aliases: ['collections']);
    var vm1bisBis = LAServer(name: 'vm1', sshPort: 22001);
    expect(vm1 == vm1bis, equals(false));
    expect(vm1 == vm1bisBis, equals(false));
  });

  final lists = LAServiceName.species_lists.toS();
  final collectory = LAServiceName.collectory.toS();
  final bie = LAServiceName.ala_bie.toS();

  test('Test step 1 of creation, valid servers-service assignment and equality',
      () {
    LAProject testProject = LAProject(
        uuid: "0",
        longName: "Living Atlas of Wakanda",
        shortName: "LAW",
        domain: "l-a.site");
    LAProject testProjectOther = LAProject(
        uuid: "0",
        longName: "Living Atlas of Wakanda",
        shortName: "LAW",
        domain: "l-a.site");

    expect(
        MapEquality().equals(testProject.services, testProjectOther.services),
        equals(true));
    expect(
        MapEquality().equals(
            testProject.serverServices, testProjectOther.serverServices),
        equals(true));
    expect(testProject.mapBounds2ndPoint == testProjectOther.mapBounds1stPoint,
        equals(true));
    expect(ListEquality().equals(testProject.servers, testProjectOther.servers),
        equals(true));
    expect(
        MapEquality().equals(testProject.variables, testProjectOther.variables),
        equals(true));
    expect(testProject.hashCode == testProjectOther.hashCode, equals(true));
    expect(testProject == testProjectOther, equals(true));
    LAServer vm1 = LAServer(name: "vm1", ip: "10.0.0.1");
    LAServer vm2 = LAServer(name: "vm2", ip: "10.0.0.2");
    LAServer vm3 = LAServer(name: "vm3", ip: "10.0.0.3");
    LAServer vm4 = LAServer(name: "vm4", ip: "10.0.0.4");
    LAProject testProjectCopy =
        testProject.copyWith(servers: [], serverServices: {});
    testProject.upsert(vm1);
    testProjectCopy.upsert(vm1);
    expect(testProject.serverServices.length, equals(1));
    expect(testProject.servers.length, equals(1));
    expect(testProjectCopy.serverServices.length, equals(1));
    expect(testProjectCopy.servers.length, equals(1));
    expect(MapEquality().equals(testProject.services, testProjectCopy.services),
        equals(true));
    expect(
        DeepCollectionEquality.unordered()
            .equals(testProject.serverServices, testProjectCopy.serverServices),
        equals(true));
    expect(testProject == testProjectCopy, equals(true));
    expect(testProject.servers, equals(testProjectCopy.servers));

    testProject.upsert(vm2);
    expect(testProjectCopy.servers.length, equals(1));

    expect(testProject.serverServices.length, equals(2));
    expect(testProject.servers == testProjectCopy.servers, equals(false));
    expect(testProjectCopy.serverServices.length, equals(1));
    expect(
        MapEquality()
            .equals(testProject.serverServices, testProjectCopy.serverServices),
        equals(false));
    expect(testProject.mapBounds2ndPoint == testProjectCopy.mapBounds1stPoint,
        equals(true));
    expect(ListEquality().equals(testProject.servers, testProjectCopy.servers),
        equals(false));
    expect(testProject.hashCode == testProjectCopy.hashCode, equals(false));

    expect(testProject == testProjectCopy, equals(false));
    testProjectCopy.upsert(vm2);
    expect(testProject == testProjectCopy, equals(true));
    expect(testProject.servers, equals(testProjectCopy.servers));
    testProject.upsert(vm3);
    testProject.upsert(vm4);
    expect(testProject == testProjectCopy, equals(false));
    testProject.assign(vm1, [LAServiceName.collectory.toS()]);
    expect(testProject == testProjectCopy, equals(false));

    expect(
        testProject
            .getServicesNameListInUse()
            .contains(LAServiceName.collectory.toS()),
        equals(true));
    expect(
        testProject.getHostname(LAServiceName.collectory.toS())[0] == vm1.name,
        equals(true));
    /* print(testProject);
    print(testProject.servers);
    print(testProject.services);
    print(testProject.getServiceE(LAServiceName.collectory)); */

    expect(testProject.getHostname(LAServiceName.regions.toS()).length == 0,
        equals(true));

    testProject.assign(vm1, [
      LAServiceName.ala_hub.toS(),
      LAServiceName.regions.toS(),
      bie,
      LAServiceName.branding.toS()
    ]);

    testProject.assign(vm2, [
      LAServiceName.collectory.toS(),
      LAServiceName.bie_index.toS(),
      LAServiceName.biocache_service.toS()
    ]);

    testProject.assign(
        vm3, [LAServiceName.solr.toS(), LAServiceName.logger.toS(), lists]);

    testProject.assign(vm4, [
      LAServiceName.spatial.toS(),
      LAServiceName.cas.toS(),
      LAServiceName.images.toS(),
      LAServiceName.biocache_backend.toS(),
      LAServiceName.biocache_cli.toS(),
      LAServiceName.nameindexer.toS()
    ]);

    expect(
        testProject
            .getServicesNameListInUse()
            .contains(LAServiceName.collectory.toS()),
        equals(true));
    expect(
        testProject.getHostname(LAServiceName.collectory.toS())[0] == vm2.name,
        equals(true));
    expect(
        testProject.getHostname(LAServiceName.collectory.toS())[0] == vm1.name,
        equals(false));
    expect(testProject.isCreated, equals(false));
    expect(testProject.numServers(), equals(4));
    // no ssh keys
    expect(testProject.validateCreation(), equals(false));
    vm1.sshKey = SshKey();
    vm2.sshKey = SshKey();
    vm3.sshKey = SshKey();
    vm4.sshKey = SshKey();
    expect(testProject.validateCreation(), equals(true));
    expect(
        testProject.servers.where((element) => element.name == "vm2").first.ip,
        equals("10.0.0.2"));
/*    print(testProject); */
    expect(testProject.getServersNameList().length, equals(4));
    expect(testProject.status, equals(LAProjectStatus.advancedDefined));
    // testProject.delete(vm1);
  });

  test('Test lat/lng center', () {
    var p = LAProject(mapBounds1stPoint: [10, 10], mapBounds2ndPoint: [20, 20]);
    expect(p.getCenter(), equals(LatLng(15, 15)));
    p.mapBounds1stPoint = [20, 20];
    p.mapBounds2ndPoint = [40, 40];
    p.setMap(LatLng(20, 20), LatLng(40, 40), 10);
    expect(p.getCenter(), equals(LatLng(30, 30)));
    expect(p.mapZoom, equals(10));
  });

  test('Test default services', () {
    var p = LAProject();

    expect(p.getServiceE(LAServiceName.collectory).use, equals(true));
    expect(p.getServiceE(LAServiceName.ala_hub).use, equals(true));
    expect(p.getServiceE(LAServiceName.biocache_service).use, equals(true));
    expect(p.getServiceE(LAServiceName.biocache_backend).use, equals(true));
    expect(p.getServiceE(LAServiceName.solr).use, equals(true));
    expect(p.getServiceE(LAServiceName.logger).use, equals(true));
  });

  test('Test disable of services', () {
    var p = LAProject();
    p.serviceInUse(bie, true);
    p.serviceInUse(lists, true);
    expect(p.getService(bie).use, equals(true));
    expect(p.getService(lists).use, equals(true));
    var pBis = p.copyWith();

    expect(p == pBis, equals(true));
    LAServer vm1 = LAServer(name: "vm1");
    p.upsert(vm1);
    p.assign(vm1, [collectory, bie, lists]);
    LAServer vm1Bis = LAServer(name: "vm1", sshUser: "john", sshPort: 22001);
    p.upsert(vm1Bis);
    expect(p.serverServices["vm1"].contains(collectory), equals(true));
    expect(p.serverServices["vm1"].contains(bie), equals(true));
    expect(p.serverServices["vm1"].contains(lists), equals(true));
    var vm1Updated =
        p.servers.where((element) => element.name == "vm1").toList()[0];
    expect(vm1Updated.sshUser == "john" && vm1Updated.sshPort == 22001,
        equals(true));
    p.serviceInUse(bie, false);
    expect(p.getService(bie).use, equals(false));
    expect(p.getService(lists).use, equals(false));
    expect(p.serverServices["vm1"].contains(collectory), equals(true));
    expect(p.serverServices["vm1"].contains(bie), equals(false));
    expect(p.serverServices["vm1"].contains(lists), equals(false));
  });
}
