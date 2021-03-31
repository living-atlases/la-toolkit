import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';

enum Component { laToolkit, alaInstall, laGenerator }

void main() {
  test('Compare versions', () {
    Version v123 = Version.parse('1.2.3');
    List<VersionConstraint> failConstraints = [
      VersionConstraint.parse('^2.0.0'),
      VersionConstraint.parse('>1.2.4'),
      VersionConstraint.parse('>1.2.3')
    ];
    List<VersionConstraint> validConstraints = [
      VersionConstraint.parse('^1.0.0'),
      VersionConstraint.parse('>1.0.0 <1.3.0'),
      VersionConstraint.parse('>=1.2.3'),
      VersionConstraint.parse('<2.0.0')
    ];
    failConstraints.forEach((cont) {
      expect(cont.allows(v123), equals(false));
    });
    validConstraints.forEach((cont) {
      expect(cont.allows(v123), equals(true));
    });
    Map<String, String> dep = {};
    dep['ala-install'] = "2.0.6";
    Map<String, Map<Component, String>> deps =
        Map<String, Map<Component, String>>();
    const toolkit = Component.laToolkit;
    const alaInstall = Component.alaInstall;
    const generator = Component.laGenerator;
    deps = {
      '> 1.0.22': {alaInstall: '>=2.0.6', generator: '>= 1.1.36'},
      '< 1.0.22': {alaInstall: '<2.0.6', generator: '>= 1.1.37'},
      '> 1.0.23': {alaInstall: '>=2.0.6', generator: '>= 1.1.37'}
    };
    Map<Component, String> combo = {
      toolkit: '1.0.22',
      alaInstall: '2.0.6',
      generator: '1.1.36'
    };
    deps.keys.forEach((String key) {
      Map<Component, String> someDeps = deps[key]!;
      VersionConstraint currentConst = VersionConstraint.parse(key);
      if (currentConst.allows(Version.parse(combo[toolkit]!))) {
        expect(
            VersionConstraint.parse(someDeps[alaInstall]!)
                .allows(Version.parse(combo[alaInstall]!)),
            equals(true));
        expect(
            VersionConstraint.parse(someDeps[generator]!)
                .allows(Version.parse(combo[generator]!)),
            equals(true));
      }
    });

    // Map<String,Map<String,String>> = deps = {};
    // toolkit 1.0.22, ala-install 2.0.6 - gen 1.1.36
  });
}
