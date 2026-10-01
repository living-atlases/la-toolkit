import 'package:flutter_test/flutter_test.dart';
import 'package:la_toolkit/models/app_state.dart';
import 'package:la_toolkit/redux/app_actions.dart';
import 'package:la_toolkit/redux/app_reducer.dart';
import 'package:la_toolkit/utils/live_sync.dart';
import 'package:la_toolkit_core/models/la_project.dart';

// What each page tells other browsers, and the status a browser reloaded on
// an editing page takes so pushes do not replace what is typed there.

void main() {
  test('pages and what they announce', () {
    expect(LiveSync.modeOf('/'), isNull);
    expect(LiveSync.modeOf('/project'), 'edit');
    expect(LiveSync.modeOf('/servers'), 'servers');
    expect(LiveSync.modeOf('/tune'), 'tune');
    expect(LiveSync.modeOf('/deploy'), 'deploy');
    expect(LiveSync.modeOf('/dashboard'), 'view');
  });

  test('only edit, servers and tune are editing pages', () {
    expect(LiveSync.editingStatusOf('tune'), LAProjectViewStatus.tune);
    expect(LiveSync.editingStatusOf('servers'), LAProjectViewStatus.servers);
    expect(LiveSync.editingStatusOf('edit'), LAProjectViewStatus.edit);
    expect(LiveSync.editingStatusOf('deploy'), isNull);
    expect(LiveSync.editingStatusOf('view'), isNull);
    expect(LiveSync.editingStatusOf(null), isNull);
  });

  AppState withStatus(LAProjectViewStatus s) => AppState(
    projects: <LAProject>[],
    currentProject: LAProject(longName: 'P', shortName: 'p', domain: 'p.org'),
    status: s,
  );

  test('a reload on the tune page leaves view', () {
    final AppState next = appReducer(
      withStatus(LAProjectViewStatus.view),
      OnEditingRoute(LAProjectViewStatus.tune),
    );
    expect(next.status, LAProjectViewStatus.tune);
  });

  test('a project being created stays in create', () {
    final AppState next = appReducer(
      withStatus(LAProjectViewStatus.create),
      OnEditingRoute(LAProjectViewStatus.edit),
    );
    expect(next.status, LAProjectViewStatus.create);
  });
}
