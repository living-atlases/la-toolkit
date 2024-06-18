import 'dart:developer';

import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_extension/yaml_extension.dart';

import 'models/LAServiceConstants.dart';
import 'models/MigrationNotesDesc.dart';
import 'models/dependencies.dart';
import 'models/laServer.dart';
import 'models/laServiceDesc.dart';
import 'models/laServiceName.dart';
import 'models/migrationNotes.dart';
import 'models/versionUtils.dart';

class DependenciesManager {
  static List<String> verify(Map<String, String> combo) {
    final String alaInstallS = combo[alaInstall]!;
    final bool skipAlaInstall = alaInstallIsNotTagged(alaInstallS);
    return verifyLAReleases(
        skipAlaInstall ? laToolsNoAlaInstall : laTools, combo);
  }

  static List<String> check(
      {String? toolkitV, String? alaInstallV, String? generatorV}) {
    if (toolkitV != null && alaInstallV != null && generatorV != null) {
      return verify(<String, String>{
        toolkit: toolkitV.replaceFirst(RegExp(r'^v'), ''),
        alaInstall: alaInstallV.replaceFirst(RegExp(r'^v'), ''),
        generator: generatorV.replaceFirst(RegExp(r'^v'), '')
      });
    } else {
      return <String>[];
    }
  }

  static List<String> verifyLAReleases(
      List<String> serviceInUse, Map<String, String> selectedVersions,
      [bool debug = false]) {
    final Set<String> lintErrors = <String>{};
    try {
      selectedVersions.forEach((String sw, String version) {
        if (debug) {
          log('Checking dependencies for $sw');
        }
        final String swForHumans = LAServiceDesc.swNameWithAliasForHumans(sw);
        if (version != 'custom' &&
            version != 'upstream' &&
            version != 'la-develop') {
          if (Dependencies.map[sw] != null) {
            final Version versionP = v(version);
            Dependencies.map[sw]!.forEach((VersionConstraint mainConstraint,
                Map<String, VersionConstraint> constraints) {
              if (mainConstraint.allows(versionP)) {
                // Now we verify the rest of constraints dependencies
                if (debug) {
                  log('$mainConstraint applies to $sw');
                }
                constraints
                    .forEach((String dependency, VersionConstraint constraint) {
                  final String? versionOfDep = selectedVersions[dependency];
                  if (debug) {
                    log("testing $swForHumans $versionP with $mainConstraint that depends on $dependency $constraint and uses ${versionOfDep ?? 'none'}");
                  }
                  // Not use internal name for LA services
                  final String depForHumans =
                      LAServiceDesc.isLAService(dependency)
                          ? LAServiceDesc.swNameWithAliasForHumans(dependency)
                          : dependency;
                  if (versionOfDep == null) {
                    if (serviceInUse.contains(dependency)) {
                      lintErrors.add('$swForHumans depends on $depForHumans');
                    }
                  } else {
                    if (versionOfDep != 'custom' &&
                        versionOfDep != 'upstream' &&
                        versionOfDep != 'la-develop' &&
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
              log('No dependencies for $sw');
            }
          }
        }
      });
      return lintErrors.toList();
    } catch (e, stacktrace) {
      log('Verify exception $e');
      log(stacktrace.toString());
      return lintErrors.toList();
    }
  }

  static List<MigrationNotesDesc> getMigrationNotes(
      List<String> servicesToDeploy, Map<String, String> selectedVersions,
      [bool debug = false]) {
    final Set<MigrationNotesDesc> migrationNotesList = <MigrationNotesDesc>{};
    try {
      selectedVersions.forEach((String sw, String version) {
        if (servicesToDeploy.contains(sw) || servicesToDeploy.contains('all')) {
          if (debug) {
            log('Checking dependencies for $sw');
          }
          if (version != 'custom' &&
              version != 'upstream' &&
              version != 'la-develop') {
            if (MigrationNotes.map[sw] != null) {
              final Version versionP = v(version);
              MigrationNotes.map[sw]!.forEach((VersionConstraint mainConstraint,
                  MigrationNotesDesc migrationNotes) {
                if (mainConstraint.allows(versionP)) {
                  // Now we verify the rest of constraints dependencies
                  if (debug) {
                    log('$mainConstraint applies to $sw');
                  }
                  migrationNotesList.add(migrationNotes);
                }
              });
            } else {
              if (debug) {
                log('No dependencies for $sw');
              }
            }
          }
        }
      });
      return migrationNotesList.toList();
    } catch (e, stacktrace) {
      log('Verify exception $e');
      log(stacktrace.toString());
      return migrationNotesList.toList();
    }
  }

  static void setDeps(String deps, [bool debug = false]) {
    final YamlMap depsYamlY = loadYaml(deps) as YamlMap;
    final Map<String, dynamic> depsYaml = depsYamlY.toMap();
    final Map<String, Map<VersionConstraint, Map<String, VersionConstraint>>>
        map =
        <String, Map<VersionConstraint, Map<String, VersionConstraint>>>{};
    for (final String module in depsYaml.keys) {
      if (debug) {
        log('Module: $module');
      }
      final Map<VersionConstraint, Map<String, VersionConstraint>> constraints =
          <VersionConstraint, Map<String, VersionConstraint>>{};
      for (final String constraintMatch
          in (depsYaml[module] as Map<String, dynamic>).keys) {
        final Map<String, VersionConstraint> depsMap =
            <String, VersionConstraint>{};
        if (debug) {
          log('  $constraintMatch');
        }
        for (final dynamic depDyn in (depsYaml[module]
            as Map<String, dynamic>)[constraintMatch] as List<dynamic>) {
          // if (debug) log("    - $dep");
          final Map<String, dynamic> dep = depDyn as Map<String, dynamic>;
          for (final String sw in dep.keys) {
            if (debug) {
              log('    - $sw: ${dep[sw]}');
            }
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
      case 'la-generator':
        return generator;
      case 'ala-install':
        return alaInstall;
      case 'la-toolkit':
        return toolkit;
      case 'java':
      case 'tomcat':
      case 'ansible':
        return sw;
      default:
        final String toSunder = sw.replaceAll('-', '_');
        // This throws ArgumentError if the enum does not exists
        return LAServiceName.values.byName(toSunder).toS();
    }
  }

  static List<String> verifySw(LAServer server, String swToCheck,
      List<String> serverServices, Map<String, String> selectedVersions,
      [bool debug = false]) {
    final Set<String> lintErrors = <String>{};
    final Map<String, List<String>> swGroups = <String, List<String>>{};

    try {
      for (final String sw in serverServices) {
        if (debug) {
          log('Checking $swToCheck in $sw');
        }
        final String? version = selectedVersions[sw];
        if (version != null) {
          final Map<VersionConstraint, Map<String, VersionConstraint>>? deps =
              Dependencies.map[sw];
          if (version != 'custom' &&
              version != 'upstream' &&
              version != 'la-develop') {
            if (deps != null) {
              final Version versionP = v(version);
              deps.forEach((VersionConstraint mainConstraint,
                  Map<String, VersionConstraint> constraints) {
                if (mainConstraint.allows(versionP)) {
                  // Now we verify the rest of constraints dependencies
                  if (debug) {
                    log('$mainConstraint applies to $sw');
                  }
                  constraints.forEach(
                      (String dependency, VersionConstraint constraint) {
                    if (dependency == swToCheck) {
                      if (swGroups.containsKey(constraint.toString())) {
                        swGroups[constraint.toString()]!.add(sw);
                      } else {
                        swGroups.putIfAbsent(
                            constraint.toString(), () => <String>[sw]);
                      }
                    }
                  });
                }
              });
            }
          }
        }
      }
      if (swGroups.length > 1) {
        // lintErrors.add(
        //   'Warning: Different versions of $swToCheck in server ${server.name}: ${_versionGroupsForHumans(swGroups, swToCheck)}');
        lintErrors.add(
            'Warning: In server ${server.name}, ${_versionGroupsForHumans(swGroups, swToCheck)}');
      }
      return lintErrors.toList();
    } catch (e, stacktrace) {
      log('Verify exception $e');
      log(stacktrace.toString());
      return lintErrors.toList();
    }
  }

  static String _versionGroupsForHumans(
      Map<String, List<String>> swGroups, String swToCheck) {
    final List<String> result = <String>[];
    for (final String version in swGroups.keys) {
      if (swGroups[version]!.length > 1) {
        result.add(
            '${swGroups[version]!.map((String sw) => LAServiceDesc.swNameWithAliasForHumans(sw)).join(', ')} use ${_swVersionTranslate(swToCheck, version)}');
      } else {
        result.add(
            '${LAServiceDesc.swNameWithAliasForHumans(swGroups[version]![0])} uses ${_swVersionTranslate(swToCheck, version)}');
      }
    }
    return result.join(', ');
  }

  static String _swVersionTranslate(String swToCheck, String version) {
    if (swToCheck == java) {
      return "$swToCheck ${version.replaceAll('.0.0', '')}";
    } else {
      return '$swToCheck $version';
    }
  }
}
