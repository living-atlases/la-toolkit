# la_toolkit_core

The LA Toolkit project model and its rules, in plain Dart (no Flutter). The web app
(`lib/` at the repository root) and the MCP server (`packages/la_toolkit_mcp`) both
depend on it, so the UI and an agent validate, lint and generate a project with the same
code.

## What is here

| Path | What |
|---|---|
| `lib/models/` | `LAProject` and everything it holds: servers, clusters, services and their catalogue (`LAServiceDesc`), variables, deploys, command history. `toGeneratorJson()` writes the `.yo-rc.json` the generator reads; `fromObject()` reads one back; `toApiJson()` is the body the backend stores. |
| `lib/lint/project_lint.dart` | The warnings of the project lint panel: `lintProject()` (placement, cluster sizes, services that need each other...) returns `LintFinding`s with an optional `LintFix` hint; `lintSelectedVersions()` + `lintDependencies()` check the releases against the dependency matrix. |
| `lib/dependencies_manager.dart` | The dependency matrix (`dependencies.yaml`, `nextgen-compat.yaml` of the backend) and where to download it from. |
| `lib/releases/deps_versions.dart` | The query and the answer of the backend's `get-deps-versions` (the releases offered for each service). |
| `lib/synth/synthesize_project.dart` | `synthesizeProject()`: a new portal from a small intent (domain, names, 1..n hosts), built on a la-docker-compose topology `.yo-rc.json` so the placement is one its CI proves. |
| `lib/utils/` | String, regexp and map helpers, and `foundation.dart`, the small stand-in for what the models used from `flutter/foundation` (`kDebugMode`, `listEquals`, a reassignable `debugPrint`). |

Presentation (icons, colours, widgets) is not here: the app adds it with extensions in
`lib/ui/model_presentation.dart`.

The models log with `print`/`debugPrint`. A program that uses stdout for something else
(the MCP server speaks JSON-RPC on it) must redirect `print`, as `la_toolkit_mcp` does
with a `Zone`.

## Development

```bash
dart pub get
dart analyze
dart test          # from this directory: fixtures are read relative to it
dart run build_runner build --delete-conflicting-outputs   # after changing a model
```

Keep `copy_with_extension` on the same major version as the app's lock (^14): newer
generators reject `LAProject`.

### Fixtures

`test/fixtures/la-docker-compose-*.yo-rc.json` are copies of
`inventories/testing/topologies/<topology>/.yo-rc.json` from la-docker-compose v1.9.0,
and `test/fixtures/get-deps-versions.json` a real backend answer. Refresh them by hand
when those change; the synthesis tests say what they must still produce.
