import 'package:la_toolkit/models/basicService.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:test/test.dart';

void main() {
  test('Compare equals versions', () {
    expect(MySql.v5_7, equals(MySql.v5_7));
  });

  test('Not equals versions', () {
    expect(PostgresSql.v9_6, isNot(equals(MySql.v5_7)));
  });

  test('Not equals software', () {
    expect(MySql.v8, isNot(equals(MySql.v5_7)));
  });

  test('Software incompatible', () {
    expect(MySql.v8.isCompatible(MySql.v5_7), equals(false));
  });

  test('Software compatible', () {
    expect(MySql.v8.isCompatible(PostgresSql.v9_6), equals(true));
  });

  test('LAServicesDesc spatial and images are incompatible', () {
    expect(
        LAServiceDesc.getE(LAServiceName.images)
            .isCompatibleWith(LAServiceDesc.get("spatial")),
        equals(false));
  });

  test('LAServicesDesc spatial and images are incompatible', () {
    expect(
        LAServiceDesc.getE(LAServiceName.spatial)
            .isCompatibleWith(LAServiceDesc.getE(LAServiceName.images)),
        equals(false));
  });

  test('LAServicesDesc spatial and doi are incompatible', () {
    expect(
        LAServiceDesc.get("images").isCompatibleWith(LAServiceDesc.get("doi")),
        equals(false));
  });

  test('LAServicesDesc images and doi are incompatible', () {
    expect(
        LAServiceDesc.get("images").isCompatibleWith(LAServiceDesc.get("doi")),
        equals(false));
  });

  test('LAServicesDesc collectory and species-lists are incompatible', () {
    expect(
        LAServiceDesc.get("collectory")
            .isCompatibleWith(LAServiceDesc.getE(LAServiceName.species_lists)),
        equals(true));
  });
}
