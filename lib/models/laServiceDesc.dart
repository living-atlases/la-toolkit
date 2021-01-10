import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:la_toolkit/models/laSubService.dart';
import 'package:mdi/mdi.dart';

import 'basicService.dart';

class LAServiceDesc {
  String name;
  String nameInt;
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

  static Map<String, LAServiceDesc> map = {
    "collectory": LAServiceDesc(
        name: "collections",
        nameInt: "collectory",
        desc: "biodiversity collections",
        optional: false,
        sample: "https://collections.ala.org.au",
        icon: Mdi.formatListBulletedType,
        basicDepends: [Java.v8, Tomcat.v8, MySql.v5_7, Nginx.def],
        admin: true,
        alaAdmin: true,
        path: ""),
    "ala_hub": LAServiceDesc(
        name: "records",
        nameInt: "ala_hub",
        desc: "occurrences search frontend",
        optional: false,
        hint: "Typically 'records' or similar",
        sample: "https://biocache.ala.org.au",
        icon: Icons.web,
        basicDepends: [Java.v8, Tomcat.v8, Nginx.def],
        admin: true,
        alaAdmin: false,
        path: ""),
    "biocache_service": LAServiceDesc(
        name: "records-ws",
        nameInt: "biocache_service",
        desc: "occurrences web service",
        optional: false,
        icon: Mdi.databaseSearchOutline,
        sample: "https://biocache.ala.org.au/ws",
        basicDepends: [Java.v8, Tomcat.v8, Nginx.def],
        path: ""),
    "ala_bie": LAServiceDesc(
        name: "species",
        nameInt: "ala_bie",
        desc: "species search frontend",
        optional: true,
        initUse: true,
        icon: Mdi.beeFlower,
        sample: "https://bie.ala.org.au",
        admin: false,
        alaAdmin: false,
        basicDepends: [Java.v8, Tomcat.v8, Nginx.def],
        path: ""),
    "bie_index": LAServiceDesc(
        name: "species-ws",
        nameInt: "bie_index",
        desc: "species web service",
        depends: "ala_bie",
        icon: Mdi.familyTree,
        optional: false,
        sample: "https://bie.ala.org.au/ws",
        basicDepends: [Java.v8, Tomcat.v8, Nginx.def],
        admin: true,
        alaAdmin: false,
        path: ""),
    "images": LAServiceDesc(
        name: "images",
        nameInt: "images",
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
    "species_lists": LAServiceDesc(
        name: "lists",
        nameInt: "species_lists",
        desc: "user provided species lists",
        depends: "ala_bie",
        optional: true,
        initUse: true,
        icon: Icons.playlist_add_outlined,
        sample: "https://lists.ala.org.au",
        basicDepends: [Java.v8, Tomcat.v8, MySql.v5_7, Nginx.def],
        admin: true,
        path: ""),
    "regions": LAServiceDesc(
        name: "regions",
        nameInt: "regions",
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
    "logger": LAServiceDesc(
        name: "logger",
        nameInt: "logger",
        desc: "event logging (downloads stats, etc)",
        optional: false,
        icon: Mdi.mathLog,
        sample: "https://logger.ala.org.au",
        admin: true,
        basicDepends: [Java.v8, Tomcat.v8, MySql.v5_7, Nginx.def],
        path: ""),
    "solr": LAServiceDesc(
        name: "index",
        nameInt: "solr",
        desc: "indexing (Solr)",
        optional: false,
        icon: Mdi.weatherSunny,
        basicDepends: [Java.v8, Solr.v7],
        admin: false,
        alaAdmin: false,
        path: ""),
    "cas": LAServiceDesc(
        name: "auth",
        nameInt: "cas",
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
    "spatial": LAServiceDesc(
        name: "spatial",
        nameInt: "spatial",
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
    "webapi": LAServiceDesc(
        name: "webapi",
        nameInt: "webapi",
        desc: "API documentation service",
        optional: true,
        initUse: false,
        sample: "https://api.ala.org.au",
        icon: Icons.integration_instructions_outlined,
        basicDepends: [Java.v8, Tomcat.v8, MySql.v5_7, Nginx.def],
        admin: true,
        path: ""),
    "dashboard": LAServiceDesc(
        name: "dashboard",
        nameInt: "dashboard",
        desc: "Dashboard with portal stats",
        optional: true,
        initUse: false,
        sample: "https://dashboard.ala.org.au",
        icon: Mdi.tabletDashboard,
        basicDepends: [Java.v8, Tomcat.v8, Nginx.def],
        alaAdmin: true,
        path: ""),
    "alerts": LAServiceDesc(
        name: "alerts",
        nameInt: "alerts",
        desc:
            "users can subscribe to notifications about new species occurrences they are interested, regions, etc",
        optional: true,
        initUse: false,
        sample: "https://alerts.ala.org.au",
        icon: Icons.notifications_active_outlined,
        basicDepends: [Java.v8, Tomcat.v8, MySql.v5_7, Nginx.def],
        admin: true,
        path: ""),
    "doi": LAServiceDesc(
        name: "doi",
        nameInt: "doi",
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
    "biocache_backend": LAServiceDesc(
        name: "biocache-backend",
        nameInt: "biocache_backend",
        desc: "cassandra and biocache-store backend",
        withoutUrl: true,
        optional: false,
        icon: Mdi.eyeOutline,
        basicDepends: [Java.v8, Cassandra.v3],
        path: ""),
    "branding": LAServiceDesc(
        name: "branding",
        nameInt: "branding",
        desc: "Web branding used by all services",
        icon: Mdi.formatWrapSquare,
        withoutUrl: true,
        optional: false,
        basicDepends: [Nginx.def],
        path: ""),
    "biocache_cli": LAServiceDesc(
        name: "biocache-cli",
        nameInt: "biocache_cli",
        desc:
            "manages the loading, sampling, processing and indexing of occurrence records",
        optional: false,
        withoutUrl: true,
        basicDepends: [Java.v8],
        icon: Mdi.powershell,
        path: ""),
    "nameindexer": LAServiceDesc(
        name: "nameindexer",
        nameInt: "nameindexer",
        desc: "nameindexer",
        optional: false,
        withoutUrl: true,
        icon: Mdi.tournament,
        basicDepends: [Java.v8],
        path: "")
  };

  static List<LAServiceDesc> list = map.values.toList();
  static List<String> names = map.keys.toList();

  // Index by name instead of nameInt
  static Map<String, LAServiceDesc> mapNameIndexed =
      map.map((st, s) => MapEntry(s.name, s));

  static Map<String, List<String>> incompatibilities = {"": []};

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
