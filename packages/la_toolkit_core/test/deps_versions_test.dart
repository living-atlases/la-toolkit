import 'dart:convert';
import 'dart:io';

import 'package:la_toolkit_core/models/la_releases.dart';
import 'package:la_toolkit_core/models/la_service_constants.dart';
import 'package:la_toolkit_core/releases/deps_versions.dart';
import 'package:test/test.dart';

/// A real answer of the dev backend (2026-09-21) to a subset of the query.
Map<String, dynamic> _answer() =>
    json.decode(File('test/fixtures/get-deps-versions.json').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  test('the query names every service artifact plus the nexus ones', () {
    final Map<String, String> q = depsVersionsQuery();
    expect(q[collectory], 'ala-collectory collectory');
    expect(q['${namematchingService}_nexus'], 'ala-namematching-server');
    expect(q['${pipelines}_nexus'], 'pipelines');
  });

  test('reads the releases, <release> when there is no <latest>', () {
    final Map<String, LAReleases> r = parseDepsVersions(
      _answer(),
      depsVersionsQuery(),
    );
    expect(r[namematchingService]!.latest, '1.8.3');
    expect(r[namematchingService]!.versions, contains('1.8.3'));
    expect(r[events]!.latest, 'latest');
    expect(r.containsKey('excludeList'), isFalse);
  });

  test('a service with unreadable metadata is left out, not fatal', () {
    final Map<String, dynamic> body = _answer()
      ..[collectory] = <String, dynamic>{'releases': 'garbage'};
    final Map<String, LAReleases> r = parseDepsVersions(
      body,
      depsVersionsQuery(),
    );
    expect(r.containsKey(collectory), isFalse);
    expect(r.containsKey(namematchingService), isTrue);
  });
}
