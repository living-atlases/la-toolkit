import 'LAServiceConstants.dart';
import 'basic_service.dart';

class LAServiceDepsDesc {
  LAServiceDepsDesc({
    required this.nameInt,
    required this.serviceDepends,
  });

  String nameInt;
  List<BasicService> serviceDepends;

  static final Map<String, LAServiceDepsDesc> v2_0_4 =
      <String, LAServiceDepsDesc>{
    collectory: LAServiceDepsDesc(
      nameInt: collectory,
      serviceDepends: <BasicService>[Nginx.def, Tomcat.def, MySql.def],
    ),
    alaHub: LAServiceDepsDesc(
      nameInt: alaHub,
      serviceDepends: <BasicService>[
        Nginx.def,
        Tomcat.def,
      ],
    ),
    biocacheService: LAServiceDepsDesc(
      nameInt: biocacheService,
      serviceDepends: <BasicService>[
        Nginx.def,
        Tomcat.def,
      ],
    ),
    bie: LAServiceDepsDesc(
      nameInt: bie,
      serviceDepends: <BasicService>[Nginx.def, Tomcat.def],
    ),
    bieIndex: LAServiceDepsDesc(
      nameInt: bieIndex,
      serviceDepends: <BasicService>[Nginx.def, Tomcat.def],
    ),
    images: LAServiceDepsDesc(
      nameInt: images,
      serviceDepends: <BasicService>[
        Nginx.def,
        ElasticSearch.v7_7_1,
        PostGis.def,
        PostgresSql.def
      ],
    ),
    speciesLists: LAServiceDepsDesc(
      nameInt: speciesLists,
      serviceDepends: <BasicService>[
        Nginx.def,
        Tomcat.def,
        MySql.def,
      ],
    ),
    regions: LAServiceDepsDesc(
      nameInt: regions,
      serviceDepends: <BasicService>[Nginx.def, Tomcat.def],
    ),
    logger: LAServiceDepsDesc(
      nameInt: logger,
      serviceDepends: <BasicService>[Nginx.def, Tomcat.def, MySql.def],
    ),
    solr: LAServiceDepsDesc(
      nameInt: solr,
      serviceDepends: <BasicService>[Solr.v7],
    ),
    solrcloud: LAServiceDepsDesc(
      nameInt: solrcloud,
      serviceDepends: <BasicService>[SolrCloud.v8],
    ),
    zookeeper: LAServiceDepsDesc(
      nameInt: zookeeper,
      serviceDepends: <BasicService>[],
    ),
    cas: LAServiceDepsDesc(
      nameInt: cas,
      serviceDepends: <BasicService>[
        Nginx.def,
        MySql.def,
        Mongo.v4_0,
        Cas.def,
        Postfix.def,
      ],
    ),
    userdetails: LAServiceDepsDesc(
      nameInt: userdetails,
      serviceDepends: <BasicService>[
        Nginx.def,
        MySql.def,
        Mongo.v4_0,
        UserDetails.def,
        Postfix.def,
      ],
    ),
    apikey: LAServiceDepsDesc(
      nameInt: apikey,
      serviceDepends: <BasicService>[
        Nginx.def,
        MySql.def,
        Cas.def,
        ApiKey.def,
      ],
    ),
    casManagement: LAServiceDepsDesc(
      nameInt: casManagement,
      serviceDepends: <BasicService>[
        Nginx.def,
        MySql.def,
        Mongo.v4_0,
        CasManagement.def,
      ],
    ),
    spatial: LAServiceDepsDesc(
      nameInt: spatial,
      serviceDepends: <BasicService>[Nginx.def, PostGis.def, PostgresSql.def],
    ),
    spatialService: LAServiceDepsDesc(
      nameInt: spatialService,
      serviceDepends: <BasicService>[Nginx.def, PostGis.def, PostgresSql.def],
    ),
    geoserver: LAServiceDepsDesc(
      nameInt: geoserver,
      serviceDepends: <BasicService>[Nginx.def, Tomcat.def],
    ),
    webapi: LAServiceDepsDesc(
      nameInt: webapi,
      serviceDepends: <BasicService>[Nginx.def, Tomcat.def, MySql.def],
    ),
    dashboard: LAServiceDepsDesc(
      nameInt: dashboard,
      serviceDepends: <BasicService>[Nginx.def, Tomcat.def],
    ),
    sds: LAServiceDepsDesc(
      nameInt: sds,
      serviceDepends: <BasicService>[Nginx.def, Tomcat.def],
    ),
    alerts: LAServiceDepsDesc(
      nameInt: alerts,
      serviceDepends: <BasicService>[
        Nginx.def,
        Tomcat.def,
        Postfix.def,
        MySql.def
      ],
    ),
    doi: LAServiceDepsDesc(
      nameInt: doi,
      serviceDepends: <BasicService>[
        Nginx.def,
        ElasticSearch.v7_3_0,
        PostgresSql.def,
        Postfix.def,
        Doi.def,
      ],
    ),
    namematchingService: LAServiceDepsDesc(
        nameInt: namematchingService,
        serviceDepends: <BasicService>[Nginx.def, NameMatchingService.def]),
    sensitiveDataService: LAServiceDepsDesc(
        nameInt: sensitiveDataService,
        serviceDepends: <BasicService>[Nginx.def, NameMatchingService.def]),
    dataQuality: LAServiceDepsDesc(
        nameInt: dataQuality,
        serviceDepends: <BasicService>[Nginx.def, Tomcat.def, PostgresSql.def]),
    biocacheBackend: LAServiceDepsDesc(
      nameInt: biocacheBackend,
      serviceDepends: <BasicService>[Cassandra.v3],
    ),
    branding: LAServiceDepsDesc(
        nameInt: 'branding', serviceDepends: <BasicService>[Nginx.def]),
    biocacheCli: LAServiceDepsDesc(
      nameInt: biocacheCli,
      serviceDepends: <BasicService>[],
    ),
    nameindexer: LAServiceDepsDesc(
      nameInt: nameindexer,
      serviceDepends: <BasicService>[],
    ),
    pipelines: LAServiceDepsDesc(
      nameInt: pipelines,
      serviceDepends: <BasicService>[],
    ),
    spark: LAServiceDepsDesc(
      nameInt: spark,
      serviceDepends: <BasicService>[Spark.def],
    ),
    hadoop: LAServiceDepsDesc(
      nameInt: hadoop,
      serviceDepends: <BasicService>[Hadoop.def],
    ),
    pipelinesJenkins: LAServiceDepsDesc(
      nameInt: pipelinesJenkins,
      serviceDepends: <BasicService>[],
    ),
    biocollect: LAServiceDepsDesc(
      nameInt: biocollect,
      serviceDepends: <BasicService>[Nginx.def, Biocollect.def],
    ),
    pdfgen: LAServiceDepsDesc(
      nameInt: pdfgen,
      serviceDepends: <BasicService>[
        Nginx.def,
        Tomcat.def,
      ],
    ),
    ecodata: LAServiceDepsDesc(
      nameInt: ecodata,
      serviceDepends: <BasicService>[
        Nginx.def,
        Ecodata.def,
        Mongo.v4_0,
        ElasticSearch.v7_14_1
      ],
    ),
    ecodataReporting: LAServiceDepsDesc(
      nameInt: ecodataReporting,
      serviceDepends: <BasicService>[Nginx.def, EcodataReporting.def],
    ),
    events: LAServiceDepsDesc(
      nameInt: events,
      serviceDepends: <BasicService>[Nginx.def],
    ),
    eventsElasticSearch: LAServiceDepsDesc(
      nameInt: eventsElasticSearch,
      serviceDepends: <BasicService>[ElasticSearch.v7_17_7],
    ),
    dockerSwarm: LAServiceDepsDesc(
        nameInt: dockerSwarm, serviceDepends: <BasicService>[]),
    dockerCommon: LAServiceDepsDesc(
        nameInt: dockerCommon, serviceDepends: <BasicService>[]),
    gatus: LAServiceDepsDesc(nameInt: gatus, serviceDepends: <BasicService>[]),
    portainer:
        LAServiceDepsDesc(nameInt: portainer, serviceDepends: <BasicService>[]),
    cassandra:
        LAServiceDepsDesc(nameInt: cassandra, serviceDepends: <BasicService>[])
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
      case 'v2.0.6':
        return v2_0_4;
      default:
        return v2_0_4;
    }
  }
}
