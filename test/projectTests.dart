import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/laServer.dart';
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
}

// test that we cannot add the same server twice

void verifyStepsValidation(List<bool> expectedResult, LAProject testProject) {
  for (var step = 0; step < expectedResult.length; step++) {
    expect(testProject.validateCreation(step), equals(expectedResult[step]));
  }
}
