import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_toolkit/models/LAServiceConstants.dart';
import 'package:la_toolkit/models/deploymentType.dart';
import 'package:la_toolkit/models/laLatLng.dart';
import 'package:la_toolkit/models/laProjectStatus.dart';
import 'package:la_toolkit/models/laServer.dart';
import 'package:la_toolkit/models/laServiceDeploy.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:la_toolkit/models/laServiceName.dart';
import 'package:la_toolkit/models/laVariable.dart';
import 'package:la_toolkit/models/la_project.dart';
import 'package:la_toolkit/models/la_service.dart';
import 'package:la_toolkit/models/sshKey.dart';
import 'package:latlong2/latlong.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Test step 0 of creation, longname', () {
    final LAProject testProject = LAProject();
    expect(testProject.isCreated, equals(false));
    expect(testProject.status, equals(LAProjectStatus.created));
  });

  test('Test step 0 of creation, shortname', () {
    final LAProject testProject =
        LAProject(longName: 'Living Atlas of Wakanda');
    expect(testProject.isCreated, equals(false));
    expect(testProject.status, equals(LAProjectStatus.created));
  });

  test('Test step 0 of creation, invalid domain', () {
    final LAProject testProject = LAProject(
        longName: 'Living Atlas of Wakanda', shortName: 'kk', domain: 'kk');
    expect(testProject.isCreated, equals(false));
    expect(testProject.status, equals(LAProjectStatus.created));
  });

  test('Test step 0 of creation, valid domain, valid step 1', () {
    final LAProject testProject = LAProject(
        longName: 'Living Atlas of Wakanda',
        shortName: 'LAW',
        domain: 'l-a.site',
        alaInstallRelease: '',
        generatorRelease: '');
    expect(testProject.validateCreation(), equals(false));
    expect(testProject.isCreated, equals(false));
    expect(testProject.status, equals(LAProjectStatus.basicDefined));
  });

  test('Test step 1 of creation, valid server', () {
    final LAProject testProject = LAProject(
        longName: 'Living Atlas of Wakanda',
        shortName: 'LAW',
        domain: 'l-a.site',
        alaInstallRelease: '',
        generatorRelease: '');
    testProject.upsertServer(LAServer(name: 'vm1', projectId: testProject.id));
    expect(testProject.isCreated, equals(false));
    expect(testProject.numServers(), equals(1));
    expect(testProject.validateCreation(), equals(false));
    expect(testProject.status, equals(LAProjectStatus.basicDefined));
  });

  test('Test step 1 of creation, valid servers', () {
    final LAProject testProject = LAProject(
        longName: 'Living Atlas of Wakanda',
        shortName: 'LAW',
        domain: 'l-a.site',
        alaInstallRelease: '',
        generatorRelease: '');
    testProject.upsertServer(LAServer(name: 'vm1', projectId: testProject.id));
    testProject.upsertServer(
        LAServer(name: 'vm2', ip: '10.0.0.1', projectId: testProject.id));
    testProject.upsertServer(
        LAServer(name: 'vm2', ip: '10.0.0.2', projectId: testProject.id));
    expect(testProject.isCreated, equals(false));
    expect(testProject.numServers(), equals(2));
    expect(testProject.validateCreation(), equals(false));
    expect(
        testProject.servers
            .where((LAServer element) => element.name == 'vm2')
            .first
            .ip,
        equals('10.0.0.2'));
    expect(testProject.status, equals(LAProjectStatus.basicDefined));
  });

  test('Servers equals', () {
    final LAServer vm1 = LAServer(name: 'vm2', ip: '10.0.0.1', projectId: '1');
    final LAServer vm1bis = vm1.copyWith(ip: '10.0.0.1', projectId: '1');
    expect(vm1 == vm1bis, equals(true));
  });

  test('Servers not equals', () {
    LAServer vm1 = LAServer(name: 'vm1', projectId: '1');
    LAServer vm1bis = LAServer(name: 'vm2', projectId: '1');
    expect(vm1 == vm1bis, equals(false));
    vm1 = LAServer(name: 'vm1', projectId: '1');
    vm1bis =
        LAServer(name: 'vm1', aliases: <String>['collections'], projectId: '1');
    final LAServer vm1bisBis =
        LAServer(name: 'vm1', sshPort: 22001, projectId: '1');
    expect(vm1 == vm1bis, equals(false));
    expect(vm1 == vm1bisBis, equals(false));
  });

  test('Test step 1 of creation, valid servers-service assignment and equality',
      () {
    final LAProject testProject = LAProject(
        //id: "0",
        longName: 'Living Atlas of Wakanda',
        shortName: 'LAW',
        domain: 'l-a.site',
        alaInstallRelease: '2.0.0',
        generatorRelease: '2.0.0');
    final LAProject testProjectOther = testProject.copyWith();

    expect(
        const ListEquality<LAService>()
            .equals(testProject.services, testProjectOther.services),
        equals(true));
    expect(
        const MapEquality<String, List<String>>().equals(
            testProject.getServerServicesForTest(),
            testProjectOther.getServerServicesForTest()),
        equals(true));
    expect(
        testProject.mapBoundsFstPoint == testProjectOther.mapBoundsFstPoint &&
            testProject.mapBoundsSndPoint == testProjectOther.mapBoundsSndPoint,
        equals(true));
    expect(
        const ListEquality<LAServer>()
            .equals(testProject.servers, testProjectOther.servers),
        equals(true));
    expect(
        const ListEquality<LAVariable>()
            .equals(testProject.variables, testProjectOther.variables),
        equals(true));
    expect(testProject.hashCode == testProjectOther.hashCode, equals(true));
    expect(testProject == testProjectOther, equals(true));
    final LAServer vm1 =
        LAServer(name: 'vm1', ip: '10.0.0.1', projectId: testProject.id);
    final LAServer vm2 =
        LAServer(name: 'vm2', ip: '10.0.0.2', projectId: testProject.id);
    final LAServer vm3 =
        LAServer(name: 'vm3', ip: '10.0.0.3', projectId: testProject.id);
    final LAServer vm4 =
        LAServer(name: 'vm4', ip: '10.0.0.4', projectId: testProject.id);
    final LAProject testProjectCopy = testProject.copyWith(
        servers: <LAServer>[], serverServices: <String, List<String>>{});
    expect(testProject.getService(biocacheCli).use, equals(true));
    testProject.upsertServer(vm1);
    testProjectCopy.upsertServer(vm1);
    expect(testProject.getServerServicesForTest().length, equals(1));
    expect(testProject.servers.length, equals(1));
    expect(testProjectCopy.getServerServicesForTest().length, equals(1));
    expect(testProjectCopy.servers.length, equals(1));
    expect(
        const ListEquality<LAService>()
            .equals(testProject.services, testProjectCopy.services),
        equals(true));
    expect(
        const DeepCollectionEquality.unordered().equals(
            testProject.getServerServicesForTest(),
            testProjectCopy.getServerServicesForTest()),
        equals(true));
    expect(testProject == testProjectCopy, equals(true));
    expect(testProject.servers, equals(testProjectCopy.servers));

    testProject.upsertServer(vm2);
    expect(testProjectCopy.servers.length, equals(1));

    expect(testProject.getServerServicesForTest().length, equals(2));
    expect(testProject.servers == testProjectCopy.servers, equals(false));
    expect(testProjectCopy.getServerServicesForTest().length, equals(1));
    expect(
        const MapEquality<String, List<String>>().equals(
            testProject.getServerServicesForTest(),
            testProjectCopy.getServerServicesForTest()),
        equals(false));
    expect(
        testProject.mapBoundsFstPoint == testProjectCopy.mapBoundsFstPoint &&
            testProject.mapBoundsSndPoint == testProjectCopy.mapBoundsSndPoint,
        equals(true));
    expect(
        const ListEquality<LAServer>()
            .equals(testProject.servers, testProjectCopy.servers),
        equals(false));
    expect(testProject.hashCode == testProjectCopy.hashCode, equals(false));
    expect(testProject == testProjectCopy, equals(false));
    testProjectCopy.upsertServer(vm2);
    expect(testProject == testProjectCopy, equals(true));
    expect(testProject.servers, equals(testProjectCopy.servers));
    testProject.upsertServer(vm3);
    testProject.upsertServer(vm4);
    expect(testProject == testProjectCopy, equals(false));
    testProject.assign(vm1, <String>[collectory]);
    expect(testProject == testProjectCopy, equals(false));

    expect(testProject.getServicesNameListInUse().contains(collectory),
        equals(true));
    expect(testProject.getHostnames(collectory)[0] == vm1.name, equals(true));
    /* print(testProject);
    print(testProject.servers);
    print(testProject.services);
    print(testProject.getServiceE(LAServiceName.collectory)); */

    expect(testProject.getHostnames(regions).isEmpty, equals(true));

    testProject.assign(vm1, <String>[alaHub, regions, bie, branding]);

    testProject.assign(vm2, <String>[collectory, bieIndex, biocacheService]);

    testProject.assign(vm3, <String>[solr, logger, speciesLists]);

    testProject.assign(vm4, <String>[
      spatial,
      cas,
      images,
      biocacheBackend,
      biocacheCli,
      nameindexer
    ]);

    expect(testProject.getServicesNameListInUse().contains(collectory),
        equals(true));
    expect(testProject.getHostnames(collectory)[0] == vm2.name, equals(true));
    expect(testProject.getHostnames(collectory)[0] == vm1.name, equals(false));
    expect(testProject.isCreated, equals(false));
    expect(testProject.numServers(), equals(4));
    // no ssh keys
    expect(testProject.validateCreation(debug: true), equals(false));
    vm1.sshKey = SshKey(name: 'k1', desc: '', encrypted: false);
    vm2.sshKey = SshKey(name: 'k2', desc: '', encrypted: false);
    vm3.sshKey = SshKey(name: 'k3', desc: '', encrypted: false);
    vm4.sshKey = SshKey(name: 'k4', desc: '', encrypted: false);
    expect(testProject.getServicesNameListInUse().isNotEmpty, equals(true));

    /*
    print(testProject.getServicesNameListInUse().length);
    print(testProject.getServicesAssignedToServers().length);
    print(testProject.getServicesNameListInUse());
    print(testProject.getServicesAssignedToServers());
    print(testProject);
    print(testProject.servicesNotAssigned()); */
    expect(
        testProject.getServicesNameListInUse().length ==
            testProject.getServicesAssigned().length,
        equals(true));
    testProject.getServicesNameListInUse().forEach((String service) {
      expect(testProject.getHostnames(service).isNotEmpty, equals(true));
    });
    expect(testProject.validateCreation(debug: true), equals(true));
    expect(
        testProject.servers
            .where((LAServer element) => element.name == 'vm2')
            .first
            .ip,
        equals('10.0.0.2'));
/*    print(testProject); */
    expect(testProject.getServersNameList().length, equals(4));
    expect(testProject.status, equals(LAProjectStatus.advancedDefined));
    expect(testProject.getService(userdetails).use, equals(true));
    // testProject.delete(vm1);
  });

  test('Test lat/lng center', () {
    final LAProject p = LAProject(
        mapBoundsFstPoint: LALatLng.from(10.0, 10.0),
        mapBoundsSndPoint: LALatLng.from(20.0, 20.0));
    expect(p.getCenter(), equals(const LatLng(15, 15)));
    p.mapBoundsFstPoint = LALatLng.from(20, 20);
    p.mapBoundsSndPoint = LALatLng.from(40, 40);
    p.setMap(const LatLng(20, 20), const LatLng(40, 40), 10);
    expect(p.getCenter(), equals(const LatLng(30, 30)));
    expect(p.mapZoom, equals(10));
  });

  test('Test default services', () {
    final LAProject p = LAProject();

    expect(p.getServiceE(LAServiceName.collectory).use, equals(true));
    expect(p.getServiceE(LAServiceName.ala_hub).use, equals(true));
    expect(p.getServiceE(LAServiceName.biocache_service).use, equals(true));
    expect(p.getServiceE(LAServiceName.biocache_backend).use, equals(true));
    expect(p.getServiceE(LAServiceName.solr).use, equals(true));
    expect(p.getServiceE(LAServiceName.logger).use, equals(true));
  });

  test('Test disable of services and other project props', () {
    final LAProject p = LAProject();
    p.domain = 'l-a.site';
    p.alaInstallRelease = '2.0.0';
    p.serviceInUse(bie, true);
    expect(p.getServicesNameListInUse().length, equals(21));

    p.serviceInUse(speciesLists, true);
    expect(p.getService(bie).use, equals(true));
    expect(p.getService(speciesLists).use, equals(true));
    final LAProject pBis = p.copyWith();

    expect(p == pBis, equals(true));
    final LAServer vm1 = LAServer(name: 'vm1', projectId: p.id);
    p.upsertServer(vm1);
    p.assign(vm1, <String>[collectory, bie, bieIndex, speciesLists]);
    expect(p.getServicesAssigned().length, equals(4));
    expect(p.serviceDeploys.length, equals(p.getServicesAssigned().length));
    final LAServer vm1Bis = LAServer(
        name: 'vm1',
        ip: '10.0.0.1',
        sshUser: 'john',
        sshPort: 22001,
        projectId: p.id);
    expect(p.getServerServices(serverId: vm1.id).contains(collectory),
        equals(true));
    p.upsertServer(vm1Bis);

    expect(p.getServerServices(serverId: vm1.id).contains(collectory),
        equals(true));
    expect(p.getServerServices(serverId: vm1.id).contains(bie), equals(true));
    expect(p.getServerServices(serverId: vm1.id).contains(speciesLists),
        equals(true));
    final LAServer vm1Updated =
        p.servers.where((LAServer element) => element.id == vm1.id).toList()[0];
    expect(vm1Updated.sshUser == 'john' && vm1Updated.sshPort == 22001,
        equals(true));
    p.serviceInUse(bie, false);
    expect(p.getService(bie).use, equals(false));
    expect(p.getService(bieIndex).use, equals(false));
    expect(p.getService(speciesLists).use, equals(false));
    expect(p.getServerServices(serverId: vm1.id).contains(collectory),
        equals(true));
    expect(p.getServerServices(serverId: vm1.id).contains(bie), equals(false));
    expect(p.getServerServices(serverId: vm1.id).contains(bieIndex),
        equals(false));
    expect(p.getServerServices(serverId: vm1.id).contains(speciesLists),
        equals(false));
    final int numServices = p.getServersNameList().length;
    p.serviceInUse(bie, true);
    p.serviceInUse(bie, false);
    p.serviceInUse(bie, true);
    // debugServiceDeployAssigned(p);
    p.getService(bie).usesSubdomain = false;
    p.getService(bie).usesSubdomain = true;
    expect(numServices == p.getServersNameList().length, equals(true));
    expect(p.getService(bie).use, equals(true));
    expect(p.getService(bieIndex).use, equals(true));
    expect(p.allServicesAssigned(), equals(false));
    expect(p.serviceDeploys.length, equals(p.getServicesAssigned().length));
    p.assign(vm1, <String>[bie]);
    debugServiceDeployAssigned(p);
    expect(p.serviceDeploys.length, equals(p.getServicesAssigned().length));
    expect(p.allServicesAssigned(), equals(false));
    p.getServicesNameListInUse().contains(bie);
    p.getServicesNameListInUse().contains(bieIndex);
    expect(p.getServicesAssigned().contains(bie), equals(true));
    expect(p.getServicesAssigned().contains(bieIndex), equals(false));
    p.assign(vm1, <String>[bie, bieIndex, branding]);
    expect(p.getServicesAssigned().contains(bie), equals(true));
    expect(p.getServicesAssigned().contains(bieIndex), equals(true));
    expect(p.getHostnames(bieIndex), equals(<String>['vm1']));
    expect(p.getHostnames(bie), equals(<String>['vm1']));
    p.getService(bie).iniPath = '/species';
    expect(
        p.etcHostsVar,
        equals(
            '      10.0.0.1 vm1 species.l-a.site species-ws.l-a.site branding.l-a.site'));

    p.getService(branding).iniPath = '/';
    p.getService(branding).suburl = '';
    expect(
        p.etcHostsVar,
        equals(
            '      10.0.0.1 vm1 species.l-a.site species-ws.l-a.site l-a.site'));
    expect(p.serviceDeploys.length, equals(p.getServicesAssigned().length));

    // print(p.getServiceDefaultVersion(p.getService(bie)));
    expect(p.getServiceDefaultVersions(p.getService(bie)).isNotEmpty,
        equals(true));
    expect(p.getServiceDeployReleases().isNotEmpty, equals(true));

    p.delete(vm1);
    expect(p.validateCreation(), equals(false));
    expect(p.servers.length, equals(0));
    expect(p.serverServices.length, equals(0));
    expect(p.serviceDeploys.length, equals(0));
  });

  test('Import yo-rc.json', () {
    const String yoRcJsonALA = r'''
    {
  "generator-living-atlas": {
    "promptValues": {
      "LA_id": "61cf297a0062311ea4e8e105",
      "LA_project_name": "Atlas of Living Australia",
      "LA_project_shortname": "ALA",
      "LA_pkg_name": "ala",
      "LA_domain": "ala.org.au",
      "LA_use_species": true,
      "LA_use_spatial": true,
      "LA_use_regions": true,
      "LA_use_species_lists": true,
      "LA_use_CAS": true,
      "LA_use_images": true,
      "LA_use_alerts": true,
      "LA_use_doi": true,
      "LA_use_webapi": true,
      "LA_use_dashboard": true,
      "LA_use_biocache_store": true,
      "LA_use_pipelines": true,
      "LA_use_solrcloud": true,
      "LA_use_sds": true,
      "LA_use_namematching_service": true,
      "LA_use_data_quality": true,
      "LA_enable_ssl": true,
      "LA_use_git": true,
      "LA_generate_branding": true,
      "LA_cas_hostname": "cloud-vm-11",
      "LA_cas_url": "auth.ala.org.au",
      "LA_spatial_hostname": "cloud-vm-12",
      "LA_spatial_url": "spatial.ala.org.au",
      "LA_branding_uses_subdomain": true,
      "LA_branding_hostname": "cloud-vm-25",
      "LA_branding_url": "ala.org.au",
      "LA_branding_path": "/commonui-bs3-2019",
      "LA_collectory_uses_subdomain": true,
      "LA_collectory_hostname": "cloud-vm-01",
      "LA_collectory_url": "collections.ala.org.au",
      "LA_collectory_path": "/",
      "LA_ala_hub_uses_subdomain": true,
      "LA_ala_hub_hostname": "cloud-vm-02, cloud-vm-03",
      "LA_ala_hub_url": "biocache.ala.org.au",
      "LA_ala_hub_path": "/",
      "LA_biocache_service_uses_subdomain": true,
      "LA_biocache_service_hostname": "cloud-vm-04, cloud-vm-05, cloud-vm-06",
      "LA_biocache_service_url": "biocache-ws.ala.org.au",
      "LA_biocache_service_path": "/ws",
      "LA_ala_bie_uses_subdomain": true,
      "LA_ala_bie_hostname": "cloud-vm-17, cloud-vm-18",
      "LA_ala_bie_url": "bie.ala.org.au",
      "LA_ala_bie_path": "/",
      "LA_bie_index_uses_subdomain": true,
      "LA_bie_index_hostname": "cloud-vm-19, cloud-vm-20",
      "LA_bie_index_url": "bie-ws.ala.org.au",
      "LA_bie_index_path": "/ws",
      "LA_images_uses_subdomain": true,
      "LA_images_hostname": "cloud-vm-22",
      "LA_images_url": "images.ala.org.au",
      "LA_images_path": "/",
      "LA_lists_uses_subdomain": true,
      "LA_lists_hostname": "cloud-vm-21",
      "LA_lists_url": "lists.ala.org.au",
      "LA_lists_path": "/",
      "LA_regions_uses_subdomain": true,
      "LA_regions_hostname": "cloud-vm-08",
      "LA_regions_url": "regions.ala.org.au",
      "LA_regions_path": "/",
      "LA_logger_uses_subdomain": true,
      "LA_logger_hostname": "cloud-vm-09",
      "LA_logger_url": "logger.ala.org.au",
      "LA_logger_path": "/",
      "LA_solr_uses_subdomain": true,
      "LA_solr_hostname": "cloud-vm-10",
      "LA_solr_url": "index.ala.org.au",
      "LA_solr_path": "/",
      "LA_biocache_backend_hostname": "cloud-vm-07",
      "LA_webapi_uses_subdomain": true,
      "LA_webapi_hostname": "cloud-vm-23",
      "LA_webapi_url": "api.ala.org.au",
      "LA_webapi_path": "/",
      "LA_dashboard_uses_subdomain": true,
      "LA_dashboard_hostname": "cloud-vm-15",
      "LA_dashboard_path": "/",
      "LA_dashboard_url": "dashboard.ala.org.au",
      "LA_sds_uses_subdomain": true,
      "LA_sds_hostname": "cloud-vm-24",
      "LA_sds_path": "/",
      "LA_sds_url": "sds.ala.org.au",
      "LA_namematching_service_hostname": "cloud-vm-46",
      "LA_namematching_service_path": "/",
      "LA_namematching_service_url": "name-matching-ws.ala.org.au",
      "LA_data_quality_hostname": "cloud-vm-47",
      "LA_data_quality_path": "/",
      "LA_data_quality_url": "data-quality-service.ala.org.au",
      "LA_alerts_uses_subdomain": true,
      "LA_alerts_hostname": "cloud-vm-13",
      "LA_alerts_path": "/",
      "LA_alerts_url": "alerts.ala.org.au",
      "LA_doi_uses_subdomain": true,
      "LA_doi_hostname": "cloud-vm-14",
      "LA_doi_path": "/",
      "LA_doi_url": "doi.ala.org.au",
      "LA_server_ips": ",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,",
      "LA_theme": "clean",
      "LA_collectory_map_centreMapLat": -26.5,
      "LA_collectory_map_centreMapLng": 133,
      "LA_spatial_map_lan": -26.5,
      "LA_spatial_map_lng": 133,
      "LA_regions_map_bounds": "[-44, 112, -9, 154]",
      "LA_spatial_map_bbox": "[-44, 112, -9, 154]",
      "LA_spatial_map_areaSqKm": 12147183.349007064,
      "LA_etc_hosts": "       cloud-vm-01 collections.ala.org.au\n       cloud-vm-02 biocache.ala.org.au\n       cloud-vm-03 biocache.ala.org.au\n       cloud-vm-04 biocache-ws.ala.org.au\n       cloud-vm-05 biocache-ws.ala.org.au\n       cloud-vm-06 biocache-ws.ala.org.au\n       cloud-vm-07 \n       cloud-vm-08 regions.ala.org.au\n       cloud-vm-09 logger.ala.org.au\n       cloud-vm-10 index.ala.org.au\n       cloud-vm-11 auth.ala.org.au\n       cloud-vm-12 spatial.ala.org.au\n       cloud-vm-15 dashboard.ala.org.au\n       cloud-vm-13 alerts.ala.org.au\n       cloud-vm-14 doi.ala.org.au\n       cloud-vm-17 bie.ala.org.au\n       cloud-vm-18 bie.ala.org.au\n       cloud-vm-19 bie-ws.ala.org.au\n       cloud-vm-20 bie-ws.ala.org.au\n       cloud-vm-21 lists.ala.org.au\n       cloud-vm-22 images.ala.org.au\n       cloud-vm-23 api.ala.org.au\n       cloud-vm-24 sds.ala.org.au\n       cloud-vm-25 ala.org.au\n       cloud-vm-26 \n       cloud-vm-27 \n       cloud-vm-28 \n       cloud-vm-29 \n       cloud-vm-30 \n       cloud-vm-31 \n       cloud-vm-32 \n       cloud-vm-33 ala.org.au\n       cloud-vm-34 ala.org.au\n       cloud-vm-35 ala.org.au\n       cloud-vm-36 ala.org.au\n       cloud-vm-37 ala.org.au\n       cloud-vm-38 ala.org.au\n       cloud-vm-39 ala.org.au\n       cloud-vm-40 ala.org.au\n       cloud-vm-41 ala.org.au\n       cloud-vm-42 ala.org.au\n       cloud-vm-43 ala.org.au\n       cloud-vm-44 ala.org.au\n       cloud-vm-45 ala.org.au\n       cloud-vm-46 name-matching-ws.ala.org.au\n       cloud-vm-47 data-quality-service.ala.org.au\n       avh-hub-1 avh.ala.org.au\n       mdba-hub-1 mdba.ala.org.au mdba-regiones.ala.org.au\n       ozcam-hub-1 ozcam.ala.org.au",
      "LA_hostnames": "cloud-vm-01, cloud-vm-02, cloud-vm-03, cloud-vm-04, cloud-vm-05, cloud-vm-06, cloud-vm-07, cloud-vm-08, cloud-vm-09, cloud-vm-10, cloud-vm-11, cloud-vm-12, cloud-vm-15, cloud-vm-13, cloud-vm-14, cloud-vm-17, cloud-vm-18, cloud-vm-19, cloud-vm-20, cloud-vm-21, cloud-vm-22, cloud-vm-23, cloud-vm-24, cloud-vm-25, cloud-vm-26, cloud-vm-27, cloud-vm-28, cloud-vm-29, cloud-vm-30, cloud-vm-31, cloud-vm-32, cloud-vm-33, cloud-vm-34, cloud-vm-35, cloud-vm-36, cloud-vm-37, cloud-vm-38, cloud-vm-39, cloud-vm-40, cloud-vm-41, cloud-vm-42, cloud-vm-43, cloud-vm-44, cloud-vm-45, cloud-vm-46, cloud-vm-47",
      "LA_ssh_keys": "",
      "LA_variable_ansible_user": "ubuntu",
      "LA_variable_caches_auth_enabled": true,
      "LA_variable_caches_collections_enabled": true,
      "LA_variable_caches_layers_enabled": true,
      "LA_variable_caches_logs_enabled": true,
      "LA_variable_email_sender": "noreply@ala.org.au",
      "LA_variable_favicon_url": "https://www.ala.org.au/app/uploads/2019/01/cropped-favicon-32x32.png",
      "LA_variable_map_zone_name": "Australia",
      "LA_variable_orgCountry": "Australia",
      "LA_variable_orgEmail": "info@ala.org.au",
      "LA_variable_support_email": "support@ala.org.au",
      "LA_variable_sds_faq_url": "https://www.ala.org.au/faq/data-sensitivity/",
      "LA_variable_sds_flag_rules": "PBC7,PBC8,PBC9",
      "LA_is_hub": false,
      "LA_software_versions": [
        [
          "ala_name_matching_version",
          "4.0"
        ],
        [
          "alerts_version",
          "1.5.3"
        ],
        [
          "apikey_version",
          "1.6.0"
        ],
        [
          "bie_hub_version",
          "1.5.2"
        ],
        [
          "bie_index_version",
          "1.5"
        ],
        [
          "biocache_cli_version",
          "2.6.1"
        ],
        [
          "biocache_hub_version",
          "4.0.8"
        ],
        [
          "biocache_service_version",
          "3.0.23"
        ],
        [
          "cas_management_version",
          "5.3.6-3"
        ],
        [
          "cas_version",
          "5.3.12-5"
        ],
        [
          "collectory_version",
          "1.6.6"
        ],
        [
          "dashboard_version",
          "2.2"
        ],
        [
          "data_quality_filter_service_version",
          "1.0.0"
        ],
        [
          "doi_service_version",
          "1.1.5"
        ],
        [
          "image_service_version",
          "1.1.7-5"
        ],
        [
          "logger_version",
          "4.0.1"
        ],
        [
          "regions_version",
          "3.3.5"
        ],
        [
          "sds_version",
          "1.6.2"
        ],
        [
          "solrcloud_version",
          "8.9.0"
        ],
        [
          "solr_version",
          "7.7.3"
        ],
        [
          "spatial_hub_version",
          "1.0.1"
        ],
        [
          "spatial_service_version",
          "1.0.1"
        ],
        [
          "species_list_version",
          "3.5.9"
        ],
        [
          "user_details_version",
          "2.4.0"
        ],
        [
          "webapi_version",
          "2.0.1"
        ]
      ],
      "LA_pipelines_hostname": "cloud-vm-26, cloud-vm-27, cloud-vm-28, cloud-vm-29, cloud-vm-30, cloud-vm-31, cloud-vm-32",
      "LA_solrcloud_hostname": "cloud-vm-33, cloud-vm-34, cloud-vm-35, cloud-vm-36, cloud-vm-37, cloud-vm-38, cloud-vm-39, cloud-vm-40",
      "LA_zookeeper_hostname": "cloud-vm-41, cloud-vm-42, cloud-vm-43, cloud-vm-44, cloud-vm-45",
      "LA_variable_pipelines_master": "cloud-vm-26",
      "LA_use_pipelines_jenkins": true,
      "LA_enable_data_quality": false,
      "LA_hubs": [
        {
          "LA_id": "61cf33900062311ea4e8e60d",
          "LA_project_name": "The Australasian Virtual Herbarium",
          "LA_project_shortname": "AVH",
          "LA_pkg_name": "avh",
          "LA_domain": "ala.org.au",
          "LA_use_species": false,
          "LA_use_regions": false,
          "LA_enable_ssl": true,
          "LA_use_git": true,
          "LA_generate_branding": true,
          "LA_branding_uses_subdomain": true,
          "LA_branding_hostname": "avh-hub-1",
          "LA_branding_url": "avh.ala.org.au",
          "LA_branding_path": "/branding",
          "LA_ala_hub_uses_subdomain": true,
          "LA_ala_hub_hostname": "avh-hub-1",
          "LA_ala_hub_url": "avh.ala.org.au",
          "LA_ala_hub_path": "/",
          "LA_ala_bie_uses_subdomain": true,
          "LA_ala_bie_hostname": "",
          "LA_ala_bie_url": "hub.ala.org.au",
          "LA_ala_bie_path": "/species",
          "LA_regions_uses_subdomain": true,
          "LA_regions_hostname": "",
          "LA_regions_url": "hub.ala.org.au",
          "LA_regions_path": "/regions",
          "LA_server_ips": "",
          "LA_theme": "clean",
          "LA_collectory_map_centreMapLat": -26.5,
          "LA_collectory_map_centreMapLng": 133,
          "LA_spatial_map_lan": -26.5,
          "LA_spatial_map_lng": 133,
          "LA_regions_map_bounds": "[-44, 112, -9, 154]",
          "LA_spatial_map_bbox": "[-44, 112, -9, 154]",
          "LA_spatial_map_areaSqKm": 12147183.349007064,
          "LA_etc_hosts": "       cloud-vm-01 collections.ala.org.au\n       cloud-vm-02 biocache.ala.org.au\n       cloud-vm-03 biocache.ala.org.au\n       cloud-vm-04 biocache-ws.ala.org.au\n       cloud-vm-05 biocache-ws.ala.org.au\n       cloud-vm-06 biocache-ws.ala.org.au\n       cloud-vm-07 \n       cloud-vm-08 regions.ala.org.au\n       cloud-vm-09 logger.ala.org.au\n       cloud-vm-10 index.ala.org.au\n       cloud-vm-11 auth.ala.org.au\n       cloud-vm-12 spatial.ala.org.au\n       cloud-vm-15 dashboard.ala.org.au\n       cloud-vm-13 alerts.ala.org.au\n       cloud-vm-14 doi.ala.org.au\n       cloud-vm-17 bie.ala.org.au\n       cloud-vm-18 bie.ala.org.au\n       cloud-vm-19 bie-ws.ala.org.au\n       cloud-vm-20 bie-ws.ala.org.au\n       cloud-vm-21 lists.ala.org.au\n       cloud-vm-22 images.ala.org.au\n       cloud-vm-23 api.ala.org.au\n       cloud-vm-24 sds.ala.org.au\n       cloud-vm-25 ala.org.au\n       cloud-vm-26 \n       cloud-vm-27 \n       cloud-vm-28 \n       cloud-vm-29 \n       cloud-vm-30 \n       cloud-vm-31 \n       cloud-vm-32 \n       cloud-vm-33 ala.org.au\n       cloud-vm-34 ala.org.au\n       cloud-vm-35 ala.org.au\n       cloud-vm-36 ala.org.au\n       cloud-vm-37 ala.org.au\n       cloud-vm-38 ala.org.au\n       cloud-vm-39 ala.org.au\n       cloud-vm-40 ala.org.au\n       cloud-vm-41 ala.org.au\n       cloud-vm-42 ala.org.au\n       cloud-vm-43 ala.org.au\n       cloud-vm-44 ala.org.au\n       cloud-vm-45 ala.org.au\n       cloud-vm-46 name-matching-ws.ala.org.au\n       cloud-vm-47 data-quality-service.ala.org.au\n       avh-hub-1 avh.ala.org.au\n       mdba-hub-1 mdba.ala.org.au mdba-regiones.ala.org.au\n       ozcam-hub-1 ozcam.ala.org.au",
          "LA_hostnames": "avh-hub-1",
          "LA_ssh_keys": "",
          "LA_variable_ansible_user": "ubuntu",
          "LA_variable_favicon_url": "https://raw.githubusercontent.com/living-atlases/artwork/master/favicon.ico",
          "LA_is_hub": true,
          "LA_software_versions": [
            [
              "biocache_hub_version",
              "3.2.9"
            ]
          ]
        },
        {
          "LA_id": "61cf34770062311ea4e8e6ac",
          "LA_project_name": "Murray-Darling Basin Authority",
          "LA_project_shortname": "MDBA",
          "LA_pkg_name": "mdba",
          "LA_domain": "ala.org.au",
          "LA_use_species": false,
          "LA_use_regions": true,
          "LA_enable_ssl": true,
          "LA_use_git": true,
          "LA_generate_branding": true,
          "LA_branding_uses_subdomain": true,
          "LA_branding_hostname": "mdba-hub-1",
          "LA_branding_url": "mdba.ala.org.au",
          "LA_branding_path": "/branding",
          "LA_ala_hub_uses_subdomain": true,
          "LA_ala_hub_hostname": "mdba-hub-1",
          "LA_ala_hub_url": "mdba.ala.org.au",
          "LA_ala_hub_path": "/",
          "LA_ala_bie_uses_subdomain": true,
          "LA_ala_bie_hostname": "",
          "LA_ala_bie_url": "hub.ala.org.au",
          "LA_ala_bie_path": "/species",
          "LA_regions_uses_subdomain": true,
          "LA_regions_hostname": "mdba-hub-1",
          "LA_regions_url": "mdba-regiones.ala.org.au",
          "LA_regions_path": "/",
          "LA_server_ips": "",
          "LA_theme": "clean",
          "LA_collectory_map_centreMapLat": -26.5,
          "LA_collectory_map_centreMapLng": 133,
          "LA_spatial_map_lan": -26.5,
          "LA_spatial_map_lng": 133,
          "LA_regions_map_bounds": "[-44, 112, -9, 154]",
          "LA_spatial_map_bbox": "[-44, 112, -9, 154]",
          "LA_spatial_map_areaSqKm": 12147183.349007064,
          "LA_etc_hosts": "       cloud-vm-01 collections.ala.org.au\n       cloud-vm-02 biocache.ala.org.au\n       cloud-vm-03 biocache.ala.org.au\n       cloud-vm-04 biocache-ws.ala.org.au\n       cloud-vm-05 biocache-ws.ala.org.au\n       cloud-vm-06 biocache-ws.ala.org.au\n       cloud-vm-07 \n       cloud-vm-08 regions.ala.org.au\n       cloud-vm-09 logger.ala.org.au\n       cloud-vm-10 index.ala.org.au\n       cloud-vm-11 auth.ala.org.au\n       cloud-vm-12 spatial.ala.org.au\n       cloud-vm-15 dashboard.ala.org.au\n       cloud-vm-13 alerts.ala.org.au\n       cloud-vm-14 doi.ala.org.au\n       cloud-vm-17 bie.ala.org.au\n       cloud-vm-18 bie.ala.org.au\n       cloud-vm-19 bie-ws.ala.org.au\n       cloud-vm-20 bie-ws.ala.org.au\n       cloud-vm-21 lists.ala.org.au\n       cloud-vm-22 images.ala.org.au\n       cloud-vm-23 api.ala.org.au\n       cloud-vm-24 sds.ala.org.au\n       cloud-vm-25 ala.org.au\n       cloud-vm-26 \n       cloud-vm-27 \n       cloud-vm-28 \n       cloud-vm-29 \n       cloud-vm-30 \n       cloud-vm-31 \n       cloud-vm-32 \n       cloud-vm-33 ala.org.au\n       cloud-vm-34 ala.org.au\n       cloud-vm-35 ala.org.au\n       cloud-vm-36 ala.org.au\n       cloud-vm-37 ala.org.au\n       cloud-vm-38 ala.org.au\n       cloud-vm-39 ala.org.au\n       cloud-vm-40 ala.org.au\n       cloud-vm-41 ala.org.au\n       cloud-vm-42 ala.org.au\n       cloud-vm-43 ala.org.au\n       cloud-vm-44 ala.org.au\n       cloud-vm-45 ala.org.au\n       cloud-vm-46 name-matching-ws.ala.org.au\n       cloud-vm-47 data-quality-service.ala.org.au\n       avh-hub-1 avh.ala.org.au\n       mdba-hub-1 mdba.ala.org.au mdba-regiones.ala.org.au\n       ozcam-hub-1 ozcam.ala.org.au",
          "LA_hostnames": "mdba-hub-1",
          "LA_ssh_keys": "",
          "LA_variable_ansible_user": "ubuntu",
          "LA_variable_favicon_url": "https://raw.githubusercontent.com/living-atlases/artwork/master/favicon.ico",
          "LA_is_hub": true,
          "LA_software_versions": [
            [
              "biocache_hub_version",
              "3.2.9"
            ],
            [
              "regions_version",
              "3.3.5"
            ]
          ]
        },
        {
          "LA_id": "61cf35690062311ea4e8e721",
          "LA_project_name": "Online Zoological Collections of Australian Museums",
          "LA_project_shortname": "OZCAM",
          "LA_pkg_name": "ozcam",
          "LA_domain": "ala.org.au",
          "LA_use_species": false,
          "LA_use_regions": false,
          "LA_enable_ssl": true,
          "LA_use_git": true,
          "LA_generate_branding": true,
          "LA_branding_uses_subdomain": true,
          "LA_branding_hostname": "ozcam-hub-1",
          "LA_branding_url": "ozcam.ala.org.au",
          "LA_branding_path": "/branding",
          "LA_ala_hub_uses_subdomain": true,
          "LA_ala_hub_hostname": "ozcam-hub-1",
          "LA_ala_hub_url": "ozcam.ala.org.au",
          "LA_ala_hub_path": "/",
          "LA_ala_bie_uses_subdomain": true,
          "LA_ala_bie_hostname": "",
          "LA_ala_bie_url": "hub.ala.org.au",
          "LA_ala_bie_path": "/species",
          "LA_regions_uses_subdomain": true,
          "LA_regions_hostname": "",
          "LA_regions_url": "hub.ala.org.au",
          "LA_regions_path": "/regions",
          "LA_server_ips": "",
          "LA_theme": "clean",
          "LA_collectory_map_centreMapLat": -26.5,
          "LA_collectory_map_centreMapLng": 133,
          "LA_spatial_map_lan": -26.5,
          "LA_spatial_map_lng": 133,
          "LA_regions_map_bounds": "[-44, 112, -9, 154]",
          "LA_spatial_map_bbox": "[-44, 112, -9, 154]",
          "LA_spatial_map_areaSqKm": 12147183.349007064,
          "LA_etc_hosts": "       cloud-vm-01 collections.ala.org.au\n       cloud-vm-02 biocache.ala.org.au\n       cloud-vm-03 biocache.ala.org.au\n       cloud-vm-04 biocache-ws.ala.org.au\n       cloud-vm-05 biocache-ws.ala.org.au\n       cloud-vm-06 biocache-ws.ala.org.au\n       cloud-vm-07 \n       cloud-vm-08 regions.ala.org.au\n       cloud-vm-09 logger.ala.org.au\n       cloud-vm-10 index.ala.org.au\n       cloud-vm-11 auth.ala.org.au\n       cloud-vm-12 spatial.ala.org.au\n       cloud-vm-15 dashboard.ala.org.au\n       cloud-vm-13 alerts.ala.org.au\n       cloud-vm-14 doi.ala.org.au\n       cloud-vm-17 bie.ala.org.au\n       cloud-vm-18 bie.ala.org.au\n       cloud-vm-19 bie-ws.ala.org.au\n       cloud-vm-20 bie-ws.ala.org.au\n       cloud-vm-21 lists.ala.org.au\n       cloud-vm-22 images.ala.org.au\n       cloud-vm-23 api.ala.org.au\n       cloud-vm-24 sds.ala.org.au\n       cloud-vm-25 ala.org.au\n       cloud-vm-26 \n       cloud-vm-27 \n       cloud-vm-28 \n       cloud-vm-29 \n       cloud-vm-30 \n       cloud-vm-31 \n       cloud-vm-32 \n       cloud-vm-33 ala.org.au\n       cloud-vm-34 ala.org.au\n       cloud-vm-35 ala.org.au\n       cloud-vm-36 ala.org.au\n       cloud-vm-37 ala.org.au\n       cloud-vm-38 ala.org.au\n       cloud-vm-39 ala.org.au\n       cloud-vm-40 ala.org.au\n       cloud-vm-41 ala.org.au\n       cloud-vm-42 ala.org.au\n       cloud-vm-43 ala.org.au\n       cloud-vm-44 ala.org.au\n       cloud-vm-45 ala.org.au\n       cloud-vm-46 name-matching-ws.ala.org.au\n       cloud-vm-47 data-quality-service.ala.org.au\n       avh-hub-1 avh.ala.org.au\n       mdba-hub-1 mdba.ala.org.au mdba-regiones.ala.org.au\n       ozcam-hub-1 ozcam.ala.org.au",
          "LA_hostnames": "ozcam-hub-1",
          "LA_ssh_keys": "",
          "LA_variable_ansible_user": "ubuntu",
          "LA_variable_favicon_url": "https://raw.githubusercontent.com/living-atlases/artwork/master/favicon.ico",
          "LA_is_hub": true,
          "LA_software_versions": [
            [
              "biocache_hub_version",
              "3.2.9"
            ]
          ]
        }
      ]
    },
    "firstRun": false
  }
}
    ''';
    const String yoRcJson = '''
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
    const String yoRcJsonCa = '''
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
    const String yoRcJsonAt = '''
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
    const String yoRcJsonDemo = '''
    {
  "generator-living-atlas": {
    "promptValues": {
      "LA_project_name": "Demo de GBIF.ES",
      "LA_project_shortname": "GBIF.ES",
      "LA_pkg_name": "gbif-es",
      "LA_domain": "demo.gbif.es",
      "LA_use_species": true,
      "LA_use_spatial": false,
      "LA_use_regions": false,
      "LA_use_species_lists": true,
      "LA_use_CAS": false,
      "LA_use_images": true,
      "LA_use_alerts": false,
      "LA_use_doi": false,
      "LA_use_webapi": false,
      "LA_use_dashboard": false,
      "LA_enable_ssl": true,
      "LA_use_git": true,
      "LA_generate_branding": true,
      "LA_cas_hostname": "demo.gbif.es",
      "LA_cas_url": "auth.demo.gbif.es",
      "LA_spatial_hostname": "demo.gbif.es",
      "LA_spatial_url": "spatial.demo.gbif.es",
      "LA_collectory_uses_subdomain": false,
      "LA_collectory_hostname": "demo.gbif.es",
      "LA_collectory_url": "demo.gbif.es",
      "LA_collectory_path": "/colecciones",
      "LA_ala_hub_uses_subdomain": false,
      "LA_ala_hub_hostname": "demo.gbif.es",
      "LA_ala_hub_url": "demo.gbif.es",
      "LA_ala_hub_path": "/registros",
      "LA_biocache_service_uses_subdomain": false,
      "LA_biocache_service_hostname": "demo.gbif.es",
      "LA_biocache_service_url": "demo.gbif.es",
      "LA_biocache_service_path": "/registros-ws",
      "LA_ala_bie_uses_subdomain": false,
      "LA_ala_bie_hostname": "demo.gbif.es",
      "LA_ala_bie_url": "demo.gbif.es",
      "LA_ala_bie_path": "/especies",
      "LA_bie_index_uses_subdomain": false,
      "LA_bie_index_hostname": "demo.gbif.es",
      "LA_bie_index_url": "demo.gbif.es",
      "LA_bie_index_path": "/especies-ws",
      "LA_images_uses_subdomain": false,
      "LA_images_hostname": "demo.gbif.es",
      "LA_images_url": "demo.gbif.es",
      "LA_images_path": "/dimages",
      "LA_lists_uses_subdomain": false,
      "LA_lists_hostname": "demo.gbif.es",
      "LA_lists_url": "demo.gbif.es",
      "LA_lists_path": "/listas",
      "LA_regions_uses_subdomain": true,
      "LA_regions_hostname": "demo.gbif.es",
      "LA_regions_url": "regions.demo.gbif.es",
      "LA_regions_path": "/",
      "LA_logger_uses_subdomain": false,
      "LA_logger_hostname": "demo.gbif.es",
      "LA_logger_url": "demo.gbif.es",
      "LA_logger_path": "/logger",
      "LA_solr_uses_subdomain": false,
      "LA_solr_hostname": "demo.gbif.es",
      "LA_solr_url": "demo.gbif.es",
      "LA_solr_path": "/index",
      "LA_biocache_backend_hostname": "demo.gbif.es",
      "LA_main_hostname": "demo.gbif.es",
      "LA_webapi_uses_subdomain": true,
      "LA_webapi_hostname": "",
      "LA_webapi_url": "",
      "LA_webapi_path": "",
      "LA_dashboard_uses_subdomain": true,
      "LA_dashboard_hostname": "demo.gbif.es",
      "LA_dashboard_path": "/",
      "LA_dashboard_url": "dashboard.demo.gbif.es",
      "LA_alerts_uses_subdomain": true,
      "LA_alerts_hostname": "demo.gbif.es",
      "LA_alerts_path": "/",
      "LA_alerts_url": "alerts.demo.gbif.es",
      "LA_doi_uses_subdomain": true,
      "LA_doi_hostname": "demo.gbif.es",
      "LA_doi_path": "/",
      "LA_doi_url": "doi.demo.gbif.es"
    },
    "firstRun": false
  }
}
''';
    const String yoRcJsonLaSite = '''
{
  "generator-living-atlas": {
    "promptValues": {
      "LA_id": "649c0e1000541ed3bc69cc62",
      "LA_project_name": "Living Atlas Demo",
      "LA_project_shortname": "LADemo",
      "LA_pkg_name": "lademo",
      "LA_domain": "l-a.site",
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
      "LA_use_biocache_store": true,
      "LA_use_pipelines": false,
      "LA_use_solrcloud": false,
      "LA_use_sds": false,
      "LA_use_biocollect": false,
      "LA_use_namematching_service": false,
      "LA_use_sensitive_data_service": false,
      "LA_use_data_quality": false,
      "LA_use_events": false,
      "LA_use_events_elasticsearch": false,
      "LA_enable_ssl": true,
      "LA_use_git": true,
      "LA_generate_branding": true,
      "LA_cas_hostname": "vm1",
      "LA_cas_url": "auth.l-a.site",
      "LA_spatial_hostname": "vm1",
      "LA_spatial_url": "spatial.l-a.site",
      "LA_spatial_path": "/",
      "LA_branding_uses_subdomain": true,
      "LA_branding_hostname": "vm1",
      "LA_branding_url": "branding.l-a.site",
      "LA_branding_path": "/brand-2023",
      "LA_collectory_uses_subdomain": true,
      "LA_collectory_hostname": "vm1",
      "LA_collectory_url": "collections.l-a.site",
      "LA_collectory_path": "/",
      "LA_ala_hub_uses_subdomain": true,
      "LA_ala_hub_hostname": "vm1",
      "LA_ala_hub_url": "records.l-a.site",
      "LA_ala_hub_path": "/",
      "LA_biocache_service_uses_subdomain": true,
      "LA_biocache_service_hostname": "vm1",
      "LA_biocache_service_url": "records-ws.l-a.site",
      "LA_biocache_service_path": "/",
      "LA_ala_bie_uses_subdomain": true,
      "LA_ala_bie_hostname": "vm1",
      "LA_ala_bie_url": "species.l-a.site",
      "LA_ala_bie_path": "/",
      "LA_bie_index_uses_subdomain": true,
      "LA_bie_index_hostname": "vm1",
      "LA_bie_index_url": "species-ws.l-a.site",
      "LA_bie_index_path": "/",
      "LA_images_uses_subdomain": true,
      "LA_images_hostname": "vm1",
      "LA_images_url": "images.l-a.site",
      "LA_images_path": "/",
      "LA_lists_uses_subdomain": true,
      "LA_lists_hostname": "vm1",
      "LA_lists_url": "lists.l-a.site",
      "LA_lists_path": "/",
      "LA_regions_uses_subdomain": true,
      "LA_regions_hostname": "vm1",
      "LA_regions_url": "regions.l-a.site",
      "LA_regions_path": "/",
      "LA_logger_uses_subdomain": true,
      "LA_logger_hostname": "vm1",
      "LA_logger_url": "logger.l-a.site",
      "LA_logger_path": "/",
      "LA_solr_uses_subdomain": true,
      "LA_solr_hostname": "vm1",
      "LA_solr_url": "solr.l-a.site",
      "LA_solr_path": "/",
      "LA_biocache_backend_hostname": "vm1",
      "LA_webapi_uses_subdomain": true,
      "LA_webapi_hostname": "",
      "LA_webapi_url": "webapi.l-a.site",
      "LA_webapi_path": "/",
      "LA_dashboard_uses_subdomain": true,
      "LA_dashboard_hostname": "",
      "LA_dashboard_path": "/",
      "LA_dashboard_url": "dashboard.l-a.site",
      "LA_sds_uses_subdomain": true,
      "LA_sds_hostname": "",
      "LA_sds_path": "/",
      "LA_sds_url": "sds.l-a.site",
      "LA_namematching_service_hostname": "",
      "LA_namematching_service_path": "/",
      "LA_namematching_service_url": "namematching.l-a.site",
      "LA_sensitive_data_service_hostname": "",
      "LA_sensitive_data_service_path": "/",
      "LA_sensitive_data_service_url": "sensitive-data-service.l-a.site",
      "LA_data_quality_hostname": "",
      "LA_data_quality_path": "/",
      "LA_data_quality_url": "data-quality.l-a.site",
      "LA_alerts_uses_subdomain": true,
      "LA_alerts_hostname": "",
      "LA_alerts_path": "/",
      "LA_alerts_url": "alerts.l-a.site",
      "LA_doi_uses_subdomain": true,
      "LA_doi_hostname": "",
      "LA_doi_path": "/",
      "LA_doi_url": "doi.l-a.site",
      "LA_biocollect_uses_subdomain": true,
      "LA_biocollect_hostname": "",
      "LA_biocollect_path": "/",
      "LA_biocollect_url": "biocollect.l-a.site",
      "LA_pdfgen_uses_subdomain": true,
      "LA_pdfgen_hostname": "",
      "LA_pdfgen_path": "/",
      "LA_pdfgen_url": "pdfgen.l-a.site",
      "LA_ecodata_uses_subdomain": true,
      "LA_ecodata_hostname": "",
      "LA_ecodata_path": "/",
      "LA_ecodata_url": "ecodata.l-a.site",
      "LA_ecodata_reporting_uses_subdomain": true,
      "LA_ecodata_reporting_hostname": "",
      "LA_ecodata_reporting_path": "/",
      "LA_ecodata_reporting_url": "ecodata-reporting.l-a.site",
      "LA_events_uses_subdomain": true,
      "LA_events_hostname": "",
      "LA_events_elasticsearch_hostname": "",
      "LA_events_path": "/",
      "LA_events_url": "events.l-a.site",
      "LA_server_ips": "172.16.16.10",
      "LA_theme": "simplex",
      "LA_collectory_map_centreMapLat": 7.874575060529807,
      "LA_collectory_map_centreMapLng": 4.449218749999986,
      "LA_spatial_map_lan": 7.874575060529807,
      "LA_spatial_map_lng": 4.449218749999986,
      "LA_regions_map_bounds": "[73.04121154664902, -171.10156250000003, -57.29206142558941, 180]",
      "LA_spatial_map_bbox": "[73.04121154664902, -171.10156250000003, -57.29206142558941, 180]",
      "LA_spatial_map_areaSqKm": 14314104.669553608,
      "LA_etc_hosts": "      172.16.16.10 vm1 collections.l-a.site records.l-a.site records-ws.l-a.site species.l-a.site species-ws.l-a.site images.l-a.site lists.l-a.site regions.l-a.site logger.l-a.site solr.l-a.site auth.l-a.site spatial.l-a.site branding.l-a.site",
      "LA_hostnames": "vm1",
      "LA_ssh_keys": "'~/.ssh/gbif-es-2022.pub'",
      "LA_variable_ansible_user": "ubuntu",
      "LA_variable_caches_auth_enabled": true,
      "LA_variable_caches_collections_enabled": true,
      "LA_variable_caches_layers_enabled": true,
      "LA_variable_caches_logs_enabled": true,
      "LA_variable_cas_webflow_encryption_key": "6Y-9jDh-br9nsP2YvUPwSA",
      "LA_variable_cas_webflow_signing_key": "YSksHGeVkjWdvH-MH2wbMfl65_4W717GtCEVgeUGvsOMeGus0x4R7sYPc9K2TxDh31sNRTBHjpvUmY5izLsolQ",
      "LA_variable_cas_oauth_encryption_key": "3HhD62J1gcEELKcCewxisgV93e-U8-GlaS0nfbp9VUU",
      "LA_variable_cas_oauth_signing_key": "81XayAcCidVfhpJSQk6jL-TNV4-sBoyZwiXNJmHDQ-OYBEW0au_J1Bgj7J8xk0rSs96rgP4s1l33Zkv_HaxxoA",
      "LA_variable_cas_oauth_access_token_encryption_key": "3HhD62J1gcEELKcCewxisgV93e-U8-GlaS0nfbp9VUU",
      "LA_variable_cas_oauth_access_token_signing_key": "xQV8UQVlus0xjo-CmGAMlXMfI94-LbG_QmCtm0Ve3GkwSnJDmdYRC3ejZga7RDTbzU9nzfNVAq7DFUK2xSOs3Q",
      "LA_variable_email_sender": "noreply@l-a.site",
      "LA_variable_favicon_url": "https://raw.githubusercontent.com/living-atlases/artwork/master/favicon.ico",
      "LA_variable_map_zone_name": "World",
      "LA_variable_orgCountry": "World",
      "LA_variable_orgEmail": "info@l-a.site",
      "LA_variable_pac4j_cookie_encryption_key": "tpX4n2Wf5hfssZyat88wQbG5Uu_T16xkSzqWXSEf1FE",
      "LA_variable_pac4j_cookie_signing_key": "3HgmnQ2aNgIRHlqsV9hqn5Wwf03j0YeK36o1-EkPrQKn76UHiUCXwb9BkPYPYM4iQ3sckTHHPy6miZ-7-srmUA",
      "LA_variable_support_email": "support@l-a.site",
      "LA_variable_oidc_use": false,
      "LA_is_hub": false,
      "LA_software_versions": [
        [
          "ala_name_matching_version",
          "3.5"
        ],
        [
          "apikey_version",
          "1.6.0"
        ],
        [
          "bie_hub_version",
          "2.0.1"
        ],
        [
          "bie_index_version",
          "1.4.7"
        ],
        [
          "biocache_cli_version",
          "2.6.1"
        ],
        [
          "biocache_hub_version",
          "4.0.12.4"
        ],
        [
          "biocache_service_version",
          "2.7.1"
        ],
        [
          "cas_management_version",
          "5.3.6-3"
        ],
        [
          "cas_version",
          "5.3.12-5"
        ],
        [
          "collectory_version",
          "1.6.4"
        ],
        [
          "image_service_version",
          "1.1.7.1"
        ],
        [
          "logger_version",
          "3.0.0"
        ],
        [
          "regions_version",
          "3.3.5"
        ],
        [
          "solr_version",
          "7.7.3"
        ],
        [
          "spatial_hub_version",
          "1.0.2"
        ],
        [
          "spatial_service_version",
          "0.4.2"
        ],
        [
          "species_list_version",
          "3.5.9"
        ],
        [
          "user_details_version",
          "2.4.0"
        ]
      ],
      "LA_pipelines_hostname": "",
      "LA_solrcloud_hostname": "",
      "LA_zookeeper_hostname": "",
      "LA_collectory_version_ge_3": false
    },
    "firstRun": false
  }
}
''';
    LAProject p = LAProject.import(yoRcJson: yoRcJsonALA)[0];
    expect(p.longName, equals('Atlas of Living Australia'));
    expect(p.shortName, equals('ALA'));
    expect(p.domain, equals('ala.org.au'));
    expect(p.useSSL, equals(true));
    expect(p.hubs.isNotEmpty, equals(true));
    expect(p.hubs[0].longName, equals('The Australasian Virtual Herbarium'));
    expect(p.hubs[0].shortName, equals('AVH'));
    expect(p.hubs[0].isHub, equals(true));

    p = LAProject.import(yoRcJson: yoRcJson)[0];
    expect(p.longName, equals('Portal de Datos de GBIF.ES'));
    expect(p.shortName, equals('GBIF.ES'));
    expect(p.domain, equals('gbif.es'));
    expect(p.useSSL, equals(true));
    LAServiceDesc.list(p.isHub)
        .where((LAServiceDesc s) => s.nameInt != sds)
        .toList()
        .forEach((LAServiceDesc service) {
      if (!<String>[
        sds,
        pipelines,
        spark,
        hadoop,
        pipelinesJenkins,
        solrcloud,
        zookeeper,
        namematchingService,
        sensitiveDataService,
        dataQuality,
        biocollect,
        pdfgen,
        ecodata,
        ecodataReporting,
        events,
        eventsElasticSearch,
        dockerSwarm,
        dockerCommon,
        gatus,
        portainer,
        cassandra
      ].contains(service.nameInt)) {
        expect(p.getService(service.nameInt).use, equals(true),
            reason:
                '${service.nameInt} should be in Use and is ${p.getService(service.nameInt).use}');
      }
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
    expect(p.getService(speciesLists).suburl, equals('listas'));
    expect(p.getService(solr).fullUrl(p.useSSL, p.domain),
        equals('https://index.gbif.es/'));

    p = LAProject.import(yoRcJson: yoRcJsonDemo)[0];
    expect(p.longName, equals('Demo de GBIF.ES'));
    expect(p.shortName, equals('GBIF.ES'));
    expect(p.domain, equals('demo.gbif.es'));
    expect(p.useSSL, equals(true));
    expect(p.dirName != null && p.dirName!.isNotEmpty, equals(true));
    for (final LAServiceDesc service in LAServiceDesc.list(p.isHub)) {
      // print(service.nameInt);
      final List<String> notUsedServices = <String>[
        webapi,
        doi,
        regions,
        alerts,
        sds,
        cas,
        apikey,
        userdetails,
        casManagement,
        spatial,
        spatialService,
        geoserver,
        dashboard,
        pipelines,
        spark,
        hadoop,
        pipelinesJenkins,
        solrcloud,
        zookeeper,
        namematchingService,
        sensitiveDataService,
        dataQuality,
        biocollect,
        pdfgen,
        ecodata,
        ecodataReporting,
        events,
        eventsElasticSearch,
        dockerSwarm,
        dockerCommon,
        gatus,
        portainer,
        cassandra
      ];
      if (notUsedServices.contains(service.nameInt)) {
        expect(p.getService(service.nameInt).use, equals(false),
            reason: '${service.nameInt} should not be in Use');
      }
      if (!notUsedServices.contains(service.nameInt)) {
        expect(p.getService(service.nameInt).use, equals(true),
            reason: '${service.nameInt} should be in Use');
        if (!service.withoutUrl && service.nameInt != branding) {
          expect(p.getService(service.nameInt).usesSubdomain, equals(false),
              reason: '${service.nameInt} should not use subdomain');
        }
        expect(p.getService(collectory).fullUrl(true, 'demo.gbif.es'),
            equals('https://demo.gbif.es/colecciones'));
        expect(p.getService(collectory).path, equals('/colecciones'));
      }
    }

    p = LAProject.import(yoRcJson: yoRcJsonCa)[0];
    expect(p.longName, equals('Canadensys'));
    expect(p.shortName, equals('Canadensys'));
    expect(p.domain, equals('canadensys.net'));
    expect(p.useSSL, equals(true));
    expect(p.dirName != null && p.dirName!.isNotEmpty, equals(true));
    for (final LAServiceDesc service in LAServiceDesc.list(p.isHub)) {
      // print("${service.nameInt}");
      if (!<String>[
        speciesLists,
        webapi,
        doi,
        bie,
        regions,
        sds,
        pipelines,
        spark,
        hadoop,
        pipelinesJenkins,
        solrcloud,
        zookeeper,
        namematchingService,
        sensitiveDataService,
        dataQuality,
        biocollect,
        pdfgen,
        ecodata,
        ecodataReporting,
        events,
        eventsElasticSearch,
        dockerSwarm,
        gatus,
        dockerCommon,
        portainer,
        cassandra
      ].contains(service.nameInt)) {
        expect(p.getService(service.nameInt).use, equals(true),
            reason: '${service.nameInt} should be in Use');
      }
      if (!service.withoutUrl) {
        expect(p.getService(service.nameInt).usesSubdomain, equals(true));
        if (!<String>[collectory, alaHub, biocacheService, alerts, images]
            .contains(service.nameInt)) {
          expect(p.getService(service.nameInt).iniPath, equals(''));
        }
      }
    }

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

    expect(p.getServerServicesForTest().keys.contains('vm-013'), equals(false));
    expect(p.getHostnames(images), equals(<String>['vm-013']));
    expect(p.getHostnames(regions), equals(<String>[]));
    // Missing branding url etc

    p = LAProject.import(yoRcJson: yoRcJsonAt)[0];
    expect(p.getService(doi).use, equals(false));
    expect(p.getService(alerts).use, equals(false));
    expect(p.getServicesNameListNotInUse().contains(doi), equals(true));
    expect(p.getServicesNameListInUse().contains(doi), equals(false));
    expect(p.getServicesNameListNotInUse().contains(alerts), equals(true));
    expect(p.getServicesNameListInUse().contains(alerts), equals(false));
    for (final LAServer server in p.servers) {
      expect(p.getServerServicesForTest()[server.id]!.contains(doi),
          equals(false));
      expect(p.getServerServicesForTest()[server.id]!.contains(alerts),
          equals(false));
    }
    expect(
        p.servers.length == p.getServerServicesForTest().length, equals(true));
    expect(p.getService(collectory).suburl, equals('collectory'));
    expect(p.prodServices.isNotEmpty, equals(true));
    expect(p.serverServices.isNotEmpty, equals(true));
    expect(p.serviceDeploys.isNotEmpty, equals(true));

    p = LAProject.import(yoRcJson: yoRcJsonLaSite)[0];
    expect(
        p
            .getServiceDeploysForSomeService(userdetails)[0]
            .softwareVersions[userdetails],
        equals('2.4.0'));
    expect(
        p
            .getServiceDeploysForSomeService(collectory)[0]
            .softwareVersions[collectory],
        equals('1.6.4'));
  });

  test('Test empty project creation toString should not fail', () {
    final LAProject testProject = LAProject();
    // https://stackoverflow.com/questions/13298969/how-do-you-unittest-exceptions-in-dart
    expect(() => testProject.toString(), returnsNormally);
    expect(() => testProject.toJson(), returnsNormally);
    expect(() => testProject.toGeneratorJson(), returnsNormally);
  });

  test('get def ansible user of project', () {
    final LAProject testProject = LAProject();

    expect(testProject.getVariableValue('ansible_user'), equals('ubuntu'));
    expect(testProject.getVariable('ansible_user').value, equals('ubuntu'));
  });

  test('Template import', () async {
    final List<LAProject> templates = await LAProject.importTemplates(
        '../../assets/la-toolkit-templates.json');
    expect(templates.length, equals(10));
    for (final LAProject p in templates) {
      expect(p.servers.isNotEmpty, equals(true));
      expect(p.services.isNotEmpty, equals(true));
      expect(p.serverServices.isNotEmpty, equals(true));
      expect(p.serviceDeploys.isNotEmpty, equals(true));
      expect(p.toString().isNotEmpty, equals(true));
      expect(p.variables.isNotEmpty, equals(true));
      if (p.shortName != 'ALA' &&
          p.shortName != 'AVH' &&
          p.shortName != 'MDBA' &&
          p.shortName != 'OZCAM') {
        // The default value
        expect(p.mapBoundsFstPoint.latitude, isNot(equals(-44)));
      }
    }
  });

  test('P multi service assign', () async {
    final LAProject p = LAProject();
    final LAServer vm1 = LAServer(name: 'vm1', ip: '10.0.0.1', projectId: p.id);
    final LAServer vm2 = LAServer(name: 'vm2', ip: '10.0.0.2', projectId: p.id);
    final LAServer vm3 = LAServer(name: 'vm3', ip: '10.0.0.3', projectId: p.id);
    p.upsertServer(vm1);
    p.upsertServer(vm2);
    p.upsertServer(vm3);
    p.assign(vm1, <String>[collectory, alaHub]);
    p.assign(vm2, <String>[alaHub]);
    Map<String, List<LAService>> assignable =
        p.getServerServicesAssignable(DeploymentType.vm);

    expect(assignable[vm1.id]!.isNotEmpty, equals(true));
    expect(assignable[vm2.id]!.isNotEmpty, equals(true));
    expect(assignable[vm2.id]!.isNotEmpty, equals(true));
    expect(
        assignable[vm1.id]!.contains(p.getService(collectory)), equals(false));
    expect(assignable[vm2.id]!.contains(p.getService(alaHub)), equals(false));
    expect(assignable[vm2.id]!.contains(p.getService(alaHub)), equals(false));
    expect(assignable[vm3.id]!.contains(p.getService(alaHub)), equals(true));
    expect(
        assignable[vm1.id]!.contains(p.getService(speciesLists)), equals(true));
    expect(
        assignable[vm2.id]!.contains(p.getService(speciesLists)), equals(true));
    p.assign(vm1, <String>[collectory, alaHub, speciesLists]);
    assignable = p.getServerServicesAssignable(DeploymentType.vm);
    expect(assignable[vm1.id]!.contains(p.getService(speciesLists)),
        equals(false));
    expect(assignable[vm2.id]!.contains(p.getService(speciesLists)),
        equals(false));
    expect(
        const ListEquality<String>()
            .equals(p.getServicesNameListInServer(vm2.id), <String>[alaHub]),
        equals(true),
        reason: 'Services in vm2: ${p.getServicesNameListInServer(vm2.id)}');
    expect(
        const ListEquality<String>()
            .equals(p.getServicesNameListInServer(vm1.id), <String>[
          speciesLists,
          collectory,
          alaHub,
        ]),
        equals(true),
        reason: 'Services in vm1: ${p.getServicesNameListInServer(vm1.id)}');
    final LAServer vm4 = LAServer(name: 'vm3', ip: '10.0.0.4', projectId: p.id);
    p.upsertServer(vm4);
    assignable = p.getServerServicesAssignable(DeploymentType.vm);
    expect(assignable[vm4.id]!.contains(p.getService(alaHub)), equals(true));
    p.alaInstallRelease = '1.2.1';
    p.getServiceDetailsForVersionCheck();
    p.setServiceDeployRelease(
        alaHub, p.getServiceDefaultVersions(p.getService(alaHub))[alaHub]!);
    final List<dynamic> generatorJson =
        p.toGeneratorJson()['LA_software_versions'] as List<dynamic>;
    expect(generatorJson.length == 1, equals(true),
        reason: generatorJson.length.toString());
  });
}

void debugServiceDeployAssigned(LAProject p) {
  for (final LAServiceDeploy sd in p.serviceDeploys) {
    final LAService s =
        p.services.firstWhere((LAService s) => s.id == sd.serviceId);

    log('Service ${s.nameInt} ($s) is used: ${s.use} on $sd');
  }
  log(p.getServicesAssigned().toString());
  expect(p.serviceDeploys.length, equals(p.getServicesAssigned().length),
      reason:
          'p.serviceDeploys.length: ${p.serviceDeploys.length} != p.getServicesAssigned().length: ${p.getServicesAssigned().length}');
}
