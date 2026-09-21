import 'dart:convert';

import 'package:la_toolkit_core/dependencies_manager.dart';
import 'package:la_toolkit_core/lint/project_lint.dart';
import 'package:la_toolkit_core/models/la_project.dart';
import 'package:la_toolkit_core/models/la_service_constants.dart';
import 'package:la_toolkit_mcp/src/lint.dart';
import 'package:la_toolkit_mcp/src/projects.dart';
import 'package:test/test.dart';

/// A generator release that needs a toolkit nobody has.
const String _matrix = '''
la-generator:
  '>= 1.0.0':
    - la-toolkit: '>= 99.0.0'
''';

/// [p] as `get-conf` returns it (a JSON round trip, hubs nested).
Json _asStored(LAProject p) => json.decode(json.encode(p.toJson())) as Json;

void main() {
  test('without the matrix the report is never clean', () {
    final Json r = lintReport(
      LAProject(),
      hasSshKeys: true,
      backendVersion: '1.8.0',
      matrixLoaded: false,
    );
    expect(r['clean'], isFalse);
    expect(r['dependenciesNotChecked'], contains('could not be downloaded'));
    expect(r['dependencyErrors'], isEmpty);
  });

  test('without the backend version the report is never clean', () {
    final Json r = lintReport(
      LAProject(),
      hasSshKeys: true,
      backendVersion: null,
      matrixLoaded: true,
    );
    expect(r['clean'], isFalse);
    expect(r['dependenciesNotChecked'], contains('version'));
  });

  test('a release the matrix rejects is reported', () {
    DependenciesManager.setDeps(_matrix);
    final LAProject p = LAProject()..generatorRelease = '1.7.0';
    final Json r = lintReport(
      p,
      hasSshKeys: true,
      backendVersion: '1.8.0',
      matrixLoaded: true,
    );
    expect(r['clean'], isFalse);
    expect(r['dependencyErrors'], isNotEmpty);
    expect(r.containsKey('dependenciesNotChecked'), isFalse);
  });

  test('findings carry the hint of their fix', () {
    final Json r = lintReport(
      LAProject(),
      hasSshKeys: false,
      backendVersion: null,
      matrixLoaded: false,
    );
    expect((r['findings'] as List<dynamic>).first, <String, dynamic>{
      'message': "You don't have any SSH key",
      'fix': fixHints.values.first,
    });
  });

  test('a hub is built under its portal and lints as a compose hub', () {
    final LAProject portal = LAProject(shortName: 'portal');
    portal.serviceInUse(dockerCompose, true);
    final LAProject hub = LAProject(
      shortName: 'hub',
      isHub: true,
      parent: portal,
    );
    portal.hubs.add(hub);
    final Json stored = _asStored(portal);
    final Json hubJson = (stored['hubs'] as List<dynamic>).first as Json;

    final LAProject model = projectModel(ProjectRef(hubJson, stored));
    expect(model.id, hub.id);
    expect(model.parent?.id, portal.id);

    final Json r = lintReport(
      model,
      hasSshKeys: true,
      backendVersion: null,
      matrixLoaded: false,
    );
    expect(
      (r['findings'] as List<dynamic>).cast<Json>().where(
        (Json f) => f['fix'] == fixHints[LintFix.openParent],
      ),
      hasLength(1),
    );
  });
}
