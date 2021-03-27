import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:la_toolkit/components/appSnackBarMessage.dart';
import 'package:la_toolkit/models/cmdHistoryEntry.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/laProjectStatus.dart';
import 'package:la_toolkit/models/laServer.dart';
import 'package:la_toolkit/projectEditPage.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:redux/redux.dart';
import 'package:universal_html/html.dart' as html;

import '../models/appState.dart';
import 'actions.dart';

final appReducer = combineReducers<AppState>([
  new TypedReducer<AppState, OnIntroEnd>(_onIntroEnd),
  new TypedReducer<AppState, OnFetchState>(_onFetchState),
  new TypedReducer<AppState, OnFetchStateFailed>(_onFetchStateFailed),
  new TypedReducer<AppState, OnFetchAlaInstallReleases>(
      _onFetchAlaInstallReleases),
  new TypedReducer<AppState, OnFetchAlaInstallReleasesFailed>(
      _onFetchAlaInstallReleasesFailed),
  new TypedReducer<AppState, OnFetchGeneratorReleases>(
      _onFetchGeneratorReleases),
  new TypedReducer<AppState, OnFetchGeneratorReleasesFailed>(
      _onFetchGeneratorReleasesFailed),
  new TypedReducer<AppState, CreateProject>(_createProject),
  new TypedReducer<AppState, ImportProject>(_importProject),
  new TypedReducer<AppState, AddTemplateProjects>(_addTemplateProjects),
  new TypedReducer<AppState, AddProject>(_addProject),
  new TypedReducer<AppState, OpenProject>(_openProject),
  new TypedReducer<AppState, GotoStepEditProject>(_gotoStepEditProject),
  new TypedReducer<AppState, NextStepEditProject>(_nextStepEditProject),
  new TypedReducer<AppState, PreviousStepEditProject>(_previousStepEditProject),
  new TypedReducer<AppState, TuneProject>(_tuneProject),
  new TypedReducer<AppState, GenerateInvProject>(_generateInvProject),
  new TypedReducer<AppState, OpenProjectTools>(_openProjectTools),
  new TypedReducer<AppState, EditService>(_editService),
  new TypedReducer<AppState, SaveCurrentProject>(_saveCurrentProject),
  new TypedReducer<AppState, DelProject>(_delProject),
  new TypedReducer<AppState, UpdateProject>(_updateProject),
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
  new TypedReducer<AppState, DeleteLog>(_onDeleteLog),
  new TypedReducer<AppState, OnAppPackageInfo>(_onAppPackageInfo),
]);

AppState _onIntroEnd(AppState state, OnIntroEnd action) {
  return state.copyWith(firstUsage: false);
}

AppState _onFetchState(AppState state, OnFetchState action) {
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
  Map<String, dynamic> json = action.templates;
  List<dynamic> projects = json['projects'];
  List<LAProject> newProjects = List<LAProject>.empty(growable: true);
  projects.forEach((pJson) {
    pJson['uuid'] = null;
    LAProject newProject = LAProject.fromJson(pJson);
    newProjects.add(newProject);
  });
  action.onAdded(projects.length);
  return state.copyWith(
      projects: new List<LAProject>.from(state.projects)
        ..insertAll(0, newProjects));
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
  String uuid = action.project.uuid;
  String url = "http://${env['BACKEND']}/api/v1/gen/$uuid/true";
  html.AnchorElement anchorElement = new html.AnchorElement(href: url);
  anchorElement.download = url;
  anchorElement.click();
  return state;
}

AppState _saveCurrentProject(AppState state, SaveCurrentProject action) {
  return state.copyWith(currentProject: action.project);
}

AppState _addProject(AppState state, AddProject action) {
  state.projects.forEach((project) {
    if (project.uuid == action.project.uuid)
      throw ("Trying to add an existing project.");
    return;
  });
  action.project.dirName = action.project.suggestDirName();
  return state.copyWith(
      currentProject: action.project,
      projects: new List<LAProject>.from(state.projects)
        ..insert(0, action.project));
}

AppState _delProject(AppState state, DelProject action) {
  return state.copyWith(
      currentProject: LAProject(),
      projects: new List<LAProject>.from(state.projects)
        ..removeWhere((item) => item.uuid == action.project.uuid));
}

AppState _updateProject(AppState state, UpdateProject action) {
  return state.copyWith(
      currentProject: action.project,
      projects: state.projects
          .map((project) =>
              project.uuid == action.project.uuid ? action.project : project)
          .toList());
}

AppState _editService(AppState state, EditService action) {
  LAProject currentProject = state.currentProject;
  currentProject.services[action.service.nameInt] = action.service;
  return state.copyWith(currentProject: currentProject);
}

AppState _testConnectivityProject(
    AppState state, TestConnectivityProject action) {
  return state;
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
      projects: state.projects
          .map((project) =>
              project.uuid == currentProject.uuid ? currentProject : project)
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
  action.cmdHistoryEntry.result = currentProject.lastCmdDetails!.result;
  if (action.fstRetrieved) {
    // remove and just search?
    currentProject.cmdHistory.insert(0, action.cmdHistoryEntry);
  } else {
    int index = currentProject.cmdHistory
        .indexWhere((cur) => cur.uuid == action.cmdHistoryEntry.uuid);
    if (index != -1) {
      currentProject.cmdHistory
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
  int index = projects.indexWhere((cur) => cur.uuid == currentProject.uuid);
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

AppState _onDeleteLog(AppState state, DeleteLog action) {
  LAProject p = state.currentProject;
  p.cmdHistory = new List<CmdHistoryEntry>.from(p.cmdHistory)
    ..removeWhere((cmd) => cmd.uuid == action.cmd.uuid);
  List<LAProject> projects = replaceProject(state, p);
  return state.copyWith(currentProject: p, projects: projects);
}

AppState _onAppPackageInfo(AppState state, OnAppPackageInfo action) {
  return state.copyWith(pkgInfo: action.packageInfo);
}
