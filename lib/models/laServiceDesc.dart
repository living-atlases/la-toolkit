import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:la_toolkit/models/laServiceDepsDesc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'LAServiceConstants.dart';
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
  String? iniPath;
  String? repository;
  bool initUse;
  bool admin;
  bool alaAdmin;
  bool hubCapable;
  bool allowMultipleDeploys;
  String? artifacts;
  bool dockerSupport;

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
      // Used only when creating the service (useful for /cas).
      this.iniPath,
      this.depends,
      required this.icon,
      this.isSubService = false,
      this.admin = false,
      this.alaAdmin = false,
      this.initUse = false,
      this.artifacts,
      this.alias,
      this.allowMultipleDeploys = false,
      this.hubCapable = false,
      this.repository,
      this.parentService,
      this.dockerSupport = false});

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
          repository == other.repository &&
          initUse == other.initUse &&
          admin == other.admin &&
          alaAdmin == other.alaAdmin &&
          artifacts == other.artifacts &&
          alias == other.alias &&
          allowMultipleDeploys == other.allowMultipleDeploys &&
          parentService == other.parentService &&
          dockerSupport == other.dockerSupport &&
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
      repository.hashCode ^
      path.hashCode ^
      initUse.hashCode ^
      admin.hashCode ^
      alaAdmin.hashCode ^
      artifacts.hashCode ^
      alias.hashCode ^
      parentService.hashCode ^
      allowMultipleDeploys.hashCode ^
      dockerSupport.hashCode ^
      hubCapable.hashCode;

  static final Map<String, LAServiceDesc> _map = {
    dockerSwarm: LAServiceDesc(
      name: "Docker Swarm",
      nameInt: dockerSwarm,
      group: dockerSwarm,
      icon: MdiIcons.ferry,
      withoutUrl: true,
      allowMultipleDeploys: true,
      desc: 'docker swarm deployment support (in development)',
      optional: true,
      isSubService: false,
      path: "",
    ),
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
        // multiple with last with precedence
        artifacts: 'ala-collectory collectory',
        allowMultipleDeploys: false,
        repository: 'https://github.com/AtlasOfLivingAustralia/collectory/',
        dockerSupport: true,
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
        artifacts: 'ala-hub',
        allowMultipleDeploys: true,
        repository: 'https://github.com/AtlasOfLivingAustralia/biocache-hubs',
        dockerSupport: true,
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
        artifacts: "biocache-service",
        allowMultipleDeploys: true,
        repository:
            'https://github.com/AtlasOfLivingAustralia/biocache-service',
        dockerSupport: true,
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
        artifacts: "ala-bie ala-bie-hub",
        repository: 'https://github.com/AtlasOfLivingAustralia/ala-bie-hub',
        dockerSupport: true,
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
        artifacts: "bie-index",
        allowMultipleDeploys: true,
        repository: 'https://github.com/AtlasOfLivingAustralia/bie-index',
        dockerSupport: true,
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
        artifacts: "image-service",
        allowMultipleDeploys: false,
        repository: 'https://github.com/AtlasOfLivingAustralia/image-service',
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
        artifacts: "specieslist-webapp",
        allowMultipleDeploys: false,
        repository:
            'https://github.com/AtlasOfLivingAustralia/specieslist-webapp',
        dockerSupport: true,
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
        allowMultipleDeploys: true,
        // ALA does not have this service redundant
        artifacts: "regions",
        repository: 'https://github.com/AtlasOfLivingAustralia/regions',
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
        artifacts: "logger-service",
        allowMultipleDeploys: false,
        repository: 'https://github.com/AtlasOfLivingAustralia/logger-service',
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
        artifacts: 'solr',
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
        artifacts: "cas",
        recommended: true,
        admin: false,
        alaAdmin: false,
        // Issue https://github.com/living-atlases/la-toolkit/issues/8
        iniPath: "",
        repository: 'https://github.com/AtlasOfLivingAustralia/ala-cas-5',
        dockerSupport: true,
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
        artifacts: "userdetails",
        admin: true,
        alaAdmin: true,
        parentService: LAServiceName.cas,
        repository: 'https://github.com/AtlasOfLivingAustralia/userdetails',
        dockerSupport: true,
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
        repository: 'https://github.com/AtlasOfLivingAustralia/apikey',
        artifacts: "apikey"),
    casManagement: LAServiceDesc(
        nameInt: casManagement,
        name: "CAS Management",
        path: '/cas-management',
        artifacts: "cas-management",
        group: "cas-servers",
        optional: true,
        initUse: true,
        desc: "",
        parentService: LAServiceName.cas,
        icon: MdiIcons.accountNetwork,
        repository:
            'https://github.com/AtlasOfLivingAustralia/ala-cas-5-services',
        dockerSupport: true,
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
        artifacts: 'spatial-hub',
        repository: 'https://github.com/AtlasOfLivingAustralia/spatial-hub',
        path: ""),
    spatialService: LAServiceDesc(
      name: 'Spatial Webservice',
      nameInt: spatialService,
      path: '/ws',
      artifacts: 'spatial-service',
      icon: MdiIcons.layersPlus,
      alaAdmin: true,
      isSubService: true,
      parentService: LAServiceName.spatial,
      group: "spatial-service",
      optional: true,
      initUse: true,
      repository: 'https://github.com/AtlasOfLivingAustralia/spatial-service',
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
        artifacts: 'webapi',
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
        artifacts: 'dashboard',
        allowMultipleDeploys: false,
        repository: 'https://github.com/AtlasOfLivingAustralia/dashboard',
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
        artifacts: "sds-webapp2",
        repository: 'https://github.com/AtlasOfLivingAustralia/sds',
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
        artifacts: "alerts",
        allowMultipleDeploys: false,
        repository: 'https://github.com/AtlasOfLivingAustralia/alerts',
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
        artifacts: "doi-service",
        repository: 'https://github.com/AtlasOfLivingAustralia/doi-service',
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
        repository: 'https://github.com/living-atlases/base-branding',
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
        artifacts: "biocache-store",
        allowMultipleDeploys: true,
        repository: 'https://github.com/AtlasOfLivingAustralia/biocache-store',
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
        artifacts: "ala-name-matching",
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
        artifacts: namematchingService,
        sample: "https://namematching-ws.ala.org.au/",
        allowMultipleDeploys: true,
        admin: false,
        alaAdmin: false,
        dockerSupport: true,
        path: ""),
    sensitiveDataService: LAServiceDesc(
        name: "sensitive-data-service",
        nameInt: sensitiveDataService,
        group: "sensitive-data-service",
        desc: "Web services for sensitive data evaluation",
        optional: true,
        withoutUrl: false,
        initUse: false,
        icon: MdiIcons.blurLinear,
        artifacts: sensitiveDataService,
        sample: "https://sensitive-ws-test.ala.org.au",
        allowMultipleDeploys: true,
        depends: LAServiceName.sds,
        admin: false,
        alaAdmin: false,
        dockerSupport: true,
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
        artifacts: "data-quality-filter-service",
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
        artifacts: pipelines,
        icon: MdiIcons.pipe,
        allowMultipleDeploys: true,
        path: ""),
    events: LAServiceDesc(
        name: events,
        nameInt: events,
        group: events,
        desc: "events extended-data-model",
        depends: LAServiceName.pipelines,
        optional: true,
        icon: Icons.event,
        initUse: false,
        sample: "https://events.test.ala.org.au/",
        alaAdmin: false,
        hubCapable: false,
        forceSubdomain: true,
        allowMultipleDeploys: false,
        artifacts: "atlasoflivingaustralia/es2vt",
        path: ""),
    eventsElasticSearch: LAServiceDesc(
        name: "events-elasticsearch",
        nameInt: eventsElasticSearch,
        group: eventsElasticSearch,
        desc: "elasticsearch for events",
        depends: LAServiceName.events,
        optional: true,
        icon: Icons.manage_search,
        initUse: false,
        //sample: "https://events.test.ala.org.au/",
        alaAdmin: false,
        withoutUrl: true,
        hubCapable: false,
        allowMultipleDeploys: true,
        // artifacts: "atlasoflivingaustralia/es2vt",
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
        artifacts: solrcloud,
        allowMultipleDeploys: true,
        depends: LAServiceName.pipelines,
        withoutUrl: true,
        dockerSupport: true,
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
        dockerSupport: true,
        path: ""),
    biocollect: LAServiceDesc(
        name: biocollect,
        nameInt: biocollect,
        group: biocollect,
        forceSubdomain: true,
        allowMultipleDeploys: false,
        icon: Icons.compost,
        desc: 'advanced data collection tool for biodiversity science',
        sample: "https://biocollect.ala.org.au/acsa",
        artifacts: "biocollect",
        optional: true,
        path: ""),
    pdfgen: LAServiceDesc(
        name: pdfgen,
        nameInt: pdfgen,
        group: pdfgen,
        allowMultipleDeploys: false,
        desc: 'Service for turning .docs into .pdfs (used by biocollect)',
        icon: MdiIcons.filePdfBox,
        depends: LAServiceName.biocollect,
        artifacts: "pdfgen",
        optional: true,
        path: ""),
    ecodata: LAServiceDesc(
        name: ecodata,
        nameInt: ecodata,
        group: ecodata,
        forceSubdomain: true,
        icon: Icons.playlist_add_circle,
        allowMultipleDeploys: false,
        depends: LAServiceName.biocollect,
        artifacts: "ecodata",
        desc: 'provides primarily data services for BioCollect applications',
        optional: true,
        path: ""),
    ecodataReporting: LAServiceDesc(
        name: 'ecodata-reporting',
        nameInt: ecodataReporting,
        group: 'ecodata-reporting',
        forceSubdomain: true,
        icon: Icons.playlist_add_check_circle,
        allowMultipleDeploys: false,
        artifacts: "ecodata",
        depends: LAServiceName.biocollect,
        desc: 'provides reporting service for ecodata',
        optional: true,
        parentService: LAServiceName.events,
        path: ""),
    gatus: LAServiceDesc(
        name: gatus,
        nameInt: gatus,
        group: gatus,
        forceSubdomain: false,
        icon: MdiIcons.listStatus,
        allowMultipleDeploys: true,
        depends: LAServiceName.docker_swarm,
        desc: 'gatus monitoring service',
        optional: true,
        sample: 'https://status.twin.sh/',
        initUse: false,
        isSubService: false,
        dockerSupport: true,
        path: ""),
    portainer: LAServiceDesc(
        name: portainer,
        nameInt: portainer,
        group: portainer,
        forceSubdomain: false,
        optional: true,
        allowMultipleDeploys: true,
        desc: "portainer docker management service",
        depends: LAServiceName.docker_swarm,
        icon: MdiIcons.crane,
        initUse: false,
        isSubService: false,
        dockerSupport: true,
        path: ""),
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

  static final List<LAServiceDesc> _list = _map.values.toList();

  static List<LAServiceDesc> get listDockerCapable => _listDockerCapable ??=
      _list.where((s) => s.dockerSupport == true).toList();
  static List<LAServiceDesc>? _listDockerCapable;

  static List<String> get listDockerCapableS =>
      _listDockerCapableS ??= listDockerCapable.map((s) => s.nameInt).toList();
  static List<String>? _listDockerCapableS;

  static List<LAServiceDesc> get listWithArtifact =>
      _listWithArtifact ??= _list.where((sd) => sd.artifacts != null).toList();
  static List<LAServiceDesc>? _listWithArtifact;

  static List<LAServiceDesc> get listHubCapable => _listHubCapable ??=
      _list.where((LAServiceDesc s) => s.hubCapable).toList();
  static List<LAServiceDesc>? _listHubCapable;

  static List<LAServiceDesc> list(bool isHub) => isHub ? listHubCapable : _list;

  static List<LAServiceDesc> get listRedundant => _listRedundant ??=
      _list.where((s) => s.allowMultipleDeploys == true).toList();
  static List<LAServiceDesc>? _listRedundant;

  static List<LAServiceDesc> listNoSub(bool isHub) {
    return isHub
        ? listHubCapable
        : (_listNoSub ??= _list.where((s) => s.isSubService != true).toList());
  }

  static List<LAServiceDesc>? _listNoSub;

  static List<String> listS(bool isHub) {
    if (isHub) {
      return _listSHub ??= listHubCapable.map((s) => s.nameInt).toList();
    } else {
      return _listS ??= _list.map((s) => s.nameInt).toList();
    }
  }

  static List<String>? _listS;
  static List<String>? _listSHub;

  static List<LAServiceDesc> listSorted(bool isHub) {
    if (isHub) {
      return _listSortedHub ??= _sortedListFrom(listHubCapable);
    } else {
      return _listSorted ??= _sortedListFrom(_list);
    }
  }

  static List<LAServiceDesc>? _listSorted;
  static List<LAServiceDesc>? _listSortedHub;

  static List<LAServiceDesc> _sortedListFrom(List<LAServiceDesc> list) {
    return List<LAServiceDesc>.from(list)
      ..sort((a, b) => compareAsciiUpperCase(a.name, b.name));
  }

  static List<LAServiceDesc> childServices(String parentNameInt) {
    return _childServices[parentNameInt] ??= _map.values
        .where((s) =>
            s.parentService != null && s.parentService!.toS() == parentNameInt)
        .toList();
  }

  static final Map<String, List<LAServiceDesc>> _childServices = {};

  static final List<String> internalServices = [
    nameindexer,
    biocacheBackend,
    biocacheCli,
    branding,
    spark,
    pipelines,
    hadoop,
    events,
    dockerSwarm
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
      if ([toolkit, alaInstall, generator].contains(sw)) {
        name = sw;
      } else {
        final LAServiceDesc laServiceDesc = LAServiceDesc.get(sw);
        name = laServiceDesc.name;
        alias = laServiceDesc.alias;
      }
    } catch (e) {
      print("Processing software $sw: $e");
      name = sw;
    }
    return "$name${alias != null ? ' ($alias)' : ''}";
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
    "namemaching_service": "ala_namematching_service_version",
    "sensitive_data__service": "ala_sensitive_data_service_version",
    "data_quality": "data_quality_filter_service_version",
    "solr": "solr_version",
    "solrcloud": "solrcloud_version",
    biocollect: "biocollect_version",
    ecodata: "ecodata_version",
    pdfgen: "pdf_service_version"
  };

  @override
  String toString() {
    return 'LAServiceDesc{nameInt: $nameInt, alias: $alias, hubCapable: $hubCapable, allowMultipleDeploys: $allowMultipleDeploys, artifact: $artifacts}';
  }
}
