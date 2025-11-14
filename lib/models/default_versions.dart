import 'package:pub_semver/pub_semver.dart';
import './la_service_constants.dart';
import './version_utils.dart';

class DefaultVersions {
  static final Map<String, String> defVersions2_1_10 = <String, String>{
    namematchingService: '3.5',
    alerts: '2.0.3',
    apikey: '1.7.0',
    bie: '2.0.2',
    bieIndex: '1.8.1',
    biocacheCli: '2.6.0',
    alaHub: '4.0.12.4',
    biocacheService: '2.7.0',
    biocollect: '6.3',
    casManagement: '6.5.5-2',
    cas: '6.5.6-3',
    collectory: '3.1.0',
    dashboard: '2.3',
    dataQuality: '1.3.0',
    doi: '2.0.0',
    images: '2.0.1',
    logger: '4.1.0',
    nameindexer: '3.5',
    regions: '3.4',
    sds: '1.6.3',
    solr: '7.7.3',
    spatial: '1.0.2',
    spatialService: '1.1.0',
    speciesLists: '4.0.3',
    userdetails: '3.0.2'
  };

  static final Map<String, String> defVersions2_0_11 = <String, String>{
    alaHub: '3.2.9',
    alerts: '1.5.1',
    bie: '1.5.0',
    bieIndex: '1.4.11',
    biocacheService: '2.4.2',
    biocacheCli: '2.6.0',
    // branding: "",
    cas: '5.3.12-2',
    casManagement: '5.3.6-1',
    collectory: '1.6.4',
    dashboard: '2.2',
    doi: '1.1.1',
    images: '1.1.7',
    speciesLists: '3.5.9',
    logger: '2.4.0',
    regions: '3.3.5',
    nameindexer: '3.5',
    sds: '1.6.2',
    solr: '7.7.3',
    spatial: '0.4',
    spatialService: '0.4',
    userdetails: '2.3.0',
    webapi: '2.0',
    biocollect: '5.2.6',
    pdfgen: '1.3',
    ecodata: '3.3.1',
  };

  static final Map<String, String> defVersions2_1_0 = <String, String>{
    alaHub: '3.2.9',
    alerts: '1.5.1',
    bie: '1.5.0',
    bieIndex: '1.4.11',
    biocacheService: '2.4.2',
    biocacheCli: '2.6.0',
    // branding: "",
    cas: '5.3.12-2',
    casManagement: '5.3.6-1',
    collectory: '1.6.4',
    dashboard: '2.2',
    doi: '1.1.1',
    images: '1.1.7',
    speciesLists: '3.5.9',
    logger: '2.4.0',
    regions: '3.3.5',
    sds: '1.6.2',
    solr: '7.7.3',
    solrcloud: '8.9.0',
    spatial: '0.4',
    spatialService: '0.4',
    userdetails: '2.3.0',
    webapi: '2.0',
    biocollect: '5.2.6',
    pdfgen: '1.3',
    ecodata: '3.3.1',
  };

  static Map<VersionConstraint, Map<String, String>> map =
      <VersionConstraint, Map<String, String>>{
    // ala-install vs rest of components
    vc('<= 2.0.11'): defVersions2_0_11,
    vc('> 2.0.11 < 2.1.0'): defVersions2_0_11,
    vc('>= 2.1.0 < 2.1.10'): defVersions2_1_0,
    vc('>= 2.1.10'): defVersions2_1_10
  };
}
