import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:la_toolkit/components/appSnackBarMessage.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/cmdHistoryDetails.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/postDeployCmd.dart';
import 'package:la_toolkit/models/preDeployCmd.dart';
import 'package:la_toolkit/models/sshKey.dart';
import 'package:la_toolkit/utils/api.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version/version.dart';

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
    await _initPrefs();
    asS = _pref!.getString(key);
    List<dynamic> projects = [];

    if (!AppUtils.isDemo()) {
      // Retrieve projects from the backend
      String stateRetrieved = "{}";
      try {
        stateRetrieved = await Api.getConf();
        Map<String, dynamic> stateRetrievedJ = json.decode(stateRetrieved);
        projects = stateRetrievedJ['projects'];
      } catch (e) {
        failedLoad = true;
      }
    }

    if (asS == null || asS.isEmpty || asS == "{}") {
      appState = initialEmptyAppState(failedLoad: failedLoad);
    } else {
      try {
        Map<String, dynamic> asJ = json.decode(asS);
        // print("Load prefs: $asJ.toString()");
        if (!AppUtils.isDemo()) {
          asJ['projects'] = projects;
        }
        appState = AppState.fromJson(asJ);
        appState.failedLoad = failedLoad;
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
    if (action is OnFetchSoftwareDepsState) {
      // ALA-INSTALL RELEASES
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
        store.dispatch(ShowSnackBar(AppSnackBarMessage.ok(
            "Failed to fetch github ala-install releases. Are you connected to Internet?")));
      }

      // LA-TOOLKIT RELEASES
      Uri laToolkitReleasesApiUrl = Uri.https(
          'api.github.com', '/repos/living-atlases/la-toolkit/releases');
      Response laToolkitReleasesResponse =
          await http.get(laToolkitReleasesApiUrl);
      if (laToolkitReleasesResponse.statusCode == 200) {
        List<dynamic> l = jsonDecode(laToolkitReleasesResponse.body) as List;
        if (l.length > 0) {
          Version lastLAToolkitVersion = Version.parse(
              l.first["tag_name"].toString().replaceFirst('v', ''));
          if (!AppUtils.isDemo()) {
            Version backendVersion =
                Version.parse(await Api.getBackendVersion());
            store.dispatch(OnFetchBackendVersion(backendVersion.toString()));
            if (backendVersion < lastLAToolkitVersion) {
              print("$backendVersion < $lastLAToolkitVersion");
              store.dispatch(ShowSnackBar(AppSnackBarMessage(
                  "There is a new version the LA-Toolkit available. Please upgrade this toolkit.",
                  Duration(seconds: 10),
                  SnackBarAction(
                      label: "MORE INFO",
                      onPressed: () async {
                        await launch(
                            "https://github.com/living-atlases/la-toolkit/#upgrade-the-toolkit");
                      }))));
            }
          }
        }
      } else {
        store.dispatch(ShowSnackBar(AppSnackBarMessage.ok(
            "Failed to fetch github la-toolkit releases")));
      }

      // GENERATOR RELEASES
      if (AppUtils.isDemo()) {
        store
            .dispatch(OnFetchGeneratorReleases(['1.1.37', '1.1.36', '1.1.35']));
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
    if (action is TestServicesProject) {
      Map<String, dynamic> results =
          await Api.checkHostServices(action.hostsServicesChecks);
      store.dispatch(OnTestServicesResults(results));
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
          dirName: currentDirName, id: action.project.id);
      if (checkedDirName == null) {
        store.dispatch(ShowSnackBar(AppSnackBarMessage.ok(
            "Failed to prepare your configuration (in details, the dirName to store it)")));
      } else {
        if (action.project.dirName != checkedDirName) {
          LAProject updatedProject = action.project;
          updatedProject.dirName = checkedDirName;
          store.dispatch(UpdateProject(updatedProject));
        }
        await Api.regenerateInv(id: action.project.id, onError: action.onError);
        if (action.deployCmd.runtimeType != PreDeployCmd &&
            action.deployCmd.runtimeType != PostDeployCmd) {
          await Api.alaInstallSelect(
                  action.project.alaInstallRelease!, action.onError)
              .then((_) => scanSshKeys(store, () => {}));
          await Api.generatorSelect(
                  action.project.generatorRelease!, action.onError)
              .then((_) => action.onReady());
        } else {
          action.onReady();
        }
      }
    }
    if (action is DeployProject) {
      if (action.cmd.runtimeType == PreDeployCmd) {
        Api.preDeploy(action);
      } else if (action.cmd.runtimeType == PostDeployCmd) {
        Api.postDeploy(action);
        // action.onError("This is under development");
      } else
        Api.ansiblew(action);
    }
    if (action is GetDeployProjectResults) {
      CmdHistoryDetails? lastCmdDet = store.state.currentProject.lastCmdDetails;
      if (lastCmdDet != null &&
          lastCmdDet.cmd != null &&
          lastCmdDet.cmd!.id == action.cmdHistoryEntry.id) {
        // Don't load results again we have this already
      } else {
        lastCmdDet = await Api.getAnsiblewResults(
            logsPrefix: action.cmdHistoryEntry.logsPrefix,
            logsSuffix: action.cmdHistoryEntry.logsSuffix);
      }
      if (lastCmdDet != null) {
        lastCmdDet.fstRetrieved = action.fstRetrieved;
        lastCmdDet.cmd = action.cmdHistoryEntry;
        Api.termLogs(
            cmd: action.cmdHistoryEntry,
            onStart: (cmd, port) {
              lastCmdDet!.port = port;
              store.dispatch(ShowDeployProjectResults(
                  action.cmdHistoryEntry, action.fstRetrieved, lastCmdDet));
              action.onReady();
              // TermDialog.show(context);
            },
            onError: (error) {
              store.dispatch(OnShowDeployProjectResultsFailed());
              action.onFailed();
              /* UiUtils.termErrorAlert(context, error); */
            });
      } else {
        store.dispatch(OnShowDeployProjectResultsFailed());
        action.onFailed();
      }
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
    await _initPrefs();
    Object toJ = state.toJson();
    // print("Saved prefs: $toJ.toString()");
    _pref!.setString(key, json.encode(toJ));
    if (!AppUtils.isDemo()) {
      if (state.failedLoad) {
        print(
            'Not saving configuration because the load of the saved configuration failed');
      } else {
        // print("Saving conf in server side");
        // Api.saveConf(state);
      }
    }
  }
}
