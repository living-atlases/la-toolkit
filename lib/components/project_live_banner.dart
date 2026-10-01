import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../models/app_state.dart';
import '../models/presence_session.dart';
import '../redux/app_actions.dart';

/// Above a project page: says when the project changed in another session
/// (a browser, the MCP) while this one had it open, when a save was refused
/// because both changed the same settings, and which other browsers have it
/// open. Reload takes the stored copy and drops what was not saved here.
class ProjectLiveBanner extends StatelessWidget {
  const ProjectLiveBanner({super.key});

  /// [child] with the banner on top of it.
  static Widget wrap(Widget child) => Column(
    children: <Widget>[
      const ProjectLiveBanner(),
      Expanded(child: child),
    ],
  );

  static String describeMode(String mode) {
    switch (mode) {
      case 'edit':
        return 'editing it';
      case 'servers':
        return 'editing its servers';
      case 'tune':
        return 'tuning it';
      case 'deploy':
        return 'deploying it';
      default:
        return 'viewing it';
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      distinct: true,
      converter: (Store<AppState> store) => _ViewModel(
        changedElsewhere: store.state.projectChangedElsewhere,
        conflicts: store.state.projectConflicts,
        others: store.state.presence
            .where(
              (PresenceSession s) =>
                  s.projectId == store.state.currentProject.id,
            )
            .toList(),
        onReload: () => store.dispatch(ReloadCurrentProject()),
      ),
      builder: (BuildContext context, _ViewModel vm) {
        final List<Widget> rows = <Widget>[];
        if (vm.changedElsewhere || vm.conflicts.isNotEmpty) {
          rows.add(
            MaterialBanner(
              key: const ValueKey<String>('project-changed-elsewhere'),
              backgroundColor: Colors.amber.shade100,
              leading: const Icon(Icons.sync_problem),
              content: Text(
                vm.conflicts.isNotEmpty
                    ? 'Not saved: another session changed the same settings '
                          '(${vm.conflicts.length}). Reload to see them; what '
                          'you changed here and did not save is lost.'
                    : 'This project was changed in another session. Your '
                          'saves keep those changes; reload to see them.',
              ),
              actions: <Widget>[
                TextButton(onPressed: vm.onReload, child: const Text('RELOAD')),
              ],
            ),
          );
        }
        if (vm.others.isNotEmpty) {
          final Set<String> modes = vm.others
              .map((PresenceSession s) => describeMode(s.mode))
              .toSet();
          rows.add(
            Container(
              key: const ValueKey<String>('project-presence'),
              width: double.infinity,
              color: Colors.blueGrey.shade50,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.people_outline, size: 18),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      vm.others.length == 1
                          ? 'Also open in another browser, ${modes.join(', ')}.'
                          : 'Also open in ${vm.others.length} other browsers: '
                                '${modes.join(', ')}.',
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return Column(mainAxisSize: MainAxisSize.min, children: rows);
      },
    );
  }
}

@immutable
class _ViewModel {
  const _ViewModel({
    required this.changedElsewhere,
    required this.conflicts,
    required this.others,
    required this.onReload,
  });

  final bool changedElsewhere;
  final List<String> conflicts;
  final List<PresenceSession> others;
  final VoidCallback onReload;

  @override
  bool operator ==(Object other) =>
      other is _ViewModel &&
      other.changedElsewhere == changedElsewhere &&
      _listEq(other.conflicts, conflicts) &&
      _listEq(other.others, others);

  static bool _listEq<T>(List<T> a, List<T> b) {
    if (a.length != b.length) {
      return false;
    }
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    changedElsewhere,
    Object.hashAll(conflicts),
    Object.hashAll(others),
  );
}
