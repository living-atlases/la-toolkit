import 'package:la_toolkit/models/Dependencies.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';

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
  });

  test('Compare dependencies ', () {
    Map<String, String> dep = {};
    dep['ala-install'] = "2.0.6";

    Map<Component, String> combo = {
      Component.laToolkit: '1.0.22',
      Component.alaInstall: '2.0.6',
      Component.laGenerator: '1.1.36'
    };
    List<String>? lintErrors = Dependencies.verify(combo);
    expect(lintErrors != null, equals(true));
    expect(lintErrors!.length, equals(0));

    combo = {
      Component.laToolkit: '1.0.21',
      Component.alaInstall: '2.0.6',
      Component.laGenerator: '1.1.36'
    };

    lintErrors = Dependencies.verify(combo);
    expect(lintErrors == null, equals(true));

    combo = {
      Component.laToolkit: '1.0.22',
      Component.alaInstall: '2.0.5',
      Component.laGenerator: '1.1.34'
    };
    lintErrors = Dependencies.verify(combo);
    expect(lintErrors != null, equals(true));
    expect(lintErrors!.length, equals(2));
    expect(lintErrors[0],
        equals('ala-install recommended version should be >=2.0.6'));
    expect(lintErrors[1],
        equals('la-generator recommended version should be >=1.1.36'));
    // print(lintErrors);
  });
}
