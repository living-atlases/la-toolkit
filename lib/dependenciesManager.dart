import 'package:la_toolkit/models/LAServiceConstants.dart';
import 'package:la_toolkit/models/MigrationNotesDesc.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

import 'models/dependencies.dart';
import 'models/laServiceName.dart';
import 'models/migrationNotes.dart';
import 'models/versionUtils.dart';

class DependenciesManager {
  static List<String> verify(Map<String, String> combo) {
    String alaInstallS = combo[alaInstall]!;
    bool skipAlaInstall = alaInstallIsNotTagged(alaInstallS);
    return verifyLAReleases(
        skipAlaInstall ? laToolsNoAlaInstall : laTools, combo);
  }

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
          if (Dependencies.map[sw] != null) {
            Version versionP = v(version);
            Dependencies.map[sw]!.forEach((VersionConstraint mainConstraint,
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

  static List<MigrationNotesDesc> getMigrationNotes(
      List<String> servicesToDeploy, Map<String, String> selectedVersions,
      [bool debug = false]) {
    Set<MigrationNotesDesc> migrationNotesList = {};
    try {
      selectedVersions.forEach((String sw, String version) {
        if ((servicesToDeploy.contains(sw) ||
            servicesToDeploy.contains('all'))) {
          if (debug) {
            print("Checking dependencies for $sw");
          }
          if (version != 'custom' && version != 'upstream') {
            if (MigrationNotes.map[sw] != null) {
              Version versionP = v(version);
              MigrationNotes.map[sw]!.forEach((VersionConstraint mainConstraint,
                  MigrationNotesDesc migrationNotes) {
                if (mainConstraint.allows(versionP)) {
                  // Now we verify the rest of constraints dependencies
                  if (debug) {
                    print("$mainConstraint applies to $sw");
                  }
                  migrationNotesList.add(migrationNotes);
                }
              });
            } else {
              if (debug) {
                print("No dependencies for $sw");
              }
            }
          }
        }
      });
      return migrationNotesList.toList();
    } catch (e, stacktrace) {
      print("Verify exception $e");
      print(stacktrace);
      return migrationNotesList.toList();
    }
  }

  static void setDeps(String deps, [bool debug = false]) {
    var depsYaml = loadYaml(deps) as Map;
    Map<String, Map<VersionConstraint, Map<String, VersionConstraint>>> map =
        {};
    for (var module in depsYaml.keys) {
      if (debug) print("Module: $module");
      Map<VersionConstraint, Map<String, VersionConstraint>> constraints = {};
      for (var constraintMatch in depsYaml[module].keys) {
        Map<String, VersionConstraint> depsMap = {};
        if (debug) print("  $constraintMatch");
        for (var dep in depsYaml[module][constraintMatch]) {
          if (debug) print("    - $dep");
          for (var sw in dep.keys) {
            if (debug) print("    $sw: ${dep[sw]}");
            depsMap.putIfAbsent(_normalize(sw), () => vc('${dep[sw]}'));
          }
        }
        constraints.putIfAbsent(vc(constraintMatch), () => depsMap);
      }
      map.putIfAbsent(_normalize(module), () => constraints);
    }
    Dependencies.map = map;
  }

  static String _normalize(String sw) {
    switch (sw) {
      case "la-generator":
        return generator;
      case "ala-install":
        return alaInstall;
      case "la-toolkit":
        return toolkit;
      case "java":
      case "tomcat":
      case "ansible":
        return sw;
      default:
        String toSunder = sw.replaceAll('-', '_');
        // This throws ArgumentError if the enum does not exists
        return LAServiceName.values.byName(toSunder).toS();
    }
  }
}
