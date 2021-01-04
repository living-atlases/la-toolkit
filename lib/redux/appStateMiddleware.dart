import 'dart:convert';

import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'appActions.dart';

class AppStateMiddleware implements MiddlewareClass<AppState> {
  final String key = "laTool1";
  SharedPreferences _pref;

  _initPrefs() async {
    if (_pref == null) _pref = await SharedPreferences.getInstance();
  }

  Future<AppState> _load() async {
    AppState appState;
    await _initPrefs();
    var asS = _pref.getString(key);
    if (asS == null) {
      print("Load prefs empty");
      appState = AppState(projects: List<LAProject>.empty());
    } else {
      var asJ = json.decode(asS);
      print("Load prefs: $asJ.toString()");
      appState = AppState.fromJson(asJ);
    }
    print("Load prefs: $appState");
    return appState;
  }

  @override
  call(Store<AppState> store, action, next) async {
    if (action is FetchProjects) {
      var state = await _load();
      print("Loaded prefs: $state");
      store.dispatch(OnFetchState(state));
    }
    next(action);
  }

  saveAppState(AppState state) async {
    await _initPrefs();
    var toJ = state.toJson();
    print("Saved prefs: $toJ.toString()");
    _pref.setString(key, json.encode(toJ));
  }
}
