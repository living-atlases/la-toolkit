import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:la_toolkit/components/appSnackBarMessage.dart';
import 'package:la_toolkit/models/cmdHistoryEntry.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/laProjectStatus.dart';
import 'package:la_toolkit/models/laServer.dart';
import 'package:la_toolkit/models/laService.dart';
import 'package:la_toolkit/projectEditPage.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:redux/redux.dart';
import 'package:universal_html/html.dart' as html;

import '../models/appState.dart';
import 'actions.dart';
import 'entityApis.dart';
import 'entityReducer.dart';

List<Reducer<AppState>> basic = [
  new TypedReducer<AppState, OnIntroEnd>(_onIntroEnd),
  new TypedReducer<AppState, OnFetchSoftwareDepsState>(_onFetchState),
  new TypedReducer<AppState, OnFetchStateFailed>(_onFetchStateFailed),
  new TypedReducer<AppState, OnFetchAlaInstallReleases>(
      _onFetchAlaInstallReleases),
  new TypedReducer<AppState, OnFetchBackendVersion>(_onFetchBackendVersion),
  new TypedReducer<AppState, OnFetchAlaInstallReleasesFailed>(
      _onFetchAlaInstallReleasesFailed),
  new TypedReducer<AppState, OnFetchGeneratorReleases>(
      _onFetchGeneratorReleases),
  new TypedReducer<AppState, OnFetchGeneratorReleasesFailed>(
      _onFetchGeneratorReleasesFailed),
  new TypedReducer<AppState, CreateProject>(_createProject),
  new TypedReducer<AppState, ImportProject>(_importProject),
  new TypedReducer<AppState, AddTemplateProjects>(_addTemplateProjects),
  new TypedReducer<AppState, OpenProject>(_openProject),
  new TypedReducer<AppState, GotoStepEditProject>(_gotoStepEditProject),
  new TypedReducer<AppState, NextStepEditProject>(_nextStepEditProject),
  new TypedReducer<AppState, PreviousStepEditProject>(_previousStepEditProject),
  new TypedReducer<AppState, TuneProject>(_tuneProject),
  new TypedReducer<AppState, GenerateInvProject>(_generateInvProject),
  new TypedReducer<AppState, OpenProjectTools>(_openProjectTools),
  new TypedReducer<AppState, EditService>(_editService),
  new TypedReducer<AppState, SaveCurrentProject>(_saveCurrentProject),
  new TypedReducer<AppState, OnDemoAddProjects>(_onDemoAddProjects),
  new TypedReducer<AppState, OnProjectsAdded>(_onProjectsAdded),
  new TypedReducer<AppState, OnProjectUpdated>(_onProjectUpdated),
  new TypedReducer<AppState, OnProjectDeleted>(_onProjectDeleted),
  new TypedReducer<AppState, OnProjectsReload>(_onProjectsReload),
  new TypedReducer<AppState, TestConnectivityProject>(_testConnectivityProject),
  new TypedReducer<AppState, OnTestConnectivityResults>(
      _onTestConnectivityResults),
  new TypedReducer<AppState, OnSshKeysScan>(_onSshKeysScan),
  new TypedReducer<AppState, OnSshKeysScanned>(_onSshKeysScanned),
  new TypedReducer<AppState, OnAddSshKey>(_onAddSshKey),
  new TypedReducer<AppState, OnImportSshKey>(_onImportSshKey),
  new TypedReducer<AppState, ShowDeployProjectResults>(
      _showDeployProjectResults),
  new TypedReducer<AppState, ShowSnackBar>(_showSnackBar),
  new TypedReducer<AppState, OnShowedSnackBar>(_onShowedSnackBar),
  new TypedReducer<AppState, PrepareDeployProject>(_prepareDeployProject),
  new TypedReducer<AppState, SaveDeployCmd>(_saveDeployCmd),
  new TypedReducer<AppState, DeleteLog>(_onDeleteLog),
  new TypedReducer<AppState, OnAppPackageInfo>(_onAppPackageInfo),
  new TypedReducer<AppState, OnTestServicesResults>(_onTestServicesResults),
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
      currentProject: new LAProject(),
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
  print('${action.project}');
  return state.copyWith(
      currentProject: action.project,
      status: LAProjectViewStatus.view,
      currentStep: 0);
}

AppState _generateInvProject(AppState state, GenerateInvProject action) {
  if (AppUtils.isDemo()) return state;
  String id = action.project.id;
  String url = "http://${env['BACKEND']}/api/v1/gen/$id/true";
  html.AnchorElement anchorElement = new html.AnchorElement(href: url);
  anchorElement.download = url;
  anchorElement.click();
  return state;
}

AppState _saveCurrentProject(AppState state, SaveCurrentProject action) {
  return state.copyWith(currentProject: action.project);
}

AppState _onDemoAddProjects(AppState state, OnDemoAddProjects action) {
  return state.copyWith(
      projects: new List<LAProject>.from(state.projects)
        ..insertAll(0, action.projects));
}

AppState _onProjectsAdded(AppState state, OnProjectsAdded action) {
  List<LAProject> ps = [];
  if (AppUtils.isDemo()) {
    LAProject newP = LAProject.fromJson(action.projectsJson[0]);
    ps = new List<LAProject>.from(state.projects)..insert(0, newP);
  } else {
    action.projectsJson.forEach((pJson) {
      ps.add(LAProject.fromJson(pJson));
    });
  }
  return state.copyWith(
      currentProject: ps[0], status: LAProjectViewStatus.view, projects: ps);
}

AppState _onProjectDeleted(AppState state, OnProjectDeleted action) {
  return state.copyWith(
      currentProject: LAProject(),
      projects: new List<LAProject>.from(state.projects)
        ..removeWhere((item) => item.id == action.project.id));
}

AppState _onProjectsReload(AppState state, OnProjectsReload action) {
  List<LAProject> ps = [];
  action.projectsJson.forEach((pJson) {
    ps.add(LAProject.fromJson(pJson));
  });
  return state.copyWith(currentProject: ps[0], projects: ps);
}

AppState _onProjectUpdated(AppState state, OnProjectUpdated action) {
  List<LAProject> ps = [];
  if (AppUtils.isDemo()) {
    LAProject updatedP = LAProject.fromJson(action.projectsJson[0]);
    ps = state.projects
        .map((project) => project.id == updatedP.id ? updatedP : project)
        .toList();
  } else {
    action.projectsJson.forEach((pJson) {
      ps.add(LAProject.fromJson(pJson));
    });
  }
  return state.copyWith(currentProject: ps[0], projects: ps);
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

AppState _onTestConnectivityResults(
    AppState state, OnTestConnectivityResults action) {
  LAProject currentProject = state.currentProject;
  currentProject.servers.forEach((server) {
    server.reachable = ServiceStatus.unknown;
    server.sshReachable = ServiceStatus.unknown;
    server.sudoEnabled = ServiceStatus.unknown;
    server.osName = "";
    server.osVersion = "";
    currentProject.upsertByName(server);
  });
  for (String serverName in action.results.keys) {
    LAServer server =
        currentProject.servers.where((e) => e.name == serverName).toList()[0];
    server.reachable = serviceStatus(action.results[serverName]['ping']);
    server.sshReachable = serviceStatus(action.results[serverName]['ssh']);
    server.sudoEnabled = serviceStatus(action.results[serverName]['sudo']);
    server.osName = action.results[serverName]['os']['name'];
    server.osVersion = action.results[serverName]['os']['version'];
    currentProject.upsertByName(server);
  }
  if (currentProject.allServersWithServicesReady() &&
      currentProject.status.value <= LAProjectStatus.reachable.value) {
    currentProject.setProjectStatus(LAProjectStatus.reachable);
  } else
    currentProject.setProjectStatus(LAProjectStatus.advancedDefined);

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

AppState _showDeployProjectResults(
    AppState state, ShowDeployProjectResults action) {
  LAProject currentProject = state.currentProject;
  currentProject.lastCmdEntry = action.cmdHistoryEntry;
  currentProject.lastCmdDetails = action.results;
  bool fstDeployed = currentProject.lastCmdDetails!.numFailures() != null;
  currentProject.fstDeployed = currentProject.fstDeployed || fstDeployed;
  CmdResult result = currentProject.lastCmdDetails!.result;
  action.cmdHistoryEntry.result = result;
  if (action.fstRetrieved) {
    // remove and just search?
    EntityApis.cmdHistoryEntryApi
        .update(action.cmdHistoryEntry.id, {'result': result.toS()});
    currentProject.cmdHistoryEntries.insert(0, action.cmdHistoryEntry);
  } else {
    int index = currentProject.cmdHistoryEntries
        .indexWhere((cur) => cur.id == action.cmdHistoryEntry.id);
    if (index != -1) {
      currentProject.cmdHistoryEntries
          .replaceRange(index, index + 1, [action.cmdHistoryEntry]);
    }
  }
  List<LAProject> projects = replaceProject(state, currentProject);
  return state.copyWith(
      currentProject: currentProject,
      projects: projects); //, repeatCmd: DeployCmd());
}

List<LAProject> replaceProject(AppState state, LAProject currentProject) {
  List<LAProject> projects = new List<LAProject>.from(state.projects);
  int index = projects.indexWhere((cur) => cur.id == currentProject.id);
  projects.replaceRange(index, index + 1, [currentProject]);
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

AppState _saveDeployCmd(AppState state, SaveDeployCmd action) {
  return state.copyWith(repeatCmd: action.deployCmd);
}

AppState _onDeleteLog(AppState state, DeleteLog action) {
  LAProject p = state.currentProject;
  p.cmdHistoryEntries = new List<CmdHistoryEntry>.from(p.cmdHistoryEntries)
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
  /* LAProject currentProject = state.currentProject;
  Map<String, dynamic> results = action.results;
  for (String serverName in results.keys) {} */
  return state;
}
