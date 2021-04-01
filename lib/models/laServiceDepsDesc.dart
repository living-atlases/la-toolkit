import 'basicService.dart';
import 'laServiceDesc.dart';

class LAServiceDepsDesc {
  String nameInt;
  List<BasicService> basicDepends;

  LAServiceDepsDesc({
    required this.nameInt,
    required this.basicDepends,
  });

  static final Map<String, LAServiceDepsDesc> v2_0_4 = {
    LAServiceName.collectory.toS(): LAServiceDepsDesc(
      nameInt: "collectory",
      basicDepends: [Java.v8, Tomcat.v8, MySql.v5_7, Nginx.def],
    ),
    LAServiceName.ala_hub.toS(): LAServiceDepsDesc(
      nameInt: "ala_hub",
      basicDepends: [Java.v8, Tomcat.v8, Nginx.def],
    ),
    LAServiceName.biocache_service.toS(): LAServiceDepsDesc(
      nameInt: "biocache_service",
      basicDepends: [Java.v8, Tomcat.v8, Nginx.def],
    ),
    LAServiceName.ala_bie.toS(): LAServiceDepsDesc(
      nameInt: "ala_bie",
      basicDepends: [Java.v8, Tomcat.v8, Nginx.def],
    ),
    LAServiceName.bie_index.toS(): LAServiceDepsDesc(
      nameInt: "bie_index",
      basicDepends: [Java.v8, Tomcat.v8, Nginx.def],
    ),
    LAServiceName.images.toS(): LAServiceDepsDesc(
      nameInt: "images",
      basicDepends: [
        Java.v8,
        Nginx.def,
        ElasticSearch.v7_7_1,
        PostGis.v2_4,
        PostgresSql.v10
      ],
    ),
    LAServiceName.species_lists.toS(): LAServiceDepsDesc(
      nameInt: "species_lists",
      basicDepends: [Java.v8, Tomcat.v8, MySql.v5_7, Nginx.def],
    ),
    LAServiceName.regions.toS(): LAServiceDepsDesc(
      nameInt: "regions",
      basicDepends: [Java.v8, Tomcat.v8, Nginx.def],
    ),
    LAServiceName.logger.toS(): LAServiceDepsDesc(
      nameInt: "logger",
      basicDepends: [Java.v8, Tomcat.v8, MySql.v5_7, Nginx.def],
    ),
    LAServiceName.solr.toS(): LAServiceDepsDesc(
      nameInt: "solr",
      basicDepends: [Java.v8, Solr.v7],
    ),
    LAServiceName.cas.toS(): LAServiceDepsDesc(
      nameInt: "cas",
      basicDepends: [Java.v8, Tomcat.v8, MySql.v5_7, Mongo.v4_0, Nginx.def],
    ),
    LAServiceName.spatial.toS(): LAServiceDepsDesc(
      nameInt: "spatial",
      basicDepends: [Java.v8, Nginx.def, PostGis.v2_4, PostgresSql.v9_6],
    ),
    LAServiceName.webapi.toS(): LAServiceDepsDesc(
      nameInt: "webapi",
      basicDepends: [Java.v8, Tomcat.v8, MySql.v5_7, Nginx.def],
    ),
    LAServiceName.dashboard.toS(): LAServiceDepsDesc(
      nameInt: "dashboard",
      basicDepends: [Java.v8, Tomcat.v8, Nginx.def],
    ),
    LAServiceName.alerts.toS(): LAServiceDepsDesc(
      nameInt: "alerts",
      basicDepends: [Java.v8, Tomcat.v8, MySql.v5_7, Nginx.def],
    ),
    LAServiceName.doi.toS(): LAServiceDepsDesc(
      nameInt: "doi",
      basicDepends: [
        Java.v8,
        Nginx.def,
        ElasticSearch.v7_3_0,
        PostgresSql.v9_6
      ],
    ),
    LAServiceName.biocache_backend.toS(): LAServiceDepsDesc(
      nameInt: "biocache_backend",
      basicDepends: [Java.v8, Cassandra.v3],
    ),
    LAServiceName.branding.toS():
        LAServiceDepsDesc(nameInt: "branding", basicDepends: [Nginx.def]),
    LAServiceName.biocache_cli.toS(): LAServiceDepsDesc(
      nameInt: "biocache_cli",
      basicDepends: [Java.v8],
    ),
    LAServiceName.nameindexer.toS(): LAServiceDepsDesc(
      nameInt: "nameindexer",
      basicDepends: [Java.v8],
    )
  };
/*
  static final Map<String, Map<String, LAServiceDepsDesc>> map = {
    "v2.0.6": v2_0_4,
    "v2.0.5": v2_0_4,
    "v2.0.4": v2_0_4,
    "latest": v2_0_4,
   }; */

  static Map<String, LAServiceDepsDesc> getDeps(String? version) {
    switch (version) {
      case "v2.0.6":
        return v2_0_4;
      default:
        return v2_0_4;
    }
  }

  // use https://pub.dev/packages/pub_semver/example
  // toolkit 1.0.22, ala-install 2.0.6 - gen 1.1.36
}
