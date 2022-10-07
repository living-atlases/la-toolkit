import 'package:la_toolkit/models/LAServiceConstants.dart';
import 'package:la_toolkit/models/versionUtils.dart';
import 'package:pub_semver/pub_semver.dart';

class Dependencies {
  static Map<String, Map<VersionConstraint, Map<String, VersionConstraint>>>
      map = {
    // WARN: Don't DUP keys

    toolkit: {
      vc('>= 1.0.22 < 1.0.23'): {
        alaInstall: vc('>= 2.0.6'),
        generator: vc('>= 1.1.36')
      },
      vc('>= 1.0.23 < 1.1.0'): {
        alaInstall: vc('>= 2.0.6'),
        generator: vc('>= 1.1.37')
      },
      vc('>= 1.1.0 < 1.1.9'): {
        alaInstall: vc('>= 2.0.7'),
        generator: vc('>= 1.1.43')
      },
      vc('>= 1.1.9 < 1.1.26'): {
        alaInstall: vc('>= 2.0.8'),
        generator: vc('>= 1.1.49')
      },
      vc('>= 1.1.26 < 1.2.0'): {
        alaInstall: vc('>= 2.0.10'),
        generator: vc('>= 1.1.51')
      },
      vc('>= 1.2.0 < 1.2.1'): {
        alaInstall: vc('>= 2.0.11'),
        generator: vc('>= 1.2.0')
      },
      vc('>= 1.2.1 < 1.2.2'): {
        alaInstall: vc('>= 2.0.11'),
        generator: vc('>= 1.2.1')
      },
      vc('>= 1.2.2 < 1.2.6'): {
        alaInstall: vc('>= 2.0.11'),
        generator: vc('>= 1.2.1')
      },
      vc('>= 1.2.6 < 1.2.8'): {
        alaInstall: vc('>= 2.0.11'),
        generator: vc('>= 1.2.2')
      },
      vc('>= 1.2.8 < 1.3.0'): {
        alaInstall: vc('>= 2.1.1'),
        generator: vc('>= 1.2.7')
      },
      vc('>= 1.3.0 < 1.3.1'): {
        alaInstall: vc('>= 2.1.2'),
        generator: vc('>= 1.2.9')
      },
      vc('>= 1.3.1 < 1.3.2'): {
        alaInstall: vc('>= 2.1.3'),
        generator: vc('>= 1.2.16')
      },
      vc('>= 1.3.2 < 1.3.3'): {
        alaInstall: vc('>= 2.1.4'),
        generator: vc('>= 1.2.20')
      },
      vc('>= 1.3.3 < 1.3.4'): {
        alaInstall: vc('>= 2.1.5'),
        generator: vc('>= 1.2.22')
      },
      vc('>= 1.3.4 < 1.3.5'): {
        alaInstall: vc('>= 2.1.5'),
        generator: vc('>= 1.2.22')
      },
      vc('>= 1.3.5 < 1.3.6'): {
        alaInstall: vc('>= 2.1.5'),
        generator: vc('>= 1.2.22')
      },
      vc('>= 1.3.6 < 1.3.7'): {
        alaInstall: vc('>= 2.1.6'),
        generator: vc('>= 1.2.29')
      },
      vc('>= 1.3.7 < 1.3.8'): {
        alaInstall: vc('>= 2.1.6'),
        generator: vc('>= 1.2.30')
      },
      vc('>= 1.3.8 < 1.3.9'): {
        alaInstall: vc('>= 2.1.7'),
        generator: vc('>= 1.2.33')
      },
      vc('>= 1.3.9 < 1.3.10'): {
        alaInstall: vc('>= 2.1.7'),
        generator: vc('>= 1.2.38')
      },
      vc('>= 1.3.10 < 1.3.11'): {
        alaInstall: vc('>= 2.1.9'),
        generator: vc('>= 1.2.46')
      },
      vc('>= 1.3.11'): {alaInstall: vc('>= 2.1.9'), generator: vc('>= 1.2.48')},
    },

    // From here copy-pasted from the wiki:
    // https://github.com/AtlasOfLivingAustralia/documentation/wiki/Dependencies#dependencies-list

    // ala-bie-hub in bie
    alaInstall: {
      vc(">= 2.0.3"): {ansible: vc("2.10.3")}
    },
    alerts: {
      vc(">= 1.5.1"): {
        regions: vc(">= 3.3.5"),
        alaHub: vc(">= 3.2.9"),
        bie: vc(">= 1.5.0")
      },
      vc(">= 2.0.0"): {java: vc(">= 11")},
    },
    apikey: {
      vc(">= 1.7.0"): {
        cas: vc(">= 6.5.6-3"),
        casManagement: vc(">= 6.5.5-2"),
        userdetails: vc(">= 3.0.1"),
        java: vc(">= 11")
      }
    },
    bie: {
      vc("> 2.0.1"): {java: vc(">= 11")}
    },
    biocacheService: {
      vc(">= 2.5.0"): {tomcat: vc(">= 9.0.0")},
      // biocache-service 2.x - uses biocache-store
      vc(">=2.7.0"): {biocacheCli: vc(">= 2.6.1")},
      // biocache-service 3.x - uses pipelines
      vc(">= 3.0.0"): {pipelines: vc("any")}
    },
    /* biocacheStore: {
      vc("any"): {biocacheService: vc("< 3.0.0")}
    }, */
    biocollect: {
      vc("any"): {alaInstall: vc(">= 2.1.7"), generator: vc(">= 1.2.32")},
    },
    biocacheCli: {
      vc("any"): {solr: vc("< 8.0.0")},
      vc(">= 2.4.5"): {images: vc(">= 1.0.7")},
      vc("< 3.0.0"): {biocacheService: vc("< 3.0.0")}
    },
    cas: {
      vc(">= 6.5.6-3"): {
        casManagement: vc(">= 6.5.5-2"),
        userdetails: vc(">= 3.0.1"),
        apikey: vc(">= 1.7.0"),
        java: vc(">= 11")
      }
    },
    casManagement: {
      vc(">= 6.5.5-2"): {
        cas: vc(">= 6.5.6-3"),
        userdetails: vc(">= 3.0.1"),
        apikey: vc(">= 1.7.0"),
        java: vc(">= 11")
      }
    },
    dashboard: {
      vc(">= 2.2"): {alaInstall: vc(">= 2.0.5")}
    },
    doi: {
      vc(">= 1.1"): {biocacheService: vc(">= 2.5.0"), regions: vc(">= 3.3.4")}
    },
    images: {
      vc(">= 1.1"): {alaInstall: vc(">= 2.0.8")}
    },
    logger: {
      vc("> 4.0.1"): {java: vc(">= 11")}
    },
    pipelines: {
      // Again, don't dup service keys or vc keys or dependencies will be overwritten
      vc("any"): {
        biocacheService: vc(">= 3.0.0"),
        alaInstall: vc(">= 2.1.0"),
        solrcloud: vc(">= 8.9.0"),
        alaNameMatchingService: vc(">= 1.0.0"),
        images: vc(">= 1.1.1-7")
      }
    },
    spatial: {
      vc(">= 0.3.12"): {spatialService: vc("> 0.3.12")}
    },
    speciesLists: {
      vc("< 4.0.0"): {nameindexer: vc("any")},
      vc(">= 4.0.0"): {namematchingService: vc("any")}
    },
    userdetails: {
      vc(">= 3.0.1"): {
        cas: vc(">= 6.5.6-3"),
        casManagement: vc(">= 6.5.5-2"),
        apikey: vc(">= 1.7.0"),
        java: vc(">= 11")
      }
    }
  };
}
