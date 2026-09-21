import 'dart:convert';
import 'dart:io';

import 'package:la_toolkit_core/dependencies_manager.dart';
import 'package:la_toolkit_core/lint/project_lint.dart';
import 'package:la_toolkit_core/releases/deps_versions.dart';
import 'package:la_toolkit_core/models/la_project.dart';
import 'package:la_toolkit_core/models/ssh_key.dart';
import 'package:la_toolkit_core/synth/synthesize_project.dart';
import 'package:test/test.dart';

/// la-docker-compose inventories/testing/topologies/1host/.yo-rc.json at
/// c70d794 (2026-09-16): the single-host configuration its CI deploys.
Map<String, dynamic> _base() =>
    json.decode(
          File(
            'test/fixtures/la-docker-compose-1host.yo-rc.json',
          ).readAsStringSync(),
        )
        as Map<String, dynamic>;

Map<String, dynamic> _promptValues(Map<String, dynamic> yoRc) =>
    (yoRc['generator-living-atlas'] as Map<String, dynamic>)['promptValues']
        as Map<String, dynamic>;

const ProjectIntent _intent = ProjectIntent(
  domain: 'example.com',
  longName: 'Example Portal',
  shortName: 'Example',
  hostName: 'ex-1',
  ip: '10.0.0.5',
);

LAProject _synth({
  ProjectIntent intent = _intent,
  Set<String> taken = const <String>{},
}) => synthesizeProject(
  _base(),
  intent,
  takenDirNames: taken,
  dockerComposeRelease: 'v1.9.0',
  generatorRelease: '1.8.33',
  sshKey: SshKey(name: 'la-toolkit', desc: '', encrypted: false),
);

void main() {
  test('the synthesized portal is complete and lints clean', () {
    final LAProject p = _synth();
    expect(p.validateCreation(debug: false), isTrue);
    expect(messages(lintProject(p, hasSshKeys: true)), isEmpty);
  });

  test('nothing of the base identity survives in the generated config', () {
    final String conf = json.encode(_synth().toGeneratorJson());
    expect(conf, isNot(contains('l-a.site')));
    expect(conf, isNot(contains('la-mh-')));
    expect(conf, isNot(contains('10.77.0.')));
    expect(conf, isNot(contains('lademo')));
  });

  test('one host carries the whole compose stack', () {
    final Map<String, dynamic> conf = _synth().toGeneratorJson();
    expect(conf['LA_domain'], 'example.com');
    expect(conf['LA_hostnames'], 'ex-1');
    expect(conf['LA_docker_compose_hostname'], 'ex-1');
    expect(conf['LA_collectory_url'], 'collections.example.com');
    expect(
      (conf['LA_nginx_docker_internal_aliases_by_host'] as Map<String, dynamic>)
          .keys,
      <String>['ex-1'],
    );
  });

  test('services and versions are the base ones', () {
    final Map<String, dynamic> base = _promptValues(_base());
    final Map<String, dynamic> conf = _synth().toGeneratorJson();
    final Iterable<String> useKeys = base.keys.where(
      (String k) => k.startsWith('LA_use_'),
    );
    for (final String k in useKeys) {
      // toGeneratorJson() leaves some flags out when off.
      expect(conf[k] ?? false, base[k] ?? false, reason: k);
    }
    Map<String, String> versions(Map<String, dynamic> m) => <String, String>{
      for (final dynamic e in m['LA_software_versions'] as List<dynamic>)
        (e as List<dynamic>)[0] as String: e[1] as String,
    };
    expect(versions(conf), versions(base));
  });

  test('the directory never collides with an existing project', () {
    final LAProject p = _synth(taken: <String>{'example'});
    expect(p.dirName, isNot('example'));
    expect(p.dirName, startsWith('example'));
  });

  test('ansible logs in as the ssh user of the intent', () {
    final LAProject p = _synth(
      intent: const ProjectIntent(
        domain: 'example.com',
        longName: 'Example Portal',
        shortName: 'Example',
        hostName: 'ex-1',
        ip: '10.0.0.5',
        sshUser: 'debian',
      ),
    );
    expect(p.toGeneratorJson()['LA_variable_ansible_user'], 'debian');
    expect(p.servers.single.sshUser, 'debian');
  });

  test('with the known releases, unpinned services get a version', () {
    DependenciesManager.setDeps('''
pipelines:
  any:
    - namematching-service: '>= 1.0.0'
''');
    List<String> depErrors(LAProject p) => lintDependencies(
      p,
      lintSelectedVersions(
        p,
        backendVersion: '1.7.1',
        alaInstallReleases: const <String>[],
        generatorReleases: const <String>[],
      ),
      backendVersion: '1.7.1',
    ).expand((List<String> g) => g).toList();

    expect(depErrors(_synth()), contains(contains('no version selected')));
    final LAProject withReleases = synthesizeProject(
      _base(),
      _intent,
      takenDirNames: const <String>{},
      dockerComposeRelease: 'v1.9.0',
      generatorRelease: '1.8.33',
      sshKey: SshKey(name: 'la-toolkit', desc: '', encrypted: false),
      laReleases: parseDepsVersions(
        json.decode(
              File('test/fixtures/get-deps-versions.json').readAsStringSync(),
            )
            as Map<String, dynamic>,
        depsVersionsQuery(),
      ),
    );
    expect(depErrors(withReleases), isEmpty);
  });

  test('disabled services are off', () {
    final LAProject p = _synth(
      intent: const ProjectIntent(
        domain: 'example.com',
        longName: 'Example Portal',
        shortName: 'Example',
        hostName: 'ex-1',
        ip: '10.0.0.5',
        disableServices: <String>['spatial'],
      ),
    );
    expect(p.getService('spatial').use, isFalse);
    expect(p.validateCreation(debug: false), isTrue);
  });

  test('a bad intent is refused with every reason', () {
    expect(
      () => _synth(
        intent: const ProjectIntent(
          domain: 'https://example.com',
          longName: 'Example Portal',
          shortName: 'Example',
          hostName: 'ex 1',
          ip: '10.0.0',
          disableServices: <String>['nope'],
        ),
      ),
      throwsA(
        isA<SynthesisException>().having(
          (SynthesisException e) => e.message,
          'message',
          allOf(
            contains('https://example.com'),
            contains('ex 1'),
            contains('10.0.0'),
            contains('nope'),
          ),
        ),
      ),
    );
  });
}

List<String> messages(List<LintFinding> f) =>
    f.map((LintFinding x) => x.message).toList();
