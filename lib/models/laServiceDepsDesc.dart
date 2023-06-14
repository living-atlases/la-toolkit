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
      serviceDepends: [Nginx.def, Tomcat.def, MySql.def],
    ),
    alaHub: LAServiceDepsDesc(
      nameInt: alaHub,
      serviceDepends: [
        Nginx.def,
        Tomcat.def,
      ],
    ),
    biocacheService: LAServiceDepsDesc(
      nameInt: biocacheService,
      serviceDepends: [
        Nginx.def,
        Tomcat.def,
      ],
    ),
    bie: LAServiceDepsDesc(
      nameInt: bie,
      serviceDepends: [Nginx.def, Tomcat.def],
    ),
    bieIndex: LAServiceDepsDesc(
      nameInt: bieIndex,
      serviceDepends: [Nginx.def, Tomcat.def],
    ),
    images: LAServiceDepsDesc(
      nameInt: images,
      serviceDepends: [
        Nginx.def,
        ElasticSearch.v7_7_1,
        PostGis.def,
        PostgresSql.def
      ],
    ),
    speciesLists: LAServiceDepsDesc(
      nameInt: speciesLists,
      serviceDepends: [
        Nginx.def,
        Tomcat.def,
        MySql.def,
      ],
    ),
    regions: LAServiceDepsDesc(
      nameInt: regions,
      serviceDepends: [Nginx.def, Tomcat.def],
    ),
    logger: LAServiceDepsDesc(
      nameInt: logger,
      serviceDepends: [Nginx.def, Tomcat.def, MySql.def],
    ),
    solr: LAServiceDepsDesc(
      nameInt: solr,
      serviceDepends: [Solr.v7],
    ),
    solrcloud: LAServiceDepsDesc(
      nameInt: solrcloud,
      serviceDepends: [SolrCloud.v8],
    ),
    zookeeper: LAServiceDepsDesc(
      nameInt: zookeeper,
      serviceDepends: [],
    ),
    cas: LAServiceDepsDesc(
      nameInt: cas,
      serviceDepends: [
        Nginx.def,
        MySql.def,
        Mongo.v4_0,
        Cas.def,
        Postfix.def,
      ],
    ),
    userdetails: LAServiceDepsDesc(
      nameInt: userdetails,
      serviceDepends: [
        Nginx.def,
        MySql.def,
        Mongo.v4_0,
        UserDetails.def,
        Postfix.def,
      ],
    ),
    apikey: LAServiceDepsDesc(
      nameInt: apikey,
      serviceDepends: [
        Nginx.def,
        MySql.def,
        Cas.def,
        ApiKey.def,
      ],
    ),
    casManagement: LAServiceDepsDesc(
      nameInt: casManagement,
      serviceDepends: [
        Nginx.def,
        MySql.def,
        Mongo.v4_0,
        CasManagement.def,
      ],
    ),
    spatial: LAServiceDepsDesc(
      nameInt: spatial,
      serviceDepends: [Nginx.def, PostGis.def, PostgresSql.def],
    ),
    spatialService: LAServiceDepsDesc(
      nameInt: spatialService,
      serviceDepends: [Nginx.def, PostGis.def, PostgresSql.def],
    ),
    geoserver: LAServiceDepsDesc(
      nameInt: geoserver,
      serviceDepends: [Nginx.def, Tomcat.def],
    ),
    webapi: LAServiceDepsDesc(
      nameInt: webapi,
      serviceDepends: [Nginx.def, Tomcat.def, MySql.def],
    ),
    dashboard: LAServiceDepsDesc(
      nameInt: dashboard,
      serviceDepends: [Nginx.def, Tomcat.def],
    ),
    sds: LAServiceDepsDesc(
      nameInt: sds,
      serviceDepends: [Nginx.def, Tomcat.def],
    ),
    alerts: LAServiceDepsDesc(
      nameInt: alerts,
      serviceDepends: [Nginx.def, Tomcat.def, Postfix.def, MySql.def],
    ),
    doi: LAServiceDepsDesc(
      nameInt: doi,
      serviceDepends: [
        Nginx.def,
        ElasticSearch.v7_3_0,
        PostgresSql.def,
        Postfix.def,
        Doi.def,
      ],
    ),
    namematchingService: LAServiceDepsDesc(
        nameInt: namematchingService,
        serviceDepends: [Nginx.def, NameMatchingService.def]),
    sensitiveDataService: LAServiceDepsDesc(
        nameInt: sensitiveDataService,
        serviceDepends: [Nginx.def, NameMatchingService.def]),
    dataQuality: LAServiceDepsDesc(
        nameInt: dataQuality,
        serviceDepends: [Nginx.def, Tomcat.def, PostgresSql.def]),
    biocacheBackend: LAServiceDepsDesc(
      nameInt: biocacheBackend,
      serviceDepends: [Cassandra.v3],
    ),
    branding:
        LAServiceDepsDesc(nameInt: "branding", serviceDepends: [Nginx.def]),
    biocacheCli: LAServiceDepsDesc(
      nameInt: biocacheCli,
      serviceDepends: [],
    ),
    nameindexer: LAServiceDepsDesc(
      nameInt: nameindexer,
      serviceDepends: [],
    ),
    pipelines: LAServiceDepsDesc(
      nameInt: pipelines,
      serviceDepends: [NameMatchingService.def, SensitiveDataService.def],
    ),
    spark: LAServiceDepsDesc(
      nameInt: spark,
      serviceDepends: [Spark.def],
    ),
    hadoop: LAServiceDepsDesc(
      nameInt: hadoop,
      serviceDepends: [Hadoop.def],
    ),
    pipelinesJenkins: LAServiceDepsDesc(
      nameInt: pipelinesJenkins,
      serviceDepends: [],
    ),
    biocollect: LAServiceDepsDesc(
      nameInt: biocollect,
      serviceDepends: [Nginx.def, Biocollect.def],
    ),
    pdfgen: LAServiceDepsDesc(
      nameInt: pdfgen,
      serviceDepends: [
        Nginx.def,
        Tomcat.def,
      ],
    ),
    ecodata: LAServiceDepsDesc(
      nameInt: ecodata,
      serviceDepends: [
        Nginx.def,
        Ecodata.def,
        Mongo.v4_0,
        ElasticSearch.v7_14_1
      ],
    ),
    ecodataReporting: LAServiceDepsDesc(
      nameInt: ecodataReporting,
      serviceDepends: [Nginx.def, EcodataReporting.def],
    ),
    events: LAServiceDepsDesc(
      nameInt: events,
      serviceDepends: [Nginx.def],
    ),
    eventsElasticSearch: LAServiceDepsDesc(
      nameInt: eventsElasticSearch,
      serviceDepends: [ElasticSearch.v7_17_7],
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
