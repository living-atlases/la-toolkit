import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:pub_semver/pub_semver.dart';

class Dependencies {
  static const String toolkit = "laToolkit";
  static const String alaInstall = "alaInstall";
  static const String generator = "laGenerator";
  static String lists = LAServiceName.species_lists.toS();
  static String collectory = LAServiceName.collectory.toS();
  static String bie = LAServiceName.ala_bie.toS();
  static String bieIndex = LAServiceName.bie_index.toS();
  static String alaHub = LAServiceName.ala_hub.toS();
  static String biocacheService = LAServiceName.biocache_service.toS();
  static String biocacheStore = LAServiceName.biocache_cli.toS();
  static String alerts = LAServiceName.alerts.toS();
  static String images = LAServiceName.images.toS();
  static String solr = LAServiceName.solr.toS();
  static String webapi = LAServiceName.webapi.toS();
  static String regions = LAServiceName.regions.toS();
  static String spatial = LAServiceName.spatial.toS();
  static String cas = LAServiceName.cas.toS();
  static String sds = LAServiceName.sds.toS();
  static String dashboard = LAServiceName.dashboard.toS();
  static String branding = LAServiceName.branding.toS();
  static String doi = LAServiceName.doi.toS();

  static Map<VersionConstraint, Map<String, VersionConstraint>> laToolkitDeps =
      {
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
  };

  static Map<String, Map<VersionConstraint, Map<String, VersionConstraint>>>
      laDeps = {
    biocacheService: {
      // biocache-service 2.x - uses biocache-store
      vc("< 3.0.0"): {biocacheStore: vc("any")},
      // biocache-service 3.x - uses pipelines
      vc(">= 3.0.0"): {"pipelines": vc("any")}
    },
    biocacheStore: {
      vc("< 3.0.0"): {biocacheService: vc("< 3.0.0")}
    },
    alerts: {
      vc(">= 1.5.1"): {
        regions: vc(">= 3.3.5"),
        alaHub: vc(">= 3.2.9"),
        bie: vc(">= 1.5.0")
      }
    }
  };

  static VersionConstraint vc(String c) => VersionConstraint.parse(c);
  static Version v(String c) => Version.parse(c);

  static List<String> verify(Map<String, String> combo) {
    Version toolkitV = v(combo[toolkit]!);
    String alaInstallS = combo[alaInstall]!;
    bool skipAlaInstall = alaInstallS == 'custom' || alaInstallS == 'upstream';
    Version generatorV = v(combo[generator]!);
    List<String>? lintError;
    try {
      laToolkitDeps.keys.firstWhere((key) => key.allows(toolkitV));
      lintError = [];
      Map<String, VersionConstraint> match =
          laToolkitDeps.entries.firstWhere((e) => e.key.allows(toolkitV)).value;
      if (!skipAlaInstall && !match[alaInstall]!.allows(v(alaInstallS))) {
        lintError.add(
            'ala-install recommended version should be ${match[alaInstall]!}');
      }
      if (!match[generator]!.allows(generatorV)) {
        lintError.add(
            'la-generator recommended version should be ${match[generator]!}');
      }
    } catch (e) {
      print("Verify exception $e");
      return [];
    }
    return lintError;
  }

  static List<String> check(
      {String? toolkitV, String? alaInstallV, String? generatorV}) {
    if (toolkitV != null && alaInstallV != null && generatorV != null) {
      Map<String, String> combo = {
        toolkit: toolkitV.replaceFirst(RegExp(r'^v'), ''),
        alaInstall: alaInstallV.replaceFirst(RegExp(r'^v'), ''),
        generator: generatorV.replaceFirst(RegExp(r'^v'), '')
      };
      return verify(combo);
    } else {
      return [];
    }
  }

  static List<String> verifyLAReleases(
      List<String> serviceInUse, Map<String, String> selectedVersions,
      [bool debug = false]) {
    List<String> lintErrors = [];
    selectedVersions.forEach((String sw, String version) {
      String swForHumans = LAServiceDesc.get(sw).name;
      Version versionP = v(version);
      if (laDeps[sw] != null) {
        laDeps[sw]!.forEach((VersionConstraint mainConstraint,
            Map<String, VersionConstraint> constraints) {
          if (mainConstraint.allows(versionP)) {
            // Now we verify the rest of constraints dependencies
            constraints
                .forEach((String dependency, VersionConstraint constraint) {
              if (debug) {
                print(
                    "testing $swForHumans $versionP with $mainConstraint that depends on $dependency $constraint and uses ${selectedVersions[dependency] ?? 'none'}");
              }
              // Not use internal name for LA services
              String depForHumans = LAServiceDesc.isLAService(dependency)
                  ? LAServiceDesc.get(dependency).name
                  : dependency;
              if (selectedVersions[dependency] == null) {
                if (serviceInUse.contains(dependency)) {
                  lintErrors.add('$swForHumans depends on $depForHumans');
                }
              } else {
                if (!constraint.allows(v(selectedVersions[dependency]!))) {
                  lintErrors
                      .add('$swForHumans depends on $depForHumans $constraint');
                }
              }
            });
          }
        });
      }
    });
    return lintErrors;
  }
}
