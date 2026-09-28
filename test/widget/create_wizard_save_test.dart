import 'package:flutter_test/flutter_test.dart';
import 'package:la_toolkit/models/app_state.dart';
import 'package:la_toolkit/redux/app_actions.dart';
import 'package:la_toolkit_core/models/la_project.dart';
import 'package:redux/redux.dart';

import 'pump_app.dart';

/// The create wizard saves on every keystroke. While the project is still in
/// `create` status it has never been POSTed, so that save must stay in redux:
/// a PATCH would make the backend create the project's services and variables
/// before the project row exists, and the AddProject that finishes the wizard
/// then fails with "Would violate uniqueness constraint" on those ids.
///
/// The API path ends in an OnProjectUpdated, so the recorded actions tell
/// which path the middleware took.
void main() {
  setUp(setUpDemoEnv);

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test('a save while the project is being created does not hit the backend',
      () async {
    final List<dynamic> dispatched = <dynamic>[];
    final Store<AppState> store = demoStore(dispatched: dispatched);
    store.dispatch(CreateProject());
    expect(store.state.status, LAProjectViewStatus.create);
    final LAProject project = store.state.currentProject;
    project.longName = 'Typing...';

    store.dispatch(SaveCurrentProject(project));
    await settle();

    expect(dispatched.whereType<OnProjectUpdated>(), isEmpty,
        reason: 'no API call');
    expect(store.state.appSnackBarMessages, isEmpty);
    expect(store.state.status, LAProjectViewStatus.create);
    expect(store.state.currentProject.longName, 'Typing...',
        reason: 'the edit still lands in redux');
    expect(store.state.loading, isFalse,
        reason: 'nothing is in flight, so nothing to wait for');
  });

  test('a save on a persisted project still goes to the backend', () async {
    final List<dynamic> dispatched = <dynamic>[];
    final Store<AppState> store = demoStore(dispatched: dispatched);
    final LAProject project = LAProject(
      longName: 'Persisted',
      shortName: 'persisted',
      domain: 'persisted.org',
    );
    store.dispatch(OpenProjectTools(project));
    expect(store.state.status, isNot(LAProjectViewStatus.create));

    store.dispatch(SaveCurrentProject(project));
    await settle();

    expect(dispatched.whereType<OnProjectUpdated>(), hasLength(1),
        reason: 'the API path ran');
    expect(store.state.appSnackBarMessages, isEmpty);
  });
}
