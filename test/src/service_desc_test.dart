import 'package:la_toolkit/models/LAServiceConstants.dart';
import 'package:la_toolkit/models/laServiceDepsDesc.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:la_toolkit/models/laServiceName.dart';
import 'package:test/test.dart';

void main() {
  test('Compare services name and map', () {
    // +1 = all
    // expect(LAServiceDesc.map.length + 1, equals(LAServiceName.values.length));
    // Set<String> list1 = LAServiceDesc.list(false).map((s) => s.nameInt).toSet();
    // Set<String> list2 = LAServiceName.values.map((s) => s.toS()).toSet();
    // print("List difference: ${list2.difference(list1).toList().toString()}");
    expect(LAServiceDesc.list(false).toSet().length,
        equals(LAServiceDesc.list(false).length));
    // +1 because 'all'
    expect(LAServiceDesc.list(false).length + 1,
        equals(LAServiceName.values.length));
    expect(LAServiceDepsDesc.v2_0_4.length + 1,
        equals(LAServiceName.values.length));
  });

  test('child services without parent', () {
    for (LAServiceDesc s in LAServiceDesc.list(true)) {
      if (s.isSubService) {
        expect(s.parentService != null, equals(true));
      }
    }
  });

  test('Compare services creation', () {
    expect("collectory".toServiceDescName() == LAServiceName.collectory,
        equals(true));
  });

  test('Compare different services ', () {
    expect(LAServiceName.bie_index == LAServiceName.ala_bie, equals(false));
  });

  test('Compare equal services ', () {
    expect(LAServiceName.bie_index == LAServiceName.bie_index, equals(true));
  });

  test('Compare services enum', () {
    expect(collectory == "collectory", equals(true));
  });

  test('Compare services name and map', () {
    expect(LAServiceDesc.listWithArtifact().length, equals(33));
  });
}
