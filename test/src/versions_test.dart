import 'package:la_toolkit/models/dependencies.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';

void main() {
  final String lists = LAServiceName.species_lists.toS();
  final String collectory = LAServiceName.collectory.toS();
  final String bie = LAServiceName.ala_bie.toS();
  final String bieIndex = LAServiceName.bie_index.toS();
  final String alaHub = LAServiceName.ala_hub.toS();
  final String biocacheService = LAServiceName.biocache_service.toS();
  final String biocacheStore = LAServiceName.biocache_cli.toS();
  final String alerts = LAServiceName.alerts.toS();
  final String images = LAServiceName.images.toS();
  final String solr = LAServiceName.solr.toS();
  final String webapi = LAServiceName.webapi.toS();
  final String regions = LAServiceName.regions.toS();
  final String spatial = LAServiceName.spatial.toS();
  final String cas = LAServiceName.cas.toS();
  final String sds = LAServiceName.sds.toS();
  final String dashboard = LAServiceName.dashboard.toS();
  final String branding = LAServiceName.branding.toS();
  final String doi = LAServiceName.doi.toS();

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
    for (VersionConstraint cont in failConstraints) {
      expect(cont.allows(v123), equals(false));
    }
    for (VersionConstraint cont in validConstraints) {
      expect(cont.allows(v123), equals(true));
    }
  });

  test('Compare toolkit dependencies ', () {
    Map<String, String> dep = {};
    dep['ala-install'] = "2.0.6";

    Map<String, String> combo = {
      "laToolkit": '1.0.22',
      "alaInstall": '2.0.6',
      "laGenerator": '1.1.36'
    };
    List<String>? lintErrors = Dependencies.verify(combo);
    expect(lintErrors.length, equals(0));

    combo = {
      "laToolkit": '1.0.21',
      "alaInstall": '2.0.6',
      "laGenerator": '1.1.36'
    };

    lintErrors = Dependencies.verify(combo);
    expect(lintErrors.isEmpty, equals(true));

    combo = {
      "laToolkit": '1.0.22',
      "alaInstall": '2.0.5',
      "laGenerator": '1.1.34'
    };
    lintErrors = Dependencies.verify(combo);
    expect(lintErrors.length, equals(2));
    expect(lintErrors[0],
        equals('ala-install recommended version should be >=2.0.6'));
    expect(lintErrors[1],
        equals('la-generator recommended version should be >=1.1.36'));

    combo = {
      "laToolkit": '1.0.23',
      "alaInstall": '2.0.6',
      "laGenerator": '1.1.34'
    };
    lintErrors = Dependencies.verify(combo);
    expect(lintErrors.length, equals(1));
    expect(lintErrors[0],
        equals('la-generator recommended version should be >=1.1.37'));

    // TODO: Check that deps are ok!
    // print(lintErrors);
  });

  test('Compare LA dependencies ', () {
    Map<String, String> softwareVersions = {
      alaHub: "1.0.0",
      // alerts: "1.6.1",
      bie: "1.0.0",
      biocacheService: "1.0.0",
    };

    List<String> servicesInUse = [
      alaHub,
      // alerts,
      bie,
      biocacheService,
      biocacheStore,
    ];

    List<String> lintErrors =
        Dependencies.verifyLAReleases(servicesInUse, softwareVersions);
    expect(lintErrors[0], equals('records-ws depends on biocache-cli'));
    expect(lintErrors.length, equals(1));

    servicesInUse.add(alerts);
    softwareVersions[alerts] = "1.6.1";

    servicesInUse.add(biocacheStore);
    softwareVersions[biocacheService] = "3.1.0";
    softwareVersions[biocacheStore] = "2.5.0";

    lintErrors = Dependencies.verifyLAReleases(servicesInUse, softwareVersions);
    expect(lintErrors[0], equals('alerts depends on records >=3.2.9'));
    expect(lintErrors[1], equals('alerts depends on species >=1.5.0'));
    expect(lintErrors[2], equals('biocache-cli depends on records-ws <3.0.0'));
    expect(lintErrors.length, equals(3));

    softwareVersions[bie] = "1.6.0";
    softwareVersions[biocacheService] = "2.5.0";
    softwareVersions[alaHub] = "3.3.0";
    lintErrors = Dependencies.verifyLAReleases(servicesInUse, softwareVersions);
    expect(lintErrors.length, equals(0));
  });
}
