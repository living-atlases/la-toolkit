import "package:collection/collection.dart";
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:la_toolkit/models/LAServiceConstants.dart';
import 'package:la_toolkit/models/laServiceDepsDesc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'laServiceName.dart';

class LAServiceDesc {
  String name;
  String nameInt;
  String group;
  String? alias;
  String desc;
  IconData icon;
  bool optional;
  bool withoutUrl;
  LAServiceName? depends;
  bool forceSubdomain;
  String? sample;
  String? hint;
  bool recommended;
  String path;
  bool initUse;
  bool admin;
  bool alaAdmin;
  bool hubCapable;
  bool allowMultipleDeploys;
  String? artifact;
  // used for spatial-service apikeys/userdetails/etc
  bool isSubService;
  LAServiceName? parentService;

  LAServiceDesc(
      {required this.name,
      required this.nameInt,
      required this.desc,
      required this.optional,
      // The host group in ansible
      required this.group,
      this.withoutUrl = false,
      this.forceSubdomain = false,
      // Optional Some backend services don't have sample urls
      this.sample,
      // Optional: Not all services has a hint to show in the textfield
      this.hint,
      this.recommended = false,
      required this.path,
      this.depends,
      required this.icon,
      this.isSubService = false,
      this.admin = false,
      this.alaAdmin = false,
      this.initUse = false,
      this.artifact,
      this.alias,
      this.allowMultipleDeploys = false,
      this.hubCapable = false,
      this.parentService});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LAServiceDesc &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          nameInt == other.nameInt &&
          group == other.group &&
          desc == other.desc &&
          icon == other.icon &&
          optional == other.optional &&
          withoutUrl == other.withoutUrl &&
          depends == other.depends &&
          forceSubdomain == other.forceSubdomain &&
          sample == other.sample &&
          hint == other.hint &&
          recommended == other.recommended &&
          path == other.path &&
          initUse == other.initUse &&
          admin == other.admin &&
          alaAdmin == other.alaAdmin &&
          artifact == other.artifact &&
          alias == other.alias &&
          allowMultipleDeploys == other.allowMultipleDeploys &&
          parentService == other.parentService &&
          hubCapable == other.hubCapable;

  @override
  int get hashCode =>
      name.hashCode ^
      nameInt.hashCode ^
      group.hashCode ^
      desc.hashCode ^
      icon.hashCode ^
      optional.hashCode ^
      withoutUrl.hashCode ^
      depends.hashCode ^
      forceSubdomain.hashCode ^
      sample.hashCode ^
      hint.hashCode ^
      recommended.hashCode ^
      path.hashCode ^
      initUse.hashCode ^
      admin.hashCode ^
      alaAdmin.hashCode ^
      artifact.hashCode ^
      alias.hashCode ^
      parentService.hashCode ^
      allowMultipleDeploys.hashCode ^
      hubCapable.hashCode;

  static final Map<String, LAServiceDesc> _map = {
    collectory: LAServiceDesc(
        name: "collections",
        nameInt: collectory,
        group: "collectory",
        desc: "biodiversity collections",
        optional: false,
        sample: "https://collections.ala.org.au",
        icon: MdiIcons.formatListBulletedType,
        admin: true,
        alaAdmin: true,
        artifact: 'ala-collectory',
        allowMultipleDeploys: false,
        path: ""),
    alaHub: LAServiceDesc(
        name: "records",
        alias: "biocache-hub",
        nameInt: "ala_hub",
        group: "biocache-hub",
        desc: "occurrences search frontend (aka biocache-hub)",
        optional: false,
        hint: "Typically 'records' or similar",
        sample: "https://biocache.ala.org.au",
        icon: Icons.web,
        admin: true,
        alaAdmin: true,
        hubCapable: true,
        artifact: 'ala-hub',
        allowMultipleDeploys: true,
        path: ""),
    biocacheService: LAServiceDesc(
        name: "records-ws",
        alias: "biocache-service",
        nameInt: "biocache_service",
        group: "biocache-service-clusterdb",
        desc: "occurrences web service (aka biocache-service)",
        optional: false,
        icon: MdiIcons.databaseSearchOutline,
        sample: "https://biocache.ala.org.au/ws",
        artifact: "biocache-service",
        allowMultipleDeploys: true,
        path: ""),
    bie: LAServiceDesc(
        name: "species",
        alias: "bie",
        nameInt: "ala_bie",
        group: "bie-hub",
        desc: "species search frontend",
        optional: true,
        initUse: true,
        icon: MdiIcons.beeFlower,
        sample: "https://bie.ala.org.au",
        admin: false,
        alaAdmin: true,
        hubCapable: true,
        allowMultipleDeploys: true,
        artifact: "ala-bie",
        path: ""),
    bieIndex: LAServiceDesc(
        name: "species-ws",
        alias: "bie-index",
        nameInt: "bie_index",
        group: "bie-index",
        desc: "species web service",
        depends: LAServiceName.ala_bie,
        icon: MdiIcons.familyTree,
        optional: false,
        sample: "https://bie.ala.org.au/ws",
        admin: true,
        alaAdmin: true,
        artifact: "bie-index",
        allowMultipleDeploys: true,
        path: ""),
    images: LAServiceDesc(
        name: "images",
        nameInt: "images",
        group: "image-service",
        desc: "images service",
        optional: true,
        initUse: true,
        alaAdmin: true,
        sample: "https://images.ala.org.au",
        icon: MdiIcons.imageMultipleOutline,
        admin: true,
        artifact: "image-service",
        allowMultipleDeploys: false,
        path: ""),
    speciesLists: LAServiceDesc(
        name: "lists",
        nameInt: "species_lists",
        group: "species-list",
        desc: "user provided species lists",
        depends: LAServiceName.ala_bie,
        optional: true,
        alaAdmin: true,
        initUse: true,
        icon: Icons.playlist_add_outlined,
        sample: "https://lists.ala.org.au",
        admin: true,
        artifact: "specieslist-webapp",
        allowMultipleDeploys: false,
        path: ""),
    regions: LAServiceDesc(
        name: regions,
        nameInt: regions,
        group: regions,
        desc: "regional data frontend",
        depends: LAServiceName.spatial,
        optional: true,
        initUse: true,
        // icon: MdiIcons.mapSearchOutline,
        icon: MdiIcons.foodSteak,
        sample: "https://regions.ala.org.au",
        alaAdmin: true,
        hubCapable: true,
        allowMultipleDeploys: true, // ALA does not have this service redundant
        artifact: "regions",
        path: ""),
    logger: LAServiceDesc(
        name: "logger",
        nameInt: "logger",
        group: "logger-service",
        desc: "event logging (downloads stats, etc)",
        optional: false,
        icon: MdiIcons.mathLog,
        sample: "https://logger.ala.org.au",
        admin: true,
        alaAdmin: true,
        artifact: "logger-service",
        allowMultipleDeploys: false,
        path: ""),
    solr: LAServiceDesc(
        name: solr,
        nameInt: solr,
        group: "solr7-server",
        desc: "species and/or biocache-store indexing",
        optional: false,
        icon: MdiIcons.weatherSunny,
        admin: false,
        alaAdmin: false,
        initUse: true,
        artifact: 'solr',
        allowMultipleDeploys: false,
        path: ""),
    cas: LAServiceDesc(
        name: "auth",
        alias: "cas",
        nameInt: cas,
        group: "cas-servers",
        desc: "CAS authentication system",
        optional: true,
        initUse: true,
        forceSubdomain: true,
        sample: "https://auth.ala.org.au/cas/",
        icon: MdiIcons.accountCheckOutline,
        artifact: "cas",
        recommended: true,
        admin: false,
        alaAdmin: false,
        path: "/cas"),
    userdetails: LAServiceDesc(
        nameInt: userdetails,
        name: "User Details",
        path: '/userdetails',
        group: "cas-servers",
        optional: true,
        initUse: true,
        desc: "",
        icon: MdiIcons.accountGroup,
        artifact: "userdetails",
        admin: true,
        alaAdmin: true,
        parentService: LAServiceName.cas,
        isSubService: true),
    apikey: LAServiceDesc(
        nameInt: apikey,
        name: "API keys",
        path: '/apikey',
        icon: MdiIcons.api,
        group: "cas-servers",
        optional: true,
        initUse: true,
        isSubService: true,
        parentService: LAServiceName.cas,
        desc: "",
        artifact: "apikey"),
    casManagement: LAServiceDesc(
        nameInt: casManagement,
        name: "CAS Management",
        path: '/cas-management',
        artifact: "cas-management",
        group: "cas-servers",
        optional: true,
        initUse: true,
        desc: "",
        parentService: LAServiceName.cas,
        icon: MdiIcons.accountNetwork,
        isSubService: true),
    spatial: LAServiceDesc(
        name: "spatial",
        nameInt: "spatial",
        group: "spatial",
        desc: "spatial front-end",
        optional: true,
        initUse: true,
        forceSubdomain: true,
        icon: MdiIcons.layers,
        sample: "https://spatial.ala.org.au",
        artifact: 'spatial-hub',
        path: ""),
    spatialService: LAServiceDesc(
      name: 'Spatial Webservice',
      nameInt: spatialService,
      path: '/ws',
      artifact: 'spatial-service',
      icon: MdiIcons.layersPlus,
      alaAdmin: true,
      isSubService: true,
      parentService: LAServiceName.spatial,
      group: "spatial-service",
      optional: true,
      initUse: true,
      desc: "",
    ),
    'geoserver': LAServiceDesc(
        name: 'Geoserver',
        nameInt: 'geoserver',
        path: '/geoserver',
        isSubService: true,
        parentService: LAServiceName.spatial,
        group: "geoserver",
        optional: true,
        initUse: true,
        desc: "",
        icon: MdiIcons.layersSearch),
    webapi: LAServiceDesc(
        name: "webapi",
        nameInt: "webapi",
        group: "webapi_standalone",
        desc: "API documentation service",
        optional: true,
        initUse: false,
        sample: "https://api.ala.org.au",
        icon: Icons.integration_instructions_outlined,
        admin: true,
        artifact: 'webapi',
        path: ""),
    dashboard: LAServiceDesc(
        name: "dashboard",
        nameInt: "dashboard",
        group: "dashboard",
        desc: "Dashboard with portal stats",
        optional: true,
        initUse: false,
        sample: "https://dashboard.ala.org.au",
        icon: MdiIcons.tabletDashboard,
        alaAdmin: true,
        artifact: 'dashboard',
        allowMultipleDeploys: false,
        path: ""),
    sds: LAServiceDesc(
        name: "sds",
        nameInt: "sds",
        group: "sds",
        desc: "Sensitive Data Service (SDS)",
        optional: true,
        initUse: false,
        sample: "https://sds.ala.org.au",
        depends: LAServiceName.species_lists,
        icon: Icons.blur_circular,
        admin: false,
        alaAdmin: true,
        allowMultipleDeploys: false,
        artifact: "sds-webapp2",
        path: ""),
    alerts: LAServiceDesc(
        name: "alerts",
        nameInt: "alerts",
        group: "alerts-service",
        desc:
            "users can subscribe to notifications about new species occurrences they are interested, regions, etc",
        optional: true,
        alaAdmin: true,
        initUse: false,
        sample: "https://alerts.ala.org.au",
        icon: Icons.notifications_active_outlined,
        admin: true,
        artifact: "alerts",
        allowMultipleDeploys: false,
        path: ""),
    doi: LAServiceDesc(
        name: "doi",
        nameInt: "doi",
        group: "doi-service",
        desc: "mainly used for generating DOIs of user downloads",
        optional: true,
        alaAdmin: true,
        initUse: false,
        sample: "https://doi.ala.org.au",
        icon: MdiIcons.link,
        admin: true,
        allowMultipleDeploys: false,
        artifact: "doi-service",
        path: ""),
    branding: LAServiceDesc(
        name: "branding",
        nameInt: "branding",
        group: "branding",
        desc: "Web branding used by all services",
        icon: Icons.format_paint,
        sample: "Styling-the-web-app",
        withoutUrl: false,
        optional: false,
        alaAdmin: false,
        allowMultipleDeploys: true,
        hubCapable: true,
        path: "brand-${DateTime.now().year}"),
    biocacheCli: LAServiceDesc(
        name: "biocache-cli",
        alias: "biocache-store",
        nameInt: "biocache_cli",
        group: "biocache-cli",
        desc:
            "manages the loading, sampling, processing and indexing of occurrence records",
        optional: true,
        withoutUrl: true,
        initUse: true,
        icon: MdiIcons.powershell,
        artifact: "biocache-store",
        allowMultipleDeploys: true,
        path: ""),
    nameindexer: LAServiceDesc(
        name: "nameindexer",
        nameInt: "nameindexer",
        group: "nameindexer",
        desc: "nameindexer",
        optional: true,
        withoutUrl: true,
        initUse: true,
        icon: MdiIcons.tournament,
        artifact: "ala-name-matching",
        allowMultipleDeploys: true,
        path: ""),
    namematchingService: LAServiceDesc(
        name: "namematching",
        nameInt: namematchingService,
        group: "namematching-service",
        desc: "namematching webservice",
        optional: true,
        withoutUrl: false,
        initUse: false,
        icon: MdiIcons.textSearch,
        artifact: "ala-namematching-server",
        sample: "https://namematching-ws.ala.org.au/",
        allowMultipleDeploys: false,
        admin: false,
        alaAdmin: false,
        path: ""),
    dataQuality: LAServiceDesc(
        name: "data-quality",
        nameInt: dataQuality,
        group: "data_quality_filter_service",
        desc: "Data Quality Filter Service",
        optional: true,
        withoutUrl: false,
        initUse: false,
        // icon: MdiIcons.airFilter,
        icon: MdiIcons.filterPlusOutline,
        artifact: "data-quality-filter-service",
        sample: "https://data-quality-service.ala.org.au",
        allowMultipleDeploys: false,
        alaAdmin: true,
        admin: false,
        path: ""),
    biocacheBackend: LAServiceDesc(
        name: "biocache-store",
        nameInt: biocacheBackend,
        group: "biocache-db",
        desc: "cassandra and biocache-store backend",
        withoutUrl: true,
        optional: true,
        initUse: true,
        allowMultipleDeploys: false,
        icon: MdiIcons.eyeOutline,
        path: ""),
    pipelines: LAServiceDesc(
        name: pipelines,
        nameInt: pipelines,
        group: "pipelines",
        desc:
            "Pipelines for data processing and indexing of biodiversity data (replacement to biocache-store)",
        optional: true,
        withoutUrl: true,
        admin: false,
        alaAdmin: false,
        // We use apt for check versions, but we set this to get the version
        artifact: pipelines,
        icon: MdiIcons.pipe,
        allowMultipleDeploys: true,
        path: ""),
    spark: LAServiceDesc(
        name: spark,
        nameInt: spark,
        group: spark,
        desc: "Spark cluster for Pipelines",
        optional: true,
        withoutUrl: true,
        admin: false,
        alaAdmin: false,
        icon: MdiIcons.shape,
        allowMultipleDeploys: true,
        parentService: LAServiceName.pipelines,
        path: ""),
    hadoop: LAServiceDesc(
        name: hadoop,
        nameInt: hadoop,
        group: hadoop,
        desc: "Hadoop cluster for Pipelines",
        optional: true,
        withoutUrl: true,
        admin: false,
        alaAdmin: false,
        icon: MdiIcons.elephant,
        allowMultipleDeploys: true,
        parentService: LAServiceName.pipelines,
        path: ""),
    pipelinesJenkins: LAServiceDesc(
        name: pipelinesJenkins,
        nameInt: pipelinesJenkins,
        group: pipelinesJenkins,
        desc: "Jenkins for pipelines",
        optional: true,
        withoutUrl: true,
        admin: false,
        alaAdmin: false,
        // We use apt for check versions
        icon: MdiIcons.accountMinusOutline,
        allowMultipleDeploys: true,
        depends: LAServiceName.pipelines,
        path: ""),
    solrcloud: LAServiceDesc(
        name: solrcloud,
        nameInt: solrcloud,
        group: solrcloud,
        desc: "pipelines indexing",
        optional: true,
        icon: MdiIcons.weatherSunny,
        admin: false,
        alaAdmin: false,
        artifact: solrcloud,
        allowMultipleDeploys: true,
        depends: LAServiceName.pipelines,
        withoutUrl: true,
        path: ""),
    zookeeper: LAServiceDesc(
        name: zookeeper,
        nameInt: zookeeper,
        group: zookeeper,
        desc: "zookeeper, for solrcloud coordination",
        optional: true,
        icon: MdiIcons.shovel,
        admin: false,
        alaAdmin: false,
        // artifact: 'solr',
        depends: LAServiceName.pipelines,
        withoutUrl: true,
        allowMultipleDeploys: true,
        path: ""),
    //spark: LAServiceDesc(name: spark, nameIn),

    /*    artifactAnsibleVar: "biocollect_version",
    artifactAnsibleVar: "ecodata_version",
    artifactAnsibleVar: "ecodata_version",*/
  };

  static LAServiceDesc get(String nameInt) {
    return _map[nameInt]!;
  }

  static bool isLAService(String nameInt) {
    return _map.containsKey(nameInt);
  }

  static LAServiceDesc getE(LAServiceName nameInt) {
    return _map[nameInt.toS()]!;
  }

  static List<LAServiceDesc> list(bool isHub) =>
      isHub ? LAServiceDesc.listHubCapable : LAServiceDesc._list;

  static List<LAServiceDesc> listWithArtifact() =>
      list(false).where((sd) => sd.artifact != null).toList();

  static List<String> listS(bool isHub) =>
      list(isHub).map((s) => s.nameInt).toList();

  static List<LAServiceDesc> listSorted(bool isHub) =>
      List<LAServiceDesc>.from(list(isHub))
        ..sort((a, b) => compareAsciiUpperCase(a.name, b.name));

  static List<LAServiceDesc> listRedundant(bool isHub) => LAServiceDesc._list
      .where((s) =>
          s.allowMultipleDeploys == true && (!isHub || (isHub && s.hubCapable)))
      .toList();

  static List<LAServiceDesc> listNoSub(bool isHub) => isHub
      ? LAServiceDesc.listHubCapable
      : LAServiceDesc._list.where((s) => s.isSubService != true).toList();

  static final List<LAServiceDesc> _list = _map.values.toList();
  static List<LAServiceDesc> listHubCapable =
      _list.where((LAServiceDesc s) => s.hubCapable).toList();

  static List<LAServiceDesc> childServices(String parentNameInt) => _map.values
      .where((s) =>
          s.parentService != null && s.parentService!.toS() == parentNameInt)
      .toList();

  static final List<String> internalServices = [
    nameindexer,
    biocacheBackend,
    biocacheCli,
    branding,
    spark,
    pipelines,
    hadoop,
  ];

  static final List<String> subServices = [
    apikey,
    casManagement,
    userdetails,
    spatialService,
    geoserver,
    spark,
    hadoop,
    pipelinesJenkins,
    nameindexer,
    biocacheCli
  ];

  bool isCompatibleWith(String? alaInstallVersion, LAServiceDesc otherService) {
    bool compatible = true;
    if (otherService == this) return true;

    Map<String, LAServiceDepsDesc> deps =
        LAServiceDepsDesc.getDeps(alaInstallVersion);

    if (name == cas && otherService == LAServiceDesc.get(pipelines) ||
        name == pipelines && otherService == LAServiceDesc.get(cas)) {
      // As it uses the same port cas and hadoop (9000)
      return false;
    }

    for (var service in deps[nameInt]!.serviceDepends) {
      for (var otherService in deps[otherService.nameInt]!.serviceDepends) {
        compatible = compatible && service.isCompatible(otherService);
        /* This fails for http port etc
        for (var port in service.tcp) {
          compatible = compatible && !otherService.tcp.contains(port);
        }
        for (var port in service.udp) {
          compatible = compatible && !otherService.udp.contains(port);
        } */
      }
    }
    return compatible;
  }

  static String swNameWithAliasForHumans(String sw) {
    String name;
    String? alias;
    try {
      final LAServiceDesc laServiceDesc = LAServiceDesc.get(sw);
      name = laServiceDesc.name;
      alias = laServiceDesc.alias;
    } catch (e) {
      name = sw;
    }
    return "$name${alias != null ? ' (' + alias + ')' : ''}";
  }

  static final Map<String, String> swToAnsibleVars = {
    "collectory": 'collectory_version',
    "ala_hub": 'biocache_hub_version',
    "biocache_service": 'biocache_service_version',
    "ala_bie": 'bie_hub_version',
    "bie_index": 'bie_index_version',
    "images": "image_service_version",
    "species_lists": "species_list_version",
    "regions": "regions_version",
    "logger": "logger_version",
    "cas": "cas_version",
    "userdetails": "user_details_version",
    "apikey": "apikey_version",
    "cas_management": "cas_management_version",
    "spatial": "spatial_hub_version",
    "spatial_service": "spatial_service_version",
    "webapi": "webapi_version",
    "dashboard": "dashboard_version",
    "sds": "sds_version",
    "alerts": "alerts_version",
    "doi": "doi_service_version",
    "biocache_cli": "biocache_cli_version",
    "nameindexer": "ala_name_matching_version",
    "namemaching_service": "namematching_service_version",
    "data_quality": "data_quality_filter_service_version",
    "solr": "solr_version",
    "solrcloud": "solrcloud_version"
  };

  @override
  String toString() {
    return 'LAServiceDesc{nameInt: $nameInt, alias: $alias, hubCapable: $hubCapable, allowMultipleDeploys: $allowMultipleDeploys, artifact: $artifact}';
  }
}
