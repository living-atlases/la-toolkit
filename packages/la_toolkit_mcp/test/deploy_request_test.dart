import 'package:la_toolkit_mcp/la_toolkit_mcp.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

DeployRequest build(Json p, Map<String, Object?> args, {Json? parent}) =>
    buildDeployRequest(ProjectRef(p, parent), args);

void main() {
  group('safety', () {
    test('defaults to a dry run that does not touch the shared checkouts', () {
      final DeployRequest r = build(project(), <String, Object?>{});
      expect(r.dryRun, isTrue);
      expect(r.prepare, isFalse);
      expect(build(project(), <String, Object?>{'prepare': true}).prepare, isTrue);
      expect(r.cmd['dryRun'], isTrue);
    });

    test('a real deploy needs confirm', () {
      expect(
        () => build(project(), <String, Object?>{'dryRun': false}),
        throwsA(isA<InvalidRequest>().having((InvalidRequest e) => e.message, 'message', contains('confirm: true'))),
      );
      final DeployRequest r = build(project(), <String, Object?>{'dryRun': false, 'confirm': true});
      expect(r.dryRun, isFalse);
      expect(r.prepare, isTrue);
    });

    // ansiblew runs the final line through `sh -c`, dry run included.
    for (final String bad in <String>['a;rm -rf /', r'$(id)', 'x y', '`id`', "a'b", 'a|b', '-x']) {
      test('refuses shell-unsafe token "$bad"', () {
        for (final String key in <String>['tags', 'skipTags', 'skipServices', 'limitToServers']) {
          expect(
            () => build(project(), <String, Object?>{key: <String>[bad]}),
            throwsA(isA<InvalidRequest>()),
            reason: key,
          );
        }
      });
    }

    test('refuses non-list and non-string entries', () {
      expect(() => build(project(), <String, Object?>{'tags': 'nginx'}), throwsA(isA<InvalidRequest>()));
      expect(() => build(project(), <String, Object?>{'tags': <Object>[1]}), throwsA(isA<InvalidRequest>()));
      expect(() => build(project(), <String, Object?>{'dryRun': 'no'}), throwsA(isA<InvalidRequest>()));
    });
  });

  group('docker-compose', () {
    test('builds a monolithic compose command with skipServices', () {
      final DeployRequest r = build(project(), <String, Object?>{
        'skipServices': <String>['spatial', 'images'],
        'tags': <String>['nginx'],
      });
      expect(r.cmd, containsPair('dockerCompose', true));
      expect(r.cmd['deployServices'], <String>['all']);
      expect(r.cmd['skipServices'], <String>['spatial', 'images']);
      expect(r.cmd['tags'], <String>['nginx']);
    });

    test('refuses a service allow-list', () {
      expect(() => build(project(), <String, Object?>{'services': <String>['collectory']}), throwsA(isA<InvalidRequest>()));
    });

    test('refuses a compose hub without servers and points at the portal', () {
      final Json portal = project();
      final Json hub = project(id: 'h1', dirName: 'hub', compose: false, isHub: true)
        ..['servers'] = <Json>[]
        ..['serverServices'] = <String, dynamic>{};
      expect(
        () => build(hub, <String, Object?>{}, parent: portal),
        throwsA(isA<InvalidRequest>().having((InvalidRequest e) => e.message, 'message', contains('Deploy the portal'))),
      );
    });
  });

  group('vm', () {
    test('remaps species-lists and rejects skipServices', () {
      final Json p = project(compose: false, vm: true);
      final DeployRequest r = build(p, <String, Object?>{'services': <String>['species-lists', 'collectory']});
      expect(r.cmd['dockerCompose'], isFalse);
      expect(r.cmd['deployServices'], <String>['lists', 'collectory']);
      expect(() => build(p, <String, Object?>{'skipServices': <String>['spatial']}), throwsA(isA<InvalidRequest>()));
    });
  });

  test('refuses hybrid projects', () {
    expect(
      () => build(project(vm: true), <String, Object?>{}),
      throwsA(isA<InvalidRequest>().having((InvalidRequest e) => e.message, 'message', contains('hybrid'))),
    );
  });

  test('refuses unknown servers in limitToServers', () {
    expect(() => build(project(), <String, Object?>{'limitToServers': <String>['nope']}), throwsA(isA<InvalidRequest>()));
    expect(build(project(), <String, Object?>{'limitToServers': <String>['la-1']}).cmd['limitToServers'], <String>['la-1']);
  });
}
