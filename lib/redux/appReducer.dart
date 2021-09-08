import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:la_toolkit/components/appSnackBarMessage.dart';
import 'package:la_toolkit/models/cmdHistoryEntry.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/laProjectStatus.dart';
import 'package:la_toolkit/models/laServer.dart';
import 'package:la_toolkit/models/laService.dart';
import 'package:la_toolkit/models/laServiceDeploy.dart';
import 'package:la_toolkit/projectEditPage.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:redux/redux.dart';
import 'package:universal_html/html.dart' as html;

import '../models/appState.dart';
import 'actions.dart';
import 'entityReducer.dart';

List<Reducer<AppState>> basic = [
  TypedReducer<AppState, OnIntroEnd>(_onIntroEnd),
  TypedReducer<AppState, OnFetchSoftwareDepsState>(_onFetchState),
  TypedReducer<AppState, OnFetchStateFailed>(_onFetchStateFailed),
  TypedReducer<AppState, OnFetchAlaInstallReleases>(_onFetchAlaInstallReleases),
  TypedReducer<AppState, OnFetchBackendVersion>(_onFetchBackendVersion),
  TypedReducer<AppState, OnFetchAlaInstallReleasesFailed>(
      _onFetchAlaInstallReleasesFailed),
  TypedReducer<AppState, OnFetchGeneratorReleases>(_onFetchGeneratorReleases),
  TypedReducer<AppState, OnFetchGeneratorReleasesFailed>(
      _onFetchGeneratorReleasesFailed),
  TypedReducer<AppState, CreateProject>(_createProject),
  TypedReducer<AppState, ImportProject>(_importProject),
  TypedReducer<AppState, AddTemplateProjects>(_addTemplateProjects),
  TypedReducer<AppState, OpenProject>(_openProject),
  TypedReducer<AppState, GotoStepEditProject>(_gotoStepEditProject),
  TypedReducer<AppState, NextStepEditProject>(_nextStepEditProject),
  TypedReducer<AppState, PreviousStepEditProject>(_previousStepEditProject),
  TypedReducer<AppState, TuneProject>(_tuneProject),
  TypedReducer<AppState, GenerateInvProject>(_generateInvProject),
  TypedReducer<AppState, OpenProjectTools>(_openProjectTools),
  TypedReducer<AppState, EditService>(_editService),
  TypedReducer<AppState, SaveCurrentProject>(_saveCurrentProject),
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
];

final appReducer =
    combineReducers<AppState>(basic + EntityReducer<LAProject>().appReducer);

AppState _onIntroEnd(AppState state, OnIntroEnd action) {
  return state.copyWith(firstUsage: false);
}

AppState _onFetchState(AppState state, OnFetchSoftwareDepsState action) {
  return state;
}

AppState _onFetchStateFailed(AppState state, OnFetchStateFailed action) {
  return state;
}

AppState _onFetchAlaInstallReleases(
    AppState state, OnFetchAlaInstallReleases action) {
  return state.copyWith(alaInstallReleases: action.releases);
}

AppState _onFetchAlaInstallReleasesFailed(
    AppState state, OnFetchAlaInstallReleasesFailed action) {
  return state;
}

AppState _onFetchGeneratorReleases(
    AppState state, OnFetchGeneratorReleases action) {
  return state.copyWith(generatorReleases: action.releases);
}

AppState _onFetchBackendVersion(AppState state, OnFetchBackendVersion action) {
  return state.copyWith(backendVersion: action.version);
}

AppState _onFetchGeneratorReleasesFailed(
    AppState state, OnFetchGeneratorReleasesFailed action) {
  return state;
}

AppState _createProject(AppState state, CreateProject action) {
  return state.copyWith(
      currentProject: LAProject(isHub: action.isHub, parent: action.parent),
      status: LAProjectViewStatus.create,
      currentStep: 0);
}

AppState _importProject(AppState state, ImportProject action) {
  return state.copyWith(
      currentProject: LAProject.import(yoRcJson: action.yoRcJson),
      status: LAProjectViewStatus.create,
      currentStep: 0);
}

AppState _addTemplateProjects(AppState state, AddTemplateProjects action) {
  return state;
}

AppState _openProject(AppState state, OpenProject action) {
  return state.copyWith(
      currentProject: action.project,
      status: LAProjectViewStatus.edit,
      currentStep: 0);
}

AppState _gotoStepEditProject(AppState state, GotoStepEditProject action) {
  return state.copyWith(currentStep: action.step);
}

AppState _nextStepEditProject(AppState state, NextStepEditProject action) {
  return state.copyWith(
      currentStep: (state.currentStep + 1 != LAProjectEditPage.totalSteps)
          ? state.currentStep + 1
          : state.currentStep);
}

AppState _previousStepEditProject(
    AppState state, PreviousStepEditProject action) {
  return state.copyWith(
      currentStep:
          (state.currentStep > 0) ? state.currentStep - 1 : state.currentStep);
}

AppState _tuneProject(AppState state, TuneProject action) {
  return state.copyWith(
      currentProject: action.project,
      status: LAProjectViewStatus.tune,
      currentStep: 0);
}

AppState _openProjectTools(AppState state, OpenProjectTools action) {
  return state.copyWith(
      currentProject: action.project,
      status: LAProjectViewStatus.view,
      currentStep: 0);
}

AppState _generateInvProject(AppState state, GenerateInvProject action) {
  if (AppUtils.isDemo()) return state;
  String id = action.project.id;
  String url = "${AppUtils.scheme}://${env['BACKEND']}/api/v1/gen/$id/true";
  html.AnchorElement anchorElement = html.AnchorElement(href: url);
  anchorElement.download = url;
  anchorElement.click();
  return state;
}

AppState _saveCurrentProject(AppState state, SaveCurrentProject action) {
  return state.copyWith(currentProject: action.project);
}

AppState _onDemoAddProjects(AppState state, OnDemoAddProjects action) {
  return state.copyWith(
      projects: List<LAProject>.from(state.projects)
        ..insertAll(0, action.projects));
}

AppState _onProjectsAdded(AppState state, OnProjectsAdded action) {
  List<LAProject> ps = [];
  if (AppUtils.isDemo()) {
    LAProject newP = LAProject.fromJson(action.projectsJson[0]);
    ps = List<LAProject>.from(state.projects)..insert(0, newP);
  } else {
    for (var pJson in action.projectsJson) {
      LAProject p = LAProject.fromJson(pJson);
      p.validateCreation();
      ps.add(p);
    }
  }
  return state.copyWith(
      currentProject: ps[0], status: LAProjectViewStatus.view, projects: ps);
}

AppState _onProjectDeleted(AppState state, OnProjectDeleted action) {
  List<LAProject> ps = [];
  if (AppUtils.isDemo()) {
    ps = List<LAProject>.from(state.projects)
      ..removeWhere((item) => item.id == action.project.id);
  } else {
    for (var pJson in action.projectsJson) {
      ps.add(LAProject.fromJson(pJson));
    }
  }
  return state.copyWith(currentProject: LAProject(), projects: ps);
}

AppState _projectsLoad(AppState state, ProjectsLoad action) {
  return state.copyWith(loading: true);
}

AppState _onProjectsLoad(AppState state, OnProjectsLoad action) {
  List<LAProject> ps = [];
  for (var pJson in action.projectsJson) {
    try {
      ps.add(LAProject.fromJson(pJson));
    } catch (e) {
      print("Failed to retrieve project");
      print(pJson);
    }
  }
  LAProject currentProject = ps.firstWhere(
      (p) => p.id == state.currentProject.id,
      orElse: () => ps.isNotEmpty ? ps[0] : LAProject());
  return state.copyWith(
      currentProject: currentProject, projects: ps, loading: false);
}

AppState _onDemoProjectsLoad(AppState state, OnDemoProjectsLoad action) {
  return state.copyWith(loading: false);
}

AppState _onProjectUpdated(AppState state, OnProjectUpdated action) {
  List<LAProject> ps = [];
  LAProject nextProject;
  if (AppUtils.isDemo()) {
    LAProject updatedP = LAProject.fromJson(action.projectsJson[0]);
    ps = state.projects
        .map((project) => project.id == updatedP.id ? updatedP : project)
        .toList();
  } else {
    for (var pJson in action.projectsJson) {
      ps.add(LAProject.fromJson(pJson));
    }
  }
  if (action.updateCurrentProject) {
    nextProject = ps.firstWhere((p) => p.id == action.projectId,
        // In the case of hubs
        orElse: () => state.currentProject);
  } else {
    // If we update a parent project, stay in hub project
    nextProject = state.currentProject;
  }
  return state.copyWith(currentProject: nextProject, projects: ps);
}

AppState _editService(AppState state, EditService action) {
  LAProject cProj = state.currentProject;
  cProj.updateService(action.service);

  return state.copyWith(currentProject: cProj);
}

AppState _testConnectivityProject(
    AppState state, TestConnectivityProject action) {
  return state.copyWith(loading: true);
}

AppState _testServicesProject(AppState state, TestServicesProject action) {
  return state.copyWith(loading: true);
}

AppState _onTestConnectivityResults(
    AppState state, OnTestConnectivityResults action) {
  LAProject currentProject = state.currentProject;

  for (LAServer server in currentProject.servers) {
    server.reachable = ServiceStatus.unknown;
    server.sshReachable = ServiceStatus.unknown;
    server.sudoEnabled = ServiceStatus.unknown;
    server.osName = "";
    server.osVersion = "";
    currentProject.upsertServer(server);
  }

  action.results['servers'].forEach((server) {
    currentProject.upsertServer(LAServer.fromJson(server));
  });

  if (currentProject.allServersWithServicesReady() &&
      currentProject.status.value <= LAProjectStatus.reachable.value) {
    currentProject.setProjectStatus(LAProjectStatus.reachable);
  } else {
    currentProject.setProjectStatus(LAProjectStatus.advancedDefined);
  }

  return state.copyWith(
      currentProject: currentProject,
      loading: false,
      projects: state.projects
          .map((project) =>
              project.id == currentProject.id ? currentProject : project)
          .toList());
}

ServiceStatus serviceStatus(result) {
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
  LAProject currentProject = state.currentProject;
  currentProject.lastCmdEntry = action.cmdHistoryEntry;
  currentProject.lastCmdDetails = action.results;
  bool fstDeployed = currentProject.lastCmdDetails!.numFailures() != null;
  currentProject.fstDeployed = currentProject.fstDeployed || fstDeployed;
  if (action.fstRetrieved) {
    currentProject.cmdHistoryEntries.insert(0, action.cmdHistoryEntry);
  } else {
    currentProject.cmdHistoryEntries = currentProject.cmdHistoryEntries
        .map((che) =>
            che.id == action.cmdHistoryEntry.id ? action.cmdHistoryEntry : che)
        .toList();
  }
  List<LAProject> projects = replaceProject(state, currentProject);
  return state.copyWith(
      loading: false,
      currentProject: currentProject,
      projects: projects); //, repeatCmd: DeployCmd());
}

List<LAProject> replaceProject(AppState state, LAProject currentProject) {
  List<LAProject> projects = List<LAProject>.from(state.projects);
  int index;
  LAProject updatedProject;
  if (currentProject.isHub) {
    index = projects.indexWhere((cur) => cur.id == currentProject.parent!.id);
    int hubIndex = currentProject.parent!.hubs
        .indexWhere((cur) => cur.id == currentProject.id);
    currentProject.parent!.hubs
        .replaceRange(hubIndex, hubIndex + 1, [currentProject]);
    updatedProject = currentProject.parent!;
  } else {
    index = projects.indexWhere((cur) => cur.id == currentProject.id);
    updatedProject = currentProject;
  }
  projects.replaceRange(index, index + 1, [updatedProject]);
  return projects;
}

AppState _showSnackBar(AppState state, ShowSnackBar action) {
  List<AppSnackBarMessage> currentMessages =
      List<AppSnackBarMessage>.from(state.appSnackBarMessages);
  if (!currentMessages.contains(action.snackMessage)) {
    currentMessages.add(action.snackMessage);
  }
  return state.copyWith(appSnackBarMessages: currentMessages);
}

AppState _onShowedSnackBar(AppState state, OnShowedSnackBar action) {
  List<AppSnackBarMessage> currentMessages =
      List<AppSnackBarMessage>.from(state.appSnackBarMessages);
  currentMessages.removeWhere((m) => m.message == action.snackMessage.message);
  return state.copyWith(appSnackBarMessages: currentMessages);
}

AppState _prepareDeployProject(AppState state, PrepareDeployProject action) {
  // print("REPEAT-CMD ${action.repeatCmd}");
  return state.copyWith(repeatCmd: action.deployCmd);
}

AppState _saveCurrentCmd(AppState state, SaveCurrentCmd action) {
  return state.copyWith(repeatCmd: action.cmd);
}

AppState _onDeletedLog(AppState state, OnDeletedLog action) {
  LAProject p = state.currentProject;
  p.cmdHistoryEntries = List<CmdHistoryEntry>.from(p.cmdHistoryEntries)
    ..removeWhere((cmd) => cmd.id == action.cmd.id);
  List<LAProject> projects = replaceProject(state, p);
  return state.copyWith(currentProject: p, projects: projects);
}

AppState _onAppPackageInfo(AppState state, OnAppPackageInfo action) {
  return AppUtils.isDemo()
      ? state.copyWith(
          pkgInfo: action.packageInfo,
          backendVersion: action.packageInfo.version)
      : state.copyWith(pkgInfo: action.packageInfo);
}

AppState _onTestServicesResults(AppState state, OnTestServicesResults action) {
  LAProject currentProject = state.currentProject;
  Map<String, dynamic> response = action.results;
  String pId = response['projectId'];
  // List<dynamic> results = response['results'];
  List<dynamic> sdsJ = response['serviceDeploys'];
  List<LAServiceDeploy> sds = [];
  for (var sdJ in sdsJ) {
    LAServiceDeploy sd = LAServiceDeploy.fromJson(sdJ);
    sds.add(sd);
    // print(sdJ);
  }
  if (currentProject.id == pId) {
    currentProject.serviceDeploys = sds;
    currentProject.checkResults = response['results'];
    return state.copyWith(
        loading: false,
        currentProject: currentProject,
        projects: replaceProject(state, currentProject));
  }
  // for (String serverName in response.keys) {}
  return state;
}
