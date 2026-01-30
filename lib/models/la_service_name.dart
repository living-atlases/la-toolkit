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
  solrcloud,
  zookeeper,
  cas,
  userdetails,
  // ignore: constant_identifier_names
  cas_management,
  apikey,
  spatial,
  // ignore: constant_identifier_names
  spatial_service,
  geoserver,
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
  // ignore: constant_identifier_names
  namematching_service,
  // ignore: constant_identifier_names
  sensitive_data_service,
  // ignore: constant_identifier_names
  data_quality,
  pipelines,
  spark,
  hadoop,
  pipelinesJenkins,
  biocollect,
  pdfgen,
  ecodata,
  // ignore: constant_identifier_names
  ecodata_reporting,
  events,
  // ignore: constant_identifier_names
  events_elasticsearch,
  // ignore: constant_identifier_names
  docker_swarm,
  docker_compose,
  docker_common,
  gatus,
  portainer,
  cassandra,
}

extension ParseToString on LAServiceName {
  String toS() {
    return toString().split('.').last;
  }
}

extension EnumParser on String {
  LAServiceName toServiceDescName() {
    return LAServiceName.values.firstWhere(
      (LAServiceName e) =>
          e.toString().toLowerCase() == '$LAServiceName.$this'.toLowerCase(),
    ); //return null if not found
  }
}
