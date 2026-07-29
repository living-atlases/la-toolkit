# LAProject Refactor Plan

> Status: FUTURE / NOT STARTED  
> Context: `lib/models/la_project.dart` — 2821 lines, god-model, bridges 10+ graph communities  
> Do NOT start until after GBIF Ebbe Nielsen Challenge 2026 deadline  

---

## Problem

`LAProject` is a god-object: it owns data, validates UI, computes ansible inventory,
manages service assignments, checks versions, builds hostnames, imports/exports JSON,
and calculates deployment readiness — all in one 2821-line class.

Graph evidence: 35 edges, bridges communities 0,1,2,4,6,7,8,10,13,14,15,18.

---

## Proposed Decomposition

### Phase 1 — Extract pure query helpers (low risk)

Extract read-only computed properties and query methods into extension files.
No state change. No Redux impact. Easy to test.

```
lib/models/la_project_extensions/
  la_project_server_queries.dart    # numServers, getServerByName, getServerById,
                                    # getServersNameList, serversWithServices,
                                    # allServersWithIPs, allServersWithSshKeys,
                                    # allServersWithSshReady, allServersWithSupportedOs,
                                    # dockerServers, getServerServices, getServerServicesFull
  la_project_service_queries.dart   # getServiceE, getService, getServicesNameListInUse,
                                    # getServicesNameListNotInUse, getServicesAssigned,
                                    # getServicesNameListInServer, servicesInDifferentServers,
                                    # allServicesAssigned, servicesNotAssigned,
                                    # isServiceInDockerCompose, isDockerClusterConfigured,
                                    # hasDockerSupportedServicesInUse
  la_project_version_queries.dart   # getSwVersionOfService, getServiceDeployRelease,
                                    # getServiceDeployReleases, getServiceDefaultVersions,
                                    # getSelectedOrDefaultVersion, getServiceDetailsForVersionCheck
  la_project_variable_queries.dart  # getVariable, getVariableOrNull, getVariableValue,
                                    # isStringVariableNullOrEmpty, additionalVariablesDecoded
```

**Dart extensions** can live in separate files without breaking existing callers:
```dart
// la_project_server_queries.dart
extension LAProjectServerQueries on LAProject {
  int numServers() => servers.length;
  // ...
}
```

---

### Phase 2 — Extract mutation helpers (medium risk)

Mutable operations that modify internal lists. These are called from Redux reducers.
Extract as extension methods first, then evaluate if they belong in reducers instead.

```
lib/models/la_project_extensions/
  la_project_server_mutations.dart  # upsertServer, upsertById, delete, assign,
                                    # assignByType, unAssign, unAssignByType,
                                    # _cleanServerServices
  la_project_service_mutations.dart # serviceInUse, updateService, setServiceDeployRelease,
                                    # setVariable, setMap, deleteCluster,
                                    # _addDockerClusterIfNotExists
```

---

### Phase 3 — Extract domain sub-models (medium risk)

Groups of related fields that could be their own value objects.

| New class | Fields extracted from LAProject |
|---|---|
| `LAProjectMapConfig` | mapBoundsFstPoint, mapBoundsSndPoint, mapZoom, getCenter(), setMap() |
| `LAProjectVersionState` | runningVersions, selectedVersions, alaInstallRelease, generatorRelease, lastSwCheck |
| `LAProjectDeployState` | status, isCreated, fstDeployed, lastCmdEntry, lastCmdDetails, cmdHistoryEntries |
| `LAProjectTheme` | theme, useSSL, dirName, additionalVariables |

LAProject holds these as fields:
```dart
LAProjectMapConfig mapConfig;
LAProjectVersionState versionState;
// etc.
```

Risk: breaks `copyWith` generated code, JSON serialization. Regenerate `.g.dart` after.

---

### Phase 4 — Extract Ansible/Generator concerns (higher risk)

`toGeneratorJson()` is ~536 lines (L1644–L2179). It knows about ansible inventory
structure, variable naming conventions, service grouping. This is not a model concern.

```
lib/services/
  la_project_ansible_exporter.dart   # toGeneratorJson() logic → LAProjectAnsibleExporter class
  la_project_inventory_builder.dart  # etcHostsVar, hostnames, sshKeysInUse, getHostnames()
```

```dart
class LAProjectAnsibleExporter {
  final LAProject project;
  const LAProjectAnsibleExporter(this.project);
  Map<String, dynamic> toGeneratorJson({...}) { ... }
}
```

---

### Phase 5 — Extract validation (low-medium risk)

Validation logic mixed with model. Extract as standalone validators.

```
lib/validators/
  la_project_validator.dart   # validateCreation(), validateDataIntegrity(),
                               # allServersWithServicesReady, getIncompatibilities(),
                               # getDockerComposeVMWarnings(), isDependencySatisfied()
```

---

### Phase 6 — Extract import/export (medium risk)

```
lib/services/
  la_project_importer.dart    # LAProject.import(), importTemplates(), _importHubs(),
                               # fromObject() factory, _rebuildEmptyClusterServices()
  la_project_serializer.dart  # toJson(), fromJson() wrappers + migration logic
```

---

### Phase 7 — Extract monitoring/health checks (low risk)

```
lib/services/
  la_project_health_checker.dart  # serverServicesToMonitor(), _getHostServicesChecks(),
                                   # prodServices getter, serviceFullUrl(), serviceTooltip()
```

---

## Target State

After all phases:

```
lib/models/
  la_project.dart                    # ~400 lines: fields, constructor, copyWith, toJson/fromJson
  la_project.g.dart                  # generated
  la_project_extensions/
    la_project_server_queries.dart
    la_project_service_queries.dart
    la_project_version_queries.dart
    la_project_variable_queries.dart
    la_project_server_mutations.dart
    la_project_service_mutations.dart
  sub_models/
    la_project_map_config.dart
    la_project_version_state.dart
    la_project_deploy_state.dart
lib/services/
  la_project_ansible_exporter.dart
  la_project_inventory_builder.dart
  la_project_importer.dart
  la_project_health_checker.dart
lib/validators/
  la_project_validator.dart
```

---

## Execution Order

```
Phase 1 → Phase 2 → Phase 5 → Phase 7 → Phase 4 → Phase 3 → Phase 6
  ^low        ^low     ^low      ^low      ^high     ^medium   ^medium
```

Do phases 1+2+5 together in one PR. They're pure extractions with no structural change.

---

## Testing Strategy

Before each phase:
1. Run `flutter test` — capture baseline pass count
2. Make extraction
3. Run `flutter test` — must match baseline
4. Grep for direct class references to moved methods — ensure no compile errors

No new tests needed for extraction phases (behavior unchanged).
Add tests for new validator/exporter classes when introduced.

---

## Risks

| Risk | Mitigation |
|---|---|
| `copyWith` codegen breaks on sub-model extraction | Run `dart run build_runner build` after each phase |
| Redux reducers import LAProject directly | Reducers call methods by name — extension methods transparent |
| JSON serialization breaks on Phase 3 | Keep `@JsonSerializable` on LAProject, not sub-models; delegate manually |
| `toGeneratorJson` is 536 lines with complex logic | Extract last, after full test coverage established |

---

## Notes

- `fromObject()` factory (L113) imports from yoRc generator format — keep near importer
- `_rebuildEmptyClusterServices` (L306) is called from `fromObject()` — move together
- Hub/parent relationship (`isHub`, `parent`, `hubs` fields) cuts across all layers — leave in core model
- `clientMigration` field — migration logic should stay in serializer
