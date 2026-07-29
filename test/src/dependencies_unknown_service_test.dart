import 'package:la_toolkit/dependencies_manager.dart';
import 'package:la_toolkit/models/dependencies.dart';
import 'package:la_toolkit/models/la_service_constants.dart';
import 'package:la_toolkit/models/version_utils.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';

/// The dependency matrix is fetched from la-toolkit-backend master, so it can
/// name services newer than this toolkit build (see species-lists-service, the
/// Java 21 microservice replacing specieslist-webapp). Unknown keys must be
/// skipped, not abort the load and leave Dependencies.map empty.
const String _fixture = '''
species-lists:
  '< 4.0.0':
    - nameindexer: any
    - java: '8'
  '>= 4.0.0':
    - namematching-service: any
    - java: '11'

species-lists-service:
  any:
    - java: '21'

collectory:
  any:
    - java: '11'
    - a-service-from-the-future: any
''';

void main() {
  group('dependencies.yaml with services unknown to this toolkit', () {
    setUp(() => DependenciesManager.setDeps(_fixture));

    test('does not throw and still loads the known modules', () {
      expect(Dependencies.map.containsKey(speciesLists), isTrue);
      expect(
        Dependencies.map[speciesLists]!.keys,
        contains(VersionConstraint.parse('>= 4.0.0')),
      );
      expect(Dependencies.map.containsKey(collectory), isTrue);
    });

    test('skips the unknown module', () {
      expect(Dependencies.map.containsKey('species_lists_service'), isFalse);
    });

    test('skips an unknown dep without dropping its known siblings', () {
      final Map<String, VersionConstraint> deps =
          Dependencies.map[collectory]![VersionConstraint.parse('any')]!;
      expect(deps.containsKey(java), isTrue);
      expect(deps[java], vc('11'));
      expect(deps.containsKey('a_service_from_the_future'), isFalse);
    });
  });
}
