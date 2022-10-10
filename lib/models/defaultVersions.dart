import 'package:la_toolkit/models/LAServiceConstants.dart';
import 'package:la_toolkit/models/versionUtils.dart';
import 'package:pub_semver/pub_semver.dart';

class DefaultVersions {
  static final Map<String, String> defVersions2_0_11 = {
    alaHub: "3.2.9",
    alerts: "1.5.1",
    bie: "1.5.0",
    bieIndex: "1.4.11",
    biocacheService: "2.4.2",
    biocacheCli: "2.6.0",
    // branding: "",
    cas: "5.3.12-2",
    casManagement: "5.3.6-1",
    collectory: "1.6.4",
    dashboard: "2.2",
    doi: "1.1.1",
    images: "1.1.7",
    speciesLists: "3.5.9",
    logger: "2.4.0",
    regions: "3.3.5",
    sds: "1.6.2",
    solr: "7.7.3",
    spatial: "0.4",
    spatialService: "0.4",
    userdetails: "2.3.0",
    webapi: "2.0",
    biocollect: "5.2.6",
    pdfgen: "1.3",
    ecodata: "3.3.1",
  };

  static final Map<String, String> defVersions2_1_0 = {
    alaHub: "3.2.9",
    alerts: "1.5.1",
    bie: "1.5.0",
    bieIndex: "1.4.11",
    biocacheService: "2.4.2",
    biocacheCli: "2.6.0",
    // branding: "",
    cas: "5.3.12-2",
    casManagement: "5.3.6-1",
    collectory: "1.6.4",
    dashboard: "2.2",
    doi: "1.1.1",
    images: "1.1.7",
    speciesLists: "3.5.9",
    logger: "2.4.0",
    regions: "3.3.5",
    sds: "1.6.2",
    solr: "7.7.3",
    solrcloud: "8.9.0",
    spatial: "0.4",
    spatialService: "0.4",
    userdetails: "2.3.0",
    webapi: "2.0",
    biocollect: "5.2.6",
    pdfgen: "1.3",
    ecodata: "3.3.1",
  };

  static Map<VersionConstraint, Map<String, String>> map = {
    // ala-install vs rest of components
    vc('<= 2.0.11'): defVersions2_0_11,
    vc('> 2.0.11 < 2.1.0'): defVersions2_0_11,
    vc('>= 2.1.0'): defVersions2_1_0
  };
}