import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/laServer.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:test/test.dart';

void main() {
  test('Test step 0 of creation, longname', () {
    LAProject testProject = LAProject(longName: "");
    expect(testProject.isCreated, equals(false));
    verifyStepsValidation([false, false, false, false, false], testProject);
  });

  test('Test step 0 of creation, shortname', () {
    LAProject testProject =
        LAProject(longName: "Living Atlas of Wakanda", shortName: "");
    expect(testProject.isCreated, equals(false));
    verifyStepsValidation([false, false, false, false, false], testProject);
  });

  test('Test step 0 of creation, invalid domain', () {
    LAProject testProject = LAProject(
        longName: "Living Atlas of Wakanda", shortName: "kk", domain: "kk");
    expect(testProject.isCreated, equals(false));
    verifyStepsValidation([false, false, false, false, false], testProject);
  });

  test('Test step 0 of creation, valid domain, valid step 1', () {
    LAProject testProject = LAProject(
        longName: "Living Atlas of Wakanda",
        shortName: "LAW",
        domain: "l-a.site");
    expect(testProject.isCreated, equals(false));
    verifyStepsValidation([true, false, false, false, false], testProject);
  });

  test('Test step 1 of creation, valid server', () {
    LAProject testProject = LAProject(
        longName: "Living Atlas of Wakanda",
        shortName: "LAW",
        domain: "l-a.site");
    testProject.upsert(LAServer(name: "vm1"));
    expect(testProject.isCreated, equals(false));
    expect(testProject.numServers(), equals(1));
    expect(testProject.validateCreation(0), equals(true));
    expect(testProject.validateCreation(1), equals(true));
    verifyStepsValidation([true, true, true, false, false], testProject);
  });

  test('Test step 1 of creation, valid servers', () {
    LAProject testProject = LAProject(
        longName: "Living Atlas of Wakanda",
        shortName: "LAW",
        domain: "l-a.site");
    testProject.upsert(LAServer(name: "vm1"));
    testProject.upsert(LAServer(name: "vm2", ipv4: "10.0.0.1"));
    testProject.upsert(LAServer(name: "vm2", ipv4: "10.0.0.2"));
    expect(testProject.isCreated, equals(false));
    expect(testProject.numServers(), equals(2));
    expect(testProject.validateCreation(0), equals(true));
    expect(testProject.validateCreation(1), equals(true));
    expect(
        testProject.servers
            .where((element) => element.name == "vm2")
            .first
            .ipv4,
        equals("10.0.0.2"));
    verifyStepsValidation([true, true, true, false, false], testProject);
  });

  test('Servers equals', () {
    LAServer vm1 = LAServer(name: 'vm1');
    LAServer vm1bis = LAServer(name: 'vm1', aliases: ['collections']);
    expect(vm1 == vm1bis, equals(true));
  });

  test('Servers not equals', () {
    LAServer vm1 = LAServer(name: 'vm1');
    LAServer vm1bis = LAServer(name: 'vm2');
    expect(vm1 != vm1bis, equals(true));
  });

  test('Test step 1 of creation, valid servers-service assignment', () {
    LAProject testProject = LAProject(
        longName: "Living Atlas of Wakanda",
        shortName: "LAW",
        domain: "l-a.site");
    LAServer vm1 = LAServer(name: "vm1", ipv4: "10.0.0.1");
    LAServer vm2 = LAServer(name: "vm2", ipv4: "10.0.0.2");
    LAServer vm3 = LAServer(name: "vm3", ipv4: "10.0.0.3");
    LAServer vm4 = LAServer(name: "vm4", ipv4: "10.0.0.4");
    testProject.upsert(vm1);
    testProject.upsert(vm2);
    testProject.upsert(vm3);
    testProject.upsert(vm4);
    testProject.assign(LAServiceName.collectory.toS(), vm1);

    expect(
        testProject
            .getServicesNameListInUse()
            .contains(LAServiceName.collectory.toS()),
        equals(true));
    expect(
        testProject.getServiceE(LAServiceName.collectory).servers.contains(vm1),
        equals(true));
    print(testProject);
    print(testProject.servers);
    print(testProject.services);
    print(testProject.getServiceE(LAServiceName.collectory));
    expect(testProject.getServiceE(LAServiceName.regions).servers.contains(vm1),
        equals(false));

    testProject.assign(LAServiceName.collectory.toS(), vm2);
    testProject.assign(LAServiceName.ala_bie.toS(), vm1);
    testProject.assign(LAServiceName.branding.toS(), vm1);
    testProject.assign(LAServiceName.bie_index.toS(), vm2);
    testProject.assign(LAServiceName.ala_hub.toS(), vm1);
    testProject.assign(LAServiceName.regions.toS(), vm1);
    testProject.assign(LAServiceName.biocache_service.toS(), vm2);
    testProject.assign(LAServiceName.solr.toS(), vm3);
    testProject.assign(LAServiceName.logger.toS(), vm3);
    testProject.assign(LAServiceName.species_lists.toS(), vm3);
    testProject.assign(LAServiceName.spatial.toS(), vm4);
    testProject.assign(LAServiceName.cas.toS(), vm4);
    testProject.assign(LAServiceName.images.toS(), vm4);
    testProject.assign(LAServiceName.biocache_backend.toS(), vm4);
    testProject.assign(LAServiceName.biocache_cli.toS(), vm4);
    testProject.assign(LAServiceName.nameindexer.toS(), vm4);

    expect(
        testProject
            .getServicesNameListInUse()
            .contains(LAServiceName.collectory.toS()),
        equals(true));
    expect(
        testProject.getServiceE(LAServiceName.collectory).servers.contains(vm2),
        equals(true));
    expect(
        testProject.getServiceE(LAServiceName.collectory).servers.contains(vm1),
        equals(false));
    expect(testProject.isCreated, equals(false));
    expect(testProject.numServers(), equals(4));
    expect(testProject.validateCreation(0), equals(true));
    expect(testProject.validateCreation(1), equals(true));
    expect(
        testProject.servers
            .where((element) => element.name == "vm2")
            .first
            .ipv4,
        equals("10.0.0.2"));
    print(testProject);
    verifyStepsValidation([true, true, true, true, true], testProject);
  });
}

// test that we cannot add the same server twice

void verifyStepsValidation(List<bool> expectedResult, LAProject testProject) {
  for (var step = 0; step < expectedResult.length; step++) {
    expect(testProject.validateCreation(step), equals(expectedResult[step]));
  }
}
