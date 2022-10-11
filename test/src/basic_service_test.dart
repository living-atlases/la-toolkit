import 'package:la_toolkit/models/basicService.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:la_toolkit/models/laServiceName.dart';
import 'package:la_toolkit/models/laVariableDesc.dart';
import 'package:test/test.dart';

void main() {
  String alaInstallVersion = "v2.0.4";
  test('Compare equals versions', () {
    expect(MySql.def, equals(MySql.def));
  });

  test('Not equals versions', () {
    expect(PostgresSql.def, isNot(equals(MySql.def)));
  });

  test('LAServicesDesc cas and pipelines are incompatible', () {
    // port collision
    expect(
        LAServiceDesc.getE(LAServiceName.pipelines)
            .isCompatibleWith(alaInstallVersion, LAServiceDesc.get("cas")),
        equals(false));
  });

  // Test with a new release, should get v2.0.4 by default
  alaInstallVersion = "v2.0.5";

  test('LAServicesDesc images and doi are incompatible', () {
    expect(
        LAServiceDesc.get("images")
            .isCompatibleWith(alaInstallVersion, LAServiceDesc.get("doi")),
        equals(false));
  });

  test('LAServicesDesc collectory and species-lists are incompatible', () {
    expect(
        LAServiceDesc.get("collectory").isCompatibleWith(
            alaInstallVersion, LAServiceDesc.getE(LAServiceName.species_lists)),
        equals(true));
  });

  test('List variables', () {
    String list = '';
    List<String> laVariablesList =
        LAVariableDesc.map.values.map((v) => v.nameInt).toList();
    laVariablesList.sort();
    for (var e in laVariablesList) {
      list = list + "LA_variable_$e: 'LA_variable_$e',\n";
    }
    // LIST variables for backend transform
    // print(list);
    expect(list.length, greaterThan(0));
  });
}
