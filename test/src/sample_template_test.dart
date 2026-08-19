import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:la_toolkit/models/deployment_type.dart';
import 'package:la_toolkit/models/la_cluster.dart';
import 'package:la_toolkit/models/la_project.dart';
import 'package:la_toolkit/models/la_releases.dart';
import 'package:la_toolkit/models/la_server.dart';
import 'package:la_toolkit/models/la_service_constants.dart';
import 'package:la_toolkit/models/la_service_desc.dart';
import 'package:la_toolkit/models/la_service_name.dart';
import 'package:la_toolkit/utils/regexp.dart';
import 'package:la_toolkit/utils/string_utils.dart';

/// The sample project shipped with the toolkit (the (+) menu adds it) is derived
/// from `topologies/base.lademo.yo-rc.json` in la-docker-compose: the
/// `TOPOLOGY=default` 3-host layout its CI deploys on every push, so what a new
/// user gets with one click is what is actually tested, not a hand-written guess
/// nor one of the manual-only reduced matrix variants.
///
/// These tests exist because the yo-rc format has no explicit "these services
/// run in the cluster" field: the docker leg is implied by
/// `LA_docker_compose_hostname` alone. Reading it wrong turns the sample into a
/// plain VM project that would deploy with ala-install.
List<Map<String, dynamic>> _loadTemplates() {
  final String content = File(
    'assets/la-toolkit-templates.json',
  ).readAsStringSync();
  return (jsonDecode(content) as List<dynamic>)
      .map((dynamic t) => t as Map<String, dynamic>)
      .toList();
}

Map<String, dynamic> _promptValues(Map<String, dynamic> template) =>
    (template['generator-living-atlas'] as Map<String, dynamic>)['promptValues']
        as Map<String, dynamic>;

LAReleases _releases(String artifacts, List<String> versions) => LAReleases(
  name: artifacts,
  artifacts: artifacts,
  latest: versions.first,
  versions: versions,
);

void main() {
  group('shipped sample project', () {
    test('is a single docker-compose template on the three CI hosts', () {
      final List<Map<String, dynamic>> templates = _loadTemplates();
      expect(templates.length, 1);
      final Map<String, dynamic> pv = _promptValues(templates[0]);
      expect(pv['LA_use_docker_compose'], true);
      expect(pv['LA_docker_compose_hostname'], 'la-mh-1, la-mh-2, la-mh-3');
    });

    test('carries no CI-only identity, addressing or secrets', () {
      final Map<String, dynamic> pv = _promptValues(_loadTemplates()[0]);
      // The 3-host source carries the Jenkins cluster's private 10.77.0.x
      // addressing, which the 1-host one did not: it must not ship.
      for (final String forbidden in <String>[
        'LA_id',
        'LA_ssh_keys',
        'LA_server_ips',
        'LA_etc_hosts',
        'LA_docker_extra_hosts_by_host',
        'LA_nginx_docker_internal_aliases_by_host',
      ]) {
        expect(pv.containsKey(forbidden), false, reason: '$forbidden shipped');
      }
      for (final MapEntry<String, dynamic> e in pv.entries) {
        expect(
          e.value is String && (e.value as String).startsWith('fixture-'),
          false,
          reason: '${e.key} still holds a CI fixture value',
        );
      }
    });

    test('imports as a pure docker-compose project', () {
      final Map<String, dynamic> pv = _promptValues(_loadTemplates()[0]);
      final LAProject p = LAProject.fromObject(pv);

      expect(p.isPureDockerCompose, true);
      expect(p.hasVmServices, false);
      // One cluster per docker host, each running its own host's services.
      expect(p.clusters.length, 3);
      for (final LACluster cluster in p.clusters) {
        expect(cluster.type, DeploymentType.dockerCompose);
        expect(p.clusterServices[cluster.id], isNotEmpty);
      }

      // The docker-compose service itself stays on the VM side.
      for (final String hostname
          in (pv['LA_docker_compose_hostname'] as String).split(', ')) {
        final String serverId = p.servers
            .firstWhere((LAServer s) => s.name == hostname)
            .id;
        expect(
          p.serverServices[serverId],
          <String>[dockerCompose],
          reason: '$hostname should only carry docker-compose on the VM',
        );
      }

      expect(p.validateDataIntegrity(), isEmpty);
      expect(p.servicesWithNowhereToRun(), isEmpty);
    });

    test('names a directory of its own, not the short name one', () {
      // 'LADemo' suggests 'lademo', which any real demo portal already owns, so
      // importTemplates takes the directory from LA_pkg_name instead. That the
      // (+) menu really does land on it is checked in the widget test.
      final Map<String, dynamic> pv = _promptValues(_loadTemplates()[0]);
      final LAProject p = LAProject.fromObject(pv);

      expect(pv['LA_pkg_name'], 'lademo-docker');
      expect(
        LARegExp.ansibleDirnameRegexpPermissive.hasMatch(
          pv['LA_pkg_name'] as String,
        ),
        true,
        reason: 'importTemplates only honours a valid directory name',
      );
      expect(p.suggestDirName(), 'lademo');
    });

    test('regenerates the same docker-compose placement', () {
      final Map<String, dynamic> pv = _promptValues(_loadTemplates()[0]);
      final LAProject p = LAProject.fromObject(pv);
      final Map<String, dynamic> conf = p.toGeneratorJson();

      expect(conf['LA_use_docker_compose'], true);
      expect(
        conf['LA_docker_compose_hostname'],
        pv['LA_docker_compose_hostname'],
      );
      // What this sample teaches: la-docker-compose indexes with pipelines +
      // solrcloud, it does not deploy standalone solr nor biocache-store.
      expect(conf['LA_use_solr'], false);
      expect(conf['LA_use_biocache_store'], false);
      expect(conf['LA_use_solrcloud'], true);
      expect(conf['LA_use_pipelines'], true);
    });
  });

  group('docker-compose placement on import', () {
    Map<String, dynamic> baseYoRc({required String composeHosts}) {
      return <String, dynamic>{
        'LA_project_name': 'Import Test',
        'LA_project_shortname': 'importtest',
        'LA_domain': 'test.org',
        'LA_enable_ssl': true,
        'LA_use_docker_compose': true,
        'LA_docker_compose_hostname': composeHosts,
        'LA_docker_compose_uses_subdomain': false,
        'LA_use_collectory': true,
        'LA_collectory_hostname': 'host1',
        'LA_collectory_uses_subdomain': true,
        'LA_collectory_url': 'collections.test.org',
        'LA_use_solr': false,
        'LA_use_biocache_store': false,
        'LA_use_biocache_cli': false,
        'LA_use_nameindexer': false,
      };
    }

    test('a docker-compose host puts its services in the cluster', () {
      final LAProject p = LAProject.fromObject(baseYoRc(composeHosts: 'host1'));

      expect(p.clusters.length, 1);
      expect(
        p.clusterServices[p.clusters[0].id],
        contains(LAServiceName.collectory.toS()),
      );
      expect(p.serverServices[p.clusters[0].serverId], <String>[dockerCompose]);
      expect(p.validateDataIntegrity(), isEmpty);
    });

    test('a plain VM host keeps its services on the VM', () {
      final Map<String, dynamic> yoRc = baseYoRc(composeHosts: '')
        ..['LA_use_docker_compose'] = false
        ..remove('LA_docker_compose_hostname');
      final LAProject p = LAProject.fromObject(yoRc);

      expect(p.clusters, isEmpty);
      expect(p.hasVmServices, true);
      expect(
        p.serverServices[p.servers[0].id],
        contains(LAServiceName.collectory.toS()),
      );
    });

    test('services the cluster cannot host stay on the VM', () {
      // biocache-store has no docker support: even on a compose host it can only
      // run on the VM, and it must not end up in both places.
      final Map<String, dynamic> yoRc = baseYoRc(composeHosts: 'host1')
        ..['LA_use_biocache_store'] = true
        ..['LA_biocache_backend_hostname'] = 'host1';
      final LAProject p = LAProject.fromObject(yoRc);

      final String serverId = p.servers[0].id;
      expect(
        LAServiceDesc.listDockerCapableS.contains(biocacheBackend),
        false,
        reason: 'test premise: biocache-store is not docker capable',
      );
      expect(p.serverServices[serverId], contains(biocacheBackend));
      expect(
        p.clusterServices[p.clusters[0].id],
        isNot(contains(biocacheBackend)),
      );
      expect(p.validateDataIntegrity(), isEmpty);
    });
  });

  group('sample project versions', () {
    // The sample's LA_software_versions comes from the CI fixture, and the
    // fixture pins namematching under ala-install's own variable name
    // (namematching_service_version), not the one the toolkit maps
    // (ala_namematching_service_version). So the service lands with no version,
    // and 'pipelines depends on namematching >=1.0.0' fires on a project the
    // user has not touched yet. Seeding from the releases the app already
    // fetched is what closes that gap.
    Map<String, LAReleases> fakeReleases() => <String, LAReleases>{
      namematchingService: _releases('ala-namematching-service', <String>[
        '1.5',
        '1.4',
      ]),
      '${namematchingService}_nexus': _releases(
        'ala-namematching-service',
        <String>['v2.0', 'v1.9'],
      ),
    };

    test('the shipped template pins no namematching version', () {
      final Map<String, dynamic> pv = _promptValues(_loadTemplates()[0]);
      final List<dynamic> versions =
          pv['LA_software_versions'] as List<dynamic>;
      final Set<String> vars = versions
          .map((dynamic v) => (v as List<dynamic>)[0] as String)
          .toSet();
      expect(
        vars.contains(LAServiceDesc.swToAnsibleVars[namematchingService]),
        false,
        reason: 'test premise: the gap this seeding covers',
      );
    });

    test('import without releases leaves the gap', () {
      final LAProject p = LAProject.fromObject(
        _promptValues(_loadTemplates()[0]),
      );
      expect(p.getServicesNameListInUse(), contains(namematchingService));
      expect(p.getServiceDeployReleases()[namematchingService], isNull);
    });

    test('import with releases seeds the missing version', () {
      final LAProject p = LAProject.fromObject(
        _promptValues(_loadTemplates()[0]),
        laReleases: fakeReleases(),
      );
      // A docker-compose deploy takes the newest Nexus tag, not the apt one.
      expect(p.getServiceDeployReleases()[namematchingService], 'v2.0');
    });

    test('a version already in the template still wins over the seed', () {
      final LAProject p = LAProject.fromObject(
        _promptValues(_loadTemplates()[0]),
        laReleases: <String, LAReleases>{
          ...fakeReleases(),
          pipelines: _releases('pipelines', <String>['9.9.9']),
          '${pipelines}_nexus': _releases('pipelines', <String>['9.9.9']),
        },
      );
      expect(p.getServiceDeployReleases()[pipelines], 'v2.0');
    });
  });

  group('free directory names', () {
    test('an unused candidate is kept as is', () {
      expect(
        StringUtils.uniqueDirName(
          candidate: 'lademo-docker',
          taken: <String>{'lademo', 'gbif-es'},
        ),
        'lademo-docker',
      );
    });

    test('a taken candidate is suffixed, skipping suffixes also taken', () {
      expect(
        StringUtils.uniqueDirName(
          candidate: 'lademo',
          taken: <String>{'lademo'},
        ),
        'lademo-1',
      );
      expect(
        StringUtils.uniqueDirName(
          candidate: 'lademo',
          taken: <String>{'lademo', 'lademo-1', 'lademo-2'},
        ),
        'lademo-3',
      );
    });

    test('dirNamesOf collects the names in use and skips the unset ones', () {
      final LAProject withDir = LAProject(shortName: 'One', dirName: 'one');
      final LAProject withoutDir = LAProject(shortName: 'Two')..dirName = null;
      expect(LAProject.dirNamesOf(<LAProject>[withDir, withoutDir]), <String>{
        'one',
      });
    });
  });
}
