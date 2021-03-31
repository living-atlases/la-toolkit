import 'package:pub_semver/pub_semver.dart';

enum Component { laToolkit, alaInstall, laGenerator }

class Dependencies {
  static const toolkit = Component.laToolkit;
  static const alaInstall = Component.alaInstall;
  static const generator = Component.laGenerator;

  static Map<VersionConstraint, Map<Component, VersionConstraint>> deps = {
    vc('>= 1.0.22 < 1.0.23'): {
      alaInstall: vc('>= 2.0.6'),
      generator: vc('>= 1.1.36')
    },
    vc('>= 1.0.23'): {alaInstall: vc('>= 2.0.6'), generator: vc('>= 1.1.37')},
  };

  static VersionConstraint vc(String c) => VersionConstraint.parse(c);
  static Version v(String c) => Version.parse(c);

  static List<String>? verify(Map<Component, String> combo) {
    Version toolkitV = v(combo[toolkit]!);
    String alaInstallS = combo[alaInstall]!;
    bool skipAlaInstall = alaInstallS == 'custom' || alaInstallS == 'upstream';
    Version generatorV = v(combo[generator]!);
    List<String>? lintError;
    try {
      deps.keys.firstWhere((key) => key.allows(toolkitV));
      lintError = [];
      Map<Component, VersionConstraint> match =
          deps.entries.firstWhere((e) => e.key.allows(toolkitV)).value;
      if (!skipAlaInstall && !match[alaInstall]!.allows(v(alaInstallS))) {
        lintError.add(
            'ala-install recommended version should be ${match[alaInstall]!}');
      }
      if (!match[generator]!.allows(generatorV)) {
        lintError.add(
            'la-generator recommended version should be ${match[generator]!}');
      }
    } catch (e) {}
    return lintError;
  }

  static List<String>? check(
      {String? toolkitV, String? alaInstallV, String? generatorV}) {
    if (toolkitV != null && alaInstallV != null && generatorV != null) {
      Map<Component, String> combo = {
        toolkit: toolkitV.replaceFirst(RegExp(r'^v'), ''),
        alaInstall: alaInstallV.replaceFirst(RegExp(r'^v'), ''),
        generator: generatorV.replaceFirst(RegExp(r'^v'), '')
      };
      return verify(combo);
    } else
      return [];
  }
}
