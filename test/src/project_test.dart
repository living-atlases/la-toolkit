import 'package:collection/collection.dart';
import 'package:la_toolkit/models/laLatLng.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/laProjectStatus.dart';
import 'package:la_toolkit/models/laServer.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:la_toolkit/models/sshKey.dart';
import 'package:latlong2/latlong.dart';
import 'package:test/test.dart';

void main() {
  final lists = LAServiceName.species_lists.toS();
  final collectory = LAServiceName.collectory.toS();
  final bie = LAServiceName.ala_bie.toS();
  final bieIndex = LAServiceName.bie_index.toS();
  final alaHub = LAServiceName.ala_hub.toS();
  final biocacheService = LAServiceName.biocache_service.toS();
  final alerts = LAServiceName.alerts.toS();
  final images = LAServiceName.images.toS();
  final solr = LAServiceName.solr.toS();
  final webapi = LAServiceName.webapi.toS();
  final regions = LAServiceName.regions.toS();
  final spatial = LAServiceName.spatial.toS();
  final cas = LAServiceName.cas.toS();
  // final dashboard = LAServiceName.dashboard.toS();
  final doi = LAServiceName.doi.toS();

  test('Test step 0 of creation, longname', () {
    LAProject testProject = LAProject(longName: "");
    expect(testProject.isCreated, equals(false));
    expect(testProject.status, equals(LAProjectStatus.created));
  });

  test('Test step 0 of creation, shortname', () {
    LAProject testProject =
        LAProject(longName: "Living Atlas of Wakanda", shortName: "");
    expect(testProject.isCreated, equals(false));
    expect(testProject.status, equals(LAProjectStatus.created));
  });

  test('Test step 0 of creation, invalid domain', () {
    LAProject testProject = LAProject(
        longName: "Living Atlas of Wakanda", shortName: "kk", domain: "kk");
    expect(testProject.isCreated, equals(false));
    expect(testProject.status, equals(LAProjectStatus.created));
  });

  test('Test step 0 of creation, valid domain, valid step 1', () {
    LAProject testProject = LAProject(
        longName: "Living Atlas of Wakanda",
        shortName: "LAW",
        domain: "l-a.site",
        alaInstallRelease: "",
        generatorRelease: "");
    expect(testProject.validateCreation(), equals(false));
    expect(testProject.isCreated, equals(false));
    expect(testProject.status, equals(LAProjectStatus.basicDefined));
  });

  test('Test step 1 of creation, valid server', () {
    LAProject testProject = LAProject(
        longName: "Living Atlas of Wakanda",
        shortName: "LAW",
        domain: "l-a.site",
        alaInstallRelease: "",
        generatorRelease: "");
    testProject.upsertByName(LAServer(name: "vm1"));
    expect(testProject.isCreated, equals(false));
    expect(testProject.numServers(), equals(1));
    expect(testProject.validateCreation(), equals(false));
    expect(testProject.status, equals(LAProjectStatus.basicDefined));
  });

  test('Test step 1 of creation, valid servers', () {
    LAProject testProject = LAProject(
        longName: "Living Atlas of Wakanda",
        shortName: "LAW",
        domain: "l-a.site",
        alaInstallRelease: "",
        generatorRelease: "");
    testProject.upsertByName(LAServer(name: "vm1"));
    testProject.upsertByName(LAServer(name: "vm2", ip: "10.0.0.1"));
    testProject.upsertByName(LAServer(name: "vm2", ip: "10.0.0.2"));
    expect(testProject.isCreated, equals(false));
    expect(testProject.numServers(), equals(2));
    expect(testProject.validateCreation(), equals(false));
    expect(
        testProject.servers.where((element) => element.name == "vm2").first.ip,
        equals("10.0.0.2"));
    expect(testProject.status, equals(LAProjectStatus.basicDefined));
  });

  test('Servers equals', () {
    LAServer vm1 = LAServer(name: 'vm2', ip: '10.0.0.1');
    LAServer vm1bis = vm1.copyWith(ip: '10.0.0.1');
    expect(vm1 == vm1bis, equals(true));
  });

  test('Servers not equals', () {
    LAServer vm1 = LAServer(name: 'vm1');
    LAServer vm1bis = LAServer(name: 'vm2');
    expect(vm1 == vm1bis, equals(false));
    vm1 = LAServer(name: 'vm1');
    vm1bis = LAServer(name: 'vm1', aliases: ['collections']);
    var vm1bisBis = LAServer(name: 'vm1', sshPort: 22001);
    expect(vm1 == vm1bis, equals(false));
    expect(vm1 == vm1bisBis, equals(false));
  });

  test('Test step 1 of creation, valid servers-service assignment and equality',
      () {
    LAProject testProject = LAProject(
        id: "0",
        longName: "Living Atlas of Wakanda",
        shortName: "LAW",
        domain: "l-a.site",
        alaInstallRelease: "",
        generatorRelease: "");
    LAProject testProjectOther = LAProject(
        id: "0",
        longName: "Living Atlas of Wakanda",
        shortName: "LAW",
        domain: "l-a.site",
        alaInstallRelease: "",
        generatorRelease: "");

    expect(
        MapEquality()
            .equals(testProject.servicesMap, testProjectOther.servicesMap),
        equals(true));
    expect(
        MapEquality().equals(testProject.getServerServicesForTest(),
            testProjectOther.getServerServicesForTest()),
        equals(true));
    expect(
        testProject.mapBoundsFstPoint == testProjectOther.mapBoundsFstPoint &&
            testProject.mapBoundsSndPoint == testProjectOther.mapBoundsSndPoint,
        equals(true));
    expect(ListEquality().equals(testProject.servers, testProjectOther.servers),
        equals(true));
    expect(
        ListEquality()
            .equals(testProject.variables, testProjectOther.variables),
        equals(true));
    expect(testProject.hashCode == testProjectOther.hashCode, equals(true));
    expect(testProject == testProjectOther, equals(true));
    LAServer vm1 = LAServer(name: "vm1", ip: "10.0.0.1");
    LAServer vm2 = LAServer(name: "vm2", ip: "10.0.0.2");
    LAServer vm3 = LAServer(name: "vm3", ip: "10.0.0.3");
    LAServer vm4 = LAServer(name: "vm4", ip: "10.0.0.4");
    LAProject testProjectCopy =
        testProject.copyWith(servers: [], serverServices: {});
    testProject.upsertByName(vm1);
    testProjectCopy.upsertByName(vm1);
    expect(testProject.getServerServicesForTest().length, equals(1));
    expect(testProject.servers.length, equals(1));
    expect(testProjectCopy.getServerServicesForTest().length, equals(1));
    expect(testProjectCopy.servers.length, equals(1));
    expect(
        MapEquality()
            .equals(testProject.servicesMap, testProjectCopy.servicesMap),
        equals(true));
    expect(
        DeepCollectionEquality.unordered().equals(
            testProject.getServerServicesForTest(),
            testProjectCopy.getServerServicesForTest()),
        equals(true));
    expect(testProject == testProjectCopy, equals(true));
    expect(testProject.servers, equals(testProjectCopy.servers));

    testProject.upsertByName(vm2);
    expect(testProjectCopy.servers.length, equals(1));

    expect(testProject.getServerServicesForTest().length, equals(2));
    expect(testProject.servers == testProjectCopy.servers, equals(false));
    expect(testProjectCopy.getServerServicesForTest().length, equals(1));
    expect(
        MapEquality().equals(testProject.getServerServicesForTest(),
            testProjectCopy.getServerServicesForTest()),
        equals(false));
    expect(
        testProject.mapBoundsFstPoint == testProjectCopy.mapBoundsFstPoint &&
            testProject.mapBoundsSndPoint == testProjectCopy.mapBoundsSndPoint,
        equals(true));
    expect(ListEquality().equals(testProject.servers, testProjectCopy.servers),
        equals(false));
    expect(testProject.hashCode == testProjectCopy.hashCode, equals(false));
    expect(testProject == testProjectCopy, equals(false));
    testProjectCopy.upsertByName(vm2);
    expect(testProject == testProjectCopy, equals(true));
    expect(testProject.servers, equals(testProjectCopy.servers));
    testProject.upsertByName(vm3);
    testProject.upsertByName(vm4);
    expect(testProject == testProjectCopy, equals(false));
    testProject.assign(vm1, [LAServiceName.collectory.toS()]);
    expect(testProject == testProjectCopy, equals(false));

    expect(
        testProject
            .getServicesNameListInUse()
            .contains(LAServiceName.collectory.toS()),
        equals(true));
    expect(
        testProject.getHostname(LAServiceName.collectory.toS())[0] == vm1.name,
        equals(true));
    /* print(testProject);
    print(testProject.servers);
    print(testProject.services);
    print(testProject.getServiceE(LAServiceName.collectory)); */

    expect(testProject.getHostname(LAServiceName.regions.toS()).length == 0,
        equals(true));

    testProject
        .assign(vm1, [alaHub, regions, bie, LAServiceName.branding.toS()]);

    testProject.assign(vm2, [collectory, bieIndex, biocacheService]);

    testProject.assign(
        vm3, [LAServiceName.solr.toS(), LAServiceName.logger.toS(), lists]);

    testProject.assign(vm4, [
      LAServiceName.spatial.toS(),
      LAServiceName.cas.toS(),
      LAServiceName.images.toS(),
      LAServiceName.biocache_backend.toS(),
      LAServiceName.biocache_cli.toS(),
      LAServiceName.nameindexer.toS()
    ]);

    expect(
        testProject
            .getServicesNameListInUse()
            .contains(LAServiceName.collectory.toS()),
        equals(true));
    expect(
        testProject.getHostname(LAServiceName.collectory.toS())[0] == vm2.name,
        equals(true));
    expect(
        testProject.getHostname(LAServiceName.collectory.toS())[0] == vm1.name,
        equals(false));
    expect(testProject.isCreated, equals(false));
    expect(testProject.numServers(), equals(4));
    // no ssh keys
    expect(testProject.validateCreation(debug: true), equals(false));
    vm1.sshKey = SshKey(name: "k1", desc: "", encrypted: false);
    vm2.sshKey = SshKey(name: "k2", desc: "", encrypted: false);
    vm3.sshKey = SshKey(name: "k3", desc: "", encrypted: false);
    vm4.sshKey = SshKey(name: "k4", desc: "", encrypted: false);
    expect(testProject.getServicesNameListInUse().length > 0, equals(true));

    print(testProject.getServicesNameListInUse().length);
    print(testProject.getServicesNameListSelected().length);
    expect(
        testProject.getServicesNameListInUse().length ==
            testProject.getServicesNameListSelected().length,
        equals(true));
    testProject.getServicesNameListInUse().forEach((service) {
      expect(testProject.getHostname(service).isNotEmpty, equals(true));
    });
    expect(testProject.validateCreation(debug: true), equals(true));
    expect(
        testProject.servers.where((element) => element.name == "vm2").first.ip,
        equals("10.0.0.2"));
/*    print(testProject); */
    expect(testProject.getServersNameList().length, equals(4));
    expect(testProject.status, equals(LAProjectStatus.advancedDefined));
    // testProject.delete(vm1);
  });

  test('Test lat/lng center', () {
    LAProject p = LAProject(
        mapBoundsFstPoint: LALatLng.from(10.0, 10.0),
        mapBoundsSndPoint: LALatLng.from(20.0, 20.0));
    expect(p.getCenter(), equals(LatLng(15, 15)));
    p.mapBoundsFstPoint = LALatLng.from(20, 20);
    p.mapBoundsSndPoint = LALatLng.from(40, 40);
    p.setMap(LatLng(20, 20), LatLng(40, 40), 10);
    expect(p.getCenter(), equals(LatLng(30, 30)));
    expect(p.mapZoom, equals(10));
  });

  test('Test default services', () {
    var p = LAProject();

    expect(p.getServiceE(LAServiceName.collectory).use, equals(true));
    expect(p.getServiceE(LAServiceName.ala_hub).use, equals(true));
    expect(p.getServiceE(LAServiceName.biocache_service).use, equals(true));
    expect(p.getServiceE(LAServiceName.biocache_backend).use, equals(true));
    expect(p.getServiceE(LAServiceName.solr).use, equals(true));
    expect(p.getServiceE(LAServiceName.logger).use, equals(true));
  });

  test('Test disable of services', () {
    var p = LAProject();
    p.domain = "l-a.site";
    p.serviceInUse(bie, true);
    p.serviceInUse(lists, true);
    expect(p.getService(bie).use, equals(true));
    expect(p.getService(lists).use, equals(true));
    var pBis = p.copyWith();

    expect(p == pBis, equals(true));
    LAServer vm1 = LAServer(name: "vm1");
    p.upsertByName(vm1);
    p.assign(vm1, [collectory, bie, bieIndex, lists]);
    LAServer vm1Bis =
        LAServer(name: "vm1", ip: "10.0.0.1", sshUser: "john", sshPort: 22001);
    expect(p.getServerServices(serverId: vm1.id).contains(collectory),
        equals(true));
    p.upsertByName(vm1Bis);

    expect(p.getServerServices(serverId: vm1.id).contains(collectory),
        equals(true));
    expect(p.getServerServices(serverId: vm1.id).contains(bie), equals(true));
    expect(p.getServerServices(serverId: vm1.id).contains(lists), equals(true));
    var vm1Updated =
        p.servers.where((element) => element.id == vm1.id).toList()[0];
    expect(vm1Updated.sshUser == "john" && vm1Updated.sshPort == 22001,
        equals(true));
    p.serviceInUse(bie, false);
    expect(p.getService(bie).use, equals(false));
    expect(p.getService(bieIndex).use, equals(false));
    expect(p.getService(lists).use, equals(false));
    expect(p.getServerServices(serverId: vm1.id).contains(collectory),
        equals(true));
    expect(p.getServerServices(serverId: vm1.id).contains(bie), equals(false));
    expect(p.getServerServices(serverId: vm1.id).contains(bieIndex),
        equals(false));
    expect(
        p.getServerServices(serverId: vm1.id).contains(lists), equals(false));
    p.serviceInUse(bie, true);
    expect(p.getService(bie).use, equals(true));
    expect(p.getService(bieIndex).use, equals(true));
    expect(p.allServicesAssignedToServers(), equals(false));
    p.assign(vm1, [bie]);
    expect(p.allServicesAssignedToServers(), equals(false));
    p.getServicesNameListInUse().contains(bie);
    p.getServicesNameListInUse().contains(bieIndex);
    expect(p.getServicesNameListSelected().contains(bie), equals(true));
    expect(p.getServicesNameListSelected().contains(bieIndex), equals(false));
    p.assign(vm1, [bie, bieIndex]);
    expect(p.getServicesNameListSelected().contains(bie), equals(true));
    expect(p.getServicesNameListSelected().contains(bieIndex), equals(true));
    expect(p.getHostname(bieIndex), equals(['vm1']));
    expect(p.getHostname(bie), equals(['vm1']));
    p.getService(bie).iniPath = "/species";
    expect(p.etcHostsVar,
        equals('      10.0.0.1 species.l-a.site species-ws.l-a.site'));
  });

  test('Import yo-rc.json', () {
    var yoRcJson = '''
{
  "generator-living-atlas": {
    "promptValues": {
      "LA_project_name": "Portal de Datos de GBIF.ES",
      "LA_project_shortname": "GBIF.ES",
      "LA_pkg_name": "gbif-es",
      "LA_domain": "gbif.es",
      "LA_use_spatial": true,
      "LA_use_regions": true,
      "LA_use_species_lists": true,
      "LA_use_CAS": true,
      "LA_enable_ssl": true,
      "LA_cas_hostname": "auth.gbif.es",
      "LA_spatial_hostname": "espacial.gbif.es",
      "LA_collectory_uses_subdomain": true,
      "LA_collectory_hostname": "colecciones.gbif.es",
      "LA_collectory_url": "colecciones.gbif.es",
      "LA_collectory_path": "/",
      "LA_ala_hub_uses_subdomain": true,
      "LA_ala_hub_hostname": "registros.gbif.es",
      "LA_ala_hub_url": "registros.gbif.es",
      "LA_ala_hub_path": "/",
      "LA_biocache_service_uses_subdomain": true,
      "LA_biocache_service_hostname": "registros-ws.gbif.es",
      "LA_biocache_service_url": "registros-ws.gbif.es",
      "LA_biocache_service_path": "/",
      "LA_ala_bie_uses_subdomain": true,
      "LA_ala_bie_hostname": "especies.gbif.es",
      "LA_ala_bie_url": "especies.gbif.es",
      "LA_ala_bie_path": "/",
      "LA_bie_index_uses_subdomain": true,
      "LA_bie_index_hostname": "especies-ws.gbif.es",
      "LA_bie_index_url": "especies-ws.gbif.es",
      "LA_bie_index_path": "/",
      "LA_images_uses_subdomain": true,
      "LA_images_hostname": "imagenes.gbif.es",
      "LA_images_url": "imagenes.gbif.es",
      "LA_images_path": "/",
      "LA_lists_uses_subdomain": true,
      "LA_lists_hostname": "listas.gbif.es",
      "LA_lists_url": "listas.gbif.es",
      "LA_lists_path": "/",
      "LA_regions_uses_subdomain": true,
      "LA_regions_hostname": "regiones.gbif.es",
      "LA_regions_url": "regiones.gbif.es",
      "LA_regions_path": "/",
      "LA_logger_uses_subdomain": true,
      "LA_logger_hostname": "logger.gbif.es",
      "LA_logger_url": "logger.gbif.es",
      "LA_logger_path": "/",
      "LA_solr_uses_subdomain": true,
      "LA_solr_hostname": "index.gbif.es",
      "LA_solr_url": "index.gbif.es",
      "LA_solr_path": "/",
      "LA_biocache_backend_hostname": "biocache-store-0.gbif.es",
      "LA_use_git": true,
      "check-ssl": "",
      "LA_use_webapi": true,
      "LA_webapi_uses_subdomain": true,
      "LA_webapi_hostname": "api.gbif.es",
      "LA_webapi_url": "api.gbif.es",
      "LA_webapi_path": "/",
      "LA_use_dashboard": true,
      "LA_dashboard_uses_subdomain": true,
      "LA_dashboard_hostname": "dashboard.gbif.es",
      "LA_dashboard_path": "/",
      "LA_use_alerts": true,
      "LA_use_doi": true,
      "LA_alerts_uses_subdomain": true,
      "LA_alerts_hostname": "alertas.gbif.es",
      "LA_alerts_path": "/",
      "LA_doi_uses_subdomain": true,
      "LA_doi_hostname": "doi.gbif.es",
      "LA_doi_path": "/"
    },
    "firstRun": false
  }
}
''';
    var yoRcJsonCa = '''
{
  "generator-living-atlas": {
    "promptValues": {
      "LA_project_name": "Canadensys",
      "LA_project_shortname": "Canadensys",
      "LA_pkg_name": "canadensys",
      "LA_domain": "canadensys.net",
      "LA_use_species": false,
      "LA_use_spatial": true,
      "LA_use_regions": false,
      "LA_use_species_lists": false,
      "LA_use_CAS": true,
      "LA_use_images": true,
      "LA_use_alerts": true,
      "LA_use_doi": false,
      "LA_use_webapi": false,
      "LA_use_dashboard": true,
      "LA_enable_ssl": true,
      "LA_use_git": true,
      "LA_generate_branding": true,
      "LA_cas_hostname": "vm-029",
      "LA_cas_url": "auth.canadensys.net",
      "LA_spatial_hostname": "vm-022",
      "LA_spatial_url": "spatial.canadensys.net",
      "LA_collectory_uses_subdomain": true,
      "LA_collectory_hostname": "vm-027",
      "LA_collectory_url": "data.canadensys.net",
      "LA_collectory_path": "/collections",
      "LA_ala_hub_uses_subdomain": true,
      "LA_ala_hub_hostname": "vm-014",
      "LA_ala_hub_url": "data.canadensys.net",
      "LA_ala_hub_path": "/explorer",
      "LA_biocache_service_uses_subdomain": true,
      "LA_biocache_service_hostname": "vm-023",
      "LA_biocache_service_url": "data.canadensys.net",
      "LA_biocache_service_path": "/explorer-ws",
      "LA_ala_bie_uses_subdomain": true,
      "LA_ala_bie_hostname": "vm-000",
      "LA_ala_bie_url": "species.canadensys.net",
      "LA_ala_bie_path": "/",
      "LA_bie_index_uses_subdomain": true,
      "LA_bie_index_hostname": "vm-000",
      "LA_bie_index_url": "species-ws.canadensys.net",
      "LA_bie_index_path": "/",
      "LA_images_uses_subdomain": true,
      "LA_images_hostname": "vm-013",
      "LA_images_url": "data.canadensys.net",
      "LA_images_path": "/images",
      "LA_lists_uses_subdomain": true,
      "LA_lists_hostname": "vm-000",
      "LA_lists_url": "lists.canadensys.net",
      "LA_lists_path": "/",
      "LA_regions_uses_subdomain": true,
      "LA_regions_hostname": "vm-000",
      "LA_regions_url": "regions.canadensys.net",
      "LA_regions_path": "/",
      "LA_logger_uses_subdomain": true,
      "LA_logger_hostname": "vm-007",
      "LA_logger_url": "logger.canadensys.net",
      "LA_logger_path": "/",
      "LA_solr_uses_subdomain": true,
      "LA_solr_hostname": "vm-021",
      "LA_solr_url": "index.canadensys.net",
      "LA_solr_path": "/",
      "LA_biocache_backend_hostname": "vm-018",
      "LA_main_hostname": "vm-004",
      "LA_webapi_uses_subdomain": true,
      "LA_webapi_hostname": "",
      "LA_webapi_url": "",
      "LA_webapi_path": "",
      "LA_dashboard_uses_subdomain": true,
      "LA_dashboard_hostname": "vm-025",
      "LA_dashboard_path": "/",
      "LA_dashboard_url": "dashboard.canadensys.net",
      "LA_alerts_uses_subdomain": true,
      "LA_alerts_hostname": "vm-006",
      "LA_alerts_path": "/alerts",
      "LA_alerts_url": "data.canadensys.net",
      "LA_doi_uses_subdomain": true,
      "LA_doi_hostname": "vm-000",
      "LA_doi_path": "/",
      "LA_doi_url": "doi.canadensys.net"
    },
    "firstRun": false
  }
}
''';
    var yoRcJsonAt = '''
{
  "generator-living-atlas": {
    "promptValues": {
      "LA_project_name": "Biodiversitäts-Atlas Österreich",
      "LA_project_shortname": "Biodiversitäts-Atlas Österreich",
      "LA_pkg_name": "biodiversitts-atlassterreich",
      "LA_domain": "biodiversityatlas.at",
      "LA_use_species": true,
      "LA_use_spatial": true,
      "LA_use_regions": true,
      "LA_use_species_lists": true,
      "LA_use_CAS": true,
      "LA_use_images": true,
      "LA_use_alerts": false,
      "LA_use_doi": false,
      "LA_use_webapi": false,
      "LA_use_dashboard": false,
      "LA_enable_ssl": true,
      "LA_use_git": true,
      "LA_generate_branding": true,
      "LA_cas_hostname": "spatial.biodiversityatlas.at",
      "LA_cas_url": "auth.biodiversityatlas.at",
      "LA_spatial_hostname": "spatial.biodiversityatlas.at",
      "LA_spatial_url": "spatial.biodiversityatlas.at",
      "LA_collectory_uses_subdomain": true,
      "LA_collectory_hostname": "core.biodiversityatlas.at",
      "LA_collectory_url": "collectory.biodiversityatlas.at",
      "LA_collectory_path": "/",
      "LA_ala_hub_uses_subdomain": true,
      "LA_ala_hub_hostname": "core.biodiversityatlas.at",
      "LA_ala_hub_url": "biocache.biodiversityatlas.at",
      "LA_ala_hub_path": "/",
      "LA_biocache_service_uses_subdomain": true,
      "LA_biocache_service_hostname": "core.biodiversityatlas.at",
      "LA_biocache_service_url": "biocache-ws.biodiversityatlas.at",
      "LA_biocache_service_path": "/",
      "LA_ala_bie_uses_subdomain": true,
      "LA_ala_bie_hostname": "core.biodiversityatlas.at",
      "LA_ala_bie_url": "bie.biodiversityatlas.at",
      "LA_ala_bie_path": "/",
      "LA_bie_index_uses_subdomain": true,
      "LA_bie_index_hostname": "core.biodiversityatlas.at",
      "LA_bie_index_url": "bie-ws.biodiversityatlas.at",
      "LA_bie_index_path": "/",
      "LA_images_uses_subdomain": true,
      "LA_images_hostname": "core.biodiversityatlas.at",
      "LA_images_url": "images.biodiversityatlas.at",
      "LA_images_path": "/",
      "LA_lists_uses_subdomain": true,
      "LA_lists_hostname": "core.biodiversityatlas.at",
      "LA_lists_url": "lists.biodiversityatlas.at",
      "LA_lists_path": "/",
      "LA_regions_uses_subdomain": true,
      "LA_regions_hostname": "core.biodiversityatlas.at",
      "LA_regions_url": "regions.biodiversityatlas.at",
      "LA_regions_path": "/",
      "LA_logger_uses_subdomain": true,
      "LA_logger_hostname": "core.biodiversityatlas.at",
      "LA_logger_url": "logger.biodiversityatlas.at",
      "LA_logger_path": "/",
      "LA_solr_uses_subdomain": true,
      "LA_solr_hostname": "core.biodiversityatlas.at",
      "LA_solr_url": "solr.biodiversityatlas.at",
      "LA_solr_path": "/",
      "LA_biocache_backend_hostname": "core.biodiversityatlas.at",
      "LA_main_hostname": "core.biodiversityatlas.at",
      "LA_webapi_uses_subdomain": true,
      "LA_webapi_hostname": "",
      "LA_webapi_url": "",
      "LA_webapi_path": "",
      "LA_dashboard_uses_subdomain": true,
      "LA_dashboard_hostname": "core.biodiversityatlas.at",
      "LA_dashboard_path": "/",
      "LA_dashboard_url": "dashboard.biodiversityatlas.at",
      "LA_alerts_uses_subdomain": true,
      "LA_alerts_hostname": "core.biodiversityatlas.at",
      "LA_alerts_path": "/",
      "LA_alerts_url": "alerts.biodiversityatlas.at",
      "LA_doi_uses_subdomain": true,
      "LA_doi_hostname": "core.biodiversityatlas.at",
      "LA_doi_path": "/",
      "LA_doi_url": "doi.biodiversityatlas.at"
    },
    "firstRun": false
  }
}    
''';
    var p = new LAProject.import(yoRcJson: yoRcJson);
    expect(p.longName, equals('Portal de Datos de GBIF.ES'));
    expect(p.shortName, equals('GBIF.ES'));
    expect(p.domain, equals('gbif.es'));
    expect(p.useSSL, equals(true));
    LAServiceDesc.list.forEach((service) {
      // print("${service.nameInt}");
      expect(p.getService(service.nameInt).use, equals(true));
      if (!service.withoutUrl) {
        expect(p.getService(service.nameInt).usesSubdomain, equals(true));
        expect(p.getService(service.nameInt).iniPath, equals(''));
        expect(p.getService(service.nameInt).suburl.contains('gbif.es'),
            equals(false));
      }
    });
    expect(p.getService(collectory).suburl, equals('colecciones'));
    expect(p.getService(bie).suburl, equals('especies'));
    expect(p.getService(spatial).suburl, equals('espacial'));
    expect(p.getService(cas).suburl, equals('auth'));
    expect(p.getService(lists).suburl, equals('listas'));
    expect(p.getService(solr).fullUrl(p.useSSL, p.domain),
        equals('https://index.gbif.es'));

    p = new LAProject.import(yoRcJson: yoRcJsonCa);
    expect(p.longName, equals('Canadensys'));
    expect(p.shortName, equals('Canadensys'));
    expect(p.domain, equals('canadensys.net'));
    expect(p.useSSL, equals(true));
    LAServiceDesc.list.forEach((service) {
      // print("${service.nameInt}");
      if (![lists, webapi, doi, bie, regions].contains(service.nameInt))
        expect(p.getService(service.nameInt).use, equals(true));
      if (!service.withoutUrl) {
        expect(p.getService(service.nameInt).usesSubdomain, equals(true));
        if (![collectory, alaHub, biocacheService, alerts, images]
            .contains(service.nameInt))
          expect(p.getService(service.nameInt).iniPath, equals(''));
      }
    });

    expect(p.getService(doi).use, equals(false));
    expect(p.getService(collectory).iniPath, equals('collections'));
    expect(p.getService(alaHub).iniPath, equals('explorer'));
    expect(p.getService(biocacheService).iniPath, equals('explorer-ws'));
    expect(p.getService(images).iniPath, equals('images'));

    expect(p.getService(collectory).suburl, equals('data'));
    expect(p.getService(alaHub).suburl, equals('data'));
    expect(p.getService(biocacheService).suburl, equals('data'));
    expect(p.getService(images).suburl, equals('data'));
    expect(p.getService(spatial).suburl, equals('spatial'));
    expect(p.getService(cas).suburl, equals('auth'));

    expect(p.getServerServicesForTest().keys.contains("vm-013"), equals(false));
    expect(p.getHostname(images), equals(["vm-013"]));
    expect(p.getHostname(regions), equals([]));
    // Missing branding url etc

    p = new LAProject.import(yoRcJson: yoRcJsonAt);
    expect(p.getService(doi).use, equals(false));
    expect(p.getService(alerts).use, equals(false));
    expect(p.getServicesNameListNotInUse().contains(doi), equals(true));
    expect(p.getServicesNameListInUse().contains(doi), equals(false));
    expect(p.getServicesNameListNotInUse().contains(alerts), equals(true));
    expect(p.getServicesNameListInUse().contains(alerts), equals(false));
    p.servers.forEach((server) {
      expect(p.getServerServicesForTest()[server.id]!.contains(doi),
          equals(false));
      expect(p.getServerServicesForTest()[server.id]!.contains(alerts),
          equals(false));
    });
    expect(
        p.servers.length == p.getServerServicesForTest().length, equals(true));
    expect(p.getService(collectory).suburl, equals('collectory'));
    expect(p.prodServices.length > 0, equals(true));
  });

  test('Test empty project creation toString should not fail', () {
    LAProject testProject = LAProject();
    // https://stackoverflow.com/questions/13298969/how-do-you-unittest-exceptions-in-dart
    expect(() => testProject.toString(), returnsNormally);
    expect(() => testProject.toJson(), returnsNormally);
    expect(() => testProject.toGeneratorJson(), returnsNormally);
  });

  test('get def ansible user of project', () {
    LAProject testProject = LAProject();

    expect(testProject.getVariableValue("ansible_user"), equals("ubuntu"));
    expect(testProject.getVariable("ansible_user").value, equals("ubuntu"));
  });
}
