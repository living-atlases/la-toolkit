import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/laService.dart';
import 'package:la_toolkit/models/sshKey.dart';

abstract class AppActions {}

class FetchProjects extends AppActions {}

class OnIntroEnd extends AppActions {}

class OnFetchState extends AppActions {
  AppState state;

  OnFetchState(this.state);
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

class TuneProject extends AppActions {
  LAProject project;

  TuneProject(this.project);
}

class PrepareDeployProject extends AppActions {
  LAProject project;

  PrepareDeployProject(this.project);
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
  DeployProject(
      {this.project,
      this.deployServices,
      this.limitToServers,
      this.tags,
      this.skipTags,
      this.onlyProperties,
      this.continueEvenIfFails,
      this.debug,
      this.dryRun});
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
  int currentStep;

  SaveCurrentProject([this.project, this.currentStep]);
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
