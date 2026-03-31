import 'package:flutter_test/flutter_test.dart';
import 'package:la_toolkit/models/la_project.dart';
import 'package:la_toolkit/models/la_server.dart';
import 'package:la_toolkit/models/la_service_constants.dart';
import 'package:la_toolkit/models/la_service_deploy.dart';

void main() {
  test('Exclude "null" string versions from generator JSON', () {
    final LAProject p = LAProject(
      longName: 'Test Project',
      shortName: 'TP',
      domain: 'test.com',
      alaInstallRelease: '2.1.10',
    );

    final LAServer server = LAServer(name: 'server1', projectId: p.id);
    p.upsertServer(server);

    // Manually add a service deploy with "null" version
    // We can't easily force "null" via assign if defaults work, so we construct LAServiceDeploy manually or hack the map

    // First assign normally
    p.assign(server, <String>[solrcloud, cas]);

    // Now hack the versions in the service deploy
    for (final LAServiceDeploy sd in p.serviceDeploys) {
      if (sd.softwareVersions.containsKey(solrcloud)) {
        sd.softwareVersions[solrcloud] = 'null';
      }
      if (sd.softwareVersions.containsKey(cas)) {
        sd.softwareVersions[cas] = 'null';
      }
    }

    final Map<String, dynamic> json = p.toGeneratorJson();
    final List<List<dynamic>> swVersions =
        json['LA_software_versions'] as List<List<dynamic>>;

    // ignore: avoid_print
    print('Software Versions with "null" injected: $swVersions');

    final List<dynamic> solrCloudEntry = swVersions.firstWhere(
      (List<dynamic> v) => v[0] == 'solrcloud_version',
      orElse: () => <dynamic>[],
    );
    final List<dynamic> casEntry = swVersions.firstWhere(
      (List<dynamic> v) => v[0] == 'cas_version',
      orElse: () => <dynamic>[],
    );

    expect(
      solrCloudEntry.isEmpty,
      true,
      reason: 'solrcloud_version should be excluded if "null" string',
    );
    expect(
      casEntry.isEmpty,
      true,
      reason: 'cas_version should be excluded if "null" string',
    );
  });
}
