import 'package:la_toolkit/models/LAServiceConstants.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:la_toolkit/utils/StringUtils.dart';
import 'package:pub_semver/pub_semver.dart';

class Dependencies {
  static const List<String> laTools = [alaInstall, generator, toolkit];
  static const List<String> laToolsNoAlaInstall = [generator, toolkit];

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
      vc('>= 1.3.7'): {alaInstall: vc('>= 2.1.6'), generator: vc('>= 1.2.30')},
    },

    // From here copy-pasted from the wiki:
    // https://github.com/AtlasOfLivingAustralia/documentation/wiki/Dependencies#dependencies-list

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
      vc(">=2.7.0"): {biocacheCli: vc(">= 2.6.1")},
      // biocache-service 3.x - uses pipelines
      vc(">= 3.0.0"): {pipelines: vc("any")}
    },
    /* biocacheStore: {
      vc("any"): {biocacheService: vc("< 3.0.0")}
    }, */
    biocacheCli: {
      vc("any"): {solr: vc("< 8.0.0")},
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
      // Again, don't dup service keys or vc keys or dependencies will be overwritten
      vc("any"): {
        biocacheService: vc(">= 3.0.0"),
        alaInstall: vc(">= 2.1.0"),
        solrcloud: vc(">= 8.9.0"),
        alaNameMatchingService: vc(">= 1.0.0"),
        images: vc(">= 1.1.1-7")
      }
    },
    dashboard: {
      vc(">= 2.2"): {alaInstall: vc(">= 2.0.5")}
    },
    spatial: {
      vc(">= 0.3.12"): {spatialService: vc("> 0.3.12")}
    }
  };

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
  };

  static Map<VersionConstraint, Map<String, String>> defaultVersions = {
    // ala-install vs rest of components
    vc('<= 2.0.11'): defVersions2_0_11,
    vc('> 2.0.11 < 2.1.0'): defVersions2_0_11,
    vc('>= 2.1.0'): defVersions2_1_0
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
    Set<String> lintErrors = {};
    try {
      selectedVersions.forEach((String sw, String version) {
        if (debug) {
          print("Checking dependencies for $sw");
        }
        final String swForHumans = LAServiceDesc.swNameWithAliasForHumans(sw);
        if (version != 'custom' && version != 'upstream') {
          if (laDeps[sw] != null) {
            Version versionP = v(version);
            laDeps[sw]!.forEach((VersionConstraint mainConstraint,
                Map<String, VersionConstraint> constraints) {
              if (mainConstraint.allows(versionP)) {
                // Now we verify the rest of constraints dependencies
                if (debug) {
                  print("$mainConstraint applies to $sw");
                }
                constraints
                    .forEach((String dependency, VersionConstraint constraint) {
                  String? versionOfDep = selectedVersions[dependency];
                  if (debug) {
                    print(
                        "testing $swForHumans $versionP with $mainConstraint that depends on $dependency $constraint and uses ${versionOfDep ?? 'none'}");
                  }
                  // Not use internal name for LA services
                  String depForHumans = LAServiceDesc.isLAService(dependency)
                      ? LAServiceDesc.swNameWithAliasForHumans(dependency)
                      : dependency;
                  if (versionOfDep == null) {
                    if (serviceInUse.contains(dependency)) {
                      lintErrors.add('$swForHumans depends on $depForHumans');
                    }
                  } else {
                    if (versionOfDep != 'custom' &&
                        versionOfDep != 'upstream' &&
                        !constraint.allows(v(versionOfDep))) {
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
        }
      });
      return lintErrors.toList();
    } catch (e, stacktrace) {
      print("Verify exception $e");
      print(stacktrace);
      return lintErrors.toList();
    }
  }
}
