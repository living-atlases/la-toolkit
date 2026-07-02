import 'package:flutter_test/flutter_test.dart';
import 'package:la_toolkit/models/la_project.dart';
import 'package:la_toolkit/models/la_server.dart';
import 'package:la_toolkit/models/la_service.dart';
import 'package:la_toolkit/models/la_service_constants.dart';
import 'package:la_toolkit/models/la_service_deploy.dart';

void main() {
  test('migration prunes obsolete portainer service on load (fromJson)', () {
    final LAService portainerSvc = LAService(
      nameInt: 'portainer',
      iniPath: '',
      use: true,
      usesSubdomain: false,
      suburl: 'portainer',
      projectId: 'proj1',
    );
    final LAService collectorySvc = LAService(
      nameInt: collectory,
      iniPath: '',
      use: true,
      usesSubdomain: true,
      suburl: 'collectory',
      projectId: 'proj1',
    );

    final LAProject p = LAProject(
      longName: 'Test',
      shortName: 'Test',
      domain: 'test.org',
      servers: <LAServer>[
        LAServer(id: 'srv1', name: 'srv1', projectId: 'proj1'),
      ],
      services: <LAService>[portainerSvc, collectorySvc],
      serverServices: <String, List<String>>{
        'srv1': <String>['portainer', collectory],
      },
      serviceDeploys: <LAServiceDeploy>[
        LAServiceDeploy(
          serviceId: portainerSvc.id,
          serverId: 'srv1',
          clusterId: null,
          projectId: 'proj1',
        ),
      ],
    );

    // Round-trip through fromJson, which runs the migration.
    final LAProject migrated = LAProject.fromJson(p.toJson());

    final List<String> names =
        migrated.services.map((LAService s) => s.nameInt).toList();
    expect(names, isNot(contains('portainer')), reason: 'portainer pruned');
    expect(names, contains(collectory), reason: 'normal service kept');
    expect(
      migrated.serverServices['srv1'],
      isNot(contains('portainer')),
      reason: 'portainer removed from serverServices',
    );
    expect(migrated.serverServices['srv1'], contains(collectory));
    expect(
      migrated.serviceDeploys.any(
        (LAServiceDeploy d) => d.serviceId == portainerSvc.id,
      ),
      isFalse,
      reason: 'portainer serviceDeploy removed',
    );
  });
}
