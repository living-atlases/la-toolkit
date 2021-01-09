import 'package:flutter/foundation.dart';

import 'basicService.dart';

class LAServiceDesc {
  String name;
  String nameInt;
  String desc;
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
      this.initUse});

  static Map<String, LAServiceDesc> map = {
    "collectory": LAServiceDesc(
        name: "collections",
        nameInt: "collectory",
        desc: "biodiversity collections",
        optional: false,
        sample: "https://collections.ala.org.au",
        basicDepends: [Java.v8, Tomcat.v8, MySql.v5_7, Nginx.def],
        path: ""),
    "ala_hub": LAServiceDesc(
        name: "records",
        nameInt: "ala_hub",
        desc: "occurrences search frontend",
        optional: false,
        hint: "Typically 'records' or similar",
        sample: "https://biocache.ala.org.au",
        basicDepends: [Java.v8, Tomcat.v8, Nginx.def],
        path: ""),
    "biocache_service": LAServiceDesc(
        name: "records-ws",
        nameInt: "biocache_service",
        desc: "occurrences web service",
        optional: false,
        sample: "https://biocache.ala.org.au/ws",
        basicDepends: [Java.v8, Tomcat.v8, Nginx.def],
        path: ""),
    "ala_bie": LAServiceDesc(
        name: "species",
        nameInt: "ala_bie",
        desc: "species search frontend",
        optional: true,
        initUse: true,
        sample: "https://bie.ala.org.au",
        basicDepends: [Java.v8, Tomcat.v8, Nginx.def],
        path: ""),
    "bie_index": LAServiceDesc(
        name: "species-ws",
        nameInt: "bie_index",
        desc: "species web service",
        depends: "ala_bie",
        optional: false,
        sample: "https://bie.ala.org.au/ws",
        basicDepends: [Java.v8, Tomcat.v8, Nginx.def],
        path: ""),
    "images": LAServiceDesc(
        name: "images",
        nameInt: "images",
        desc: "images service",
        optional: true,
        initUse: true,
        sample: "https://images.ala.org.au",
        basicDepends: [
          Java.v8,
          Nginx.def,
          ElasticSearch.v7_7_1,
          PostGis.v2_4,
          PostgresSql.v10
        ],
        path: ""),
    "species_lists": LAServiceDesc(
        name: "lists",
        nameInt: "species_lists",
        desc: "user provided species lists",
        depends: "ala_bie",
        optional: true,
        initUse: true,
        sample: "https://lists.ala.org.au",
        basicDepends: [Java.v8, Tomcat.v8, MySql.v5_7, Nginx.def],
        path: ""),
    "regions": LAServiceDesc(
        name: "regions",
        nameInt: "regions",
        desc: "regional data frontend",
        depends: "spatial",
        optional: true,
        initUse: true,
        sample: "https://regions.ala.org.au",
        basicDepends: [Java.v8, Tomcat.v8, Nginx.def],
        path: ""),
    "logger": LAServiceDesc(
        name: "logger",
        nameInt: "logger",
        desc: "event logging (downloads stats, etc)",
        optional: false,
        sample: "https://logger.ala.org.au",
        basicDepends: [Java.v8, Tomcat.v8, MySql.v5_7, Nginx.def],
        path: ""),
    "solr": LAServiceDesc(
        name: "index",
        nameInt: "solr",
        desc: "indexing (Solr)",
        optional: false,
        basicDepends: [Java.v8, Solr.v7],
        path: ""),
    "cas": LAServiceDesc(
        name: "auth",
        nameInt: "cas",
        desc: "CAS authentication system",
        optional: true,
        initUse: true,
        forceSubdomain: true,
        sample: "https://auth.ala.org.au/cas/",
        recommended: true,
        basicDepends: [Java.v8, Tomcat.v8, MySql.v5_7, Mongo.v4_0, Nginx.def],
        path: ""),
    "spatial": LAServiceDesc(
        name: "spatial",
        nameInt: "spatial",
        desc: "spatial front-end",
        optional: true,
        initUse: true,
        forceSubdomain: true,
        sample: "https://spatial.ala.org.au",
        basicDepends: [Java.v8, Nginx.def, PostGis.v2_4, PostgresSql.v9_6],
        path: ""),
    "webapi": LAServiceDesc(
        name: "webapi",
        nameInt: "webapi",
        desc: "API documentation service",
        optional: true,
        initUse: false,
        sample: "https://api.ala.org.au",
        basicDepends: [Java.v8, Tomcat.v8, MySql.v5_7, Nginx.def],
        path: ""),
    "dashboard": LAServiceDesc(
        name: "dashboard",
        nameInt: "dashboard",
        desc: "Dashboard with portal stats",
        optional: true,
        initUse: false,
        sample: "https://dashboard.ala.org.au",
        basicDepends: [Java.v8, Tomcat.v8, Nginx.def],
        path: ""),
    "alerts": LAServiceDesc(
        name: "alerts",
        nameInt: "alerts",
        desc:
            "users can subscribe to notifications about new species occurrences they are interested, regions, etc",
        optional: true,
        initUse: false,
        sample: "https://alerts.ala.org.au",
        basicDepends: [Java.v8, Tomcat.v8, MySql.v5_7, Nginx.def],
        path: ""),
    "doi": LAServiceDesc(
        name: "doi",
        nameInt: "doi",
        desc: "mainly used for generating DOIs of user downloads",
        optional: true,
        initUse: false,
        sample: "https://doi.ala.org.au",
        basicDepends: [
          Java.v8,
          Nginx.def,
          ElasticSearch.v7_3_0,
          PostgresSql.v9_6
        ],
        path: ""),
    "biocache_backend": LAServiceDesc(
        name: "biocache-backend",
        nameInt: "biocache_backend",
        desc: "cassandra and biocache-store backend",
        withoutUrl: true,
        optional: false,
        basicDepends: [Java.v8, Cassandra.v3],
        path: ""),
    "branding": LAServiceDesc(
        name: "branding",
        nameInt: "branding",
        desc: "Web branding used by all services",
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
        path: ""),
    "nameindexer": LAServiceDesc(
        name: "nameindexer",
        nameInt: "nameindexer",
        desc: "nameindexer",
        optional: false,
        withoutUrl: true,
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
