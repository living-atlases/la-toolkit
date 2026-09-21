import 'package:flutter_test/flutter_test.dart';
import 'package:la_toolkit_core/models/deployment_type.dart';
import 'package:la_toolkit_core/models/la_cluster.dart';
import 'package:la_toolkit_core/models/la_project.dart';
import 'package:la_toolkit_core/models/la_server.dart';
import 'package:la_toolkit_core/models/la_service_deploy.dart';
import 'package:objectid/objectid.dart';

/// A data hub owns no docker infrastructure: it PLACES its services on the
/// portal's compose clusters (or on VMs of its own) and never copies the
/// portal's rows. [LAPlacement] is what resolves the portal's cluster and its
/// carrier for the hub; what is persisted is the hub's own serviceDeploys
/// referencing the portal's cluster id.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  LAProject buildComposePortal({List<String> hubCapable = const <String>[
    'ala_hub',
    'ala_bie',
    'regions',
    'branding',
  ]}) {
    final LAProject portal = LAProject(
      longName: 'Portal',
      shortName: 'portal',
      domain: 'l-a.site',
      alaInstallRelease: '1.0.0',
      generatorRelease: '1.0.0',
    );
    final LAServer server = LAServer(
      id: ObjectId().toString(),
      name: 'la-mh-1',
      ip: '10.0.0.1',
      projectId: portal.id,
    );
    portal.upsertServer(server);
    portal.serviceInUse('docker_compose', true);
    for (final String s in hubCapable) {
      portal.serviceInUse(s, true);
    }
    portal.assign(server, const <String>['docker_compose']);
    portal.assignByType(server.id, DeploymentType.dockerCompose, hubCapable);
    return portal;
  }

  LACluster composeClusterOf(LAProject portal) => portal.clusters.firstWhere(
        (LACluster c) => c.type == DeploymentType.dockerCompose,
      );

  // The toolkit no longer guesses a hub's placement (living-atlases/la-docker-compose#14
  // lifted the single-cluster/co-location constraints, and the user now picks
  // where each hub service runs exactly like on the portal itself). `suggest`
  // just gives most tests here a ready-made fixture: every hub-capable service
  // the hub uses, placed on the portal's one compose cluster.
  LAProject attachHub(
    LAProject portal, {
    bool species = true,
    bool regions = true,
    bool suggest = true,
  }) {
    final LAProject hub = LAProject(
      longName: 'Hub',
      shortName: 'hub',
      domain: 'records-hub.l-a.site',
      alaInstallRelease: '1.0.0',
      generatorRelease: '1.0.0',
      isHub: true,
      parent: portal,
    );
    hub.serviceInUse('ala_hub', true);
    hub.serviceInUse('branding', true);
    hub.serviceInUse('ala_bie', species);
    hub.serviceInUse('regions', regions);
    portal.hubs.add(hub);
    if (suggest && portal.isDockerComposeEnabled) {
      final List<String> toPlace = <String>[
        'ala_hub',
        'branding',
        if (species) 'ala_bie',
        if (regions) 'regions',
      ];
      hub.assignByType(
        composeClusterOf(portal).id,
        DeploymentType.dockerCompose,
        toPlace,
      );
    }
    return hub;
  }

  group('hub placed on the portal compose cluster', () {
    test('resolves the portal machine without owning anything', () {
      final LAProject portal = buildComposePortal();
      final LAProject hub = attachHub(portal);

      expect(hub.isDockerComposeEnabled, isTrue,
          reason: 'the mode is inherited from the parent');
      expect(hub.isDockerClusterConfigured(), isTrue);
      expect(hub.hasDockerComposeServices, isTrue);
      expect(hub.isPureDockerCompose, isTrue,
          reason: 'no VM-assigned services of its own');
      expect(hub.getHostnames('ala_hub'), equals(<String>['la-mh-1']));

      expect(hub.clusters, isEmpty, reason: "the cluster is the portal's");
      expect(hub.servers, isEmpty, reason: "the machine is the portal's");
      expect(hub.clusterServices.keys, equals(<String>[composeClusterOf(portal).id]));
      for (final LAServiceDeploy sd in hub.serviceDeploys) {
        expect(sd.projectId, hub.id);
        expect(sd.clusterId, composeClusterOf(portal).id);
        expect(sd.type, DeploymentType.dockerCompose);
      }
      expect(hub.placement.isBorrowed(composeClusterOf(portal)), isTrue);
    });

    test('only the services the hub actually uses are placed', () {
      final LAProject portal = buildComposePortal();
      final LAProject hub = attachHub(portal, species: false, regions: false);

      final List<String> assigned = hub.getServicesAssigned(true)..sort();
      expect(assigned, equals(<String>['ala_hub', 'branding']));
      expect(hub.getHostnames('ala_bie'), isEmpty);
    });

    test('assigning onto the portal cluster creates no cluster of its own', () {
      final LAProject portal = buildComposePortal();
      final LAProject hub = attachHub(portal, suggest: false);
      expect(hub.getServicesAssigned(), isEmpty);

      hub.assignByType(
        composeClusterOf(portal).id,
        DeploymentType.dockerCompose,
        <String>['ala_hub'],
      );

      expect(hub.clusters, isEmpty);
      expect(hub.servers, isEmpty);
      expect(hub.getHostnames('ala_hub'), equals(<String>['la-mh-1']));
      expect(hub.serviceDeploys.single.serverId, portal.servers.single.id);
    });

    test('the portal keeps its cluster when the hub steps off it', () {
      final LAProject portal = buildComposePortal();
      final LAProject hub = attachHub(portal);

      hub.deleteCluster(composeClusterOf(portal));

      expect(hub.getServicesAssigned(), isEmpty);
      expect(hub.serviceDeploys, isEmpty);
      expect(portal.clusters, hasLength(1));
      expect(portal.getServicesAssigned(true), contains('ala_hub'));
    });

    test('deleting the portal cluster unplaces the hubs on it', () {
      final LAProject portal = buildComposePortal();
      final LAProject hub = attachHub(portal);

      portal.deleteCluster(composeClusterOf(portal));

      expect(portal.clusters, isEmpty);
      expect(hub.clusterServices, isEmpty);
      expect(hub.serviceDeploys, isEmpty);
      expect(hub.validateDataIntegrity(), isEmpty);
    });

    test('a hub of a VM portal gets no compose placement', () {
      final LAProject portal = LAProject(
        longName: 'VM Portal',
        shortName: 'vmportal',
        domain: 'example.org',
        alaInstallRelease: '1.0.0',
        generatorRelease: '1.0.0',
      );
      final LAServer server = LAServer(
        id: ObjectId().toString(),
        name: 'vm-1',
        ip: '10.0.0.9',
        projectId: portal.id,
      );
      portal.upsertServer(server);
      portal.serviceInUse('ala_hub', true);
      portal.assign(server, const <String>['ala_hub']);

      final LAProject hub = attachHub(portal, species: false, regions: false);

      expect(hub.isDockerComposeEnabled, isFalse);
      expect(hub.getServicesAssigned(), isEmpty);
    });
  });

  group('hybrid hub', () {
    test('own VM for records, portal cluster for branding', () {
      final LAProject portal = buildComposePortal();
      final LAProject hub = attachHub(portal, species: false, regions: false, suggest: false);
      final LAServer hubVm = LAServer(
        id: ObjectId().toString(),
        name: 'hub-vm',
        ip: '10.0.0.50',
        projectId: hub.id,
      );
      hub.upsertServer(hubVm);
      hub.assign(hubVm, const <String>['ala_hub']);
      hub.assignByType(
        composeClusterOf(portal).id,
        DeploymentType.dockerCompose,
        <String>['branding'],
      );

      expect(hub.isHybrid, isTrue);
      expect(hub.serversWithServices().map((LAServer s) => s.name),
          equals(<String>['hub-vm']),
          reason: 'ownership never reaches the portal machines');
      expect(hub.getHostnames('ala_hub'), equals(<String>['hub-vm']));
      expect(hub.getHostnames('branding'), equals(<String>['la-mh-1']));

      final Map<String, dynamic> conf = hub.toGeneratorJson();
      expect(conf['LA_ala_hub_hostname'], 'hub-vm');
      expect(conf['LA_branding_hostname'], 'la-mh-1');
    });

    test('deleting the hub VM keeps the compose placement', () {
      final LAProject portal = buildComposePortal();
      final LAProject hub = attachHub(portal, species: false, regions: false, suggest: false);
      final LAServer hubVm = LAServer(
        id: ObjectId().toString(),
        name: 'hub-vm',
        ip: '10.0.0.50',
        projectId: hub.id,
      );
      hub.upsertServer(hubVm);
      hub.assign(hubVm, const <String>['ala_hub']);
      hub.assignByType(
        composeClusterOf(portal).id,
        DeploymentType.dockerCompose,
        <String>['branding'],
      );

      hub.delete(hubVm);

      expect(hub.getHostnames('branding'), equals(<String>['la-mh-1']));
      expect(hub.getServicesAssigned(true), equals(<String>['branding']));
    });
  });

  group('persistence', () {
    test('the hub payload references the portal cluster and carries no copy', () {
      final LAProject portal = buildComposePortal();
      final LAProject hub = attachHub(portal);

      final Map<String, dynamic> json = hub.toJson();
      expect(json['clusters'], isEmpty);
      expect(json['servers'], isEmpty);
      final List<dynamic> deploys = json['serviceDeploys'] as List<dynamic>;
      expect(deploys, isNotEmpty);
      for (final dynamic d in deploys) {
        expect((d as Map<String, dynamic>)['clusterId'], composeClusterOf(portal).id);
        expect(d['projectId'], hub.id);
      }
    });

    test('survives a toJson/fromJson round trip of the portal', () {
      final LAProject portal = buildComposePortal();
      attachHub(portal);

      final LAProject restored = LAProject.fromJson(portal.toJson());
      expect(restored.hubs, hasLength(1));
      final LAProject restoredHub = restored.hubs.first;
      expect(restoredHub.parent, isNotNull);
      expect(restoredHub.isDockerComposeEnabled, isTrue);
      expect(restoredHub.getHostnames('ala_hub'), equals(<String>['la-mh-1']));
      expect(restoredHub.clusters, isEmpty);
      expect(restored.clusters, hasLength(1));
    });

    test('survives the backend dropping clusterServices', () {
      // populate-project rebuilds clusterServices from the ServiceDeploy rows;
      // an older backend that only bucketed the project's OWN clusters sends
      // a hub back with none, so the client rebuilds them from the deploys.
      final LAProject portal = buildComposePortal();
      attachHub(portal);
      final Map<String, dynamic> json = portal.toJson();
      final Map<String, dynamic> hubJson =
          (json['hubs'] as List<dynamic>).first as Map<String, dynamic>;
      hubJson['clusterServices'] = <String, List<String>>{};

      final LAProject restored = LAProject.fromJson(json);
      expect(restored.hubs.first.getHostnames('ala_hub'), equals(<String>['la-mh-1']));
    });

    test('duplicating the portal re-points the hub at the clone cluster', () {
      final LAProject portal = buildComposePortal();
      attachHub(portal);

      final LAProject clone = LAProject.duplicate(
        portal,
        newShortName: 'portal2',
        newLongName: 'Portal 2',
        newDomain: 'l-a2.site',
        newDirName: 'portal2',
      );
      final LAProject cloneHub = clone.hubs.single;
      final String cloneClusterId = composeClusterOf(clone).id;
      expect(cloneClusterId, isNot(composeClusterOf(portal).id));
      expect(cloneHub.clusterServices.keys, equals(<String>[cloneClusterId]));
      for (final LAServiceDeploy sd in cloneHub.serviceDeploys) {
        expect(sd.clusterId, cloneClusterId);
        expect(sd.serverId, clone.servers.single.id);
      }
      expect(cloneHub.servers, isEmpty);
      expect(cloneHub.getHostnames('ala_hub'), equals(<String>['la-mh-1-portal2']));
    });
  });

  group('hub generator json carries the portal docker facts', () {
    test('a hub of a compose portal is generated as compose', () {
      final LAProject portal = buildComposePortal();
      final LAProject hub = attachHub(portal);

      final Map<String, dynamic> hubConf = hub.toGeneratorJson();
      expect(hubConf['LA_use_docker_compose'], isTrue);
      expect(
        hubConf['LA_docker_compose_hostname'],
        equals(portal.toGeneratorJson()['LA_docker_compose_hostname']),
      );
      expect(hubConf['LA_ala_hub_hostname'], equals('la-mh-1'));
    });

    test('the hub hostnames become nginx aliases, not extra hosts', () {
      final LAProject portal = buildComposePortal();
      final LAProject hub = attachHub(portal);
      hub.getService('ala_hub').iniPath = 'records';

      final Map<String, dynamic> conf = portal.toGeneratorJson();
      final Map<String, dynamic> aliases =
          conf['LA_nginx_docker_internal_aliases_by_host']
              as Map<String, dynamic>;
      final List<String> forHost =
          (aliases['la-mh-1'] as List<dynamic>).cast<String>();
      expect(
        forHost,
        contains(hub.getService('ala_hub').url(hub.domain)),
        reason:
            'else the hub JVM resolves its own hostname through public DNS from '
            'inside the stack',
      );
    });
  });

  group('la-docker-compose placement constraints (living-atlases/la-docker-compose#14)', () {
    test('a hub on the portal records cluster passes', () {
      final LAProject portal = buildComposePortal();
      final LAProject hub = attachHub(portal);
      expect(hub.hubComposePlacementErrors(), isEmpty);
    });

    test("a hub spread over two of the portal's clusters is fine", () {
      final LAProject portal = buildComposePortal();
      final LAServer second = LAServer(
        id: ObjectId().toString(),
        name: 'la-mh-2',
        ip: '10.0.0.2',
        projectId: portal.id,
      );
      portal.upsertServer(second);
      portal.assign(second, const <String>['docker_compose']);
      portal.assignByType(second.id, DeploymentType.dockerCompose, const <String>['ala_bie']);
      final LAProject hub = attachHub(portal);
      final LACluster secondCluster = portal.clusters.firstWhere(
        (LACluster c) => c.serverId == second.id,
      );
      hub.unAssignByType(composeClusterOf(portal).id, DeploymentType.dockerCompose, 'ala_bie');
      hub.assignByType(secondCluster.id, DeploymentType.dockerCompose, <String>['ala_bie']);

      expect(hub.hubComposePlacementErrors(), isEmpty);
      expect(hub.getHostnames('ala_bie'), equals(<String>['la-mh-2']));
      expect(hub.getHostnames('ala_hub'), equals(<String>['la-mh-1']));
    });

    test('a hub service on a cluster with no portal copy of it is fine', () {
      // Each hub alias is now resolved independently (setup-facts.yml's
      // hub_alias_hosts), so a hub service no longer needs the portal's own
      // copy of it on the same host.
      final LAProject portal = buildComposePortal(hubCapable: <String>['ala_hub', 'branding']);
      portal.serviceInUse('ala_bie', true);
      final LAProject hub = attachHub(portal, regions: false, suggest: false);
      hub.assignByType(
        composeClusterOf(portal).id,
        DeploymentType.dockerCompose,
        const <String>['ala_hub', 'branding', 'ala_bie'],
      );

      expect(hub.hubComposePlacementErrors(), isEmpty);
    });

    test('a hub placed on a cluster the portal no longer has is flagged', () {
      final LAProject portal = buildComposePortal();
      final LAProject hub = attachHub(portal);
      final LACluster cluster = composeClusterOf(portal);
      final String staleClusterId = cluster.id;

      portal.deleteCluster(cluster);
      // Simulate a desynced client still holding the stale reference.
      hub.clusterServices[staleClusterId] = <String>['ala_hub'];

      final List<String> errors = hub.hubComposePlacementErrors();
      expect(errors, isNotEmpty);
      expect(errors.single, contains('no longer has'));
    });

    test('a hub on VMs only has nothing to check', () {
      final LAProject portal = buildComposePortal();
      final LAProject hub = attachHub(portal, suggest: false);
      expect(hub.hubComposePlacementErrors(), isEmpty);
    });
  });
}
