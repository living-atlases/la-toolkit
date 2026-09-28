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
      expect(
        build(project(), <String, Object?>{'prepare': true}).prepare,
        isTrue,
      );
      expect(r.cmd['dryRun'], isTrue);
    });

    test('a real deploy needs confirm', () {
      expect(
        () => build(project(), <String, Object?>{'dryRun': false}),
        throwsA(
          isA<InvalidRequest>().having(
            (InvalidRequest e) => e.message,
            'message',
            contains('confirm: true'),
          ),
        ),
      );
      final DeployRequest r = build(project(), <String, Object?>{
        'dryRun': false,
        'confirm': true,
      });
      expect(r.dryRun, isFalse);
      expect(r.prepare, isTrue);
    });

    // ansiblew runs the final line through `sh -c`, dry run included.
    for (final String bad in <String>[
      'a;rm -rf /',
      r'$(id)',
      'x y',
      '`id`',
      "a'b",
      'a|b',
      '-x',
    ]) {
      test('refuses shell-unsafe token "$bad"', () {
        for (final String key in <String>[
          'tags',
          'skipTags',
          'skipServices',
          'limitToServers',
        ]) {
          expect(
            () => build(project(), <String, Object?>{
              key: <String>[bad],
            }),
            throwsA(isA<InvalidRequest>()),
            reason: key,
          );
        }
      });
    }

    test('refuses non-list and non-string entries', () {
      expect(
        () => build(project(), <String, Object?>{'tags': 'nginx'}),
        throwsA(isA<InvalidRequest>()),
      );
      expect(
        () => build(project(), <String, Object?>{
          'tags': <Object>[1],
        }),
        throwsA(isA<InvalidRequest>()),
      );
      expect(
        () => build(project(), <String, Object?>{'dryRun': 'no'}),
        throwsA(isA<InvalidRequest>()),
      );
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
      expect(
        () => build(project(), <String, Object?>{
          'services': <String>['collectory'],
        }),
        throwsA(isA<InvalidRequest>()),
      );
    });

    test('refuses a compose hub without servers and points at the portal', () {
      final Json portal = project();
      final Json hub =
          project(id: 'h1', dirName: 'hub', compose: false, isHub: true)
            ..['servers'] = <Json>[]
            ..['serverServices'] = <String, dynamic>{};
      expect(
        () => build(hub, <String, Object?>{}, parent: portal),
        throwsA(
          isA<InvalidRequest>().having(
            (InvalidRequest e) => e.message,
            'message',
            contains('Deploy the portal'),
          ),
        ),
      );
    });
  });

  group('vm', () {
    test('remaps species-lists and rejects skipServices', () {
      final Json p = project(compose: false, vm: true);
      final DeployRequest r = build(p, <String, Object?>{
        'services': <String>['species-lists', 'collectory'],
      });
      expect(r.cmd['dockerCompose'], isFalse);
      expect(r.cmd['deployServices'], <String>['lists', 'collectory']);
      expect(
        () => build(p, <String, Object?>{
          'skipServices': <String>['spatial'],
        }),
        throwsA(isA<InvalidRequest>()),
      );
    });
  });

  group('hybrid', () {
    Matcher refusal(String text) => throwsA(
      isA<InvalidRequest>().having(
        (InvalidRequest e) => e.message,
        'message',
        contains(text),
      ),
    );

    test('needs a leg', () {
      expect(
        () => build(project(vm: true), <String, Object?>{}),
        refusal('leg'),
      );
      expect(
        () => build(hybridPortal(), <String, Object?>{'leg': 'both'}),
        refusal('"docker" or "vm"'),
      );
    });

    test('the docker leg is built as in the UI, on the compose hosts only', () {
      final DeployRequest r = build(
        hybridPortal(vmOnComposeHost: <String>['logger']),
        <String, Object?>{
          'leg': 'docker',
          'skipServices': <String>['cas'],
        },
      );
      expect(r.cmd['dockerCompose'], isTrue);
      expect(r.cmd['deployServices'], <String>['all']);
      // Never the VM: limitToServers defaults to the compose hosts.
      expect(r.cmd['limitToServers'], <String>['dc1.docker_compose']);
      // User skips expanded to their sub-services, plus the VM services that
      // share the compose host (la-docker-compose enables them by group).
      expect(
        r.cmd['skipServices'],
        containsAll(<String>['cas', 'userdetails', 'apikey', 'logger']),
      );
      expect(r.desc, contains('docker leg'));
    });

    test('the docker leg refuses a VM in limitToServers', () {
      expect(
        () => build(hybridPortal(), <String, Object?>{
          'leg': 'docker',
          'limitToServers': <String>['vm1'],
        }),
        refusal('compose hosts'),
      );
    });

    test('the docker leg keeps its monolithic contract', () {
      expect(
        () => build(hybridPortal(), <String, Object?>{
          'leg': 'docker',
          'services': <String>['cas'],
        }),
        refusal('monolithic'),
      );
    });

    test('the vm leg deploys only VM services, no skip list', () {
      final DeployRequest r = build(hybridPortal(), <String, Object?>{
        'leg': 'vm',
      });
      expect(r.cmd['dockerCompose'], isFalse);
      expect(
        r.cmd['deployServices'],
        unorderedEquals(<String>['branding', 'collectory']),
      );
      expect(
        () => build(hybridPortal(), <String, Object?>{
          'leg': 'vm',
          'skipServices': <String>['cas'],
        }),
        throwsA(isA<InvalidRequest>()),
      );
      expect(
        () => build(hybridPortal(), <String, Object?>{
          'leg': 'vm',
          'services': <String>['cas'],
        }),
        refusal('nothing'),
      );
    });

    test('a leg that does not match a non-hybrid project is refused', () {
      expect(
        () => build(project(), <String, Object?>{'leg': 'vm'}),
        refusal('not hybrid'),
      );
      expect(
        build(project(), <String, Object?>{
          'leg': 'docker',
        }).cmd['dockerCompose'],
        isTrue,
      );
    });
  });

  test('composeHostNames names the servers carrying a compose cluster', () {
    expect(composeHostNames(hybridPortal()), <String>['dc1']);
    expect(composeHostNames(project(compose: false, vm: true)), isEmpty);
  });

  test('refuses unknown servers in limitToServers', () {
    expect(
      () => build(project(), <String, Object?>{
        'limitToServers': <String>['nope'],
      }),
      throwsA(isA<InvalidRequest>()),
    );
    expect(
      build(project(), <String, Object?>{
        'limitToServers': <String>['la-1'],
      }).cmd['limitToServers'],
      <String>['la-1'],
    );
  });
}
