import 'dart:convert';
import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version/version.dart';

import '../components/appSnackBarMessage.dart';
import '../dependencies_manager.dart';
import '../models/LAServiceConstants.dart';
import '../models/appState.dart';
import '../models/cmdHistoryEntry.dart';
import '../models/cmd_history_details.dart';
import '../models/laReleases.dart';
import '../models/laServiceDesc.dart';
import '../models/la_project.dart';
import '../models/postDeployCmd.dart';
import '../models/preDeployCmd.dart';
import '../models/sshKey.dart';
import '../utils/api.dart';
import '../utils/casUtils.dart';
import '../utils/utils.dart';
import 'app_actions.dart';
import 'entityActions.dart';
import 'entityApis.dart';

class AppStateMiddleware implements MiddlewareClass<AppState> {
  final String key = 'laTool20210418';
  SharedPreferences? _pref;

  Future<void> _initPrefs() async {
    _pref ??= await SharedPreferences.getInstance();
  }

  Future<AppState> getState() async {
    AppState appState;

    String? asS;
    await _initPrefs();
    asS = _pref!.getString(key);

    if (asS == null || asS.isEmpty || asS == '{}') {
      appState = initialEmptyAppState();
    } else {
      try {
        final Map<String, dynamic> asJ =
            json.decode(asS) as Map<String, dynamic>;
        appState = AppState.fromJson(asJ);
      } catch (e) {
        log('Failed to decode conf: $e');
        appState = initialEmptyAppState(failedLoad: true);
      }
    }
    return appState.copyWith(loading: true);
  }

  AppState initialEmptyAppState({bool failedLoad = false}) {
    log('Load prefs empty (and failed $failedLoad)');
    return AppState(
        failedLoad: failedLoad,
        firstUsage: !failedLoad,
        currentProject: LAProject(),
        projects: List<LAProject>.empty(),
        sshKeys: List<SshKey>.empty());
  }

  @override
  call(Store<AppState> store, action, next) async {
    if (action is OnFetchSoftwareDepsState) {
      // ALA-INSTALL RELEASES
      final Uri alaInstallReleasesApiUrl = Uri.https('api.github.com',
          '/repos/AtlasOfLivingAustralia/ala-install/releases');

      final Response alaInstallReleasesResponse =
          await http.get(alaInstallReleasesApiUrl);
      if (alaInstallReleasesResponse.statusCode == 200) {
        final List<dynamic> l =
            jsonDecode(alaInstallReleasesResponse.body) as List;
        final List<String> alaInstallReleases = <String>[];
        for (final element in l) {
          alaInstallReleases.add(element['tag_name'] as String);
        }
        // Remove the old ones
        const int limitResults = 6;
        alaInstallReleases.removeRange(alaInstallReleases.length - limitResults,
            alaInstallReleases.length);
        alaInstallReleases.add('upstream');
        alaInstallReleases.add('custom');
        if (!const ListEquality()
            .equals(alaInstallReleases, store.state.alaInstallReleases)) {
          store.dispatch(OnFetchAlaInstallReleases(alaInstallReleases));
        }
        scanSshKeys(store, () {});
      } else {
        store.dispatch(OnFetchAlaInstallReleasesFailed());
        store.dispatch(ShowSnackBar(AppSnackBarMessage.ok(
            'Failed to fetch github ala-install releases. Are you connected to Internet?')));
      }

      // LA-TOOLKIT RELEASES
      final Uri laToolkitReleasesApiUrl = Uri.https(
          'api.github.com', '/repos/living-atlases/la-toolkit/releases');
      final Response laToolkitReleasesResponse =
          await http.get(laToolkitReleasesApiUrl);
      if (laToolkitReleasesResponse.statusCode == 200) {
        final List<dynamic> l =
            jsonDecode(laToolkitReleasesResponse.body) as List;
        if (l.isNotEmpty) {
          final Version lastLAToolkitVersion = Version.parse(
              l.first['tag_name'].toString().replaceFirst('v', ''));
          if (!AppUtils.isDemo()) {
            final Version backendVersion =
                Version.parse(await Api.getBackendVersion() ?? '');
            store.dispatch(OnFetchBackendVersion(backendVersion.toString()));
            if (backendVersion < lastLAToolkitVersion) {
              log('$backendVersion < $lastLAToolkitVersion');
              store.dispatch(ShowSnackBar(AppSnackBarMessage(
                  'There is a new version the LA-Toolkit available. Please upgrade this toolkit.',
                  const Duration(seconds: 5),
                  SnackBarAction(
                      label: 'MORE INFO',
                      onPressed: () async {
                        await launchUrl(Uri.parse(
                            'https://github.com/living-atlases/la-toolkit/#upgrade-the-toolkit'));
                      }))));
            }
          }
        }
      } else {
        store.dispatch(ShowSnackBar(AppSnackBarMessage.ok(
            'Failed to fetch github la-toolkit releases')));
      }

      // GENERATOR RELEASES
      if (AppUtils.isDemo()) {
        store.dispatch(OnFetchGeneratorReleases(
            <String>['1.2.29', '1.2.28', '1.2.27', '1.2.26']));
      } else {
        // generatorReleasesApiUrl =
        //  "https://registry.npmjs.org/generator-living-atlas";
        // As this does not have CORS enabled we use a proxy
        final Uri generatorReleasesApiUrl = AppUtils.uri(
            dotenv.env['BACKEND']!, '/api/v1/get-generator-versions');
        final Response generatorReleasesResponse = await http.get(
          generatorReleasesApiUrl,
          //  headers: {'Accept': 'application/vnd.npm.install-v1+json'},
        );
        if (generatorReleasesResponse.statusCode == 200) {
          final Map<String, dynamic> l = json
              .decode(generatorReleasesResponse.body) as Map<String, dynamic>;
          final Map<String, dynamic> versions =
              l['versions'] as Map<String, dynamic>;
          final List<String> generatorReleases = <String>[];
          for (final String key in versions.keys) {
            generatorReleases.insert(0, key);
          }
          if (!const ListEquality()
              .equals(generatorReleases, store.state.generatorReleases)) {
            store.dispatch(OnFetchGeneratorReleases(generatorReleases));
          }
        } else {
          store.dispatch(OnFetchGeneratorReleasesFailed());
        }
      }

      // Dependencies
      final String deps = await Api.fetchDependencies();
      DependenciesManager.setDeps(deps);

      if (!AppUtils.isDemo()) {
        // ALA other Releases
        if (!action.force &&
            store.state.lastSwCheck != null &&
            (store.state.lastSwCheck!
                .isAfter(DateTime.now().subtract(const Duration(hours: 12))))) {
          log('Not checking LA versions because we retrieved them already today');
          log(store.state.laReleases.toString());
        } else {
          Map<String, LAReleases> releases = <String, LAReleases>{};
          final Map<String, String> servicesAndSub = <String, String>{};
          for (final LAServiceDesc service in LAServiceDesc.listWithArtifact) {
            servicesAndSub[service.nameInt] = service.artifacts!;
          }
          releases = await getDepsVersions(servicesAndSub);
          store.dispatch(OnLAVersionsSwCheckEnd(releases, DateTime.now()));
          if (action.onReady != null) {
            action.onReady!();
          }
        }
      }
    }
    if (action is AddProject) {
      try {
        action.project.dirName = action.project.suggestDirName();
        if (!AppUtils.isDemo()) {
          store.dispatch(Loading());
          final List<LAProject> projects = <LAProject>[
            action.project,
            ...action.project.hubs
          ];
          final List<dynamic> addedProjects = await Api.addProjects(projects);
          store.dispatch(OnProjectsAdded(addedProjects));
          await genSshConf(action.project);
        } else {
          // We just add to the store
          store.dispatch(OnDemoAddProjects(<LAProject>[action.project]));
        }
      } catch (e) {
        store.dispatch(
            ShowSnackBar(AppSnackBarMessage.ok('Failed to save project ($e)')));
      }
    }
    if (action is AddTemplateProjects) {
      final List<LAProject> projects = await LAProject.importTemplates(
          AssetsUtils.pathWorkaround('la-toolkit-templates.json'));
      try {
        if (!AppUtils.isDemo()) {
          store.dispatch(Loading());
          final List<dynamic> projectsAdded =
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
            ShowSnackBar(AppSnackBarMessage.ok('Failed to add projects ($e)')));
      }
    }
    if (action is DelProject) {
      try {
        store.dispatch(Loading());
        final List<dynamic> projects = AppUtils.isDemo()
            ? store.state.projects
                .where((LAProject p) => p.id != action.project.id)
                .toList()
            : await Api.deleteProject(project: action.project);
        store.dispatch(OnProjectDeleted(action.project, projects));
      } catch (e) {
        log('Failed to delete project $e');
        store.dispatch(ShowSnackBar(
            AppSnackBarMessage.ok('Failed to delete project ($e)')));
      }
    }

    if (action is OpenProjectTools || action is TuneProject) {
      final LAProject project = action.project as LAProject;
      if (!project.isHub &&
          (project.allServicesAssigned() || project.inProduction)) {
        if (project.lastSwCheck == null ||
            project.lastSwCheck!
                .add(const Duration(hours: 1))
                .isBefore(DateTime.now())) {
          Api.getServiceDetailsForVersionCheck(project)
              .then((Map<String, String> serviceVersions) {
            store.dispatch(OnPortalRunningVersionsRetrieved(serviceVersions));
            if (AppUtils.isDev()) {
              log(serviceVersions.toString());
            }
          });
        }
      }
    }

    if (action is UpdateProject) {
      store.dispatch(Loading());
      final LAProject project = action.project;
      await _updateProject(
          project, store, action.updateCurrentProject, action.openProjectView);
    }
    if (action is ProjectsLoad) {
      store.dispatch(Loading());
      Api.getConf().then((List<dynamic> projects) {
        if (!AppUtils.isDemo()) {
          store.dispatch(OnProjectsLoad(projects));
        } else {
          store.dispatch(OnDemoProjectsLoad());
        }
      });
    }
    if (action is TestConnectivityProject) {
      final LAProject project = action.project;
      try {
        await genSshConf(project);
        Api.testConnectivity(project.serversWithServices())
            .then((Map<String, dynamic> results) {
          store.dispatch(OnTestConnectivityResults(results));
          action.onServersStatusReady();
        });
      } catch (e) {
        action.onFailed();
        store.dispatch(ShowSnackBar(AppSnackBarMessage(
            'Failed to test the connectivity with your servers.')));
      }
    }
    if (action is TestServicesProject) {
      try {
        Api.checkHostServices(action.project.id, action.hostsServicesChecks)
            // without await to correct set appState.loading
            .then((Map<String, dynamic> results) {
          action.onResults();
          store.dispatch(OnTestServicesResults(results));
        });
      } catch (e) {
        action.onFailed();
        store.dispatch(ShowSnackBar(AppSnackBarMessage(
            'Failed to test the connectivity with your servers.')));
      }
    }
    if (action is OnSshKeysScan) {
      scanSshKeys(store, action.onKeysScanned);
    }
    if (action is OnAddSshKey) {
      Api.genSshKey(action.name).then((_) => scanSshKeys(store, () {}));
    }
    if (action is OnImportSshKey) {
      Api.importSshKey(action.name, action.publicKey, action.privateKey)
          .then((_) => scanSshKeys(store, () {}));
    }
    if (action is PrepareDeployProject) {
      try {
        String? currentDirName = action.project.dirName;
        currentDirName ??= action.project.suggestDirName();
        // verify that the dirName is not an Portal with the same dirname
        // in case of hubs we avoid this security check as the hub inventories are located inside the portal
        // configuration
        final String? checkedDirName = action.project.isHub
            ? action.project.dirName
            : await Api.checkDirName(
                dirName: currentDirName, id: action.project.id);
        if (checkedDirName == null) {
          store.dispatch(ShowSnackBar(AppSnackBarMessage.ok(
              'Failed to prepare your configuration (in details, the dirName to store it)')));
        } else {
          final LAProject project = action.project;
          if (action.project.dirName != checkedDirName) {
            project.dirName = checkedDirName;
          }

          await _updateProject(project, store, true, false);
          if (project.isHub) {
            await _updateProject(project.parent!, store, false, false);
          }

          if (action.deployCmd.runtimeType != PreDeployCmd &&
              action.deployCmd.runtimeType != PostDeployCmd) {
            await Api.alaInstallSelect(
                    action.project.alaInstallRelease!, action.onError)
                .then((_) => scanSshKeys(store, () {}));
            await Api.generatorSelect(
                    action.project.generatorRelease!, action.onError)
                .then((_) => action.onReady());
            await Api.regenerateInv(
                project: action.project, onError: action.onError);
          } else {
            await Api.generatorSelect(
                    action.project.generatorRelease!, action.onError)
                .then((_) => action.onReady());
            await Api.regenerateInv(
                project: action.project, onError: action.onError);
          }
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
      } else {
        Api.ansiblew(action);
      }
    }
    if (action is BrandingDeploy) {
      Api.deployBranding(action);
    }

    if (action is PipelinesRun) {
      Api.pipelinesRun(action);
    }

    if (action is GetCmdResults) {
      CmdHistoryDetails? lastCmdDet = store.state.currentProject.lastCmdDetails;
      if (lastCmdDet != null &&
          lastCmdDet.cmd != null &&
          lastCmdDet.cmd!.id == action.cmdHistoryEntry.id) {
        // Don't load results again we have this already
      } else {
        lastCmdDet = await Api.getCmdResults(
            cmdHistoryEntryId: action.cmdHistoryEntry.id,
            logsPrefix: action.cmdHistoryEntry.logsPrefix,
            logsSuffix: action.cmdHistoryEntry.logsSuffix);
      }
      if (lastCmdDet != null) {
        lastCmdDet.fstRetrieved = action.fstRetrieved;
        lastCmdDet.cmd = action.cmdHistoryEntry;
        if (action.fstRetrieved ||
            action.cmdHistoryEntry.result == CmdResult.unknown) {
          // Compute result with ansible + code
          final CmdResult result = lastCmdDet.result;
          action.cmdHistoryEntry.result = result;
          action.cmdHistoryEntry.duration = lastCmdDet.duration;
          // Update backend
          await EntityApis.cmdHistoryEntryApi.update(action.cmdHistoryEntry.id,
              <String, String>{'result': result.toS()});
        }
        Api.termLogs(
            cmd: action.cmdHistoryEntry,
            onStart: (String cmd, int port, int ttydPid) {
              lastCmdDet!.port = port;
              lastCmdDet.pid = ttydPid;
              store.dispatch(ShowCmdResults(
                  action.cmdHistoryEntry, action.fstRetrieved, lastCmdDet));
              action.onReady();
            },
            onError: (int error) {
              store.dispatch(OnShowCmdResultsFailed());
              action.onFailed();
            });
      } else {
        store.dispatch(OnShowCmdResultsFailed());
        action.onFailed();
      }
    }
    if (action is RequestUpdateOneProps<CmdHistoryEntry>) {
      EntityApis.cmdHistoryEntryApi.update(action.id, action.props);
    }
    if (action is DeleteLog) {
      try {
        await EntityApis.cmdHistoryEntryApi.delete(id: action.cmd.id);
        store.dispatch(OnDeletedLog(action.cmd));
      } catch (e) {
        store.dispatch(ShowSnackBar(AppSnackBarMessage(
            'Something was wrong trying to delete that log, check the server logs')));
      }
    }
    if (action is OnInitCasKeys) {
      final String pac4jCookieSigningKey = await CASUtils.gen512CasKey();
      final String pac4jCookieEncryptionKey = await CASUtils.gen256CasKey();
      final String casWebflowSigningKey = await CASUtils.gen512CasKey();
      final String casWebflowEncryptionKey = await CASUtils.gen128CasKey();
      store.dispatch(OnInitCasKeysResults(
          pac4jCookieSigningKey: pac4jCookieSigningKey,
          pac4jCookieEncryptionKey: pac4jCookieEncryptionKey,
          casWebflowSigningKey: casWebflowSigningKey,
          casWebflowEncryptionKey: casWebflowEncryptionKey));
    }
    if (action is OnInitCasOAuthKeys) {
      final String casOauthSigningKey = await CASUtils.gen512CasKey();
      final String casOauthEncryptionKey = await CASUtils.gen256CasKey();
      final String casOauthAccessTokenSigningKey =
          await CASUtils.gen512CasKey();
      final String casOauthAccessTokenEncryptionKey =
          await CASUtils.gen256CasKey();
      store.dispatch(OnInitCasOAuthKeysResults(
          casOauthSigningKey: casOauthSigningKey,
          casOauthEncryptionKey: casOauthEncryptionKey,
          casOauthAccessTokenSigningKey: casOauthAccessTokenSigningKey,
          casOauthAccessTokenEncryptionKey: casOauthAccessTokenEncryptionKey));
    }
    next(action);
  }

  Future<Map<String, LAReleases>> getDepsVersions(
      Map<String, String> deps) async {
    final Uri depsBackUrl =
        AppUtils.uri(dotenv.env['BACKEND']!, '/api/v1/get-deps-versions');
    final Response response = await http.post(depsBackUrl,
        headers: <String, String>{'Content-type': 'application/json'},
        body: utf8
            .encode(json.encode(<String, Map<String, String>>{'deps': deps})));
    final Map<String, dynamic> jsonBody =
        json.decode(response.body) as Map<String, dynamic>;
    final Map<String, LAReleases> releases = <String, LAReleases>{};
    final Map<String, dynamic> excludeList =
        jsonBody['excludeList'] as Map<String, dynamic>;

    for (final String service in jsonBody.keys) {
      try {
        if (service == 'excludeList') {
          continue;
        }
        if (service == events) {
          // TODO (vjrj): Process docker tags as versions too
          releases[events] = LAReleases(
              name: events,
              latest: 'latest',
              versions: const <String>[],
              artifacts: events);
          continue;
        }
        log('Processing $service deps');
        final List<String> versions = <String>[];
        final List<String> releasesVersions =
            getResponseVersions(jsonBody, 'releases', service);
        final List<String> snapshotVersions =
            getResponseVersions(jsonBody, 'snapshots', service);
        final String latest = jsonBody[service]['releases']['metadata']
                ['versioning']['latest']
            .toString();
        versions.addAll(releasesVersions.reversed.toList().sublist(
            0, 30 > releasesVersions.length ? releasesVersions.length : 30));
        versions.addAll(snapshotVersions.reversed.toList().sublist(
            0, 2 > snapshotVersions.length ? snapshotVersions.length : 2));
        // exclude
        final List<dynamic> serviceExcludeList =
            excludeList[service] as List<dynamic>? ?? <dynamic>[];
        versions.removeWhere((String v) =>
            excludeList[service] != null && serviceExcludeList.contains(v));
        final LAReleases servReleases = LAReleases(
            name: service,
            artifacts: deps[service]!,
            latest: latest,
            // remove dups
            versions: versions.toSet().toList());
        releases[service] = servReleases;
      } catch (e) {
        if (kDebugMode) {
          print('----- Error getting $service deps ($e)');
          // print(stacktrace);
        }
      }
    }

    return releases;
  }

  List<String> getResponseVersions(
      Map<String, dynamic> jsonBody, String repo, String service) {
    final thisVersions = jsonBody[service][repo]['metadata']['versioning']
        ['versions']['version'];
    final List<String> groupVersions = thisVersions.runtimeType == String
        ? <String>[thisVersions as String]
        : thisVersions.cast<String>() as List<String>;
    return groupVersions;
  }

  Future<void> _updateProject(LAProject project, Store<AppState> store,
      bool updateCurrentProject, bool openProjectView) async {
    try {
      final List<dynamic> projects = await Api.updateProject(project: project);
      await genSshConf(project);
      store.dispatch(
          OnProjectUpdated(project.id, projects, updateCurrentProject));
      if (openProjectView) {
        store.dispatch(OpenProjectTools(project));
      }
    } catch (e, stacktrace) {
      log('Failed to update project $e');
      log(stacktrace.toString());
      if (AppUtils.isDev()) {
        store.dispatch(ShowSnackBar(
            AppSnackBarMessage.ok('Failed to update project ($e)')));
      } else {
        store.dispatch(
            ShowSnackBar(AppSnackBarMessage.ok('Failed to update project')));
      }
    }
  }

  void scanSshKeys(Store<AppState> store, VoidCallback onKeysScanned) {
    Api.sshKeysScan().then((List<SshKey> keys) {
      if (!const ListEquality<SshKey>().equals(keys, store.state.sshKeys)) {
        store.dispatch(OnSshKeysScanned(keys));
      }
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

    final Map<String, dynamic> toJ = state.toJson();
    if (!AppUtils.isDemo()) {
      // Do not persist projects in users local storage
      toJ.remove('projects');
    }
    // log("Saved prefs: $toJ.toString()");
    _pref!.setString(key, json.encode(toJ));
    if (!AppUtils.isDemo()) {
      if (state.failedLoad) {
        log('Not saving configuration because the load of the saved configuration failed');
      } else {
        // log("Saving conf in server side");
        // Api.saveConf(state);
      }
    }
  }
}
