import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/sshKey.dart';
import 'package:la_toolkit/utils/api.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'appActions.dart';

class AppStateMiddleware implements MiddlewareClass<AppState> {
  final String key = "laTool20210116";
  SharedPreferences _pref;

  _initPrefs() async {
    if (_pref == null) _pref = await SharedPreferences.getInstance();
  }

  Future<AppState> getState() async {
    AppState appState;

    String asS;
    if (AppUtils.isDemo()) {
      await _initPrefs();
      asS = _pref.getString(key);
    } else {
      asS = await Api.getConf();
    }
    if (asS == null || asS.isEmpty || asS == "{}") {
      appState = initialEmptyAppState();
    } else {
      try {
        Map<String, dynamic> asJ = json.decode(asS);
        // print("Load prefs: $asJ.toString()");
        // appState = AppState.fromJson(asJ);
        appState = AppState.fromJson(asJ);
      } catch (e) {
        print(e);
        appState = initialEmptyAppState();
      }
    }

    return appState;
  }

  AppState initialEmptyAppState() {
    print("Load prefs empty");
    return AppState(
        projects: List<LAProject>.empty(),
        sshKeys: List<SshKey>.empty(),
        currentStep: 0);
  }

  @override
  call(Store<AppState> store, action, next) async {
    if (action is OnFetchState) {
      /* if (!AppUtils.isDev() ||
          store.state.alaInstallReleases == null ||
          store.state.alaInstallReleases.length == 0) { */
      var alaInstallReleasesApiUrl =
          'https://api.github.com/repos/AtlasOfLivingAustralia/ala-install/releases';
      var alaInstallReleasesResponse = await http.get(alaInstallReleasesApiUrl);
      if (alaInstallReleasesResponse.statusCode == 200) {
        var l = jsonDecode(alaInstallReleasesResponse.body) as List;
        List<String> alaInstallReleases = [];
        l.forEach((element) => alaInstallReleases.add(element["tag_name"]));
        // Remove the old ones
        num limitResults = 6;
        alaInstallReleases.removeRange(alaInstallReleases.length - limitResults,
            alaInstallReleases.length);
        alaInstallReleases.add('upstream');
        alaInstallReleases.add('custom');
        store.dispatch(OnFetchAlaInstallReleases(alaInstallReleases));
        scanSshKeys(store, () => {});
      } else {
        store.dispatch(OnFetchAlaInstallReleasesFailed());
      }
      if (AppUtils.isDemo()) {
        store.dispatch(OnFetchGeneratorReleases(['1.1.31', '1.1.30']));
      } else {
        var generatorReleasesApiUrl =
            "https://registry.npmjs.org/generator-living-atlas";
        // As this does not have CORS enabled we use a proxy
        generatorReleasesApiUrl =
            "${env['BACKEND']}api/v1/get-generator-versions";
        var generatorReleasesResponse = await http.get(
          generatorReleasesApiUrl,
          //  headers: {'Accept': 'application/vnd.npm.install-v1+json'},
        );
        if (generatorReleasesResponse.statusCode == 200) {
          Map<String, dynamic> l = json.decode(generatorReleasesResponse.body);
          Map<String, dynamic> versions = l['versions'];
          List<String> generatorReleases = [];
          versions.keys.forEach((key) => generatorReleases.insert(0, key));
          store.dispatch(OnFetchGeneratorReleases(generatorReleases));
        } else {
          store.dispatch(OnFetchGeneratorReleasesFailed());
        }
      }
    }
    if (action is AddProject) {
      genSshConf(action.project);
    }
    if (action is UpdateProject) {
      genSshConf(action.project);
    }
    if (action is TestConnectivityProject) {
      var project = action.project;
      genSshConf(project);
      Api.testConnectivity(project.serversWithServices()).then((results) {
        store.dispatch(OnTestConnectivityResults(results));
        action.onServersStatusReady();
      });
    }
    if (action is OnSshKeysScan) {
      scanSshKeys(store, action.onKeysScanned);
    }
    if (action is OnAddSshKey) {
      Api.genSshKey(action.name).then((_) => scanSshKeys(store, () => {}));
    }
    if (action is OnImportSshKey) {
      Api.importSshKey(action.name, action.publicKey, action.privateKey)
          .then((_) => scanSshKeys(store, () => {}));
    }
    if (action is PrepareDeployProject) {
      await Api.alaInstallSelect(
              action.project.alaInstallRelease, action.onError)
          .then((_) => scanSshKeys(store, () => {}));
      await Api.regenerateInv(
          uuid: action.project.uuid, onError: action.onError);
      await Api.generatorSelect(action.project.generatorRelease, action.onError)
          .then((_) => action.onReady());
    }
    if (action is DeployProject) {
      Api.ansiblew(action);
    }
    if (action is GetDeployProjectResults) {
      Api.getAnsiblewResults(action.logsSuffix).then((results) {
        store.dispatch(ShowDeployProjectResults(results));
      });
    }
    next(action);
  }

  void scanSshKeys(store, VoidCallback onKeysScanned) {
    Api.sshKeysScan().then((keys) {
      store.dispatch(OnSshKeysScanned(keys));
      onKeysScanned();
    });
  }

  genSshConf(LAProject project) {
    if (project.isCreated) {
      Api.genSshConf(project);
    }
  }

  saveAppState(AppState state) async {
    if (AppUtils.isDemo()) {
      await _initPrefs();
      var toJ = state.toJson();
      // print("Saved prefs: $toJ.toString()");
      _pref.setString(key, json.encode(toJ));
    } else {
      Api.saveConf(state);
    }
  }
}
