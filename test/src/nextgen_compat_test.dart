import 'package:la_toolkit/dependencies_manager.dart';
import 'package:la_toolkit/models/la_service_constants.dart';
import 'package:la_toolkit/models/nextgen_compat.dart';
import 'package:test/test.dart';

const String _fixture = '''
nextgen-compat:
  logger:
    from: '> 4.5.0'
    last-safe: '4.5.0'
    reason: bootstrap5-branding
  alerts:
    from: '> 5.2.4'
    last-safe: '5.2.4'
    reason: bootstrap5-branding
''';

void main() {
  group('nextgen-compat guard', () {
    setUp(() => DependenciesManager.setNextgenCompat(_fixture));

    test('parses entries into the static map', () {
      expect(NextgenCompat.map.containsKey(logger), isTrue);
      expect(NextgenCompat.map[logger]!.lastSafe, '4.5.0');
      expect(NextgenCompat.map[logger]!.reason, 'bootstrap5-branding');
      expect(NextgenCompat.map.containsKey(alerts), isTrue);
    });

    test('warns on nextgen (bootstrap5) versions', () {
      expect(
        DependenciesManager.verifyNextgen(<String, String>{logger: '4.7.0'}),
        hasLength(1),
      );
      expect(
        DependenciesManager.verifyNextgen(<String, String>{logger: '4.6.1'}),
        hasLength(1),
      );
      expect(
        DependenciesManager.verifyNextgen(<String, String>{alerts: '5.3.2'}),
        hasLength(1),
      );
    });

    test('does not warn on last-safe or older versions', () {
      expect(
        DependenciesManager.verifyNextgen(<String, String>{logger: '4.5.0'}),
        isEmpty,
      );
      expect(
        DependenciesManager.verifyNextgen(<String, String>{alerts: '5.2.4'}),
        isEmpty,
      );
    });

    test('ignores non-tagged and empty versions', () {
      for (final String v in <String>['custom', 'upstream', 'la-develop',
        'null', '']) {
        expect(
          DependenciesManager.verifyNextgen(<String, String>{logger: v}),
          isEmpty,
          reason: 'version "$v" should not trigger the guard',
        );
      }
    });

    test('ignores services without an entry', () {
      expect(
        DependenciesManager.verifyNextgen(<String, String>{collectory: '5.1.1'}),
        isEmpty,
      );
    });

    test('message mentions the app and the last-safe version', () {
      final List<String> warnings =
          DependenciesManager.verifyNextgen(<String, String>{logger: '4.7.0'});
      expect(warnings.single, contains('4.5.0'));
      expect(warnings.single, contains('theme'));
    });
  });

  test('malformed / empty input leaves the map empty without throwing', () {
    DependenciesManager.setNextgenCompat('not: a valid nextgen file');
    expect(NextgenCompat.map, isEmpty);
    DependenciesManager.setNextgenCompat('');
    expect(NextgenCompat.map, isEmpty);
  });
}
