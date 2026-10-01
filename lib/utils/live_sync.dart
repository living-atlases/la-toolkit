import 'dart:developer';

import 'package:beamer/beamer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:la_toolkit_core/models/la_project.dart';
import 'package:redux/redux.dart';
import 'package:sails_io/sails_io.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io_client;

import '../models/app_state.dart';
import '../models/presence_session.dart';
import '../redux/app_actions.dart';
import 'debounce.dart';
import 'utils.dart';

/// The websocket to the backend: project changes pushed by other sessions
/// (`project`), and which other browsers have a project open (`presence`).
class LiveSync {
  LiveSync(this._store, this._router);

  final Store<AppState> _store;
  final BeamerDelegate _router;
  late final SailsIOClient _io;
  String? _announcedProject;
  String? _announcedMode;

  String _url(String path) =>
      "${AppUtils.scheme}://${dotenv.env['BACKEND']}$path";

  void start() {
    _io = SailsIOClient(
      socket_io_client.io(
        _url('?__sails_io_sdk_version=0.11.0'),
        socket_io_client.OptionBuilder().setTransports(<String>[
          'websocket',
        ]).build(),
      ),
    );

    // On every (re)connect: a socket loses its rooms when it drops (a
    // backend restart), and would stop hearing about changes.
    _io.socket.onConnect((_) {
      _io.get(
        url: _url('/api/v1/projects-subs'),
        cb: (dynamic body, JWR jwrResponse) {},
      );
      _announcedProject = null;
      _announcedMode = null;
      _announce(_store.state);
    });

    _io.socket.onError((dynamic e) {
      log('sails websocket: Error connecting to backend');
      log(e.toString());
    });

    // https://sailsjs.com/documentation/reference/web-sockets/socket-client/io-socket-on
    final Debouncer debouncer = Debouncer(milliseconds: 1000);
    _io.socket.on('project', (dynamic projects) {
      debouncer.run(() {
        if (kDebugMode) {
          log('sails websocket: projects subs call');
        }
        _store.dispatch(OnProjectsPushed(projects as List<dynamic>));
      });
    });

    _io.socket.on('presence', (dynamic sessions) {
      final String? me = _io.socket.id;
      _store.dispatch(
        OnPresence(
          (sessions as List<dynamic>)
              .map(
                (dynamic s) =>
                    PresenceSession.fromJson(s as Map<String, dynamic>),
              )
              .where((PresenceSession s) => s.id != me)
              .toList(),
        ),
      );
    });

    _store.onChange.listen(_announce);
    _router.addListener(_onRoute);
    _onRoute();
  }

  void _onRoute() {
    final LAProjectViewStatus? editing = editingStatusOf(modeOf(_path()));
    if (editing != null && _store.state.status == LAProjectViewStatus.view) {
      _store.dispatch(OnEditingRoute(editing));
    }
    _announce(_store.state);
  }

  /// The app status of an editing page, `null` for the others.
  static LAProjectViewStatus? editingStatusOf(String? mode) {
    switch (mode) {
      case 'edit':
        return LAProjectViewStatus.edit;
      case 'servers':
        return LAProjectViewStatus.servers;
      case 'tune':
        return LAProjectViewStatus.tune;
      default:
        return null;
    }
  }

  /// What a page means for others: `null` outside a project.
  static String? modeOf(String path) {
    switch (path) {
      case '/':
      case '':
        return null;
      case '/project':
        return 'edit';
      case '/servers':
        return 'servers';
      case '/tune':
        return 'tune';
      case '/deploy':
      case '/predeploy':
      case '/postdeploy':
      case '/branding-deploy':
      case '/pipelines':
        return 'deploy';
      default:
        return 'view';
    }
  }

  // Whether the open project is one the backend has (not a project being
  // created): isCreated is recomputed by validation and says otherwise for
  // some stored projects.
  static bool _stored(AppState state) {
    final String id = state.currentProject.id;
    return state.projects.any(
      (LAProject p) => p.id == id || p.hubs.any((LAProject h) => h.id == id),
    );
  }

  // `configuration`, not `currentConfiguration`: that one is null until the
  // router reports its first route, and reading it has side effects.
  String _path() {
    try {
      return _router.configuration.uri.path;
    } catch (_) {
      return '/';
    }
  }

  // Tells the backend which project this browser has open, and on which
  // page, whenever that changes.
  void _announce(AppState state) {
    if (_io.socket.disconnected) {
      return;
    }
    final String? mode = modeOf(_path());
    final String? projectId = mode != null && _stored(state)
        ? state.currentProject.id
        : null;
    if (projectId == _announcedProject && mode == _announcedMode) {
      return;
    }
    _announcedProject = projectId;
    _announcedMode = mode;
    _io.post(
      url: _url('/api/v1/presence'),
      data: <String, dynamic>{'projectId': projectId, 'mode': mode},
      cb: (dynamic body, JWR jwrResponse) {},
    );
  }
}
