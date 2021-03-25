import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:la_toolkit/components/appSnackBarMessage.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/sshKey.dart';
import 'package:la_toolkit/utils/api.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'appActions.dart';

class AppStateMiddleware implements MiddlewareClass<AppState> {
  final String key = "laTool20210418";
  SharedPreferences? _pref;

  _initPrefs() async {
    if (_pref == null) _pref = await SharedPreferences.getInstance();
  }

  Future<AppState> getState() async {
    AppState appState;
    bool failedLoad = false;

    String? asS;
    if (AppUtils.isDemo()) {
      await _initPrefs();
      asS = _pref!.getString(key);
    } else {
      asS = await Api.getConf().onError((error, stackTrace) {
        failedLoad = true;
        return "";
      });
    }
    if (asS == null || asS.isEmpty || asS == "{}") {
      appState = initialEmptyAppState(failedLoad: failedLoad);
    } else {
      try {
        Map<String, dynamic> asJ = json.decode(asS);
        // print("Load prefs: $asJ.toString()");
        // appState = AppState.fromJson(asJ);
        appState = AppState.fromJson(asJ);
      } catch (e) {
        print("Failed to decode conf: $e");
        appState = initialEmptyAppState(failedLoad: true);
      }
    }
    return appState;
  }

  AppState initialEmptyAppState({bool failedLoad: false}) {
    print("Load prefs empty (and failed $failedLoad)");
    return AppState(
        failedLoad: failedLoad,
        firstUsage: !failedLoad,
        currentProject: LAProject(),
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
      Uri alaInstallReleasesApiUrl = Uri.https('api.github.com',
          '/repos/AtlasOfLivingAustralia/ala-install/releases');
      Response alaInstallReleasesResponse =
          await http.get(alaInstallReleasesApiUrl);
      if (alaInstallReleasesResponse.statusCode == 200) {
        List<dynamic> l = jsonDecode(alaInstallReleasesResponse.body) as List;
        List<String> alaInstallReleases = [];
        l.forEach((element) => alaInstallReleases.add(element["tag_name"]));
        // Remove the old ones
        int limitResults = 6;
        alaInstallReleases.removeRange(alaInstallReleases.length - limitResults,
            alaInstallReleases.length);
        alaInstallReleases.add('upstream');
        alaInstallReleases.add('custom');
        if (!ListEquality()
            .equals(alaInstallReleases, store.state.alaInstallReleases))
          store.dispatch(OnFetchAlaInstallReleases(alaInstallReleases));
        scanSshKeys(store, () => {});
      } else {
        store.dispatch(OnFetchAlaInstallReleasesFailed());
      }
      if (AppUtils.isDemo()) {
        store.dispatch(OnFetchGeneratorReleases(['1.1.31', '1.1.30']));
      } else {
        // generatorReleasesApiUrl =
        //  "https://registry.npmjs.org/generator-living-atlas";
        // As this does not have CORS enabled we use a proxy
        Uri generatorReleasesApiUrl =
            Uri.http(env['BACKEND']!, "/api/v1/get-generator-versions");
        Response generatorReleasesResponse = await http.get(
          generatorReleasesApiUrl,
          //  headers: {'Accept': 'application/vnd.npm.install-v1+json'},
        );
        if (generatorReleasesResponse.statusCode == 200) {
          Map<String, dynamic> l = json.decode(generatorReleasesResponse.body);
          Map<String, dynamic> versions = l['versions'];
          List<String> generatorReleases = [];
          versions.keys.forEach((key) => generatorReleases.insert(0, key));
          if (!ListEquality()
              .equals(generatorReleases, store.state.generatorReleases))
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
      LAProject project = action.project;
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
      String? currentDirName = action.project.dirName;
      currentDirName ??= action.project.suggestDirName();
      String? checkedDirName = await Api.checkDirName(
          dirName: currentDirName, uuid: action.project.uuid);
      if (checkedDirName == null) {
        store.dispatch(ShowSnackBar(AppSnackBarMessage(
            message:
                "Failed to prepare your configuration (in details, the dirName to store it)")));
      } else {
        if (action.project.dirName != checkedDirName) {
          LAProject updatedProject =
              action.project.copyWith(dirName: checkedDirName);
          store.dispatch(UpdateProject(updatedProject));
        }
        await Api.alaInstallSelect(
                action.project.alaInstallRelease!, action.onError)
            .then((_) => scanSshKeys(store, () => {}));
        await Api.regenerateInv(
            uuid: action.project.uuid, onError: action.onError);
        await Api.generatorSelect(
                action.project.generatorRelease!, action.onError)
            .then((_) => action.onReady());
      }
    }
    if (action is DeployProject) {
      Api.ansiblew(action);
    }
    if (action is GetDeployProjectResults) {
      Api.getAnsiblewResults(
              logsPrefix: action.cmdHistoryEntry.logsPrefix,
              logsSuffix: action.cmdHistoryEntry.logsSuffix)
          .then((results) {
        if (results != null) {
          results.fstRetrieved = action.fstRetrieved;
          results.cmd = action.cmdHistoryEntry;
          store.dispatch(ShowDeployProjectResults(
              action.cmdHistoryEntry, action.fstRetrieved, results));
          action.onReady();
        } else {
          store.dispatch(OnShowDeployProjectResultsFailed());
          action.onFailed();
        }
      });
    }
    next(action);
  }

  void scanSshKeys(store, VoidCallback onKeysScanned) {
    Api.sshKeysScan().then((keys) {
      if (!ListEquality().equals(keys, store.state.sshKeys))
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
      Object toJ = state.toJson();
      // print("Saved prefs: $toJ.toString()");
      _pref!.setString(key, json.encode(toJ));
    } else {
      if (state.failedLoad) {
        print(
            'Not saving configuration because the load of the saved configuration failed');
      } else {
        print("Saving conf in server side");
        print(state);
        Api.saveConf(state);
      }
    }
  }
}
