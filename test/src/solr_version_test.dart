import 'package:flutter_test/flutter_test.dart';
import 'package:la_toolkit/models/la_project.dart';
import 'package:la_toolkit/models/la_server.dart';
import 'package:la_toolkit/models/la_service_constants.dart';

void main() {
  test('Solrcloud version should be present for 2.1.10', () {
    final LAProject p = LAProject(
      longName: 'Test Project',
      shortName: 'TP',
      domain: 'test.com',
      alaInstallRelease: '2.1.10',
    );

    final LAServer server = LAServer(name: 'server1', projectId: p.id);
    p.upsertServer(server);
    p.assign(server, <String>[solrcloud]);

    final Map<String, dynamic> json = p.toGeneratorJson();
    final List<List<dynamic>> swVersions =
        json['LA_software_versions'] as List<List<dynamic>>;

    final List<dynamic> solrCloudEntry = swVersions.firstWhere(
      (List<dynamic> v) => v[0] == 'solrcloud_version',
      orElse: () => <dynamic>[],
    );

    expect(
      solrCloudEntry.isNotEmpty,
      true,
      reason: 'solrcloud_version should be present',
    );
    expect(
      solrCloudEntry[1],
      '8.9.0',
      reason: 'solrcloud_version should be 8.9.0',
    );
  });

  test('Empty versions should be excluded from generator JSON', () {
    final LAProject p = LAProject(
      longName: 'Test Project',
      shortName: 'TP',
      domain: 'test.com',
      alaInstallRelease: '2.0.0', // Older version might not have solrcloud
    );

    final LAServer server = LAServer(name: 'server1', projectId: p.id);
    p.upsertServer(server);

    // Assign solrcloud, but 2.0.0 defaults might not have it
    p.assign(server, <String>[solrcloud]);

    final Map<String, dynamic> json = p.toGeneratorJson();
    final List<List<dynamic>> swVersions =
        json['LA_software_versions'] as List<List<dynamic>>;

    final List<dynamic> solrCloudEntry = swVersions.firstWhere(
      (List<dynamic> v) => v[0] == 'solrcloud_version',
      orElse: () => <dynamic>[],
    );

    expect(
      solrCloudEntry.isEmpty,
      true,
      reason: 'solrcloud_version should be excluded if empty',
    );
  });

  test('Spatial version should be correct for 2.1.10', () {
    final LAProject p = LAProject(
      longName: 'Test Project',
      shortName: 'TP',
      domain: 'test.com',
      alaInstallRelease: '2.1.10',
    );

    final LAServer server = LAServer(name: 'server1', projectId: p.id);
    p.upsertServer(server);
    p.assign(server, <String>[spatial]);

    final Map<String, dynamic> json = p.toGeneratorJson();
    final List<List<dynamic>> swVersions =
        json['LA_software_versions'] as List<List<dynamic>>;

    final List<dynamic> spatialEntry = swVersions.firstWhere(
      (List<dynamic> v) => v[0] == 'spatial_hub_version',
      orElse: () => <dynamic>[],
    );

    expect(
      spatialEntry.isNotEmpty,
      true,
      reason: 'spatial_hub_version should be present',
    );
    expect(
      spatialEntry[1],
      '1.0.2',
      reason: 'spatial_hub_version should be 1.0.2',
    );
  });
}
