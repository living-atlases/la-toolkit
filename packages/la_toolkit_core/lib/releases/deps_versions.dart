// The software releases the toolkit offers for each service (the version
// dropdowns, and what a template or synthesized project is pinned to when its
// base names no version). The backend reads them from the maven/nexus
// metadata; this builds its query and reads its answer.
import '../models/la_releases.dart';
import '../models/la_service_constants.dart';
import '../models/la_service_desc.dart';
import '../utils/foundation.dart';

/// The body of `POST /api/v1/get-deps-versions` (`{deps: query}`): each
/// service with an artifact, plus the nexus artifacts of the few services
/// published in both repositories.
Map<String, String> depsVersionsQuery() {
  final Map<String, String> servicesAndSub = <String, String>{};
  for (final LAServiceDesc service in LAServiceDesc.listWithArtifact) {
    servicesAndSub[service.nameInt] = service.artifacts!;
    if (service.nameInt == sensitiveDataService) {
      servicesAndSub['${sensitiveDataService}_nexus'] =
          'ala-sensitive-data-service';
    }
    if (service.nameInt == namematchingService) {
      servicesAndSub['${namematchingService}_nexus'] =
          'ala-namematching-server';
    }
    if (service.nameInt == pipelines) {
      servicesAndSub['${pipelines}_nexus'] = 'pipelines';
    }
  }
  return servicesAndSub;
}

/// The releases in the backend's answer ([jsonBody]) to [deps]. A service
/// whose metadata cannot be read is left out.
Map<String, LAReleases> parseDepsVersions(
  Map<String, dynamic> jsonBody,
  Map<String, String> deps,
) {
  final Map<String, LAReleases> releases = <String, LAReleases>{};
  final Map<String, dynamic> excludeList =
      jsonBody['excludeList'] as Map<String, dynamic>;

  for (final String service in jsonBody.keys) {
    try {
      if (service == 'excludeList') {
        continue;
      }
      if (service == events) {
        // TODO(vjrj): Process docker tags as versions too
        releases[events] = LAReleases(
          name: events,
          latest: 'latest',
          versions: const <String>[],
          artifacts: events,
        );
        continue;
      }
      debugPrint('Processing $service deps (artifacts: ${deps[service]})');
      final List<String> versions = <String>[];
      final List<String> releasesVersions = _responseVersions(
        jsonBody,
        'releases',
        service,
      );
      final List<String> snapshotVersions = _responseVersions(
        jsonBody,
        'snapshots',
        service,
      );
      final Map<String, dynamic> serviceData =
          jsonBody[service] as Map<String, dynamic>;
      final Map<String, dynamic> releasesData =
          serviceData['releases'] as Map<String, dynamic>;
      final Map<String, dynamic> metadataData =
          releasesData['metadata'] as Map<String, dynamic>;
      final Map<String, dynamic> versioningData =
          metadataData['versioning'] as Map<String, dynamic>;
      // Not every artifact publishes <latest> (ala-namematching-server only
      // has <release>), and reading the missing key gave the literal string
      // 'null' as the newest version.
      final dynamic latestData =
          versioningData['latest'] ?? versioningData['release'];
      final String latest = latestData.toString();
      versions.addAll(
        releasesVersions.reversed.toList().sublist(
          0,
          30 > releasesVersions.length ? releasesVersions.length : 30,
        ),
      );
      versions.addAll(
        snapshotVersions.reversed.toList().sublist(
          0,
          2 > snapshotVersions.length ? snapshotVersions.length : 2,
        ),
      );
      // exclude
      final List<dynamic> serviceExcludeList =
          excludeList[service] as List<dynamic>? ?? <dynamic>[];
      versions.removeWhere(
        (String v) =>
            excludeList[service] != null && serviceExcludeList.contains(v),
      );
      final LAReleases servReleases = LAReleases(
        name: service,
        artifacts: deps[service]!,
        latest: latest,
        // remove dups
        versions: versions.toSet().toList(),
      );
      releases[service] = servReleases;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('----- Error getting $service deps ($e)');
        // debugPrint(stacktrace);
      }
    }
  }

  return releases;
}

List<String> _responseVersions(
  Map<String, dynamic> jsonBody,
  String repo,
  String service,
) {
  final Map<String, dynamic> serviceData =
      jsonBody[service] as Map<String, dynamic>;
  final Map<String, dynamic> repoData =
      serviceData[repo] as Map<String, dynamic>;
  final Map<String, dynamic> metadata =
      repoData['metadata'] as Map<String, dynamic>;
  final Map<String, dynamic> versioning =
      metadata['versioning'] as Map<String, dynamic>;
  final dynamic versionData = versioning['versions'];
  final Map<String, dynamic> versionMap = versionData as Map<String, dynamic>;
  final dynamic thisVersions = versionMap['version'];

  final List<String> groupVersions = thisVersions.runtimeType == String
      ? <String>[thisVersions as String]
      : (thisVersions as List<dynamic>).cast<String>();
  return groupVersions;
}
