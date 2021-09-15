import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:la_toolkit/models/laServiceDepsDesc.dart';
import 'package:la_toolkit/models/laSubService.dart';
import 'package:mdi/mdi.dart';

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
final sds = LAServiceName.sds.toS();
final dashboard = LAServiceName.dashboard.toS();
final branding = LAServiceName.branding.toS();
final doi = LAServiceName.doi.toS();

enum LAServiceName {
  all,
  collectory,
  // ignore: constant_identifier_names
  ala_hub,
  // ignore: constant_identifier_names
  biocache_service,
  // ignore: constant_identifier_names
  ala_bie,
  // ignore: constant_identifier_names
  bie_index,
  images,
  // ignore: constant_identifier_names
  species_lists,
  regions,
  logger,
  solr,
  cas,
  spatial,
  webapi,
  dashboard,
  sds,
  alerts,
  doi,
  // ignore: constant_identifier_names
  biocache_backend,
  branding,
  // ignore: constant_identifier_names
  biocache_cli,
  // ignore: constant_identifier_names
  nameindexer,
}

extension ParseToString on LAServiceName {
  String toS() {
    return toString().split('.').last;
  }
}

extension EnumParser on String {
  LAServiceName toServiceDescName() {
    return LAServiceName.values.firstWhere((e) =>
        e.toString().toLowerCase() ==
        '${(LAServiceName).toString()}.$this'
            .toLowerCase()); //return null if not found
  }
}

class LAServiceDesc {
  String name;
  String nameInt;
  String group;
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
  List<LASubServiceDesc> subServices;
  bool admin;
  bool alaAdmin;
  bool hubCapable;
  String? artifact;
  String? artifactAnsibleVar;

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
          subServices == other.subServices &&
          admin == other.admin &&
          alaAdmin == other.alaAdmin &&
          artifact == other.artifact &&
          artifactAnsibleVar == other.artifactAnsibleVar &&
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
      subServices.hashCode ^
      admin.hashCode ^
      alaAdmin.hashCode ^
      artifact.hashCode ^
      artifactAnsibleVar.hashCode ^
      hubCapable.hashCode;

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
      subServices,
      this.admin = false,
      this.alaAdmin = false,
      this.initUse = false,
      this.artifact,
      this.artifactAnsibleVar,
      this.hubCapable = false})
      : subServices = subServices ?? [];

  static final Map<String, LAServiceDesc> _map = {
    LAServiceName.collectory.toS(): LAServiceDesc(
        name: "collections",
        nameInt: "collectory",
        group: "collectory",
        desc: "biodiversity collections",
        optional: false,
        sample: "https://collections.ala.org.au",
        icon: Mdi.formatListBulletedType,
        admin: true,
        alaAdmin: true,
        artifact: 'ala-collectory',
        artifactAnsibleVar: 'collectory_version',
        path: ""),
    LAServiceName.ala_hub.toS(): LAServiceDesc(
        name: "records",
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
        artifactAnsibleVar: 'biocache_hub_version',
        path: ""),
    LAServiceName.biocache_service.toS(): LAServiceDesc(
        name: "records-ws",
        nameInt: "biocache_service",
        group: "biocache-service-clusterdb",
        desc: "occurrences web service (aka biocache-service)",
        optional: false,
        icon: Mdi.databaseSearchOutline,
        sample: "https://biocache.ala.org.au/ws",
        artifact: "biocache-service",
        artifactAnsibleVar: 'biocache_service_version',
        path: ""),
    LAServiceName.ala_bie.toS(): LAServiceDesc(
        name: "species",
        nameInt: "ala_bie",
        group: "bie-hub",
        desc: "species search frontend",
        optional: true,
        initUse: true,
        icon: Mdi.beeFlower,
        sample: "https://bie.ala.org.au",
        admin: false,
        alaAdmin: true,
        hubCapable: true,
        artifact: "ala-bie",
        artifactAnsibleVar: 'bie_hub_version',
        path: ""),
    LAServiceName.bie_index.toS(): LAServiceDesc(
        name: "species-ws",
        nameInt: "bie_index",
        group: "bie-index",
        desc: "species web service",
        depends: LAServiceName.ala_bie,
        icon: Mdi.familyTree,
        optional: false,
        sample: "https://bie.ala.org.au/ws",
        admin: true,
        alaAdmin: true,
        artifact: "bie-index",
        artifactAnsibleVar: 'bie_index_version',
        path: ""),
    LAServiceName.images.toS(): LAServiceDesc(
        name: "images",
        nameInt: "images",
        group: "image-service",
        desc: "images service",
        optional: true,
        initUse: true,
        alaAdmin: true,
        sample: "https://images.ala.org.au",
        icon: Mdi.imageMultipleOutline,
        admin: true,
        artifact: "image-service",
        artifactAnsibleVar: "image_service_version",
        path: ""),
    LAServiceName.species_lists.toS(): LAServiceDesc(
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
        artifactAnsibleVar: "species_list_version",
        path: ""),
    LAServiceName.regions.toS(): LAServiceDesc(
        name: "regions",
        nameInt: "regions",
        group: "regions",
        desc: "regional data frontend",
        depends: LAServiceName.spatial,
        optional: true,
        initUse: true,
        // icon: Mdi.mapSearchOutline,
        icon: Mdi.foodSteak,
        sample: "https://regions.ala.org.au",
        alaAdmin: true,
        hubCapable: true,
        artifact: "regions",
        artifactAnsibleVar: "regions_version",
        path: ""),
    LAServiceName.logger.toS(): LAServiceDesc(
        name: "logger",
        nameInt: "logger",
        group: "logger-service",
        desc: "event logging (downloads stats, etc)",
        optional: false,
        icon: Mdi.mathLog,
        sample: "https://logger.ala.org.au",
        admin: true,
        artifact: "logger-service",
        artifactAnsibleVar: "logger_version",
        path: ""),
    LAServiceName.solr.toS(): LAServiceDesc(
        name: "index",
        nameInt: "solr",
        group: "solr7-server",
        desc: "indexing (Solr)",
        optional: false,
        icon: Mdi.weatherSunny,
        admin: false,
        alaAdmin: false,
        path: ""),
    LAServiceName.cas.toS(): LAServiceDesc(
        name: "auth",
        nameInt: "cas",
        group: "cas-servers",
        desc: "CAS authentication system",
        optional: true,
        initUse: true,
        forceSubdomain: true,
        sample: "https://auth.ala.org.au/cas/",
        icon: Mdi.accountCheckOutline,
        recommended: true,
        subServices: [
          LASubServiceDesc(
            name: "CAS",
            path: '/cas',
            icon: Mdi.accountCheckOutline,
            artifact: "cas",
            artifactAnsibleVar: "cas_version",
            admin: false,
            alaAdmin: false,
          ),
          LASubServiceDesc(
            name: "User Details",
            path: '/userdetails',
            icon: Mdi.accountGroup,
            artifact: "userdetails",
            artifactAnsibleVar: "user_details_version",
            admin: true,
            alaAdmin: true,
          ),
          LASubServiceDesc(
              name: "API keys",
              path: '/apikey',
              icon: Mdi.api,
              artifactAnsibleVar: "apikey_version",
              artifact: "apikey"),
          LASubServiceDesc(
              name: "CAS Management",
              path: '/cas-management',
              artifact: "cas-management",
              artifactAnsibleVar: "cas_management_version",
              icon: Mdi.accountNetwork),
        ],
        path: ""),
    LAServiceName.spatial.toS(): LAServiceDesc(
        name: "spatial",
        nameInt: "spatial",
        group: "spatial",
        desc: "spatial front-end",
        optional: true,
        initUse: true,
        forceSubdomain: true,
        icon: Mdi.layers,
        sample: "https://spatial.ala.org.au",
        artifact: 'spatial-hub',
        artifactAnsibleVar: "spatial_hub_version",
        subServices: [
          LASubServiceDesc(
              name: 'Spatial Webservice',
              path: '/ws',
              artifact: 'spatial-service',
              artifactAnsibleVar: "spatial_service_version",
              icon: Mdi.layersPlus,
              alaAdmin: true),
          LASubServiceDesc(
              name: 'Geoserver', path: '/geoserver', icon: Mdi.layersSearch)
        ],
        path: ""),
    LAServiceName.webapi.toS(): LAServiceDesc(
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
        artifactAnsibleVar: "webapi_version",
        path: ""),
    LAServiceName.dashboard.toS(): LAServiceDesc(
        name: "dashboard",
        nameInt: "dashboard",
        group: "dashboard",
        desc: "Dashboard with portal stats",
        optional: true,
        initUse: false,
        sample: "https://dashboard.ala.org.au",
        icon: Mdi.tabletDashboard,
        alaAdmin: true,
        artifact: 'dashboard',
        artifactAnsibleVar: "dashboard_version",
        path: ""),
    LAServiceName.sds.toS(): LAServiceDesc(
        name: "sds",
        nameInt: "sds",
        group: "sds",
        desc: "Sensitive Data Service (SDS)",
        optional: true,
        initUse: false,
        sample: "https://sds.ala.org.au",
        depends: LAServiceName.species_lists,
        icon: Icons.blur_circular,
        alaAdmin: true,
        artifact: "sds-webapp2",
        artifactAnsibleVar: "sds_version",
        path: ""),
    LAServiceName.alerts.toS(): LAServiceDesc(
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
        artifactAnsibleVar: "alerts_version",
        path: ""),
    LAServiceName.doi.toS(): LAServiceDesc(
        name: "doi",
        nameInt: "doi",
        group: "doi-service",
        desc: "mainly used for generating DOIs of user downloads",
        optional: true,
        alaAdmin: true,
        initUse: false,
        sample: "https://doi.ala.org.au",
        icon: Mdi.link,
        admin: true,
        artifact: "doi-service",
        artifactAnsibleVar: "doi_service_version",
        path: ""),
    LAServiceName.biocache_backend.toS(): LAServiceDesc(
        name: "biocache-backend",
        nameInt: "biocache_backend",
        group: "biocache-db",
        desc: "cassandra and biocache-store backend",
        withoutUrl: true,
        optional: false,
        icon: Mdi.eyeOutline,
        path: ""),
    LAServiceName.branding.toS(): LAServiceDesc(
        name: "branding",
        nameInt: "branding",
        group: "branding",
        desc: "Web branding used by all services",
        icon: Icons.format_paint,
        sample: "Styling-the-web-app",
        withoutUrl: false,
        optional: false,
        alaAdmin: false,
        hubCapable: true,
        path: "brand-${DateTime.now().year}"),
    LAServiceName.biocache_cli.toS(): LAServiceDesc(
        name: "biocache-cli",
        nameInt: "biocache_cli",
        group: "biocache-cli",
        desc:
            "manages the loading, sampling, processing and indexing of occurrence records",
        optional: false,
        withoutUrl: true,
        icon: Mdi.powershell,
        artifact: "biocache-store",
        artifactAnsibleVar: "biocache_cli_version",
        path: ""),
    LAServiceName.nameindexer.toS(): LAServiceDesc(
        name: "nameindexer",
        nameInt: "nameindexer",
        group: "nameindexer",
        desc: "nameindexer",
        optional: false,
        withoutUrl: true,
        icon: Mdi.tournament,
        artifact: "ala-name-matching",
        artifactAnsibleVar: "namematching_service_version",
        path: "")
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

  static final List<LAServiceDesc> _list = _map.values.toList();
  static List<LAServiceDesc> listHubCapable =
      _list.where((LAServiceDesc s) => s.hubCapable).toList();

  static List<String> internalServices = [
    LAServiceName.nameindexer.toS(),
    LAServiceName.biocache_backend.toS(),
    LAServiceName.biocache_cli.toS(),
    LAServiceName.branding.toS(),
  ];

  bool isCompatibleWith(String? alaInstallVersion, LAServiceDesc otherService) {
    bool compatible = true;
    if (otherService == this) return true;

    Map<String, LAServiceDepsDesc> deps =
        LAServiceDepsDesc.getDeps(alaInstallVersion);

    for (var service in deps[nameInt]!.serviceDepends) {
      for (var otherService in deps[otherService.nameInt]!.serviceDepends) {
        compatible = compatible && service.isCompatible(otherService);
      }
    }
    return compatible;
  }
}
