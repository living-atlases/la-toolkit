import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:la_toolkit/models/la_project.dart';
import 'package:la_toolkit/utils/utils.dart';

import '../widget/pump_app.dart';

/// The `.yo-rc.json` the backend writes is literally
/// `{"generator-living-atlas": {"promptValues": <toGeneratorJson()>}}`
/// (api/controllers/gen.js), so producing it here is the same file a real
/// "prepare deploy" would produce -- the only faithful input for testing the
/// rest of the chain (generator -> la-docker-compose) against multi-hub.
///
/// Set LA_YORC_OUT to also drop that file somewhere, which is how the offline
/// end-to-end run gets its inventories:
///   LA_YORC_OUT=/tmp/e2e/.yo-rc.json flutter test test/src/sample_yorc_export_test.dart
///   cd /tmp/e2e && yo living-atlas --replay-dont-ask --force
void main() {
  setUp(setUpDemoEnv);

  test('the shipped sample exports a .yo-rc a generator can replay', () async {
    final List<LAProject> projects = await LAProject.importTemplates(
      AssetsUtils.pathWorkaround('la-toolkit-templates.json'),
    );
    final LAProject portal = projects.firstWhere((LAProject p) => !p.isHub);
    final Map<String, dynamic> conf = portal.toGeneratorJson();

    expect(conf['LA_use_docker_compose'], true);
    expect(conf['LA_pkg_name'], 'lademo-docker');

    final List<dynamic> hubs = conf['LA_hubs'] as List<dynamic>;
    expect(hubs.length, 2, reason: 'the sample ships the two hubs CI deploys');

    for (final dynamic h in hubs) {
      final Map<String, dynamic> hub = h as Map<String, dynamic>;
      // What makes a hub deployable in the portal's stack: it inherits the
      // portal's docker facts (it owns no infrastructure) and keeps its own
      // package name, which is the directory its inventory is written to.
      expect(hub['LA_use_docker_compose'], true);
      expect(
        hub['LA_docker_compose_hostname'],
        conf['LA_docker_compose_hostname'],
      );
      expect(hub['LA_is_hub'], true);
      expect(hub['LA_pkg_name'], isNotNull);
      expect(hub['LA_ala_hub_url'], isNotNull);
    }
    expect(
      hubs.map((dynamic h) => (h as Map<String, dynamic>)['LA_pkg_name']).toSet(),
      <String>{'lademo-docker-hub', 'lademo-docker-hub2'},
    );

    // The complete hub brings its own branding; the records-only one brings
    // none and consumes the portal's.
    final Map<String, dynamic> full = hubs[0] as Map<String, dynamic>;
    final Map<String, dynamic> recordsOnly = hubs[1] as Map<String, dynamic>;
    expect(full['LA_variable_branding_source'], isNotNull);
    expect(full['LA_use_species'], true);
    expect(full['LA_use_regions'], true);
    expect(full['LA_use_branding'], true);
    // The toolkit fills branding_source with a default path whether or not the
    // hub wants one, so what says "no branding of my own" is the service being
    // off. The generator reads that flag, not the value.
    expect(recordsOnly['LA_use_branding'], false);
    // ...and no branding workspace is scaffolded for it either.
    expect(full['LA_generate_branding'], true);
    expect(recordsOnly['LA_generate_branding'], false);
    expect(recordsOnly['LA_use_species'], false);
    expect(recordsOnly['LA_use_regions'], false);

    final String? out = Platform.environment['LA_YORC_OUT'];
    if (out != null && out.isNotEmpty) {
      final File file = File(out);
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(<String, dynamic>{
          'generator-living-atlas': <String, dynamic>{
            'promptValues': conf,
            'firstRun': false,
          },
        }),
      );
      // ignore: avoid_print
      print('LA_YORC_OUT written: ${file.path}');
    }
  });
}
