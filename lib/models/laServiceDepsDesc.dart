import 'package:la_toolkit/models/LAServiceConstants.dart';

import 'basicService.dart';

class LAServiceDepsDesc {
  String nameInt;
  List<BasicService> serviceDepends;

  LAServiceDepsDesc({
    required this.nameInt,
    required this.serviceDepends,
  });

  static final Map<String, LAServiceDepsDesc> v2_0_4 = {
    collectory: LAServiceDepsDesc(
      nameInt: collectory,
      serviceDepends: [Java.v8, Nginx.def, Tomcat.v8, MySql.v5_7],
    ),
    alaHub: LAServiceDepsDesc(
      nameInt: alaHub,
      serviceDepends: [
        Java.v8,
        Nginx.def,
        Tomcat.v8,
      ],
    ),
    biocacheService: LAServiceDepsDesc(
      nameInt: biocacheService,
      serviceDepends: [
        Java.v8,
        Nginx.def,
        Tomcat.v8,
      ],
    ),
    bie: LAServiceDepsDesc(
      nameInt: bie,
      serviceDepends: [Java.v8, Nginx.def, Tomcat.v8],
    ),
    bieIndex: LAServiceDepsDesc(
      nameInt: bieIndex,
      serviceDepends: [Java.v8, Nginx.def, Tomcat.v8],
    ),
    images: LAServiceDepsDesc(
      nameInt: images,
      serviceDepends: [
        Java.v8,
        Nginx.def,
        ElasticSearch.v7_7_1,
        PostGis.v2_4,
        PostgresSql.v10
      ],
    ),
    speciesLists: LAServiceDepsDesc(
      nameInt: speciesLists,
      serviceDepends: [
        Java.v8,
        Nginx.def,
        Tomcat.v8,
        MySql.v5_7,
      ],
    ),
    regions: LAServiceDepsDesc(
      nameInt: regions,
      serviceDepends: [Java.v8, Nginx.def, Tomcat.v8],
    ),
    logger: LAServiceDepsDesc(
      nameInt: logger,
      serviceDepends: [Java.v8, Nginx.def, Tomcat.v8, MySql.v5_7],
    ),
    solr: LAServiceDepsDesc(
      nameInt: solr,
      serviceDepends: [Java.v8, Solr.v7],
    ),
    solrcloud: LAServiceDepsDesc(
      nameInt: solrcloud,
      serviceDepends: [Java.v11, SolrCloud.v8],
    ),
    zookeeper: LAServiceDepsDesc(
      nameInt: zookeeper,
      serviceDepends: [Java.v8],
    ),
    cas: LAServiceDepsDesc(
      nameInt: cas,
      serviceDepends: [
        Java.v8,
        Nginx.def,
        MySql.v5_7,
        Mongo.v4_0,
        Cas.def,
        Postfix.def,
      ],
    ),
    userdetails: LAServiceDepsDesc(
      nameInt: userdetails,
      serviceDepends: [
        Java.v8,
        Nginx.def,
        MySql.v5_7,
        Mongo.v4_0,
        UserDetails.def,
        Postfix.def,
      ],
    ),
    apikey: LAServiceDepsDesc(
      nameInt: apikey,
      serviceDepends: [
        Java.v8,
        Nginx.def,
        MySql.v5_7,
        Cas.def,
        ApiKey.def,
      ],
    ),
    casManagement: LAServiceDepsDesc(
      nameInt: casManagement,
      serviceDepends: [
        Java.v8,
        Nginx.def,
        MySql.v5_7,
        Mongo.v4_0,
        CasManagement.def,
      ],
    ),
    spatial: LAServiceDepsDesc(
      nameInt: spatial,
      serviceDepends: [Java.v8, Nginx.def, PostGis.v2_4, PostgresSql.v9_6],
    ),
    spatialService: LAServiceDepsDesc(
      nameInt: spatialService,
      serviceDepends: [Java.v8, Nginx.def, PostGis.v2_4, PostgresSql.v9_6],
    ),
    geoserver: LAServiceDepsDesc(
      nameInt: geoserver,
      serviceDepends: [Java.v8, Nginx.def, Tomcat.v8],
    ),
    webapi: LAServiceDepsDesc(
      nameInt: webapi,
      serviceDepends: [Java.v8, Nginx.def, Tomcat.v8, MySql.v5_7],
    ),
    dashboard: LAServiceDepsDesc(
      nameInt: dashboard,
      serviceDepends: [Java.v8, Nginx.def, Tomcat.v8],
    ),
    sds: LAServiceDepsDesc(
      nameInt: sds,
      serviceDepends: [Java.v8, Nginx.def, Tomcat.v8],
    ),
    alerts: LAServiceDepsDesc(
      nameInt: alerts,
      serviceDepends: [Java.v8, Nginx.def, Tomcat.v8, Postfix.def, MySql.v5_7],
    ),
    doi: LAServiceDepsDesc(
      nameInt: doi,
      serviceDepends: [
        Java.v8,
        Nginx.def,
        ElasticSearch.v7_3_0,
        PostgresSql.v9_6,
        Postfix.def,
        Doi.def,
      ],
    ),
    biocacheBackend: LAServiceDepsDesc(
      nameInt: biocacheBackend,
      serviceDepends: [Java.v8, Cassandra.v3],
    ),
    branding:
        LAServiceDepsDesc(nameInt: "branding", serviceDepends: [Nginx.def]),
    biocacheCli: LAServiceDepsDesc(
      nameInt: biocacheCli,
      serviceDepends: [Java.v8],
    ),
    nameindexer: LAServiceDepsDesc(
      nameInt: nameindexer,
      serviceDepends: [Java.v8],
    ),
    pipelines: LAServiceDepsDesc(
      nameInt: pipelines,
      serviceDepends: [Java.v8],
    ),
    spark: LAServiceDepsDesc(
      nameInt: spark,
      serviceDepends: [Java.v8, Spark.def],
    ),
    hadoop: LAServiceDepsDesc(
      nameInt: hadoop,
      serviceDepends: [Java.v8, Hadoop.def],
    ),
    pipelinesJenkins: LAServiceDepsDesc(
      nameInt: pipelinesJenkins,
      serviceDepends: [Java.v8],
    ),
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
}
