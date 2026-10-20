import 'package:la_toolkit_core/dependencies_manager.dart';
import 'package:la_toolkit_core/models/la_service_constants.dart';
import 'package:la_toolkit_core/models/nextgen_compat.dart';
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
  collectory:
    from: '> 6.2.2'
    last-safe: '6.0.0'
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
      expect(
        DependenciesManager.verifyNextgen(<String, String>{
          collectory: '6.3.0',
        }),
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
      expect(
        DependenciesManager.verifyNextgen(<String, String>{
          collectory: '6.0.0',
        }),
        isEmpty,
      );
    });

    test('ignores non-tagged and empty versions', () {
      for (final String v in <String>[
        'custom',
        'upstream',
        'la-develop',
        'null',
        '',
      ]) {
        expect(
          DependenciesManager.verifyNextgen(<String, String>{logger: v}),
          isEmpty,
          reason: 'version "$v" should not trigger the guard',
        );
      }
    });

    test('ignores services without an entry', () {
      expect(
        DependenciesManager.verifyNextgen(<String, String>{images: '1.1.7'}),
        isEmpty,
      );
    });

    test('bootstrap5 message asks for a Bootstrap 5 branding', () {
      final List<String> warnings = DependenciesManager.verifyNextgen(
        <String, String>{logger: '4.7.0'},
      );
      expect(warnings.single, contains('4.7.0'));
      expect(warnings.single, contains('Bootstrap 5'));
      expect(warnings.single, contains('.mustache'));
      expect(warnings.single, contains('4.5.0'));
      expect(warnings.single, isNot(contains('not support')));
      expect(warnings.single, isNot(contains('{last}')));
    });

    test('other reasons keep the last-safe suggestion', () {
      DependenciesManager.setNextgenCompat('''
nextgen-compat:
  sds:
    from: '< 1.6.4'
    last-safe: '1.7.1'
    reason: no-community-image
  doi:
    from: '< 3.0.2'
    last-safe: '4.1.0'
    reason: some-future-reason
''');
      expect(
        DependenciesManager.verifyNextgen(<String, String>{
          sds: '1.6.3',
        }).single,
        allOf(contains('container image'), contains('use 1.7.1 for now')),
      );
      expect(
        DependenciesManager.verifyNextgen(<String, String>{
          doi: '2.0.0',
        }).single,
        allOf(contains('not supported'), contains('use 4.1.0 for now')),
      );
    });
  });

  test('malformed / empty input leaves the map empty without throwing', () {
    DependenciesManager.setNextgenCompat('not: a valid nextgen file');
    expect(NextgenCompat.map, isEmpty);
    DependenciesManager.setNextgenCompat('');
    expect(NextgenCompat.map, isEmpty);
  });
}
