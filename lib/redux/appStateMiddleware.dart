import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:la_toolkit/components/appSnackBarMessage.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/cmdHistoryDetails.dart';
import 'package:la_toolkit/models/cmdHistoryEntry.dart';
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
import 'entityActions.dart';
import 'entityApis.dart';

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

    if (asS == null || asS.isEmpty || asS == "{}") {
      appState = initialEmptyAppState(failedLoad: failedLoad);
    } else {
      try {
        Map<String, dynamic> asJ = json.decode(asS);
        appState = AppState.fromJson(asJ);
      } catch (e) {
        print("Failed to decode conf: $e");
        appState = initialEmptyAppState(failedLoad: true);
      }
    }
    return appState.copyWith(loading: true);
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
                  Duration(seconds: 5),
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
      try {
        action.project.dirName = action.project.suggestDirName();
        List<dynamic> projects = await Api.addProject(project: action.project);
        store.dispatch(OnProjectsAdded(projects));
        await genSshConf(action.project);
      } catch (e) {
        store.dispatch(
            ShowSnackBar(AppSnackBarMessage.ok("Failed to save project ($e)")));
      }
    }
    if (action is AddTemplateProjects) {
      List<LAProject> projects = await LAProject.importTemplates(
          AssetsUtils.pathWorkaround('la-toolkit-templates.json'));
      try {
        if (!AppUtils.isDemo()) {
          List<dynamic> projectsAdded =
              await Api.addProjects(projects.reversed.toList());
          store.dispatch(OnProjectsAdded(projectsAdded));
          action.onAdded(projectsAdded.length);
        } else {
          // We just add to the store
          store.dispatch(OnDemoAddProjects(projects));
          action.onAdded(projects.length);
        }
        // store.dispatch(OnProjectAdded(projects));
      } catch (e) {
        store.dispatch(
            ShowSnackBar(AppSnackBarMessage.ok("Failed to add projects ($e)")));
      }
    }
    if (action is DelProject) {
      try {
        await Api.deleteProject(project: action.project);
        store.dispatch(OnProjectDeleted(action.project));
      } catch (e) {
        store.dispatch(ShowSnackBar(
            AppSnackBarMessage.ok("Failed to delete project ($e)")));
      }
    }
    if (action is UpdateProject) {
      try {
        List<dynamic> projects =
            await Api.updateProject(project: action.project);
        store.dispatch(OnProjectUpdated(projects));
        await genSshConf(action.project);
      } catch (e) {
        store.dispatch(
            ShowSnackBar(AppSnackBarMessage.ok("Failed to update project")));
      }
    }
    if (action is ProjectsLoad) {
      Api.getConf()
          .then((projects) => store.dispatch(OnProjectsLoad(projects)));
    }
    if (action is TestConnectivityProject) {
      LAProject project = action.project;
      try {
        await genSshConf(project);
        Api.testConnectivity(project.serversWithServices()).then((results) {
          store.dispatch(OnTestConnectivityResults(results));
          action.onServersStatusReady();
        });
      } catch (e) {
        action.onFailed();
        store.dispatch(ShowSnackBar(AppSnackBarMessage(
            "Failed to test the connectivity with your servers.")));
      }
    }
    if (action is TestServicesProject) {
      try {
        Api.checkHostServices(action.hostsServicesChecks)
            // without await to correct set appState.loading
            .then((results) {
          action.onResults();
          store.dispatch(OnTestServicesResults(results));
        });
      } catch (e) {
        action.onFailed();
        store.dispatch(ShowSnackBar(AppSnackBarMessage(
            "Failed to test the connectivity with your servers.")));
      }
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
      try {
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

          if (action.deployCmd.runtimeType != PreDeployCmd &&
              action.deployCmd.runtimeType != PostDeployCmd) {
            await Api.alaInstallSelect(
                    action.project.alaInstallRelease!, action.onError)
                .then((_) => scanSshKeys(store, () => {}));
            await Api.generatorSelect(
                    action.project.generatorRelease!, action.onError)
                .then((_) => action.onReady());
            await Api.regenerateInv(
                id: action.project.id, onError: action.onError);
          }
          await Api.regenerateInv(
              id: action.project.id, onError: action.onError);
          action.onReady();
        }
      } catch (e) {
        action.onError(
            'Something was wrong trying to prepare the deploy, check the server logs');
      }
    }
    if (action is DeployProject) {
      if (action.cmd.runtimeType == PreDeployCmd) {
        await genSshConf(
            action.project, (action.cmd as PreDeployCmd).rootBecome);
        Api.preDeploy(action);
      } else if (action.cmd.runtimeType == PostDeployCmd) {
        Api.postDeploy(action);
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
            },
            onError: (error) {
              store.dispatch(OnShowDeployProjectResultsFailed());
              action.onFailed();
            });
      } else {
        store.dispatch(OnShowDeployProjectResultsFailed());
        action.onFailed();
      }
    }
    if (action is RequestUpdateOneProps<CmdHistoryEntry>) {
      EntityApis.cmdHistoryEntryApi.update(action.id, action.props);
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

  genSshConf(LAProject project, [bool forceRoot = false]) async {
    if (project.isCreated) {
      await Api.genSshConf(project, forceRoot);
    }
  }

  saveAppState(AppState state) async {
    await _initPrefs();

    Map<String, dynamic> toJ = state.toJson();
    if (!AppUtils.isDemo()) {
      // Do not persist projects in users local storage
      toJ.remove('projects');
    }
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
