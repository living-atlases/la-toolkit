import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:la_toolkit/utils/StringUtils.dart';
import 'package:pub_semver/pub_semver.dart';

class Dependencies {
  static const String toolkit = "laToolkit";
  static const String alaInstall = "ala-install";
  static const String generator = "la-generator";
  static const List<String> laTools = [alaInstall, generator, toolkit];
  static const List<String> laToolsNoAlaInstall = [generator, toolkit];
  static String alaHub = LAServiceName.ala_hub.toS();
  static String alerts = LAServiceName.alerts.toS();
  static String apikey = LAServiceName.apikey.toS();
  static String bie = LAServiceName.ala_bie.toS();
  static String bieIndex = LAServiceName.bie_index.toS();
  static String biocacheService = LAServiceName.biocache_service.toS();
  static String biocacheStore = LAServiceName.biocache_cli.toS();
  static String branding = LAServiceName.branding.toS();
  static String cas = LAServiceName.cas.toS();
  static String casManagement = LAServiceName.cas_management.toS();
  static String collectory = LAServiceName.collectory.toS();
  static String dashboard = LAServiceName.dashboard.toS();
  static String doi = LAServiceName.doi.toS();
  static String images = LAServiceName.images.toS();
  static String lists = LAServiceName.species_lists.toS();
  static String logger = LAServiceName.logger.toS();
  static String regions = LAServiceName.regions.toS();
  static String sds = LAServiceName.sds.toS();
  static String solr = LAServiceName.solr.toS();
  static String spatial = LAServiceName.spatial.toS();
  static String spatialService = LAServiceName.spatial_service.toS();
  static String userdetails = LAServiceName.userdetails.toS();
  static String webapi = LAServiceName.webapi.toS();
  static String pipelines = "pipelines";
  static String tomcat = "tomcat";
  static String ansible = "ansible";

  static Map<String, Map<VersionConstraint, Map<String, VersionConstraint>>>
      laDeps = {
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
      vc('>= 1.2.0'): {alaInstall: vc('>= 2.0.11'), generator: vc('>= 1.2.0')},
    },

    // from here copy-pasted from the wiki
    alerts: {
      vc(">= 1.5.1"): {
        regions: vc(">= 3.3.5"),
        alaHub: vc(">= 3.2.9"),
        bie: vc(">= 1.5.0")
      }
    },
    alaInstall: {
      vc(">= 2.0.3"): {ansible: vc("2.10.3")}
    },
    alerts: {
      vc(">= 1.5.1"): {
        regions: vc(">= 3.3.5"),
        alaHub: vc(">= 3.2.9"),
        bie: vc(">= 1.5.0")
      }
    },
    biocacheService: {
      vc(">= 2.5.0"): {tomcat: vc(">= 9.0.0")},
      // biocache-service 2.x - uses biocache-store
      vc(">=2.7.0"): {biocacheStore: vc(">= 2.6.1")},
      // biocache-service 3.x - uses pipelines
      vc(">= 3.0.0"): {"pipelines": vc("any")}
    },
    /* biocacheStore: {
      vc("any"): {biocacheService: vc("< 3.0.0")}
    }, */
    biocacheStore: {
      vc(">= 2.4.5"): {images: vc(">= 1.0.7")},
      vc("< 3.0.0"): {biocacheService: vc("< 3.0.0")}
    },
    doi: {
      vc(">= 1.1"): {biocacheService: vc(">= 2.5.0"), regions: vc(">= 3.3.4")}
    },
    images: {
      vc(">= 1.1"): {alaInstall: vc(">= 2.0.8")}
    },
    pipelines: {
      vc("any"): {biocacheService: vc(">= 3.0.0")}
    },
    dashboard: {
      vc(">= 2.2"): {alaInstall: vc(">= 2.0.5")}
    },
    spatial: {
      vc(">= 0.3.12"): {spatialService: vc("> 0.3.12")}
    }
  };

  static Map<VersionConstraint, Map<String, String>> defaultVersions = {
    // ala-install vs rest of components
    vc('<= 2.0.11'): {
      // Newer versions of biocache-service require tomcat8/9
      alaHub: "3.2.9",
      alerts: "1.5.1",
      bie: "1.5.0",
      bieIndex: "1.4.11",
      biocacheService: "2.4.2",
      biocacheStore: "2.6.0",
      // branding: "",
      cas: "5.3.12-2",
      casManagement: "5.3.6-1",
      collectory: "1.6.4",
      dashboard: "2.2",
      doi: "1.1.1",
      images: "1.1.7",
      lists: "3.5.9",
      logger: "2.4.0",
      regions: "3.3.5",
      sds: "1.6.2",
      // solr: "",
      spatial: "0.4",
      spatialService: "0.4",
      userdetails: "2.3.0",
      webapi: "2.0",
    }
  };

// biocollect_version=5.1.2

  static VersionConstraint vc(String c) =>
      VersionConstraint.parse(StringUtils.semantize(c));

  static Version v(String c) => Version.parse(StringUtils.semantize(c));

  static List<String> verify(Map<String, String> combo) {
    String alaInstallS = combo[alaInstall]!;
    bool skipAlaInstall = alaInstallIsNotTagged(alaInstallS);
    return verifyLAReleases(
        skipAlaInstall ? laToolsNoAlaInstall : laTools, combo);
  }

  static bool alaInstallIsNotTagged(String alaInstallS) =>
      alaInstallS == 'custom' || alaInstallS == 'upstream';

  static List<String> check(
      {String? toolkitV, String? alaInstallV, String? generatorV}) {
    if (toolkitV != null && alaInstallV != null && generatorV != null) {
      return verify({
        toolkit: toolkitV.replaceFirst(RegExp(r'^v'), ''),
        alaInstall: alaInstallV.replaceFirst(RegExp(r'^v'), ''),
        generator: generatorV.replaceFirst(RegExp(r'^v'), '')
      });
    } else {
      return [];
    }
  }

  static List<String> verifyLAReleases(
      List<String> serviceInUse, Map<String, String> selectedVersions,
      [bool debug = false]) {
    List<String> lintErrors = [];
    try {
      selectedVersions.forEach((String sw, String version) {
        if (debug) {
          print("Checking dependencies for $sw");
        }
        final String swForHumans = LAServiceDesc.swNameWithAliasForHumans(sw);
        Version versionP = v(version);
        if (laDeps[sw] != null) {
          laDeps[sw]!.forEach((VersionConstraint mainConstraint,
              Map<String, VersionConstraint> constraints) {
            if (mainConstraint.allows(versionP)) {
              // Now we verify the rest of constraints dependencies
              if (debug) {
                print("$mainConstraint applies to $sw");
              }
              constraints
                  .forEach((String dependency, VersionConstraint constraint) {
                if (debug) {
                  print(
                      "testing $swForHumans $versionP with $mainConstraint that depends on $dependency $constraint and uses ${selectedVersions[dependency] ?? 'none'}");
                }
                // Not use internal name for LA services
                String depForHumans = LAServiceDesc.isLAService(dependency)
                    ? LAServiceDesc.swNameWithAliasForHumans(dependency)
                    : dependency;
                if (selectedVersions[dependency] == null) {
                  if (serviceInUse.contains(dependency)) {
                    lintErrors.add('$swForHumans depends on $depForHumans');
                  }
                } else {
                  if (!constraint.allows(v(selectedVersions[dependency]!))) {
                    lintErrors.add(sw == toolkit
                        ? '$dependency recommended version should be $constraint'
                        : '$swForHumans depends on $depForHumans $constraint');
                  }
                }
              });
            }
          });
        } else {
          if (debug) {
            print("No dependencies for $sw");
          }
        }
      });
      return lintErrors;
    } catch (e) {
      print("Verify exception $e");
      return lintErrors;
    }
  }
}
