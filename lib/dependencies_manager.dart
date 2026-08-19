import 'dart:developer';

import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_extension/yaml_extension.dart';

import 'models/dependencies.dart';
import 'models/la_server.dart';
import 'models/la_service_constants.dart';
import 'models/la_service_desc.dart';
import 'models/la_service_name.dart';
import 'models/migration_notes.dart';
import 'models/migration_notes_desc.dart';
import 'models/nextgen_compat.dart';
import 'models/version_utils.dart';

class DependenciesManager {
  static List<String> verify(Map<String, String> combo) {
    final String alaInstallS = combo[alaInstall]!;
    final bool skipAlaInstall = alaInstallIsNotTagged(alaInstallS);
    return verifyLAReleases(
      skipAlaInstall ? laToolsNoAlaInstall : laTools,
      combo,
    );
  }

  static List<String> check({
    String? toolkitV,
    String? alaInstallV,
    String? generatorV,
  }) {
    if (toolkitV != null && alaInstallV != null && generatorV != null) {
      return verify(<String, String>{
        toolkit: toolkitV.replaceFirst(RegExp(r'^v'), ''),
        alaInstall: alaInstallV.replaceFirst(RegExp(r'^v'), ''),
        generator: generatorV.replaceFirst(RegExp(r'^v'), ''),
      });
    } else {
      return <String>[];
    }
  }

  static List<String> verifyLAReleases(
    List<String> serviceInUse,
    Map<String, String> selectedVersions, [
    bool debug = false,
  ]) {
    final Set<String> lintErrors = <String>{};
    try {
      selectedVersions.forEach((String sw, String version) {
        if (debug) {
          log('Checking dependencies for $sw');
        }
        final String swForHumans = LAServiceDesc.swNameWithAliasForHumans(sw);
        if (version != 'custom' &&
            version != 'upstream' &&
            version != 'la-develop' &&
            version != 'null' &&
            version.isNotEmpty) {
          if (Dependencies.map[sw] != null) {
            Version? versionP;
            try {
              versionP = v(version);
            } catch (e) {
              log('🔴 ERROR parsing version for $sw: version="$version" - $e');
              // log(stacktrace.toString());
              return;
            }
            Dependencies.map[sw]!.forEach((
              VersionConstraint mainConstraint,
              Map<String, VersionConstraint> constraints,
            ) {
              if (mainConstraint.allows(versionP!)) {
                // Now we verify the rest of constraints dependencies
                if (debug) {
                  log('$mainConstraint applies to $sw');
                }
                constraints.forEach((
                  String dependency,
                  VersionConstraint constraint,
                ) {
                  final String? versionOfDep = selectedVersions[dependency];
                  if (debug) {
                    log(
                      "testing $swForHumans $versionP with $mainConstraint that depends on $dependency $constraint and uses ${versionOfDep ?? 'none'}",
                    );
                  }
                  // Not use internal name for LA services
                  final String depForHumans =
                      LAServiceDesc.isLAService(dependency)
                      ? LAServiceDesc.swNameWithAliasForHumans(dependency)
                      : dependency;
                  if (versionOfDep == null) {
                    // An 'any' constraint just requires the dependency to be
                    // present; the service being in use already satisfies it,
                    // so a missing version is not worth warning about.
                    if (serviceInUse.contains(dependency) &&
                        !constraint.isAny) {
                      // Same wording as the mismatch case plus the reason, so
                      // the user sees both the constraint and what to do about
                      // it: 'pipelines depends on namematching' alone said
                      // neither.
                      lintErrors.add(
                        '$swForHumans depends on $depForHumans $constraint '
                        '(no version selected yet)',
                      );
                    }
                  } else {
                    if (versionOfDep != 'custom' &&
                        versionOfDep != 'upstream' &&
                        versionOfDep != 'la-develop' &&
                        versionOfDep != 'null' &&
                        versionOfDep.isNotEmpty) {
                      Version? versionOfDepP;
                      try {
                        versionOfDepP = v(versionOfDep);
                      } catch (e) {
                        log(
                          '🔴 ERROR parsing version for dependency $dependency: version="$versionOfDep" (from $sw) - $e',
                        );
                        // log(stacktrace.toString());
                        return;
                      }
                      if (!constraint.allows(versionOfDepP)) {
                        lintErrors.add(
                          sw == toolkit
                              ? '$dependency recommended version should be $constraint'
                              : '$swForHumans depends on $depForHumans $constraint',
                        );
                      }
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
    List<String> servicesToDeploy,
    Map<String, String> selectedVersions, [
    bool debug = false,
  ]) {
    final Set<MigrationNotesDesc> migrationNotesList = <MigrationNotesDesc>{};
    try {
      selectedVersions.forEach((String sw, String version) {
        if (servicesToDeploy.contains(sw) || servicesToDeploy.contains('all')) {
          if (debug) {
            log('Checking dependencies for $sw');
          }
          if (version != 'custom' &&
              version != 'upstream' &&
              version != 'la-develop' &&
              version.isNotEmpty) {
            if (MigrationNotes.map[sw] != null) {
              final Version versionP = v(version);
              MigrationNotes.map[sw]!.forEach((
                VersionConstraint mainConstraint,
                MigrationNotesDesc migrationNotes,
              ) {
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

  // reason key (from nextgen-compat.yaml) -> human explanation
  static const Map<String, String> _nextgenReasonText = <String, String>{
    'bootstrap5-branding':
        'uses a new theme that the community branding does not support yet',
    'no-community-image':
        'has no published community container image',
  };

  static void setNextgenCompat(String yamlStr, [bool debug = false]) {
    final Map<String, NextgenCompatEntry> result =
        <String, NextgenCompatEntry>{};
    try {
      final YamlMap y = loadYaml(yamlStr) as YamlMap;
      final Map<String, dynamic> root = y.toMap();
      final dynamic section = root['nextgen-compat'];
      if (section is Map) {
        section.forEach((dynamic swKey, dynamic entry) {
          if (entry is Map) {
            try {
              final String sw = _normalize(swKey as String);
              result[sw] = NextgenCompatEntry(
                from: vc('${entry['from']}'),
                lastSafe: '${entry['last-safe']}',
                reason: '${entry['reason']}',
              );
              if (debug) {
                log('nextgen-compat: $sw ${entry['from']} (${entry['reason']})');
              }
            } catch (e) {
              log('🔴 ERROR parsing nextgen-compat entry "$swKey": $e');
            }
          }
        });
      }
    } catch (e, stacktrace) {
      log('setNextgenCompat exception $e');
      log(stacktrace.toString());
    }
    NextgenCompat.map = result;
  }

  static List<String> verifyNextgen(Map<String, String> selectedVersions) {
    final Set<String> lintErrors = <String>{};
    try {
      selectedVersions.forEach((String sw, String version) {
        final NextgenCompatEntry? entry = NextgenCompat.map[sw];
        if (entry == null) {
          return;
        }
        if (version == 'custom' ||
            version == 'upstream' ||
            version == 'la-develop' ||
            version == 'null' ||
            version.isEmpty) {
          return;
        }
        Version? versionP;
        try {
          versionP = v(version);
        } catch (e) {
          log('🔴 ERROR parsing version for $sw: version="$version" - $e');
          return;
        }
        if (entry.from.allows(versionP)) {
          final String human = LAServiceDesc.swNameWithAliasForHumans(sw);
          final String reasonText =
              _nextgenReasonText[entry.reason] ??
              'is not supported by the community stack yet';
          lintErrors.add(
            '$human $version $reasonText — use ${entry.lastSafe} for now.',
          );
        }
      });
      return lintErrors.toList();
    } catch (e, stacktrace) {
      log('verifyNextgen exception $e');
      log(stacktrace.toString());
      return lintErrors.toList();
    }
  }

  static void setDeps(String deps, [bool debug = false]) {
    final YamlMap depsYamlY = loadYaml(deps) as YamlMap;
    final Map<String, dynamic> depsYaml = depsYamlY.toMap();
    final Map<String, Map<VersionConstraint, Map<String, VersionConstraint>>>
    map = <String, Map<VersionConstraint, Map<String, VersionConstraint>>>{};
    for (final String module in depsYaml.keys) {
      final String? moduleKey = _normalizeOrSkip(module);
      if (moduleKey == null) {
        continue;
      }
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
        for (final dynamic depDyn
            in (depsYaml[module] as Map<String, dynamic>)[constraintMatch]
                as List<dynamic>) {
          // if (debug) log("    - $dep");
          final Map<String, dynamic> dep = depDyn as Map<String, dynamic>;
          for (final String sw in dep.keys) {
            final String? depKey = _normalizeOrSkip(sw);
            if (depKey == null) {
              continue;
            }
            if (debug) {
              log('    - $sw: ${dep[sw]}');
            }
            depsMap.putIfAbsent(depKey, () => vc('${dep[sw]}'));
          }
        }
        constraints.putIfAbsent(vc(constraintMatch), () => depsMap);
      }
      map.putIfAbsent(moduleKey, () => constraints);
    }
    Dependencies.map = map;
  }

  /// Returns null (and logs) when the key is not a service this toolkit knows.
  /// The dependency matrix lives in la-toolkit-backend master and can name
  /// services newer than this build, so unknown keys are skipped instead of
  /// aborting the whole load.
  static String? _normalizeOrSkip(String sw) {
    try {
      return _normalize(sw);
    } catch (e) {
      log('⚠️ dependencies.yaml: skipping unknown software "$sw"');
      return null;
    }
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

  static List<String> verifySw(
    LAServer server,
    String swToCheck,
    List<String> serverServices,
    Map<String, String> selectedVersions, [
    bool debug = false,
  ]) {
    final Set<String> lintErrors = <String>{};
    final Map<String, List<String>> swGroups = <String, List<String>>{};

    try {
      for (final String sw in serverServices) {
        if (debug) {
          log('Checking $swToCheck in $sw');
        }
        final String? version = selectedVersions[sw];
        if (version != null && version != 'null') {
          final Map<VersionConstraint, Map<String, VersionConstraint>>? deps =
              Dependencies.map[sw];
          if (version != 'custom' &&
              version != 'upstream' &&
              version != 'la-develop' &&
              version.isNotEmpty) {
            if (deps != null) {
              final Version versionP = v(version);
              deps.forEach((
                VersionConstraint mainConstraint,
                Map<String, VersionConstraint> constraints,
              ) {
                if (mainConstraint.allows(versionP)) {
                  // Now we verify the rest of constraints dependencies
                  if (debug) {
                    log('$mainConstraint applies to $sw');
                  }
                  constraints.forEach((
                    String dependency,
                    VersionConstraint constraint,
                  ) {
                    if (dependency == swToCheck) {
                      if (swGroups.containsKey(constraint.toString())) {
                        swGroups[constraint.toString()]!.add(sw);
                      } else {
                        swGroups.putIfAbsent(
                          constraint.toString(),
                          () => <String>[sw],
                        );
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
          'Warning: In server ${server.name}, ${_versionGroupsForHumans(swGroups, swToCheck)}',
        );
      }
      return lintErrors.toList();
    } catch (e, stacktrace) {
      log('Verify exception $e');
      log(stacktrace.toString());
      return lintErrors.toList();
    }
  }

  static String _versionGroupsForHumans(
    Map<String, List<String>> swGroups,
    String swToCheck,
  ) {
    final List<String> result = <String>[];
    for (final String version in swGroups.keys) {
      if (swGroups[version]!.length > 1) {
        result.add(
          '${swGroups[version]!.map((String sw) => LAServiceDesc.swNameWithAliasForHumans(sw)).join(', ')} use ${_swVersionTranslate(swToCheck, version)}',
        );
      } else {
        result.add(
          '${LAServiceDesc.swNameWithAliasForHumans(swGroups[version]![0])} uses ${_swVersionTranslate(swToCheck, version)}',
        );
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
