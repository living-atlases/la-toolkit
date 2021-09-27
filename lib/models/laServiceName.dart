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
  pipelines
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
