import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';

abstract class AppActions {}

class FetchProjects extends AppActions {}

class OnIntroEnd extends AppActions {}

class OnFetchState extends AppActions {
  AppState state;

  OnFetchState(this.state);
}

class OnFetchProjectsFailed extends AppActions {}

class AddProject extends AppActions {
  AddProject();
}

class DelProject extends AppActions {
  String uuid;

  DelProject(this.uuid);
}

class EditProject extends AppActions {
  LAProject project;

  EditProject(this.project);
}

class SaveCurrentProject extends AppActions {
  LAProject project;
  int currentStep;

  SaveCurrentProject(this.project, this.currentStep);
}
