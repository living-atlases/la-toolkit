import 'package:flutter_test/flutter_test.dart';
import 'package:la_toolkit/models/la_project.dart';
import 'package:la_toolkit/models/la_server.dart';
import 'package:la_toolkit/models/la_service_constants.dart';

void main() {
  test('Reproduce solrcloud_version null issue', () {
    final LAProject p = LAProject(
      longName: 'Test Project',
      shortName: 'TP',
      domain: 'test.com',
      alaInstallRelease: '2.1.0',
    );

    // Add server
    final server = LAServer(name: 'server1', projectId: p.id);
    p.upsertServer(server);

    // Assign solrcloud
    // p.assign(server, [solrcloud]);

    // Check JSON
    var json = p.toGeneratorJson();
    var swVersions = json['LA_software_versions'] as List<List<dynamic>>;

    print('Software Versions (Solrcloud not assigned): $swVersions');

    // Check if solrcloud_version is present
    bool hasSolrCloud = swVersions.any((v) => v[0] == 'solrcloud_version');
    expect(hasSolrCloud, false);

    // Now assign Solrcloud
    p.assign(server, [solrcloud]);

    json = p.toGeneratorJson();
    swVersions = json['LA_software_versions'] as List<List<dynamic>>;
    print('Software Versions (Solrcloud assigned): $swVersions');

    var solrCloudEntry = swVersions.firstWhere(
      (v) => v[0] == 'solrcloud_version',
      orElse: () => [],
    );

    if (solrCloudEntry.isNotEmpty) {
      print('Solrcloud version value: ${solrCloudEntry[1]}');
    } else {
      print('Solrcloud version not found after assignment');
    }
  });

  test('Check solrcloud_version with 2.1.10', () {
    final LAProject p = LAProject(
      longName: 'Test Project',
      shortName: 'TP',
      domain: 'test.com',
      alaInstallRelease: '2.1.10',
    );

    // Add server
    final server = LAServer(name: 'server1', projectId: p.id);
    p.upsertServer(server);

    // Assign solrcloud
    p.assign(server, [solrcloud]);

    var json = p.toGeneratorJson();
    var swVersions = json['LA_software_versions'] as List<List<dynamic>>;
    print('Software Versions (2.1.10): $swVersions');

    var solrCloudEntry = swVersions.firstWhere(
      (v) => v[0] == 'solrcloud_version',
      orElse: () => [],
    );
    if (solrCloudEntry.isNotEmpty) {
      print('Solrcloud version (2.1.10): "${solrCloudEntry[1]}"');
    } else {
      print('Solrcloud version (2.1.10) not found');
    }
  });

  test('Check solrcloud_version with null project version', () {
    final LAProject p = LAProject(
      longName: 'Test Project',
      shortName: 'TP',
      domain: 'test.com',
      alaInstallRelease: null,
    );

    // Add server
    final server = LAServer(name: 'server1', projectId: p.id);
    p.upsertServer(server);

    // Assign solrcloud
    p.assign(server, [solrcloud]);

    var json = p.toGeneratorJson();
    var swVersions = json['LA_software_versions'] as List<List<dynamic>>;
    print('Software Versions (release null): $swVersions');

    var solrCloudEntry = swVersions.firstWhere(
      (v) => v[0] == 'solrcloud_version',
      orElse: () => [],
    );
    if (solrCloudEntry.isNotEmpty) {
      print('Solrcloud version (null release): ${solrCloudEntry[1]}');
    }
  });
}
