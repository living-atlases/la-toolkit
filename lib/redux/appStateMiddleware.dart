import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/sshKey.dart';
import 'package:la_toolkit/utils/api.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'appActions.dart';

class AppStateMiddleware implements MiddlewareClass<AppState> {
  final String key = "laTool20210116";
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
      appState = AppState(
          projects: List<LAProject>.empty(), sshKeys: List<SshKey>.empty());
    } else {
      var asJ = json.decode(asS);
      // print("Load prefs: $asJ.toString()");
      appState = AppState.fromJson(asJ);
    }
    // print("Load prefs: $appState");
    return appState;
  }

  @override
  call(Store<AppState> store, action, next) async {
    if (action is FetchProjects) {
      var state = await _load();
      // print("Loaded prefs: $state");
      store.dispatch(OnFetchState(state));

      /* if (!AppUtils.isDev() ||
          store.state.alaInstallReleases == null ||
          store.state.alaInstallReleases.length == 0) { */
      var url =
          'https://api.github.com/repos/AtlasOfLivingAustralia/ala-install/releases';
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var l = jsonDecode(response.body) as List;
        List<String> alaInstallReleases = [];
        l.forEach((element) => alaInstallReleases.add(element["tag_name"]));
        // Remove the old ones
        alaInstallReleases.removeRange(
            alaInstallReleases.length - 6, alaInstallReleases.length);
        alaInstallReleases.add('upstream');
        store.dispatch(OnFetchAlaInstallReleases(alaInstallReleases));
        Api.sshKeysScan()
            .then((keys) => store.dispatch(OnSshKeysScanned(keys)));
      } else {
        store.dispatch(OnFetchAlaInstallReleasesFailed());
      }
      // }
    }
    if (action is AddProject) {
      getSshConf(action.project);
    }
    if (action is UpdateProject) {
      getSshConf(action.project);
    }
    if (action is TestConnectivityProject) {
      getSshConf(action.project);
    }

    next(action);
  }

  getSshConf(LAProject project) {
    if (project.isCreated) {
      Api.genSshConf(project);
    }
  }

  saveAppState(AppState state) async {
    await _initPrefs();
    var toJ = state.toJson();
    // print("Saved prefs: $toJ.toString()");
    _pref.setString(key, json.encode(toJ));
  }
}
