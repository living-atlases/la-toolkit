import 'package:la_toolkit/models/laProject.dart';
import 'package:redux/redux.dart';

import '../models/appState.dart';
import 'actions.dart';

final appReducer = combineReducers<AppState>([
  new TypedReducer<AppState, OnIntroEnd>(_onIntroEnd),
  new TypedReducer<AppState, OnFetchState>(_onFetchState),
  new TypedReducer<AppState, AddProject>(_addProject),
  new TypedReducer<AppState, EditService>(_editService),
  new TypedReducer<AppState, SaveCurrentProject>(_saveCurrentProject),
  new TypedReducer<AppState, DelProject>(_delProject),
  new TypedReducer<AppState, EditProject>(_editProject),
]);

AppState _onIntroEnd(AppState state, OnIntroEnd action) {
  return state.copyWith(firstUsage: false);
}

AppState _onFetchState(AppState state, OnFetchState action) {
  return action.state;
}

AppState _addProject(AppState state, AddProject action) {
  return state.copyWith(
      currentProject: LAProject.def,
      status: LAProjectStatus.create,
      currentStep: 0);
}

AppState _saveCurrentProject(AppState state, SaveCurrentProject action) {
  return state.copyWith(
      currentProject: action.project,
      status: LAProjectStatus.create,
      currentStep: action.currentStep);
}

AppState _delProject(AppState state, DelProject action) {
  return state.copyWith(
      projects: new List<LAProject>.from(state.projects)
        ..removeWhere((item) => item.uuid == action.uuid));
}

AppState _editProject(AppState state, EditProject action) {
  // Rewritte this
  return state.copyWith(
      projects: state.projects
          .map((project) =>
              project.uuid == action.project.uuid ? action.project : project)
          .toList());
}

AppState _editService(AppState state, EditService action) {
  LAProject currentProject = state.currentProject;
  currentProject.services[action.service.name] = action.service;
  return state.copyWith(currentProject: currentProject);
}
