/// The toolkit's own project lint (la_toolkit_core), as the MCP reports it.
library;

import 'package:la_toolkit_core/lint/project_lint.dart';
import 'package:la_toolkit_core/models/la_project.dart';

import 'projects.dart';

/// The model of [ref], built the way the app builds it: from the portal, so a
/// hub gets its `parent` (compose mode, borrowed clusters) wired by
/// `LAProject.fromJson`. Building a hub from its own JSON would leave it
/// orphaned and lint it as a non-compose project.
LAProject projectModel(ProjectRef ref) {
  final LAProject portal = LAProject.fromJson(ref.parent ?? ref.project);
  if (!ref.isHub) return portal;
  return portal.hubs.firstWhere(
    (LAProject h) => h.id == ref.id,
    orElse: () => throw StateError('Hub ${ref.id} is not under its portal.'),
  );
}

/// What the agent is told to do for each [LintFix].
const Map<LintFix, String> fixHints = <LintFix, String>{
  LintFix.sshKeys: 'Add or generate an ssh key in the toolkit (SSH keys page).',
  LintFix.tuneProject: 'Set it in the project Tune page.',
  LintFix.editProject:
      'Change the servers or services in the project Edit page.',
  LintFix.openParent: 'Deploy the parent portal instead.',
};

/// The UI's lint panel as JSON. [matrixLoaded] false means the dependency
/// matrix could not be read: the dependency checks were then skipped, and
/// the report says so instead of passing them silently.
Json lintReport(
  LAProject project, {
  required bool hasSshKeys,
  required String? backendVersion,
  required bool matrixLoaded,
  List<String> alaInstallReleases = const <String>[],
  List<String> generatorReleases = const <String>[],
}) {
  final List<LintFinding> findings = lintProject(
    project,
    hasSshKeys: hasSshKeys,
  );
  final bool checkDeps = matrixLoaded && backendVersion != null;
  final List<String> dependencyErrors = checkDeps
      ? lintDependencies(
          project,
          lintSelectedVersions(
            project,
            backendVersion: backendVersion,
            alaInstallReleases: alaInstallReleases,
            generatorReleases: generatorReleases,
          ),
          backendVersion: backendVersion,
        ).expand((List<String> g) => g).toList()
      : <String>[];
  return <String, dynamic>{
    'project': project.shortName,
    'clean': findings.isEmpty && dependencyErrors.isEmpty && checkDeps,
    'findings': <Json>[
      for (final LintFinding f in findings)
        <String, dynamic>{
          'message': f.message,
          if (f.fix != null) 'fix': fixHints[f.fix],
        },
    ],
    'dependencyErrors': dependencyErrors,
    if (!checkDeps)
      'dependenciesNotChecked': backendVersion == null
          ? 'The backend did not report its version.'
          : 'The dependency matrix could not be downloaded.',
  };
}
