import 'package:package_info_plus/package_info_plus.dart';

import '../components/app_snack_bar_message.dart';
import '../models/branding_deploy_cmd.dart';
import '../models/cmd_history_details.dart';
import '../models/cmd_history_entry.dart';
import '../models/common_cmd.dart';
import '../models/deploy_cmd.dart';
import '../models/host_services_checks.dart';
import '../models/la_project.dart';
import '../models/la_releases.dart';
import '../models/la_service.dart';
import '../models/pipelines_cmd.dart';
import '../models/post_deploy_cmd.dart';
import '../models/pre_deploy_cmd.dart';
import '../models/ssh_key.dart';

abstract class AppActions {}

class FetchState extends AppActions {}

class OnIntroEnd extends AppActions {}

class OnFetchSoftwareDepsState extends AppActions {
  OnFetchSoftwareDepsState({this.force = false, this.onReady});

  bool force;
  VoidCallback? onReady;
}

class OnFetchStateFailed extends AppActions {
  OnFetchStateFailed();
}

class OnFetchProjectsFailed extends AppActions {}

class OnFetchAlaInstallReleases extends AppActions {
  OnFetchAlaInstallReleases(this.releases);

  List<String> releases;
}

class OnFetchBackendVersion extends AppActions {
  OnFetchBackendVersion(this.version);

  String version;
}

class OnFetchSystemStatus extends AppActions {
  OnFetchSystemStatus(this.dbUpgradeRequired);

  bool dbUpgradeRequired;
}

class OnLAVersionsSwCheckEnd extends AppActions {
  OnLAVersionsSwCheckEnd(this.releases, this.time);

  Map<String, LAReleases> releases;
  DateTime time;
}

class OnFetchAlaInstallReleasesFailed extends AppActions {}

class OnFetchGeneratorReleases extends AppActions {
  OnFetchGeneratorReleases(this.releases);

  List<String> releases;
}

class OnFetchGeneratorReleasesFailed extends AppActions {}

class Loading extends AppActions {}

class CreateProject extends AppActions {
  CreateProject({this.isHub = false, this.parent});

  bool isHub;
  LAProject? parent;
}

class ImportProject extends AppActions {
  ImportProject({required this.yoRcJson});

  String yoRcJson;
}

class AddTemplateProjects extends AppActions {
  AddTemplateProjects({required this.onAdded});

  Function(int) onAdded;
}

class AddProject extends AppActions {
  AddProject(this.project);

  LAProject project;
}

class OnDemoAddProjects extends AppActions {
  OnDemoAddProjects(this.projects);

  List<LAProject> projects;
}

class OnProjectsAdded extends AppActions {
  OnProjectsAdded(this.projectsJson);

  List<dynamic> projectsJson;
}

class DelProject extends AppActions {
  DelProject(this.project);

  LAProject project;
}

class OnProjectDeleted extends AppActions {
  OnProjectDeleted(this.project, this.projectsJson);

  LAProject project;
  List<dynamic> projectsJson;
}

class OnProjectUpdated extends AppActions {
  OnProjectUpdated(
    this.projectId,
    this.projectsJson,
    this.updateCurrentProject,
  );

  String projectId;
  List<dynamic> projectsJson;
  bool updateCurrentProject;
}

class ProjectsLoad extends AppActions {
  ProjectsLoad();
}

class OnProjectsLoad extends AppActions {
  OnProjectsLoad(this.projectsJson, [this.setCurrentProject = true]);

  List<dynamic> projectsJson;
  bool setCurrentProject;
}

class OnDemoProjectsLoad extends AppActions {
  OnDemoProjectsLoad();
}

class OpenProject extends AppActions {
  OpenProject(this.project);

  LAProject project;
}

class OpenServersProject extends AppActions {
  OpenServersProject(this.project);

  LAProject project;
}

class NextStepEditProject extends AppActions {
  NextStepEditProject();
}

class PreviousStepEditProject extends AppActions {
  PreviousStepEditProject();
}

class GotoStepEditProject extends AppActions {
  GotoStepEditProject(this.step);

  int step;
}

class TuneProject extends AppActions {
  TuneProject(this.project);

  LAProject project;
}

class OnPreDeployTasks extends AppActions {
  OnPreDeployTasks(this.project, this.preDeployCmd);

  LAProject project;
  PreDeployCmd preDeployCmd;
}

class OnPostDeployTasks extends AppActions {
  OnPostDeployTasks(this.project, this.postDeployCmd);

  LAProject project;
  PostDeployCmd postDeployCmd;
}

class OnViewLogs extends AppActions {
  OnViewLogs(this.project);

  LAProject project;
}

class PrepareDeployProject extends AppActions {
  PrepareDeployProject({
    required this.project,
    required this.onReady,
    required this.deployCmd,
    required this.onError,
  });

  LAProject project;
  VoidCallback onReady;
  CommonCmd deployCmd;
  Function(String) onError;
}

class SaveCurrentCmd extends AppActions {
  SaveCurrentCmd({required this.cmd});

  CommonCmd cmd;
}

abstract class DeployAction extends AppActions {
  DeployAction({
    required this.project,
    required this.onStart,
    required this.onError,
  });

  LAProject project;
  Function(CmdHistoryEntry cmd, int port, int ttydPid) onStart;
  ErrorCallback onError;
}

class DeployProject extends DeployAction {
  DeployProject({
    required this.cmd,
    required super.project,
    required super.onStart,
    required super.onError,
  });

  DeployCmd cmd;
}

class BrandingDeploy extends DeployAction {
  BrandingDeploy({
    required this.cmd,
    required super.project,
    required super.onStart,
    required super.onError,
  });

  BrandingDeployCmd cmd;
}

class PipelinesRun extends DeployAction {
  PipelinesRun({
    required this.cmd,
    required super.project,
    required super.onStart,
    required super.onError,
  });

  PipelinesCmd cmd;
}

class GetCmdResults extends AppActions {
  GetCmdResults({
    required this.cmdHistoryEntry,
    required this.fstRetrieved,
    required this.onReady,
    required this.onFailed,
  });

  CmdHistoryEntry cmdHistoryEntry;
  VoidCallback onReady;
  VoidCallback onFailed;
  bool fstRetrieved;
}

class ShowCmdResults extends AppActions {
  ShowCmdResults(this.cmdHistoryEntry, this.fstRetrieved, this.results);

  CmdHistoryEntry cmdHistoryEntry;
  CmdHistoryDetails results;
  bool fstRetrieved;
}

class OnShowCmdResultsFailed extends AppActions {}

class OpenProjectTools extends AppActions {
  OpenProjectTools(this.project);

  LAProject project;
}

class UpdateProject extends AppActions {
  UpdateProject(
    this.project, [
    this.updateCurrentProject = true,
    this.openProjectView = true,
  ]);

  LAProject project;
  bool updateCurrentProject;
  bool openProjectView;
}

class GenerateInvProject extends AppActions {
  GenerateInvProject(this.project);

  LAProject project;
}

class EditService extends AppActions {
  EditService(this.service);

  LAService service;
}

class SaveCurrentProject extends AppActions {
  SaveCurrentProject(this.project);

  LAProject project;
}

typedef VoidCallback = void Function();
typedef ErrorCallback = void Function(int error);

class TestConnectivityProject extends AppActions {
  TestConnectivityProject(
    this.project,
    this.onServersStatusReady,
    this.onFailed,
  );

  LAProject project;
  VoidCallback onServersStatusReady;
  VoidCallback onFailed;
}

class TestConnectivitySingleServer extends AppActions {
  TestConnectivitySingleServer(
    this.project,
    this.serverId,
    this.onServersStatusReady,
    this.onFailed,
  );

  LAProject project;
  String serverId;
  VoidCallback onServersStatusReady;
  VoidCallback onFailed;
}

class TestServicesProject extends AppActions {
  TestServicesProject(
    this.project,
    this.hostsServicesChecks,
    this.onResults,
    this.onFailed,
  );

  LAProject project;
  HostsServicesChecks hostsServicesChecks;
  VoidCallback onResults;
  VoidCallback onFailed;
}

class TestServicesSingleServer extends AppActions {
  TestServicesSingleServer(
    this.project,
    this.serverId,
    this.onResults,
    this.onFailed,
  );

  LAProject project;
  String serverId;
  VoidCallback onResults;
  VoidCallback onFailed;
}

class OnTestConnectivityResults extends AppActions {
  OnTestConnectivityResults(this.results);

  Map<String, dynamic> results;
}

class OnPortalRunningVersionsRetrieved extends AppActions {
  OnPortalRunningVersionsRetrieved(this.versions);

  Map<String, String> versions;
}

class OnSshKeysScan extends AppActions {
  OnSshKeysScan(this.onKeysScanned);

  VoidCallback onKeysScanned;
}

class OnSshKeysScanned extends AppActions {
  OnSshKeysScanned(this.keys);

  List<SshKey> keys;
}

class OnAddSshKey extends AppActions {
  OnAddSshKey(this.name);

  String name;
}

class OnImportSshKey extends AppActions {
  OnImportSshKey(this.name, this.publicKey, this.privateKey);

  String name;
  String publicKey;
  String privateKey;
}

class ShowSnackBar extends AppActions {
  ShowSnackBar(this.snackMessage);

  AppSnackBarMessage snackMessage;
}

class OnShowedSnackBar extends AppActions {
  OnShowedSnackBar(this.snackMessage);

  AppSnackBarMessage snackMessage;
}

class DeleteLog extends AppActions {
  DeleteLog(this.cmd);

  CmdHistoryEntry cmd;
}

class OnDeletedLog extends AppActions {
  OnDeletedLog(this.cmd);

  CmdHistoryEntry cmd;
}

class OnAppPackageInfo extends AppActions {
  OnAppPackageInfo(this.packageInfo);

  PackageInfo packageInfo;
}

class OnTestServicesResults extends AppActions {
  OnTestServicesResults(this.results);

  Map<String, dynamic> results;
}

class OnTestServicesProgress extends AppActions {
  OnTestServicesProgress(
    this.serverId,
    this.serverName,
    this.status,
    this.results,
  );

  String serverId;
  String serverName;
  String status;
  List<dynamic>? results;
}

class OnTestServicesComplete extends AppActions {
  OnTestServicesComplete(this.results);

  Map<String, dynamic> results;
}

class OnInitCasKeys extends AppActions {
  OnInitCasKeys();
}

class OnInitCasKeysResults extends AppActions {
  OnInitCasKeysResults({
    required this.pac4jCookieSigningKey,
    required this.pac4jCookieEncryptionKey,
    required this.casWebflowSigningKey,
    required this.casWebflowEncryptionKey,
  });

  String pac4jCookieSigningKey;
  String pac4jCookieEncryptionKey;
  String casWebflowSigningKey;
  String casWebflowEncryptionKey;
}

class OnInitCasOAuthKeys extends AppActions {
  OnInitCasOAuthKeys();
}

class OnInitCasOAuthKeysResults extends AppActions {
  OnInitCasOAuthKeysResults({
    required this.casOauthSigningKey,
    required this.casOauthEncryptionKey,
    required this.casOauthAccessTokenSigningKey,
    required this.casOauthAccessTokenEncryptionKey,
  });

  String casOauthSigningKey;
  String casOauthEncryptionKey;
  String casOauthAccessTokenSigningKey;
  String casOauthAccessTokenEncryptionKey;
}

class OnSelectTuneTab extends AppActions {
  OnSelectTuneTab({required this.currentTab});

  int currentTab;
}

class SolrQuery extends AppActions {
  SolrQuery({
    required this.project,
    required this.solrHost,
    required this.query,
    required this.onError,
    required this.onResult,
  });

  final String project;
  final String solrHost;
  final String query;
  final Function(String) onError;
  Function(Map<String, dynamic>) onResult;
}

class SolrRawQuery extends AppActions {
  SolrRawQuery({
    required this.project,
    required this.solrHost,
    required this.query,
    required this.onError,
    required this.onResult,
  });

  final String project;
  final String solrHost;
  final String query;
  final Function(String) onError;
  Function(dynamic) onResult;
}

class MySqlQuery extends AppActions {
  MySqlQuery({
    required this.project,
    required this.mySqlHost,
    required this.db,
    required this.query,
    required this.onError,
    required this.onResult,
  });

  final String project;
  final String mySqlHost;
  final String db;
  final String query;
  final Function(String) onError;
  Function(dynamic) onResult;
}
