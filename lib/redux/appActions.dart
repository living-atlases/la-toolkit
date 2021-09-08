import 'package:la_toolkit/components/appSnackBarMessage.dart';
import 'package:la_toolkit/models/brandingDeployCmd.dart';
import 'package:la_toolkit/models/cmdHistoryDetails.dart';
import 'package:la_toolkit/models/cmdHistoryEntry.dart';
import 'package:la_toolkit/models/commonCmd.dart';
import 'package:la_toolkit/models/deployCmd.dart';
import 'package:la_toolkit/models/hostServicesChecks.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/laService.dart';
import 'package:la_toolkit/models/postDeployCmd.dart';
import 'package:la_toolkit/models/sshKey.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../models/preDeployCmd.dart';

abstract class AppActions {}

class FetchState extends AppActions {}

class OnIntroEnd extends AppActions {}

class OnFetchSoftwareDepsState extends AppActions {
  OnFetchSoftwareDepsState();
}

class OnFetchStateFailed extends AppActions {
  OnFetchStateFailed();
}

class OnFetchProjectsFailed extends AppActions {}

class OnFetchAlaInstallReleases extends AppActions {
  List<String> releases;

  OnFetchAlaInstallReleases(this.releases);
}

class OnFetchBackendVersion extends AppActions {
  String version;
  OnFetchBackendVersion(this.version);
}

class OnFetchAlaInstallReleasesFailed extends AppActions {}

class OnFetchGeneratorReleases extends AppActions {
  List<String> releases;

  OnFetchGeneratorReleases(this.releases);
}

class OnFetchGeneratorReleasesFailed extends AppActions {}

class CreateProject extends AppActions {
  bool isHub;
  LAProject? parent;
  CreateProject({this.isHub = false, this.parent});
}

class ImportProject extends AppActions {
  String yoRcJson;
  ImportProject({required this.yoRcJson});
}

class AddTemplateProjects extends AppActions {
  Function(int) onAdded;
  AddTemplateProjects({required this.onAdded});
}

class AddProject extends AppActions {
  LAProject project;

  AddProject(this.project);
}

class OnDemoAddProjects extends AppActions {
  List<LAProject> projects;

  OnDemoAddProjects(this.projects);
}

class OnProjectsAdded extends AppActions {
  List<dynamic> projectsJson;

  OnProjectsAdded(this.projectsJson);
}

class DelProject extends AppActions {
  LAProject project;

  DelProject(this.project);
}

class OnProjectDeleted extends AppActions {
  LAProject project;
  List<dynamic> projectsJson;

  OnProjectDeleted(this.project, this.projectsJson);
}

class OnProjectUpdated extends AppActions {
  String projectId;
  List<dynamic> projectsJson;
  bool updateCurrentProject;
  OnProjectUpdated(
      this.projectId, this.projectsJson, this.updateCurrentProject);
}

class ProjectsLoad extends AppActions {
  ProjectsLoad();
}

class OnProjectsLoad extends AppActions {
  List<dynamic> projectsJson;

  OnProjectsLoad(this.projectsJson);
}

class OnDemoProjectsLoad extends AppActions {
  OnDemoProjectsLoad();
}

class OpenProject extends AppActions {
  LAProject project;

  OpenProject(this.project);
}

class NextStepEditProject extends AppActions {
  NextStepEditProject();
}

class PreviousStepEditProject extends AppActions {
  PreviousStepEditProject();
}

class GotoStepEditProject extends AppActions {
  int step;

  GotoStepEditProject(this.step);
}

class TuneProject extends AppActions {
  LAProject project;

  TuneProject(this.project);
}

class OnPreDeployTasks extends AppActions {
  LAProject project;
  PreDeployCmd preDeployCmd;
  OnPreDeployTasks(this.project, this.preDeployCmd);
}

class OnPostDeployTasks extends AppActions {
  LAProject project;
  PostDeployCmd postDeployCmd;
  OnPostDeployTasks(this.project, this.postDeployCmd);
}

class OnViewLogs extends AppActions {
  LAProject project;
  OnViewLogs(this.project);
}

class PrepareDeployProject extends AppActions {
  LAProject project;
  VoidCallback onReady;
  CommonCmd deployCmd;
  Function(String) onError;
  PrepareDeployProject(
      {required this.project,
      required this.onReady,
      required this.deployCmd,
      required this.onError});
}

class SaveCurrentCmd extends AppActions {
  CommonCmd cmd;
  SaveCurrentCmd({required this.cmd});
}

abstract class DeployAction extends AppActions {
  LAProject project;
  Function(CmdHistoryEntry cmd, int port, int ttydPid) onStart;
  ErrorCallback onError;
  DeployAction(
      {required this.project, required this.onStart, required this.onError});
}

class DeployProject extends DeployAction {
  DeployCmd cmd;

  DeployProject(
      {required this.cmd,
      required LAProject project,
      required Function(CmdHistoryEntry cmd, int port, int ttydPid) onStart,
      required ErrorCallback onError})
      : super(project: project, onStart: onStart, onError: onError);
}

class BrandingDeploy extends DeployAction {
  BrandingDeployCmd cmd;

  BrandingDeploy(
      {required this.cmd,
      required LAProject project,
      required Function(CmdHistoryEntry cmd, int port, int ttydPid) onStart,
      required ErrorCallback onError})
      : super(project: project, onStart: onStart, onError: onError);
}

class GetCmdResults extends AppActions {
  CmdHistoryEntry cmdHistoryEntry;
  VoidCallback onReady;
  VoidCallback onFailed;
  bool fstRetrieved;

  GetCmdResults(
      {required this.cmdHistoryEntry,
      required this.fstRetrieved,
      required this.onReady,
      required this.onFailed});
}

class ShowCmdResults extends AppActions {
  CmdHistoryEntry cmdHistoryEntry;
  CmdHistoryDetails results;
  bool fstRetrieved;

  ShowCmdResults(this.cmdHistoryEntry, this.fstRetrieved, this.results);
}

class OnShowCmdResultsFailed extends AppActions {}

class OpenProjectTools extends AppActions {
  LAProject project;

  OpenProjectTools(this.project);
}

class UpdateProject extends AppActions {
  LAProject project;
  bool updateCurrentProject;
  bool openProjectView;
  UpdateProject(this.project,
      [this.updateCurrentProject = true, this.openProjectView = true]);
}

class GenerateInvProject extends AppActions {
  LAProject project;

  GenerateInvProject(this.project);
}

class EditService extends AppActions {
  LAService service;

  EditService(this.service);
}

class SaveCurrentProject extends AppActions {
  LAProject project;

  SaveCurrentProject(this.project);
}

typedef VoidCallback = void Function();
typedef ErrorCallback = void Function(int error);

class TestConnectivityProject extends AppActions {
  LAProject project;
  VoidCallback onServersStatusReady;
  VoidCallback onFailed;

  TestConnectivityProject(
      this.project, this.onServersStatusReady, this.onFailed);
}

class TestServicesProject extends AppActions {
  LAProject project;
  HostsServicesChecks hostsServicesChecks;
  VoidCallback onResults;
  VoidCallback onFailed;

  TestServicesProject(
      this.project, this.hostsServicesChecks, this.onResults, this.onFailed);
}

class OnTestConnectivityResults extends AppActions {
  Map<String, dynamic> results;

  OnTestConnectivityResults(this.results);
}

class OnSshKeysScan extends AppActions {
  VoidCallback onKeysScanned;

  OnSshKeysScan(this.onKeysScanned);
}

class OnSshKeysScanned extends AppActions {
  List<SshKey> keys;

  OnSshKeysScanned(this.keys);
}

class OnAddSshKey extends AppActions {
  String name;

  OnAddSshKey(this.name);
}

class OnImportSshKey extends AppActions {
  String name;
  String publicKey;
  String privateKey;

  OnImportSshKey(this.name, this.publicKey, this.privateKey);
}

class ShowSnackBar extends AppActions {
  AppSnackBarMessage snackMessage;
  ShowSnackBar(this.snackMessage);
}

class OnShowedSnackBar extends AppActions {
  AppSnackBarMessage snackMessage;
  OnShowedSnackBar(this.snackMessage);
}

class DeleteLog extends AppActions {
  CmdHistoryEntry cmd;
  DeleteLog(this.cmd);
}

class OnDeletedLog extends AppActions {
  CmdHistoryEntry cmd;
  OnDeletedLog(this.cmd);
}

class OnAppPackageInfo extends AppActions {
  PackageInfo packageInfo;
  OnAppPackageInfo(this.packageInfo);
}

class OnTestServicesResults extends AppActions {
  Map<String, dynamic> results;

  OnTestServicesResults(this.results);
}
