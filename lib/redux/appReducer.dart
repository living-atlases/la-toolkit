import 'package:la_toolkit/models/laProject.dart';
import 'package:redux/redux.dart';

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
  new TypedReducer<AppState, CreateProject>(_createProject),
  new TypedReducer<AppState, AddProject>(_addProject),
  new TypedReducer<AppState, OpenProject>(_openProject),
  new TypedReducer<AppState, OpenProjectTools>(_openProjectTools),
  new TypedReducer<AppState, EditService>(_editService),
  new TypedReducer<AppState, SaveCurrentProject>(_saveCurrentProject),
  new TypedReducer<AppState, DelProject>(_delProject),
  new TypedReducer<AppState, UpdateProject>(_updateProject),
]);

AppState _onIntroEnd(AppState state, OnIntroEnd action) {
  return state.copyWith(firstUsage: false);
}

AppState _onFetchState(AppState state, OnFetchState action) {
  return action.state;
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

AppState _createProject(AppState state, CreateProject action) {
  return state.copyWith(
      currentProject: new LAProject(),
      status: LAProjectViewStatus.create,
      currentStep: 0);
}

AppState _openProject(AppState state, OpenProject action) {
  return state.copyWith(
      currentProject: action.project,
      status: LAProjectViewStatus.edit,
      currentStep: 0);
}

AppState _openProjectTools(AppState state, OpenProjectTools action) {
  return state.copyWith(
      currentProject: action.project, status: LAProjectViewStatus.view);
}

AppState _saveCurrentProject(AppState state, SaveCurrentProject action) {
  return state.copyWith(
      currentProject: action.project, currentStep: action.currentStep);
}

AppState _addProject(AppState state, AddProject action) {
  state.projects.forEach((project) {
    if (project.uuid == action.project.uuid)
      throw ("Trying to add an existing project.");
    return state;
  });
  return state.copyWith(
      projects: new List<LAProject>.from(state.projects)..add(action.project));
}

AppState _delProject(AppState state, DelProject action) {
  return state.copyWith(
      projects: new List<LAProject>.from(state.projects)
        ..removeWhere((item) => item.uuid == state.currentProject.uuid));
}

AppState _updateProject(AppState state, UpdateProject action) {
  return state.copyWith(
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
