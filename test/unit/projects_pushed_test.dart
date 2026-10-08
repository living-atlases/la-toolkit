import 'package:flutter_test/flutter_test.dart';
import 'package:la_toolkit/models/app_state.dart';
import 'package:la_toolkit/redux/app_actions.dart';
import 'package:la_toolkit/redux/app_reducer.dart';
import 'package:la_toolkit_core/models/cmd.dart';
import 'package:la_toolkit_core/models/cmd_history_details.dart';
import 'package:la_toolkit_core/models/cmd_history_entry.dart';
import 'package:la_toolkit_core/models/la_project.dart';

// A push (another browser, the MCP, a deploy) refreshes the project list
// always, and the open project only when the user is just looking at it.

Map<String, dynamic> json(LAProject p) => p.toJson();

void main() {
  late LAProject portal;
  late LAProject hub;

  setUp(() {
    portal = LAProject(
      longName: 'Portal',
      shortName: 'portal',
      domain: 'p.org',
    );
    hub = LAProject(
      longName: 'Hub',
      shortName: 'hub',
      isHub: true,
      parent: portal,
    );
  });

  List<dynamic> pushedWith({String portalName = 'Portal', String? hubName}) {
    final Map<String, dynamic> p = json(portal)..['longName'] = portalName;
    final Map<String, dynamic> h = json(hub)..['longName'] = hubName ?? 'Hub';
    p['hubs'] = <dynamic>[h];
    return <dynamic>[p];
  }

  AppState reduce(AppState s, List<dynamic> pushed) =>
      appReducer(s, OnProjectsPushed(pushed));

  test('in the project view the open project is replaced', () {
    final AppState s = AppState(
      projects: <LAProject>[portal],
      currentProject: portal,
      status: LAProjectViewStatus.view,
    );
    final AppState next = reduce(s, pushedWith(portalName: 'Changed by MCP'));
    expect(next.currentProject.longName, 'Changed by MCP');
    expect(next.projects.single.longName, 'Changed by MCP');
  });

  test('an open hub is found inside its portal', () {
    final AppState s = AppState(
      projects: <LAProject>[portal],
      currentProject: hub,
      status: LAProjectViewStatus.view,
    );
    final AppState next = reduce(s, pushedWith(hubName: 'Hub renamed'));
    expect(next.currentProject.id, hub.id);
    expect(next.currentProject.longName, 'Hub renamed');
  });

  for (final LAProjectViewStatus status in <LAProjectViewStatus>[
    LAProjectViewStatus.edit,
    LAProjectViewStatus.servers,
    LAProjectViewStatus.tune,
    LAProjectViewStatus.create,
  ]) {
    test('while in ${status.toS()} the open project is kept', () {
      portal.longName = 'Unsaved local edit';
      final AppState s = AppState(
        projects: <LAProject>[portal],
        currentProject: portal,
        status: status,
      );
      final AppState next = reduce(s, pushedWith(portalName: 'Remote'));
      expect(next.currentProject.longName, 'Unsaved local edit');
      expect(next.projects.single.longName, 'Remote');
    });
  }

  test('a project deleted elsewhere does not switch to another one', () {
    final LAProject gone = LAProject(longName: 'Gone', shortName: 'gone');
    final AppState s = AppState(
      projects: <LAProject>[portal, gone],
      currentProject: gone,
      status: LAProjectViewStatus.view,
    );
    final AppState next = reduce(s, pushedWith());
    expect(next.currentProject.id, gone.id);
    expect(next.projects.map((LAProject p) => p.id), <String>[portal.id]);
  });

  test('the results on screen survive a push at the end of a deploy', () {
    final CmdHistoryEntry entry = CmdHistoryEntry(
      logsPrefix: 'portal',
      logsSuffix: 'fast',
      desc: 'Fast deploy',
      rawCmd: 'fast-deploy.sh',
      cmd: Cmd(type: CmdType.fastDeploy, properties: <String, dynamic>{}),
    );
    final CmdHistoryDetails details = CmdHistoryDetails(
      code: 0,
      results: <dynamic>[],
      logs: '',
      logsColorized: '',
    );
    portal
      ..lastCmdEntry = entry
      ..lastCmdDetails = details
      ..runningVersions = <String, String>{'collectory': '5.0.0'};
    // The backend's copy has the command in its history, now finished.
    final Map<String, dynamic> stored = json(portal)
      ..remove('lastCmdEntry') // the backend does not store it
      ..['cmdHistoryEntries'] = <dynamic>[
        (entry.toJson()..['result'] = 'success'),
      ];
    final AppState next = reduce(
      AppState(
        projects: <LAProject>[portal],
        currentProject: portal,
        status: LAProjectViewStatus.view,
      ),
      <dynamic>[stored],
    );
    expect(next.currentProject.lastCmdEntry?.id, entry.id);
    expect(next.currentProject.lastCmdEntry?.result, CmdResult.success);
    expect(next.currentProject.lastCmdDetails, same(details));
    expect(next.currentProject.runningVersions, <String, String>{
      'collectory': '5.0.0',
    });
  });
}
