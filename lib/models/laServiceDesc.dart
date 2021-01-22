import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:la_toolkit/models/laSubService.dart';
import 'package:mdi/mdi.dart';

import 'basicService.dart';

enum LAServiceName {
  all,
  collectory,
  ala_hub,
  biocache_service,
  ala_bie,
  bie_index,
  images,
  species_lists,
  regions,
  logger,
  solr,
  cas,
  spatial,
  webapi,
  dashboard,
  alerts,
  doi,
  biocache_backend,
  branding,
  biocache_cli,
  nameindexer,
}

extension ParseToString on LAServiceName {
  String toS() {
    return this.toString().split('.').last;
  }
}

extension EnumParser on String {
  LAServiceName toServiceDescName() {
    return LAServiceName.values.firstWhere(
        (e) =>
            e.toString().toLowerCase() ==
            '${(LAServiceName).toString()}.$this'.toLowerCase(),
        orElse: () => null); //return null if not found
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
  String depends;
  List<BasicService> basicDepends;
  bool forceSubdomain;
  String sample;
  String hint;
  bool recommended;
  String path;
  bool initUse;
  List<LASubServiceDesc> subServices;
  bool admin;
  bool alaAdmin;

  LAServiceDesc(
      {@required this.name,
      @required this.nameInt,
      @required this.desc,
      @required this.optional,
      // The host group in ansible
      @required this.group,
      this.withoutUrl = false,
      this.forceSubdomain = false,
      // Optional Some backend services don't have sample urls
      this.sample,
      // Optional: Not all services has a hint to show in the textfield
      this.hint,
      this.recommended = false,
      @required this.path,
      this.depends,
      @required this.basicDepends,
      @required this.icon,
      subServices,
      this.admin: false,
      this.alaAdmin: false,
      this.initUse})
      : subServices = subServices ?? [];

  static final Map<String, LAServiceDesc> map = {
    LAServiceName.collectory.toS(): LAServiceDesc(
        name: "collections",
        nameInt: "collectory",
        group: "collectory",
        desc: "biodiversity collections",
        optional: false,
        sample: "https://collections.ala.org.au",
        icon: Mdi.formatListBulletedType,
        basicDepends: [Java.v8, Tomcat.v8, MySql.v5_7, Nginx.def],
        admin: true,
        alaAdmin: true,
        path: ""),
    LAServiceName.ala_hub.toS(): LAServiceDesc(
        name: "records",
        nameInt: "ala_hub",
        group: "biocache-hub",
        desc: "occurrences search frontend",
        optional: false,
        hint: "Typically 'records' or similar",
        sample: "https://biocache.ala.org.au",
        icon: Icons.web,
        basicDepends: [Java.v8, Tomcat.v8, Nginx.def],
        admin: true,
        alaAdmin: false,
        path: ""),
    LAServiceName.biocache_service.toS(): LAServiceDesc(
        name: "records-ws",
        nameInt: "biocache_service",
        group: "biocache-service-clusterdb",
        desc: "occurrences web service",
        optional: false,
        icon: Mdi.databaseSearchOutline,
        sample: "https://biocache.ala.org.au/ws",
        basicDepends: [Java.v8, Tomcat.v8, Nginx.def],
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
        alaAdmin: false,
        basicDepends: [Java.v8, Tomcat.v8, Nginx.def],
        path: ""),
    LAServiceName.bie_index.toS(): LAServiceDesc(
        name: "species-ws",
        nameInt: "bie_index",
        group: "bie-index",
        desc: "species web service",
        depends: "ala_bie",
        icon: Mdi.familyTree,
        optional: false,
        sample: "https://bie.ala.org.au/ws",
        basicDepends: [Java.v8, Tomcat.v8, Nginx.def],
        admin: true,
        alaAdmin: false,
        path: ""),
    LAServiceName.images.toS(): LAServiceDesc(
        name: "images",
        nameInt: "images",
        group: "image-service",
        desc: "images service",
        optional: true,
        initUse: true,
        sample: "https://images.ala.org.au",
        icon: Mdi.imageMultipleOutline,
        basicDepends: [
          Java.v8,
          Nginx.def,
          ElasticSearch.v7_7_1,
          PostGis.v2_4,
          PostgresSql.v10
        ],
        admin: true,
        path: ""),
    LAServiceName.species_lists.toS(): LAServiceDesc(
        name: "lists",
        nameInt: "species_lists",
        group: "species-list",
        desc: "user provided species lists",
        depends: "ala_bie",
        optional: true,
        initUse: true,
        icon: Icons.playlist_add_outlined,
        sample: "https://lists.ala.org.au",
        basicDepends: [Java.v8, Tomcat.v8, MySql.v5_7, Nginx.def],
        admin: true,
        path: ""),
    LAServiceName.regions.toS(): LAServiceDesc(
        name: "regions",
        nameInt: "regions",
        group: "regions",
        desc: "regional data frontend",
        depends: "spatial",
        optional: true,
        initUse: true,
        // icon: Mdi.mapSearchOutline,
        icon: Mdi.foodSteak,
        sample: "https://regions.ala.org.au",
        basicDepends: [Java.v8, Tomcat.v8, Nginx.def],
        alaAdmin: true,
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
        basicDepends: [Java.v8, Tomcat.v8, MySql.v5_7, Nginx.def],
        path: ""),
    LAServiceName.solr.toS(): LAServiceDesc(
        name: "index",
        nameInt: "solr",
        group: "solr7-server",
        desc: "indexing (Solr)",
        optional: false,
        icon: Mdi.weatherSunny,
        basicDepends: [Java.v8, Solr.v7],
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
        basicDepends: [Java.v8, Tomcat.v8, MySql.v5_7, Mongo.v4_0, Nginx.def],
        subServices: [
          LASubServiceDesc(
            name: "CAS",
            path: '/cas',
            icon: Mdi.accountCheckOutline,
            admin: false,
            alaAdmin: false,
          ),
          LASubServiceDesc(
            name: "User Details",
            path: '/userdetails/',
            icon: Mdi.accountGroup,
            admin: true,
            alaAdmin: true,
          ),
          LASubServiceDesc(name: "API keys", path: '/apikey/', icon: Mdi.api),
          LASubServiceDesc(
              name: "CAS Management",
              path: '/cas-management/',
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
        basicDepends: [Java.v8, Nginx.def, PostGis.v2_4, PostgresSql.v9_6],
        subServices: [
          LASubServiceDesc(
              name: 'Spatial Webservice', path: '/ws/', icon: Mdi.layersPlus),
          LASubServiceDesc(
              name: 'Geoserver', path: '/geoserver/', icon: Mdi.layersSearch)
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
        basicDepends: [Java.v8, Tomcat.v8, MySql.v5_7, Nginx.def],
        admin: true,
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
        basicDepends: [Java.v8, Tomcat.v8, Nginx.def],
        alaAdmin: true,
        path: ""),
    LAServiceName.alerts.toS(): LAServiceDesc(
        name: "alerts",
        nameInt: "alerts",
        group: "alerts-service",
        desc:
            "users can subscribe to notifications about new species occurrences they are interested, regions, etc",
        optional: true,
        initUse: false,
        sample: "https://alerts.ala.org.au",
        icon: Icons.notifications_active_outlined,
        basicDepends: [Java.v8, Tomcat.v8, MySql.v5_7, Nginx.def],
        admin: true,
        path: ""),
    LAServiceName.doi.toS(): LAServiceDesc(
        name: "doi",
        nameInt: "doi",
        group: "doi-service",
        desc: "mainly used for generating DOIs of user downloads",
        optional: true,
        initUse: false,
        sample: "https://doi.ala.org.au",
        icon: Mdi.link,
        basicDepends: [
          Java.v8,
          Nginx.def,
          ElasticSearch.v7_3_0,
          PostgresSql.v9_6
        ],
        admin: true,
        path: ""),
    LAServiceName.biocache_backend.toS(): LAServiceDesc(
        name: "biocache-backend",
        nameInt: "biocache_backend",
        group: "biocache-db",
        desc: "cassandra and biocache-store backend",
        withoutUrl: true,
        optional: false,
        icon: Mdi.eyeOutline,
        basicDepends: [Java.v8, Cassandra.v3],
        path: ""),
    LAServiceName.branding.toS(): LAServiceDesc(
        name: "branding",
        nameInt: "branding",
        group: "ala-demo",
        desc: "Web branding used by all services",
        icon: Mdi.formatWrapSquare,
        withoutUrl: false,
        optional: false,
        basicDepends: [Nginx.def],
        path: "branding-${DateTime.now().year}"),
    LAServiceName.biocache_cli.toS(): LAServiceDesc(
        name: "biocache-cli",
        nameInt: "biocache_cli",
        group: "biocache-cli",
        desc:
            "manages the loading, sampling, processing and indexing of occurrence records",
        optional: false,
        withoutUrl: true,
        basicDepends: [Java.v8],
        icon: Mdi.powershell,
        path: ""),
    LAServiceName.nameindexer.toS(): LAServiceDesc(
        name: "nameindexer",
        nameInt: "nameindexer",
        group: "nameindexer",
        desc: "nameindexer",
        optional: false,
        withoutUrl: true,
        icon: Mdi.tournament,
        basicDepends: [Java.v8],
        path: "")
  };

  static LAServiceDesc get(String nameInt) {
    return map[nameInt];
  }

  static LAServiceDesc getE(LAServiceName nameInt) {
    return map[nameInt.toS()];
  }

  static List<LAServiceDesc> list = map.values.toList();
  static List<String> keyNames = map.keys.map((entry) => entry).toList();

  // Index by name instead of nameInt
  /*
  static Map<String, LAServiceDesc> mapNameIndexed =
      map.map((st, s) => MapEntry(s.name, s)); */

  /* static Map<String, List<String>> incompatibilities = {"": []}; */

  bool isCompatibleWith(LAServiceDesc otherService) {
    var compatible = true;
    if (otherService == this) return true;

    this.basicDepends.forEach((service) {
      otherService.basicDepends.forEach((otherService) {
        compatible = compatible && service.isCompatible(otherService);
      });
    });
    // print("${nameInt} is compatible with ${otherService.nameInt}: ${compatible}");
    return compatible;
  }
}
