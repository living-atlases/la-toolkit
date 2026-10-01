import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_toolkit/components/project_live_banner.dart';
import 'package:la_toolkit/models/app_state.dart';
import 'package:la_toolkit/models/presence_session.dart';
import 'package:la_toolkit/redux/app_actions.dart';
import 'package:la_toolkit/redux/app_reducer.dart';
import 'package:la_toolkit_core/models/la_project.dart';
import 'package:redux/redux.dart';

// The banner above the project pages: changed elsewhere, refused saves,
// other browsers, and Reload taking the stored copy.

void main() {
  late LAProject stored;
  late LAProject local;

  setUpAll(() => dotenv.testLoad(fileInput: 'DEMO=false'));

  setUp(() {
    stored = LAProject(longName: 'Stored', shortName: 's', domain: 's.org');
    local = LAProject.fromJson(stored.toJson())..longName = 'Typed here';
  });

  Future<Store<AppState>> pump(WidgetTester tester, AppState state) async {
    final Store<AppState> store = Store<AppState>(
      appReducer,
      initialState: state,
    );
    await tester.pumpWidget(
      StoreProvider<AppState>(
        store: store,
        child: MaterialApp(
          home: Scaffold(body: ProjectLiveBanner.wrap(const Text('page'))),
        ),
      ),
    );
    return store;
  }

  AppState editing({
    bool changed = false,
    List<String>? conflicts,
    List<PresenceSession>? presence,
  }) => AppState(
    projects: <LAProject>[stored],
    currentProject: local,
    status: LAProjectViewStatus.tune,
    projectChangedElsewhere: changed,
    projectConflicts: conflicts,
    presence: presence,
  );

  testWidgets('nothing to say: only the page', (WidgetTester tester) async {
    await pump(tester, editing());
    expect(find.text('page'), findsOneWidget);
    expect(find.text('RELOAD'), findsNothing);
    expect(find.byIcon(Icons.people_outline), findsNothing);
  });

  testWidgets('changed elsewhere: Reload takes the stored copy', (
    WidgetTester tester,
  ) async {
    final Store<AppState> store = await pump(tester, editing(changed: true));
    expect(find.textContaining('changed in another session'), findsOneWidget);
    await tester.tap(find.text('RELOAD'));
    await tester.pump();
    expect(store.state.currentProject.longName, 'Stored');
    expect(store.state.projectChangedElsewhere, isFalse);
    expect(find.text('RELOAD'), findsNothing);
  });

  testWidgets('a refused save says so', (WidgetTester tester) async {
    await pump(tester, editing(conflicts: <String>['project.longName']));
    expect(find.textContaining('Not saved'), findsOneWidget);
  });

  testWidgets('other browsers on this project, not on others', (
    WidgetTester tester,
  ) async {
    await pump(
      tester,
      editing(
        presence: <PresenceSession>[
          PresenceSession(id: 'a', projectId: local.id, mode: 'servers'),
          const PresenceSession(id: 'b', projectId: 'other', mode: 'edit'),
        ],
      ),
    );
    expect(
      find.text('Also open in another browser, editing its servers.'),
      findsOneWidget,
    );
  });

  test('a save that went through clears the banner', () {
    final AppState s = editing(changed: true, conflicts: <String>['x']);
    final AppState next = appReducer(
      s,
      OnProjectUpdated(local.id, <dynamic>[stored.toJson()], true),
    );
    expect(next.projectChangedElsewhere, isFalse);
    expect(next.projectConflicts, isEmpty);
    expect(next.currentProject.longName, 'Stored');
  });

  test('a refused save keeps what was typed and raises the banner', () {
    final AppState next = appReducer(
      editing(),
      OnProjectConflict(
        local.id,
        <String>['project.longName'],
        <dynamic>[stored.toJson()],
      ),
    );
    expect(next.currentProject.longName, 'Typed here');
    expect(next.projectChangedElsewhere, isTrue);
    expect(next.projectConflicts, <String>['project.longName']);
    expect(next.loading, isFalse);
  });
}
