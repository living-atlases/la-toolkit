import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:redux/redux.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:universal_html/html.dart' as html;

import '../components/app_snack_bar_message.dart';
import '../models/app_state.dart';
import '../models/cmd_history_entry.dart';
import '../models/la_project.dart';
import '../models/la_project_status.dart';
import '../models/la_server.dart';
import '../models/la_service.dart';
import '../models/la_service_deploy.dart';
import '../models/la_variable_desc.dart';
import '../project_edit_page.dart';
import '../utils/utils.dart';
import 'actions.dart';
import 'entity_reducer.dart';

List<Reducer<AppState>> basic = <Reducer<AppState>>[
  TypedReducer<AppState, OnIntroEnd>(_onIntroEnd),
  TypedReducer<AppState, OnFetchSoftwareDepsState>(_onFetchSoftwareDepsState),
  TypedReducer<AppState, OnFetchStateFailed>(_onFetchStateFailed),
  TypedReducer<AppState, OnFetchAlaInstallReleases>(_onFetchAlaInstallReleases),
  TypedReducer<AppState, OnLAVersionsSwCheckEnd>(_onLAVersionsSwCheckEnd),
  TypedReducer<AppState, OnFetchBackendVersion>(_onFetchBackendVersion),
  TypedReducer<AppState, OnFetchAlaInstallReleasesFailed>(
    _onFetchAlaInstallReleasesFailed,
  ),
  TypedReducer<AppState, OnFetchGeneratorReleases>(_onFetchGeneratorReleases),
  TypedReducer<AppState, OnFetchGeneratorReleasesFailed>(
    _onFetchGeneratorReleasesFailed,
  ),
  TypedReducer<AppState, Loading>(_loading),
  TypedReducer<AppState, OnRegenerateInventorySuccess>(
    _onRegenerateInventorySuccess,
  ),
  TypedReducer<AppState, CreateProject>(_createProject),
  TypedReducer<AppState, ImportProject>(_importProject),
  TypedReducer<AppState, AddTemplateProjects>(_addTemplateProjects),
  TypedReducer<AppState, OpenProject>(_openProject),
  TypedReducer<AppState, OpenServersProject>(_openServersProject),
  TypedReducer<AppState, GotoStepEditProject>(_gotoStepEditProject),
  TypedReducer<AppState, NextStepEditProject>(_nextStepEditProject),
  TypedReducer<AppState, PreviousStepEditProject>(_previousStepEditProject),
  TypedReducer<AppState, TuneProject>(_tuneProject),
  TypedReducer<AppState, GenerateInvProject>(_generateInvProject),
  TypedReducer<AppState, OpenProjectTools>(_openProjectTools),
  TypedReducer<AppState, EditService>(_editService),
  TypedReducer<AppState, SaveCurrentProject>(_saveCurrentProject),
  TypedReducer<AppState, UpdateProjectLocal>(_updateProjectLocal),
  TypedReducer<AppState, OnUpdateProjectFailed>(_onUpdateProjectFailed),
  TypedReducer<AppState, OnDemoAddProjects>(_onDemoAddProjects),
  TypedReducer<AppState, OnProjectsAdded>(_onProjectsAdded),
  TypedReducer<AppState, OnProjectUpdated>(_onProjectUpdated),
  TypedReducer<AppState, OnProjectDeleted>(_onProjectDeleted),
  TypedReducer<AppState, ProjectsLoad>(_projectsLoad),
  TypedReducer<AppState, OnProjectsLoad>(_onProjectsLoad),
  TypedReducer<AppState, OnDemoProjectsLoad>(_onDemoProjectsLoad),
  TypedReducer<AppState, TestConnectivityProject>(_testConnectivityProject),
  TypedReducer<AppState, TestServicesProject>(_testServicesProject),
  TypedReducer<AppState, OnTestConnectivityResults>(_onTestConnectivityResults),
  TypedReducer<AppState, OnTestServicesResults>(_onTestServicesResults),
  TypedReducer<AppState, OnTestServicesProgress>(_onTestServicesProgress),
  TypedReducer<AppState, OnTestServicesComplete>(_onTestServicesComplete),
  TypedReducer<AppState, OnSshKeysScan>(_onSshKeysScan),
  TypedReducer<AppState, OnSshKeysScanned>(_onSshKeysScanned),
  TypedReducer<AppState, OnAddSshKey>(_onAddSshKey),
  TypedReducer<AppState, OnImportSshKey>(_onImportSshKey),
  TypedReducer<AppState, ShowCmdResults>(_showDeployProjectResults),
  TypedReducer<AppState, ShowSnackBar>(_showSnackBar),
  TypedReducer<AppState, OnShowedSnackBar>(_onShowedSnackBar),
  TypedReducer<AppState, PrepareDeployProject>(_prepareDeployProject),
  TypedReducer<AppState, SaveCurrentCmd>(_saveCurrentCmd),
  TypedReducer<AppState, OnDeletedLog>(_onDeletedLog),
  TypedReducer<AppState, OnAppPackageInfo>(_onAppPackageInfo),
  TypedReducer<AppState, OnPortalRunningVersionsRetrieved>(
    _onPortalRunningVersionsRetrieved,
  ),
  TypedReducer<AppState, OnInitCasKeysResults>(_onInitCasKeysResults),
  TypedReducer<AppState, OnInitCasOAuthKeysResults>(_onInitCasOAuthKeysResults),
  TypedReducer<AppState, OnSelectTuneTab>(_onSelectTuneTab),
];

final Reducer<AppState> appReducer = combineReducers<AppState>(
  basic + EntityReducer<LAProject>().appReducer,
);

AppState _onIntroEnd(AppState state, OnIntroEnd action) {
  return state.copyWith(firstUsage: false);
}

AppState _onFetchSoftwareDepsState(
  AppState state,
  OnFetchSoftwareDepsState action,
) {
  return state.copyWith(depsLoading: true);
}

AppState _onFetchStateFailed(AppState state, OnFetchStateFailed action) {
  return state;
}

AppState _onFetchAlaInstallReleases(
  AppState state,
  OnFetchAlaInstallReleases action,
) {
  return state.copyWith(alaInstallReleases: action.releases);
}

AppState _onLAVersionsSwCheckEnd(
  AppState state,
  OnLAVersionsSwCheckEnd action,
) {
  debugPrint(action.releases.toString());
  return state.copyWith(
    laReleases: action.releases,
    lastSwCheck: action.time,
    depsLoading: false,
  );
}

AppState _onFetchAlaInstallReleasesFailed(
  AppState state,
  OnFetchAlaInstallReleasesFailed action,
) {
  return state;
}

AppState _onFetchGeneratorReleases(
  AppState state,
  OnFetchGeneratorReleases action,
) {
  return state.copyWith(generatorReleases: action.releases);
}

AppState _onFetchBackendVersion(AppState state, OnFetchBackendVersion action) {
  return state.copyWith(backendVersion: action.version);
}

AppState _onFetchGeneratorReleasesFailed(
  AppState state,
  OnFetchGeneratorReleasesFailed action,
) {
  return state;
}

AppState _loading(AppState state, Loading action) {
  return state.copyWith(loading: true);
}

AppState _onRegenerateInventorySuccess(
  AppState state,
  OnRegenerateInventorySuccess action,
) {
  return state.copyWith(loading: false);
}

AppState _createProject(AppState state, CreateProject action) {
  return state.copyWith(
    currentProject: LAProject(isHub: action.isHub, parent: action.parent),
    status: LAProjectViewStatus.create,
    loading: true,
    currentStep: 0,
  );
}

AppState _importProject(AppState state, ImportProject action) {
  final List<LAProject> newProjectAndHubs = LAProject.import(
    yoRcJson: action.yoRcJson,
  );
  final List<LAProject> projects = List<LAProject>.from(state.projects);
  return state.copyWith(
    currentProject: newProjectAndHubs[0],
    status: LAProjectViewStatus.create,
    projects: projects..addAll(newProjectAndHubs),
    currentStep: 0,
  );
}

AppState _addTemplateProjects(AppState state, AddTemplateProjects action) {
  return state.copyWith(loading: !AppUtils.isDemo());
}

AppState _openProject(AppState state, OpenProject action) {
  return state.copyWith(
    currentProject: action.project,
    status: LAProjectViewStatus.edit,
    currentStep: 0,
  );
}

AppState _openServersProject(AppState state, OpenServersProject action) {
  return state.copyWith(
    currentProject: action.project,
    status: LAProjectViewStatus.servers,
    loading: true,
    currentStep: 0,
  );
}

AppState _gotoStepEditProject(AppState state, GotoStepEditProject action) {
  return state.copyWith(currentStep: action.step);
}

AppState _nextStepEditProject(AppState state, NextStepEditProject action) {
  return state.copyWith(
    currentStep: (state.currentStep + 1 != LAProjectEditPage.totalSteps)
        ? state.currentStep + 1
        : state.currentStep,
  );
}

AppState _previousStepEditProject(
  AppState state,
  PreviousStepEditProject action,
) {
  return state.copyWith(
    currentStep: (state.currentStep > 0)
        ? state.currentStep - 1
        : state.currentStep,
  );
}

AppState _tuneProject(AppState state, TuneProject action) {
  return state.copyWith(
    currentProject: action.project,
    status: LAProjectViewStatus.tune,
    currentStep: 0,
  );
}

AppState _openProjectTools(AppState state, OpenProjectTools action) {
  return state.copyWith(
    currentProject: action.project,
    status: LAProjectViewStatus.view,
    currentStep: 0,
  );
}

AppState _generateInvProject(AppState state, GenerateInvProject action) {
  if (AppUtils.isDemo()) {
    return state;
  }
  final String id = action.project.id;
  final String url =
      "${AppUtils.scheme}://${dotenv.env['BACKEND']}/api/v1/gen/$id/true";
  final html.AnchorElement anchorElement = html.AnchorElement(href: url);
  anchorElement.download = url;
  anchorElement.click();
  return state;
}

AppState _saveCurrentProject(AppState state, SaveCurrentProject action) {
  return state.copyWith(currentProject: action.project, loading: true);
}

AppState _updateProjectLocal(AppState state, UpdateProjectLocal action) {
  // Use copyWith to force a new instance, triggering ViewModel updates
  return state.copyWith(
    currentProject: action.project.copyWith(),
    loading: false,
  );
}

AppState _onUpdateProjectFailed(AppState state, OnUpdateProjectFailed action) {
  return state.copyWith(loading: false);
}

AppState _onDemoAddProjects(AppState state, OnDemoAddProjects action) {
  return state.copyWith(
    projects: List<LAProject>.from(state.projects)
      ..insertAll(0, action.projects),
    loading: false,
  );
}

AppState _onProjectsAdded(AppState state, OnProjectsAdded action) {
  List<LAProject> ps = <LAProject>[];
  if (AppUtils.isDemo()) {
    final LAProject newP = LAProject.fromJson(
      action.projectsJson[0] as Map<String, dynamic>,
    );
    ps = List<LAProject>.from(state.projects)..insert(0, newP);
  } else {
    for (final dynamic pJson in action.projectsJson) {
      final LAProject p = LAProject.fromJson(pJson as Map<String, dynamic>);
      p.validateCreation();
      ps.add(p);
    }
  }
  return state.copyWith(
    currentProject: ps[0],
    status: LAProjectViewStatus.view,
    projects: ps,
    loading: false,
  );
}

AppState _onProjectDeleted(AppState state, OnProjectDeleted action) {
  List<LAProject> ps = <LAProject>[];
  if (AppUtils.isDemo()) {
    ps = List<LAProject>.from(state.projects)
      ..removeWhere((LAProject item) => item.id == action.project.id);
  } else {
    for (final dynamic pJson in action.projectsJson) {
      ps.add(LAProject.fromJson(pJson as Map<String, dynamic>));
    }
  }
  return state.copyWith(
    currentProject: LAProject(),
    projects: ps,
    loading: false,
  );
}

AppState _projectsLoad(AppState state, ProjectsLoad action) {
  return state.copyWith(loading: true);
}

AppState _onProjectsLoad(AppState state, OnProjectsLoad action) {
  final List<LAProject> ps = <LAProject>[];
  for (final dynamic pJson in action.projectsJson) {
    try {
      ps.add(LAProject.fromJson(pJson as Map<String, dynamic>));
    } catch (e, stackTrace) {
      debugPrint('Exception: $e\nStack trace: ${Chain.forTrace(stackTrace)}');
      debugPrint('Failed to retrieve project');

      //  debugPrint(pJson.toString());
    }
  }
  final LAProject currentProject = action.setCurrentProject
      ? ps.firstWhere(
          (LAProject p) => p.id == state.currentProject.id,
          orElse: () => ps.isNotEmpty ? ps[0] : LAProject(),
        )
      : state.currentProject;
  // debugPrint("Next project ${currentProject.shortName} <<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
  return state.copyWith(
    currentProject: currentProject,
    projects: ps,
    loading: false,
  );
}

AppState _onDemoProjectsLoad(AppState state, OnDemoProjectsLoad action) {
  return state.copyWith(loading: false);
}

AppState _onProjectUpdated(AppState state, OnProjectUpdated action) {
  List<LAProject> ps = <LAProject>[];
  LAProject nextProject;
  if (AppUtils.isDemo()) {
    final LAProject updatedP = LAProject.fromJson(
      action.projectsJson[0] as Map<String, dynamic>,
    );
    ps = state.projects
        .map(
          (LAProject project) => project.id == updatedP.id ? updatedP : project,
        )
        .toList();
  } else {
    for (final dynamic pJson in action.projectsJson) {
      ps.add(LAProject.fromJson(pJson as Map<String, dynamic>));
    }
  }
  if (action.updateCurrentProject) {
    nextProject = ps.firstWhere(
      (LAProject p) => p.id == action.projectId,
      // In the case of hubs
      orElse: () => state.currentProject,
    );
  } else {
    // If we update a parent project, stay in hub project
    nextProject = state.currentProject;
  }
  // debugPrint("Next project ${nextProject.shortName} <<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
  return state.copyWith(
    currentProject: nextProject,
    projects: ps,
    loading: false,
  );
}

AppState _editService(AppState state, EditService action) {
  final LAProject cProj = state.currentProject;
  cProj.updateService(action.service);

  return state.copyWith(currentProject: cProj);
}

AppState _testConnectivityProject(
  AppState state,
  TestConnectivityProject action,
) {
  return state.copyWith(loading: true);
}

AppState _testServicesProject(AppState state, TestServicesProject action) {
  // Clear previous progress when starting new checks
  return state.copyWith(
    loading: true,
    serviceCheckProgress: <String, Map<String, dynamic>>{},
  );
}

AppState _onTestConnectivityResults(
  AppState state,
  OnTestConnectivityResults action,
) {
  final LAProject currentProject = state.currentProject;

  // ignore: avoid_dynamic_calls
  final dynamic servers = action.results['servers'];

  // Only reset and update servers that are in the results
  if (servers != null) {
    final Set<String> updatedServerIds = <String>{};

    for (final dynamic server in (servers as List<dynamic>)) {
      final Map<String, dynamic> serverData = server as Map<String, dynamic>;
      updatedServerIds.add(serverData['id'] as String);
    }

    // Reset only the servers that will be updated
    for (final LAServer server in currentProject.servers) {
      if (updatedServerIds.contains(server.id)) {
        server.reachable = ServiceStatus.unknown;
        server.sshReachable = ServiceStatus.unknown;
        server.sudoEnabled = ServiceStatus.unknown;
        server.osName = '';
        server.osVersion = '';
        currentProject.upsertServer(server);
      }
    }

    // Update with new data
    for (final dynamic server in servers) {
      currentProject.upsertServer(
        LAServer.fromJson(server as Map<String, dynamic>),
      );
    }
  }

  if (currentProject.status != LAProjectStatus.inProduction) {
    if (currentProject.allServersWithServicesReady() &&
        currentProject.status.value <= LAProjectStatus.reachable.value) {
      currentProject.status = LAProjectStatus.reachable;
    } else {
      currentProject.status = LAProjectStatus.advancedDefined;
    }
  }

  return state.copyWith(
    currentProject: currentProject,
    loading: false,
    projects: state.projects
        .map(
          (LAProject project) =>
              project.id == currentProject.id ? currentProject : project,
        )
        .toList(),
  );
}

ServiceStatus serviceStatus(bool result) {
  return (result == true) ? ServiceStatus.success : ServiceStatus.failed;
}

AppState _onSshKeysScan(AppState state, OnSshKeysScan action) {
  return state;
}

AppState _onSshKeysScanned(AppState state, OnSshKeysScanned action) {
  return state.copyWith(sshKeys: action.keys);
}

AppState _onAddSshKey(AppState state, OnAddSshKey action) {
  return state;
}

AppState _onImportSshKey(AppState state, OnImportSshKey action) {
  return state;
}

AppState _showDeployProjectResults(AppState state, ShowCmdResults action) {
  final LAProject currentProject = state.currentProject;
  currentProject.lastCmdEntry = action.cmdHistoryEntry;
  currentProject.lastCmdDetails = action.results;
  final bool fstDeployed = currentProject.lastCmdDetails!.numFailures() != null;
  currentProject.fstDeployed = currentProject.fstDeployed || fstDeployed;
  if (action.fstRetrieved) {
    currentProject.cmdHistoryEntries.insert(0, action.cmdHistoryEntry);
  } else {
    currentProject.cmdHistoryEntries = currentProject.cmdHistoryEntries
        .map(
          (CmdHistoryEntry che) => che.id == action.cmdHistoryEntry.id
              ? action.cmdHistoryEntry
              : che,
        )
        .toList();
  }
  final List<LAProject> projects = replaceProject(state, currentProject);
  return state.copyWith(
    loading: false,
    currentProject: currentProject,
    projects: projects,
  ); //, repeatCmd: DeployCmd());
}

List<LAProject> replaceProject(AppState state, LAProject currentProject) {
  final List<LAProject> projects = List<LAProject>.from(state.projects);
  int index;
  LAProject updatedProject;
  if (currentProject.isHub) {
    index = projects.indexWhere(
      (LAProject cur) => cur.id == currentProject.parent!.id,
    );
    final int hubIndex = currentProject.parent!.hubs.indexWhere(
      (LAProject cur) => cur.id == currentProject.id,
    );
    currentProject.parent!.hubs.replaceRange(
      hubIndex,
      hubIndex + 1,
      <LAProject>[currentProject],
    );
    updatedProject = currentProject.parent!;
  } else {
    index = projects.indexWhere((LAProject cur) => cur.id == currentProject.id);
    updatedProject = currentProject;
  }
  projects.replaceRange(index, index + 1, <LAProject>[updatedProject]);
  return projects;
}

AppState _showSnackBar(AppState state, ShowSnackBar action) {
  final List<AppSnackBarMessage> currentMessages =
      List<AppSnackBarMessage>.from(state.appSnackBarMessages);
  if (!currentMessages.contains(action.snackMessage)) {
    currentMessages.add(action.snackMessage);
  }
  return state.copyWith(appSnackBarMessages: currentMessages);
}

AppState _onShowedSnackBar(AppState state, OnShowedSnackBar action) {
  final List<AppSnackBarMessage> currentMessages =
      List<AppSnackBarMessage>.from(state.appSnackBarMessages);
  currentMessages.removeWhere(
    (AppSnackBarMessage m) => m.message == action.snackMessage.message,
  );
  return state.copyWith(appSnackBarMessages: currentMessages);
}

AppState _prepareDeployProject(AppState state, PrepareDeployProject action) {
  // debugPrint("REPEAT-CMD ${action.repeatCmd}");
  return state.copyWith(repeatCmd: action.deployCmd);
}

AppState _saveCurrentCmd(AppState state, SaveCurrentCmd action) {
  return state.copyWith(repeatCmd: action.cmd);
}

AppState _onDeletedLog(AppState state, OnDeletedLog action) {
  final LAProject p = state.currentProject;
  p.cmdHistoryEntries = List<CmdHistoryEntry>.from(p.cmdHistoryEntries)
    ..removeWhere((CmdHistoryEntry cmd) => cmd.id == action.cmd.id);
  final List<LAProject> projects = replaceProject(state, p);
  return state.copyWith(currentProject: p, projects: projects);
}

AppState _onAppPackageInfo(AppState state, OnAppPackageInfo action) {
  return AppUtils.isDemo()
      ? state.copyWith(
          pkgInfo: action.packageInfo,
          backendVersion: action.packageInfo.version,
        )
      : state.copyWith(pkgInfo: action.packageInfo);
}

AppState _onTestServicesResults(AppState state, OnTestServicesResults action) {
  final LAProject currentProject = state.currentProject;
  final Map<String, dynamic> response = action.results;
  final String pId = response['projectId'] as String;
  // List<dynamic> results = response['results'];
  final List<dynamic> sdsJ = response['serviceDeploys'] as List<dynamic>;
  final List<LAServiceDeploy> sds = <LAServiceDeploy>[];
  for (final dynamic sdJ in sdsJ) {
    final LAServiceDeploy sd = LAServiceDeploy.fromJson(
      sdJ as Map<String, dynamic>,
    );
    sds.add(sd);
    // debugPrint(sdJ);
  }
  if (currentProject.id == pId) {
    currentProject.serviceDeploys = sds;
    // Merge new results with existing ones instead of replacing
    final Map<String, dynamic> newResults =
        response['results'] as Map<String, dynamic>;
    final Map<String, dynamic> mergedResults = Map<String, dynamic>.from(
      currentProject.checkResults,
    );

    // Remove old _monitoring_ keys for servers that are in newResults
    // This ensures warnings disappear when monitoring tools are installed
    for (final String key in newResults.keys) {
      if (!key.startsWith('_')) {
        // This is a server ID - remove its monitoring key if it exists
        final String monitoringKey = '_monitoring_$key';
        mergedResults.remove(monitoringKey);
      }
    }

    mergedResults.addAll(newResults);
    currentProject.checkResults = mergedResults;
    return state.copyWith(
      loading: false,
      currentProject: currentProject,
      projects: replaceProject(state, currentProject),
    );
  }
  // for (String serverName in response.keys) {}
  return state;
}

AppState _onTestServicesProgress(
  AppState state,
  OnTestServicesProgress action,
) {
  final LAProject currentProject = state.currentProject;
  final Map<String, Map<String, dynamic>> progressMap =
      Map<String, Map<String, dynamic>>.from(state.serviceCheckProgress);

  // Update progress for this server
  progressMap[action.serverId] = <String, dynamic>{
    'serverName': action.serverName,
    'status': action.status,
    'resultsCount': action.results?.length ?? 0,
  };

  // Update check results progressively
  if (action.results != null && action.results!.isNotEmpty) {
    final Map<String, dynamic> currentResults = Map<String, dynamic>.from(
      currentProject.checkResults,
    );

    // Update or add results for this server
    if (currentResults.containsKey(action.serverId)) {
      // Append new results
      final List<dynamic> existingResults =
          currentResults[action.serverId] as List<dynamic>;
      currentResults[action.serverId] = <dynamic>[
        ...existingResults,
        ...action.results!,
      ];
    } else {
      currentResults[action.serverId] = action.results;
    }

    currentProject.checkResults = currentResults;

    return state.copyWith(
      currentProject: currentProject,
      serviceCheckProgress: progressMap,
      projects: replaceProject(state, currentProject),
    );
  }

  return state.copyWith(serviceCheckProgress: progressMap);
}

AppState _onTestServicesComplete(
  AppState state,
  OnTestServicesComplete action,
) {
  final LAProject currentProject = state.currentProject;
  final Map<String, dynamic> response = action.results;
  final String pId = response['projectId'] as String;
  final List<dynamic> sdsJ = response['serviceDeploys'] as List<dynamic>;
  final List<LAServiceDeploy> sds = <LAServiceDeploy>[];
  for (final dynamic sdJ in sdsJ) {
    final LAServiceDeploy sd = LAServiceDeploy.fromJson(
      sdJ as Map<String, dynamic>,
    );
    sds.add(sd);
  }
  if (currentProject.id == pId) {
    currentProject.serviceDeploys = sds;
    currentProject.checkResults = response['results'] as Map<String, dynamic>;
    return state.copyWith(
      loading: false,
      currentProject: currentProject,
      projects: replaceProject(state, currentProject),
    );
  }
  return state;
}

AppState _onPortalRunningVersionsRetrieved(
  AppState state,
  OnPortalRunningVersionsRetrieved action,
) {
  final LAProject cp = state.currentProject;
  cp.runningVersions = action.versions;
  cp.lastSwCheck = DateTime.now();
  return state.copyWith(currentProject: cp);
}

AppState _onInitCasKeysResults(AppState state, OnInitCasKeysResults action) {
  final LAProject cp = state.currentProject;
  cp.setVariable(
    LAVariableDesc.get('pac4j_cookie_signing_key'),
    action.pac4jCookieSigningKey,
  );
  cp.setVariable(
    LAVariableDesc.get('pac4j_cookie_encryption_key'),
    action.pac4jCookieEncryptionKey,
  );
  cp.setVariable(
    LAVariableDesc.get('cas_webflow_signing_key'),
    action.casWebflowSigningKey,
  );
  cp.setVariable(
    LAVariableDesc.get('cas_webflow_encryption_key'),
    action.casWebflowEncryptionKey,
  );
  return state.copyWith(currentProject: cp);
}

AppState _onInitCasOAuthKeysResults(
  AppState state,
  OnInitCasOAuthKeysResults action,
) {
  final LAProject cp = state.currentProject;
  cp.setVariable(
    LAVariableDesc.get('cas_oauth_signing_key'),
    action.casOauthSigningKey,
  );
  cp.setVariable(
    LAVariableDesc.get('cas_oauth_encryption_key'),
    action.casOauthAccessTokenEncryptionKey,
  );
  cp.setVariable(
    LAVariableDesc.get('cas_oauth_access_token_signing_key'),
    action.casOauthAccessTokenSigningKey,
  );
  cp.setVariable(
    LAVariableDesc.get('cas_oauth_access_token_encryption_key'),
    action.casOauthAccessTokenEncryptionKey,
  );
  return state.copyWith(currentProject: cp);
}

AppState _onSelectTuneTab(AppState state, OnSelectTuneTab action) {
  return state.copyWith(currentTuneTab: action.currentTab);
}
