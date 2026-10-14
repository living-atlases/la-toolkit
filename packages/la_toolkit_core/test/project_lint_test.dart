import 'package:la_toolkit_core/lint/project_lint.dart';
import 'package:la_toolkit_core/models/deployment_type.dart';
import 'package:la_toolkit_core/models/la_cluster.dart';
import 'package:la_toolkit_core/models/la_project.dart';
import 'package:la_toolkit_core/models/la_project_status.dart';
import 'package:la_toolkit_core/models/la_server.dart';
import 'package:la_toolkit_core/models/la_service_constants.dart';
import 'package:test/test.dart';

List<String> messages(List<LintFinding> findings) =>
    findings.map((LintFinding f) => f.message).toList();

void main() {
  group('lintProject', () {
    test('no ssh key is the first finding and points to the keys page', () {
      final List<LintFinding> findings = lintProject(
        LAProject(),
        hasSshKeys: false,
      );
      expect(
        findings.first,
        const LintFinding("You don't have any SSH key", fix: LintFix.sshKeys),
      );
      expect(
        messages(lintProject(LAProject(), hasSshKeys: true)),
        isNot(contains("You don't have any SSH key")),
      );
    });

    test('a compose service placed on a VM is reported', () {
      final LAProject p = LAProject();
      final LAServer vm1 = LAServer(
        id: 'vm1',
        name: 'vm1',
        ip: '10.0.0.1',
        projectId: p.id,
      );
      p.upsertServer(vm1);
      p.serviceInUse(dockerCompose, true);
      p.assign(vm1, <String>[dockerCompose, collectory]);

      final List<String> found = messages(lintProject(p, hasSshKeys: true));
      expect(
        found.where((String m) => m.contains('vm1 is a Docker Compose host')),
        hasLength(1),
      );
    });

    test('a service only on staging compose hosts is reported', () {
      final LAProject p = LAProject(domain: 'example.org');
      final LAServer prod = LAServer(
        id: 'prod',
        name: 'prod',
        ip: '10.0.0.1',
        projectId: p.id,
      );
      final LAServer staging = LAServer(
        id: 'staging',
        name: 'staging',
        ip: '10.0.0.2',
        projectId: p.id,
      );
      p.upsertServer(prod);
      p.upsertServer(staging);
      p.serviceInUse(dockerCompose, true);
      p.serviceInUse(collectory, true);
      p.serviceInUse(alaHub, true);
      p.assign(prod, <String>[dockerCompose]);
      p.assign(staging, <String>[dockerCompose]);
      p.assignByType(prod.id, DeploymentType.dockerCompose, <String>[alaHub]);
      p.assignByType(staging.id, DeploymentType.dockerCompose, <String>[
        collectory,
        alaHub,
      ]);
      p.status = LAProjectStatus.basicDefined;
      String? finding() => messages(lintProject(p, hasSshKeys: true))
          .where((String m) => m.contains('only on staging'))
          .firstOrNull;

      // Without stages everything is production.
      expect(p.servicesOnlyInStaging(), isEmpty);
      expect(finding(), isNull);

      p.placement.composeClusters
              .firstWhere((LACluster c) => c.serverId == staging.id)
              .stage =
          ClusterStage.staging;
      // ala_hub also runs on production: only collectory is staging-only.
      expect(p.servicesOnlyInStaging(), <String>[collectory]);
      expect(finding(), contains('collect'));
      expect(finding(), isNot(contains('records')));
    });

    test('pipelines without solrcloud', () {
      final LAProject p = LAProject();
      p.serviceInUse(pipelines, true);
      p.serviceInUse(solrcloud, false);
      expect(
        messages(lintProject(p, hasSshKeys: true)),
        contains('You should use solrcloud for indexing pipelines'),
      );
    });

    test('a compose hub with no server points to its portal', () {
      final LAProject portal = LAProject(shortName: 'portal');
      portal.serviceInUse(dockerCompose, true);
      final LAProject hub = LAProject(
        shortName: 'hub',
        isHub: true,
        parent: portal,
      );
      final Iterable<LintFinding> toParent = lintProject(
        hub,
        hasSshKeys: true,
      ).where((LintFinding f) => f.fix == LintFix.openParent);
      expect(toParent, hasLength(1));
      expect(
        toParent.first.message,
        startsWith('hub has no server of its own'),
      );
    });
  });

  group('lintSelectedVersions', () {
    test('without a backend only the service releases are compared', () {
      final Map<String, String> versions = lintSelectedVersions(
        LAProject(),
        backendVersion: null,
        alaInstallReleases: <String>['2.3.0'],
        generatorReleases: <String>['1.5.0'],
      );
      expect(versions.containsKey(toolkit), isFalse);
      expect(versions.containsKey(alaInstall), isFalse);
    });

    test('unpinned tools fall back to the newest known release', () {
      final LAProject p = LAProject();
      p.alaInstallRelease = null;
      p.generatorRelease = null;
      final Map<String, String> versions = lintSelectedVersions(
        p,
        backendVersion: '1.7.0',
        alaInstallReleases: <String>['2.3.0', '2.2.0'],
        generatorReleases: <String>[],
      );
      expect(versions[toolkit], '1.7.0');
      expect(versions[alaInstall], '2.3.0');
      expect(versions[generator], '1.4.3');
    });
  });

  group('lintDependencies', () {
    test('every group is empty without a backend version', () {
      final List<List<String>> groups = lintDependencies(
        LAProject(),
        const <String, String>{},
        backendVersion: null,
      );
      expect(groups, hasLength(greaterThanOrEqualTo(2)));
      expect(groups.every((List<String> g) => g.isEmpty), isTrue);
    });
  });
}
