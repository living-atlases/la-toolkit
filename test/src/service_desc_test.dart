import 'package:la_toolkit/models/laServiceDepsDesc.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:test/test.dart';

void main() {
  test('Compare services name and map', () {
    // +1 = all
    // expect(LAServiceDesc.map.length + 1, equals(LAServiceName.values.length));
    expect(LAServiceDesc.list(false).length + 1,
        equals(LAServiceName.values.length));
    expect(LAServiceDepsDesc.v2_0_4.length + 1,
        equals(LAServiceName.values.length));
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
    expect(LAServiceName.collectory.toS() == "collectory", equals(true));
  });
}
