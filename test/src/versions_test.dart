import 'package:la_toolkit/dependencies_manager.dart';
import 'package:la_toolkit/models/LAServiceConstants.dart';
import 'package:la_toolkit/models/versionUtils.dart';
import 'package:la_toolkit/utils/StringUtils.dart';
import 'package:la_toolkit/utils/api.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';

void main() async {
  final String deps = await Api.fetchDependencies();
  DependenciesManager.setDeps(deps, true);

  test('Compare versions', () {
    final Version v123 = Version.parse('1.2.3');
    final Version v123SNAP = Version.parse('1.2.3-SNAPSHOT');
    final List<VersionConstraint> failConstraints = <VersionConstraint>[
      VersionConstraint.parse('^2.0.0'),
      VersionConstraint.parse('>1.2.4'),
      VersionConstraint.parse('>1.2.3')
    ];
    final List<VersionConstraint> validConstraints = <VersionConstraint>[
      VersionConstraint.parse('^1.0.0'),
      VersionConstraint.parse('>1.0.0 <1.3.0'),
      VersionConstraint.parse('>=1.2.3'),
      VersionConstraint.parse('<2.0.0'),
      VersionConstraint.parse('1.2.3'),
    ];
    for (final VersionConstraint cont in failConstraints) {
      expect(cont.allows(v123), equals(false));
    }
    for (final VersionConstraint cont in validConstraints) {
      expect(cont.allows(v123), equals(true));
    }
    for (final VersionConstraint cont in failConstraints) {
      expect(cont.allows(v123SNAP), equals(false));
    }
    for (final VersionConstraint cont in validConstraints) {
      expect(cont.allows(v123SNAP), equals(true),
          // 1.2.3-SNAPSHOT < 1.2.3, so skip for now
          // https://semver.org/#spec-item-11
          reason: '$cont fails with $v123SNAP',
          skip: true);
    }
  });

  test('Compare toolkit dependencies ', () {
    final Map<String, String> dep = <String, String>{};
    dep['ala-install'] = '2.0.6';

    Map<String, String> combo = <String, String>{
      toolkit: '1.0.22',
      alaInstall: '2.0.6',
      generator: '1.1.36'
    };
    List<String>? lintErrors = DependenciesManager.verify(combo);
    expect(lintErrors.length, equals(0));

    combo = <String, String>{toolkit: '1.0.21', alaInstall: '2.0.6', generator: '1.1.36'};

    lintErrors = DependenciesManager.verify(combo);
    expect(lintErrors.isEmpty, equals(true));

    combo = <String, String>{toolkit: '1.0.22', alaInstall: '2.0.5', generator: '1.1.34'};
    lintErrors = DependenciesManager.verify(combo);
    expect(lintErrors.length, equals(2));
    expect(lintErrors[0],
        equals('ala-install recommended version should be >=2.0.6'));
    expect(lintErrors[1],
        equals('la-generator recommended version should be >=1.1.36'));

    combo = <String, String>{toolkit: '1.0.23', alaInstall: '2.0.6', generator: '1.1.34'};
    lintErrors = DependenciesManager.verify(combo);
    expect(lintErrors.length, equals(1));
    expect(lintErrors[0],
        equals('la-generator recommended version should be >=1.1.37'));

    // TODO: Check that deps are ok!
    // print(lintErrors);
  });

  test('Compare LA dependencies ', () {
    final Map<String, String> softwareVersions = <String, String>{
      alaHub: '1.0.0',
      bie: '1.0.0',
      biocacheService: '2.7.0',
    };

    final List<String> servicesInUse = <String>[alaHub, bie, biocacheService, biocacheCli];

    List<String> lintErrors =
        DependenciesManager.verifyLAReleases(servicesInUse, softwareVersions);
    expect(
        lintErrors[0],
        equals(
            'records-ws (biocache-service) depends on biocache-cli (biocache-store)'));
    expect(lintErrors.length, equals(1));

    servicesInUse.add(alerts);
    softwareVersions[alerts] = '1.6.1';

    servicesInUse.add(biocacheCli);
    softwareVersions[biocacheService] = '3.1.0';
    softwareVersions[biocacheCli] = '2.5.0';

    lintErrors =
        DependenciesManager.verifyLAReleases(servicesInUse, softwareVersions);
    expect(
        lintErrors[0],
        equals(
            'records-ws (biocache-service) depends on biocache-cli (biocache-store) >=2.6.1'));
    expect(lintErrors[1],
        equals('alerts depends on records (biocache-hub) >=3.2.9'));
    expect(lintErrors[2], equals('alerts depends on species (bie) >=1.5.0'));
    expect(
        lintErrors[3],
        equals(
            'biocache-cli (biocache-store) depends on records-ws (biocache-service) <3.0.0'));
    expect(lintErrors.length, equals(4));

    softwareVersions[bie] = '1.6.0';
    softwareVersions[biocacheService] = '2.5.0';
    softwareVersions[alaHub] = '3.3.0';
    lintErrors =
        DependenciesManager.verifyLAReleases(servicesInUse, softwareVersions);
    expect(lintErrors.length, equals(0));

    servicesInUse.add(regions);
    lintErrors =
        DependenciesManager.verifyLAReleases(servicesInUse, softwareVersions);
    expect(lintErrors[0], equals('alerts depends on regions'));
    expect(lintErrors.length, equals(1));

    softwareVersions[regions] = '1.0.0';
    lintErrors =
        DependenciesManager.verifyLAReleases(servicesInUse, softwareVersions);
    expect(lintErrors[0], equals('alerts depends on regions >=3.3.5'));
    expect(lintErrors.length, equals(1));

    softwareVersions[regions] = '3.3.5';
    lintErrors =
        DependenciesManager.verifyLAReleases(servicesInUse, softwareVersions);
    expect(lintErrors.length, equals(0));

    softwareVersions[regions] = '3.3.5';
    lintErrors =
        DependenciesManager.verifyLAReleases(servicesInUse, softwareVersions);
    expect(lintErrors.length, equals(0));

    // check subservices and other non ALA software
    softwareVersions[spatialService] = '3.0.0';
    lintErrors =
        DependenciesManager.verifyLAReleases(servicesInUse, softwareVersions);
    expect(lintErrors.length, equals(0));
  });

  test('LA versions should be parsable', () {
    expect(StringUtils.semantize('1.0.0'), equals('1.0.0'));
    expect(StringUtils.semantize('1.0'), equals('1.0.0'));
    expect(StringUtils.semantize('v1.0.0'), equals('1.0.0'));
    expect(StringUtils.semantize('9.0'), equals('9.0.0'));
    expect(StringUtils.semantize('1.0-SNAPSHOT'), equals('1.0.0-SNAPSHOT'));
    expect(StringUtils.semantize('2.4.PRERELEASE'), equals('2.4.0-PRERELEASE'));
    expect(StringUtils.semantize('1.0.0.1'), equals('1.0.0-1'));
    expect(StringUtils.semantize('9'), equals('9.0.0'));
    expect(StringUtils.semantize('>= 1.5'), equals('>= 1.5.0'));
    expect(StringUtils.semantize('> 1.5'), equals('> 1.5.0'));
    expect(StringUtils.semantize('<= 9'), equals('<= 9.0.0'));
    expect(v('1.0.0').major == 1, equals(true));
    expect(v('1.0.0-SNAPSHOT').major == 1, equals(true));
    expect(v('1.0-SNAPSHOT').major == 1, equals(true));

    expect(v('1.0').major == 1, equals(true));
    expect(v('1.0') == v('1.0.0'), equals(true));
    expect(v('1.0.0.1') == v('1.0.0-1'), equals(true));
  });
}
