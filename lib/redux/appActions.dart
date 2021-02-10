import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/laService.dart';

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

class TestConnectivityProject extends AppActions {
  LAProject project;

  TestConnectivityProject(this.project);
}
