import 'package:flutter_test/flutter_test.dart';
import 'package:la_toolkit/components/app_snack_bar_message.dart';
import 'package:la_toolkit/models/app_state.dart';
import 'package:la_toolkit/models/la_project.dart';
import 'package:la_toolkit/redux/app_actions.dart';
import 'package:redux/redux.dart';

import 'pump_app.dart';

/// The create wizard saves on every keystroke. While the project is still in
/// `create` status it has never been POSTed, so that save must stay in redux:
/// a PATCH would make the backend create the project's services and variables
/// before the project row exists, and the AddProject that finishes the wizard
/// then fails with "Would violate uniqueness constraint" on those ids.
///
/// In demo mode Api.updateProject throws (it casts a Map to a List), and the
/// middleware turns that into a "Failed to update project" snackbar: the
/// snackbar is therefore the proof that the API path ran.
void main() {
  setUp(setUpDemoEnv);

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test('a save while the project is being created does not hit the backend',
      () async {
    final Store<AppState> store = demoStore();
    store.dispatch(CreateProject());
    expect(store.state.status, LAProjectViewStatus.create);
    final LAProject project = store.state.currentProject;
    project.longName = 'Typing...';

    store.dispatch(SaveCurrentProject(project));
    await settle();

    expect(store.state.appSnackBarMessages, isEmpty,
        reason: 'no API call, so no failure snackbar');
    expect(store.state.status, LAProjectViewStatus.create);
    expect(store.state.currentProject.longName, 'Typing...',
        reason: 'the edit still lands in redux');
    expect(store.state.loading, isFalse,
        reason: 'nothing is in flight, so nothing to wait for');
  });

  test('a save on a persisted project still goes to the backend', () async {
    final Store<AppState> store = demoStore();
    final LAProject project = LAProject(
      longName: 'Persisted',
      shortName: 'persisted',
      domain: 'persisted.org',
    );
    store.dispatch(OpenProjectTools(project));
    expect(store.state.status, isNot(LAProjectViewStatus.create));

    store.dispatch(SaveCurrentProject(project));
    await settle();

    expect(
      store.state.appSnackBarMessages.map((AppSnackBarMessage m) => m.message),
      contains(startsWith('Failed to update project')),
      reason: 'demo-mode proxy for "the API path ran"',
    );
  });
}
