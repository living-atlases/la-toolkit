import 'package:la_toolkit/models/basic_service.dart';
import 'package:la_toolkit/models/la_service_desc.dart';
import 'package:la_toolkit/models/la_service_name.dart';
import 'package:la_toolkit/models/la_variable_desc.dart';

import 'package:test/test.dart';

void main() {
  String alaInstallVersion = 'v2.0.4';
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
            .isCompatibleWith(alaInstallVersion, LAServiceDesc.get('cas')),
        equals(false));
  });

  // Test with a new release, should get v2.0.4 by default
  alaInstallVersion = 'v2.0.5';

  test('LAServicesDesc images and doi are incompatible', () {
    expect(
        LAServiceDesc.get('images')
            .isCompatibleWith(alaInstallVersion, LAServiceDesc.get('doi')),
        equals(false));
  });

  test('LAServicesDesc collectory and species-lists are incompatible', () {
    expect(
        LAServiceDesc.get('collectory').isCompatibleWith(
            alaInstallVersion, LAServiceDesc.getE(LAServiceName.species_lists)),
        equals(true));
  });

  test('List variables', () {
    String list = '';
    final List<String> laVariablesList =
        LAVariableDesc.map.values.map((LAVariableDesc v) => v.nameInt).toList();
    laVariablesList.sort();
    for (final String e in laVariablesList) {
      list = "${list}LA_variable_$e: 'LA_variable_$e',\n";
    }
    // LIST variables for backend transform
    // print(list);
    expect(list.length, greaterThan(0));
  });
}
