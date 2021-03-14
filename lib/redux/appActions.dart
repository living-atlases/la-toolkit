import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/laService.dart';
import 'package:la_toolkit/models/sshKey.dart';

abstract class AppActions {}

class FetchState extends AppActions {}

class OnIntroEnd extends AppActions {}

class OnFetchState extends AppActions {
  OnFetchState();
}

class OnFetchStateFailed extends AppActions {
  OnFetchStateFailed();
}

class OnFetchProjectsFailed extends AppActions {}

class OnFetchAlaInstallReleases extends AppActions {
  List<String> releases;

  OnFetchAlaInstallReleases(this.releases);
}

class OnFetchAlaInstallReleasesFailed extends AppActions {}

class OnFetchGeneratorReleases extends AppActions {
  List<String> releases;

  OnFetchGeneratorReleases(this.releases);
}

class OnFetchGeneratorReleasesFailed extends AppActions {}

class CreateProject extends AppActions {
  CreateProject();
}

class AddProject extends AppActions {
  LAProject project;

  AddProject(this.project);
}

class DelProject extends AppActions {
  LAProject project;

  DelProject(this.project);
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

class PrepareDeployProject extends AppActions {
  LAProject project;
  VoidCallback onReady;
  Function(String) onError;
  PrepareDeployProject({this.project, this.onReady, this.onError});
}

class DeployProject extends AppActions {
  LAProject project;
  List<String> deployServices;
  List<String> limitToServers;
  List<String> skipTags;
  List<String> tags;
  bool onlyProperties;
  bool continueEvenIfFails;
  bool debug;
  bool dryRun;
  Function(String) onStart;
  ErrorCallback onError;

  DeployProject(
      {this.project,
      this.deployServices,
      this.limitToServers,
      this.tags,
      this.skipTags,
      this.onlyProperties,
      this.continueEvenIfFails,
      this.debug,
      this.dryRun,
      this.onStart,
      this.onError});
}

class GetDeployProjectResults extends AppActions {
  String logsSuffix;

  GetDeployProjectResults(this.logsSuffix);
}

class ShowDeployProjectResults extends AppActions {
  List<dynamic> results;

  ShowDeployProjectResults(this.results);
}

class OpenProjectTools extends AppActions {
  LAProject project;

  OpenProjectTools(this.project);
}

class UpdateProject extends AppActions {
  LAProject project;

  UpdateProject(this.project);
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

  SaveCurrentProject([this.project]);
}

typedef void VoidCallback();
typedef void ErrorCallback(error);

class TestConnectivityProject extends AppActions {
  LAProject project;
  VoidCallback onServersStatusReady;

  TestConnectivityProject(this.project, this.onServersStatusReady);
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
