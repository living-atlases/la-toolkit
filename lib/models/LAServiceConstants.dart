import 'laServiceName.dart';

final String alaHub = LAServiceName.ala_hub.toS();
final String alerts = LAServiceName.alerts.toS();
final String apikey = LAServiceName.apikey.toS();
final String bie = LAServiceName.ala_bie.toS();
final String bieIndex = LAServiceName.bie_index.toS();
final String biocacheCli = LAServiceName.biocache_cli.toS();
final String biocacheService = LAServiceName.biocache_service.toS();
final String biocacheBackend = LAServiceName.biocache_backend.toS();
final String branding = LAServiceName.branding.toS();
final String cas = LAServiceName.cas.toS();
final String casManagement = LAServiceName.cas_management.toS();
final String collectory = LAServiceName.collectory.toS();
final String dashboard = LAServiceName.dashboard.toS();
final String doi = LAServiceName.doi.toS();
final String geoserver = LAServiceName.geoserver.toS();
final String images = LAServiceName.images.toS();
final String logger = LAServiceName.logger.toS();
final String nameindexer = LAServiceName.nameindexer.toS();
final String namematchingService = LAServiceName.namematching_service.toS();
final String sensitiveDataService = LAServiceName.sensitive_data_service.toS();
final String dataQuality = LAServiceName.data_quality.toS();
final String pipelines = LAServiceName.pipelines.toS();
final String spark = LAServiceName.spark.toS();
final String hadoop = LAServiceName.hadoop.toS();
final String pipelinesJenkins = LAServiceName.pipelinesJenkins.toS();
final String regions = LAServiceName.regions.toS();
final String sds = LAServiceName.sds.toS();
final String solr = LAServiceName.solr.toS();
final String solrcloud = LAServiceName.solrcloud.toS();
final String zookeeper = LAServiceName.zookeeper.toS();
final String spatial = LAServiceName.spatial.toS();
final String spatialService = LAServiceName.spatial_service.toS();
final String speciesLists = LAServiceName.species_lists.toS();
final String userdetails = LAServiceName.userdetails.toS();
final String webapi = LAServiceName.webapi.toS();
final String biocollect = LAServiceName.biocollect.toS();
final String pdfgen = LAServiceName.pdfgen.toS();
final String ecodata = LAServiceName.ecodata.toS();
final String ecodataReporting = LAServiceName.ecodata_reporting.toS();
const String toolkit = 'laToolkit';
const String alaInstall = 'ala-install';
const String generator = 'la-generator';
const String tomcat = 'tomcat';
const String ansible = 'ansible';
const String java = 'java';
final String events = LAServiceName.events.toS();
final String eventsElasticSearch = LAServiceName.events_elasticsearch.toS();
final String dockerSwarm = LAServiceName.docker_swarm.toS();
final String gatus = LAServiceName.gatus.toS();
final String portainer = LAServiceName.portainer.toS();
final String cassandra = LAServiceName.cassandra.toS();

const List<String> laTools = <String>[alaInstall, generator, toolkit];
const List<String> laToolsNoAlaInstall = <String>[generator, toolkit];
List<String> servicesWithoutUrlButShow = <String>[
  biocacheBackend,
  eventsElasticSearch,
  pipelines,
  solrcloud,
  dockerSwarm,
  zookeeper,
  cassandra
];
