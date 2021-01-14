import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:test/test.dart';

void main() {
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
