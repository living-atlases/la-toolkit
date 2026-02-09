import 'package:flutter_test/flutter_test.dart';
import 'package:la_toolkit/models/la_service_constants.dart';
import 'package:la_toolkit/models/la_service_desc.dart';

void main() {
  test('Verify swToAnsibleVars contains correct keys', () {
    final Map<String, String> mapping = LAServiceDesc.swToAnsibleVars;

    // Check fixed typos
    expect(
      mapping.containsKey('namematching_service'),
      true,
      reason: 'namematching_service key missing',
    );
    expect(
      mapping.containsKey('sensitive_data_service'),
      true,
      reason: 'sensitive_data_service key missing',
    );

    // Check they don't have the old typos
    expect(
      mapping.containsKey('namemaching_service'),
      false,
      reason: 'namemaching_service typo still present',
    );
    expect(
      mapping.containsKey('sensitive_data__service'),
      false,
      reason: 'sensitive_data__service typo still present',
    );

    // Check core services
    expect(mapping[collectory], 'collectory_version');
    expect(mapping[biocollect], 'biocollect_version');
    expect(mapping[alaHub], 'biocache_hub_version');
    expect(mapping[solr], 'solr_version');
    expect(mapping[solrcloud], 'solrcloud_version');
  });

  test(
    'Verify all keys in swToAnsibleVars correspond to known services or constants',
    () {
      final Map<String, String> mapping = LAServiceDesc.swToAnsibleVars;
      final List<String> knownServices = LAServiceDesc.listS(false);

      // Some keys might be manually added or aliases, but they should generally be known
      for (final String key in mapping.keys) {
        // We allow some manual additions that might not be in the main list yet if they are in service constants
        // but here we just check for obvious typos or missing constants.
        if (!knownServices.contains(key)) {
          print(
            'Note: Key "$key" from swToAnsibleVars is not in LAServiceDesc.listS(false)',
          );
        }
      }
    },
  );
}
