import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/cmdHistoryDetails.dart';
import 'package:la_toolkit/models/cmdHistoryEntry.dart';
import 'package:la_toolkit/models/deployCmd.dart';
import 'package:la_toolkit/models/hostServicesChecks.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/laServer.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:la_toolkit/models/sshKey.dart';
import 'package:la_toolkit/redux/actions.dart';
import 'package:la_toolkit/utils/utils.dart';

class Api {
  static Function uri = AppUtils.uri;

  static Future<String> genCasKey(int size) async {
    if (AppUtils.isDemo()) return "";
    Uri url = uri(env['BACKEND']!, "/api/v1/cas-gen/$size");
    Response response = await http.get(url);
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse["value"].toString();
    } else {
      return "";
    }
  }

  static Future<void> genSshConf(LAProject project,
      [bool forceRoot = false]) async {
    if (AppUtils.isDemo()) return;
    Uri url = uri(env['BACKEND']!, "/api/v1/gen-ssh-conf");
    List<Map<String, dynamic>> servers = project.toJson()['servers'];
    String user = project.getVariableValue("ansible_user")!.toString();
    // print(user);
    Response response = await http.post(url,
        headers: {'Content-type': 'application/json'},
        body: utf8.encode(json.encode({
          'name': project.shortName,
          'id': project.id,
          'servers': servers,
          'user': forceRoot ? 'root' : user.toString()
        })));
    if (response.statusCode == 200) {}
    // errors.dart:187 Uncaught (in promise) Error: Expected a value of type 'Map<String, dynamic>', but got one of type 'List<Map<String, dynamic>>'
    return;
  }

  static Future<List<SshKey>> sshKeysScan() async {
    if (AppUtils.isDemo()) return [];
    Uri url = uri(env['BACKEND']!, "/api/v1/ssh-key-scan");
    Response response = await http.get(url);
    if (response.statusCode == 200) {
      Iterable l = json.decode(response.body)['keys'];
      List<SshKey> keys = List<SshKey>.from(l.map((k) {
        return SshKey.fromJson(k);
      }));
      return keys;
    } else {
      return List<SshKey>.empty();
    }
  }

  static Future<void> genSshKey(String name) async {
    if (AppUtils.isDemo()) return;
    Uri url = uri(env['BACKEND']!, "/api/v1/ssh-key-gen/$name");
    http
        .get(url)
        .then((response) => jsonDecode(response.body))
        .catchError((error) => {print(error)});
  }

  static Future<Map<String, dynamic>> testConnectivity(
      List<LAServer> servers) async {
    if (AppUtils.isDemo()) return {};
    Uri url = uri(env['BACKEND']!, "/api/v1/test-connectivity");
    Response response = await http.post(url,
        headers: {'Content-type': 'application/json'},
        body: utf8.encode(json.encode({
          'servers': servers,
        })));
    if (response.statusCode == 200) {
      Map<String, dynamic> l = json.decode(response.body);
      // for (var element in l.keys) {
      // print("out: ${l[element]['out']}");
      // }
      return l;
    } else {
      return {};
    }
  }

  static Future<void> importSshKey(
      String name, String publicKey, String privateKey) async {
    if (AppUtils.isDemo()) return;
    Uri url = uri(env['BACKEND']!, "/api/v1/ssh-key-import");
    Response response = await http.post(url,
        headers: {'Content-type': 'application/json'},
        body: utf8.encode(json.encode({
          'name': name,
          'publicKey': publicKey,
          'privateKey': privateKey,
        })));
    if (response.statusCode != 200) {
      return;
    }
  }

  static Future<void> saveConf(AppState state) async {
    Map map = {
      for (LAProject item in state.projects) item.id: item.toGeneratorJson()
    };
    if (AppUtils.isDemo()) return;
    Uri url = uri(env['BACKEND']!, "/api/v1/save-conf");
    Map<String, dynamic> stateJ = state.toJson();
    stateJ['projectsMap'] = map;
    try {
      Response response = await http.post(url,
          headers: {'Content-type': 'application/json'},
          body: utf8.encode(json.encode(stateJ)));
      if (response.statusCode == 200) {
        return;
      } else {
        throw "Failed to save configuration (${response.reasonPhrase}))";
      }
    } catch (e) {
      print(e);
      throw "Failed to save configuration ($e)";
    }
  }

  static Future<List<dynamic>> getConf() async {
    if (AppUtils.isDemo()) return [];
    Uri url = uri(env['BACKEND']!, "/api/v1/get-conf");

    Response response = await http.get(url);
    if (response.statusCode == 200) {
      return retrieveProjectList(response);
    } else {
      throw "Failed to load configuration";
    }
  }

  static List<dynamic> retrieveProjectList(http.Response response) {
    Map<String, dynamic> stateRetrievedJ = json.decode(response.body);
    return stateRetrievedJ['projects'];
  }

  static Future<void> alaInstallSelect(
      String version, Function(String) onError) async {
    const userError = 'Error selecting that ala-install version';
    if (AppUtils.isDemo()) return;
    Uri url = uri(env['BACKEND']!, "/api/v1/ala-install-select/$version");
    await http
        .get(url)
        .then(
            (response) => response.statusCode != 200 ? onError(userError) : {})
        .catchError((error) {
      print(error);
      onError(userError);
    });
  }

  static Future<void> generatorSelect(
      String version, Function(String) onError) async {
    if (AppUtils.isDemo()) return;
    const userError = 'Error installing that generator version';
    Uri url = uri(env['BACKEND']!, "/api/v1/generator-select/$version");
    await http
        .get(url)
        .then(
            (response) => response.statusCode != 200 ? onError(userError) : {})
        .catchError((error) {
      print(error);
      onError(userError);
    });
  }

  static Future<void> regenerateInv(
      {required String id, required Function(String) onError}) async {
    if (AppUtils.isDemo()) return;
    const userError = 'Error generating your inventories';
    Uri url = uri(env['BACKEND']!, "/api/v1/gen/$id/false");
    http
        .get(url)
        .then(
            (response) => response.statusCode != 200 ? onError(userError) : {})
        .catchError((error) {
      print(error);
      onError(userError);
    });
  }

  static Future<void> term(
      {required Function(String cmd, int port, int ttydPid) onStart,
      required ErrorCallback onError,
      String? server,
      String? projectId}) async {
    if (AppUtils.isDemo()) {
      onStart("", 2011, 1);
      return;
    }
    Uri url = uri(env['BACKEND']!, "/api/v1/term");
    Object? body;
    if (server != null && projectId != null) {
      body = utf8.encode(json.encode({'id': projectId, 'server': server}));
    }
    http
        .post(url, headers: {'Content-type': 'application/json'}, body: body)
        .then((response) {
      if (response.statusCode == 200) {
        Map<String, dynamic> l = json.decode(response.body);
        onStart(l['cmd'], l['port'], l['ttydPid']);
      } else {
        onError(response.statusCode);
      }
    });
  }

  static Future<void> termLogs(
      {required CmdHistoryEntry cmd,
      required Function(String cmd, int port, int ttydPort) onStart,
      required ErrorCallback onError}) async {
    if (AppUtils.isDemo()) return;
    Uri url = uri(env['BACKEND']!, "/api/v1/term-logs");
    http
        .post(url,
            headers: {'Content-type': 'application/json'},
            body: utf8.encode(json.encode(
                {'logsPrefix': cmd.logsPrefix, 'logsSuffix': cmd.logsSuffix})))
        .then((response) {
      if (response.statusCode == 200) {
        Map<String, dynamic> l = json.decode(response.body);
        onStart(l['cmd'], l['port'], l['ttydPid']);
      } else {
        onError(response.statusCode);
      }
    });
  }

  static Future<void> ansiblew(DeployProject action) async {
    if (AppUtils.isDemo()) return;
    Uri url = uri(env['BACKEND']!, "/api/v1/ansiblew");
    String desc = action.cmd.desc;
    // use lists in ansiblew
    DeployCmd cmdTr = action.cmd.copyWith();
    cmdTr.deployServices = cmdTr.deployServices
        .map((name) =>
            name == LAServiceName.species_lists.toS() ? "lists" : name)
        .toList();
    doCmd(
        url: url,
        projectId: action.project.id,
        desc: desc,
        cmd: cmdTr.toJson(),
        action: action);
  }

  static void doCmd(
      {required Uri url,
      required String projectId,
      required String desc,
      required Map<String, dynamic> cmd,
      required DeployProject action}) {
    http
        .post(url,
            headers: {'Content-type': 'application/json'},
            body: utf8.encode(
                json.encode({'id': projectId, 'desc': desc, 'cmd': cmd})))
        .then((response) {
      if (response.statusCode == 200) {
        Map<String, dynamic> l = json.decode(response.body);
        action.onStart(
            CmdHistoryEntry.fromJson(l['cmdEntry']), l['port'], l['ttydPid']);
      } else {
        action.onError(response.statusCode);
      }
    }).catchError((error) {
      print(error);
      action.onError(error);
    });
  }

  static Future<CmdHistoryDetails?> getAnsiblewResults(
      {required cmdHistoryEntryId,
      required String logsPrefix,
      required String logsSuffix}) async {
    if (AppUtils.isDemo()) return null;
    Uri url = uri(env['BACKEND']!, "/api/v1/ansiblew-results");
    Response response = await http.post(url,
        headers: {'Content-type': 'application/json'},
        body: utf8.encode(json.encode({
          'cmdHistoryEntryId': cmdHistoryEntryId,
          'logsPrefix': logsPrefix,
          'logsSuffix': logsSuffix
        })));
    if (response.statusCode == 200) {
      return CmdHistoryDetails.fromJson(json.decode(response.body));
    }
    return null;
  }

  static Future<String?> checkDirName(
      {required String dirName, required String id}) async {
    if (AppUtils.isDemo()) return null;
    Uri url = uri(env['BACKEND']!, "/api/v1/check-dir-name");
    Response response = await http.post(url,
        headers: {'Content-type': 'application/json'},
        body: utf8.encode(json.encode({'dirName': dirName, 'id': id})));
    if (response.statusCode == 200) {
      return json.decode(response.body)['dirName'];
    }
    return null;
  }

  static Future<String?> getBackendVersion() async {
    if (AppUtils.isDemo()) return null;
    Uri url = uri(env['BACKEND']!, "/api/v1/get-backend-version");
    Response response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body)['version'];
    } else {
      return null;
    }
  }

  static Future<void> preDeploy(DeployProject action) async {
    if (AppUtils.isDemo()) return;
    Uri url = uri(env['BACKEND']!, "/api/v1/pre-deploy");
    doCmd(
        url: url,
        projectId: action.project.id,
        desc: action.cmd.desc,
        cmd: action.cmd.toJson(),
        action: action);
  }

  static Future<void> postDeploy(DeployProject action) async {
    if (AppUtils.isDemo()) return;
    Uri url = uri(env['BACKEND']!, "/api/v1/post-deploy");
    doCmd(
        url: url,
        projectId: action.project.id,
        desc: action.cmd.desc,
        cmd: action.cmd.toJson(),
        action: action);
  }

  static Future<Map<String, dynamic>> checkHostServices(
      String projectId, HostsServicesChecks hostsServicesChecks) async {
    if (AppUtils.isDemo()) return {};
    Uri url = uri(env['BACKEND']!, "/api/v1/test-host-services");
    Response response = await http.post(url,
        headers: {'Content-type': 'application/json'},
        body: utf8.encode(json.encode({
          'projectId': projectId,
          'hostsServices': hostsServicesChecks.toJson(),
        })));
    if (response.statusCode == 200) {
      Map<String, dynamic> l = json.decode(response.body);
      return l;
    } else {
      return {};
    }
  }

  static Future<List<dynamic>> addProject({required LAProject project}) async {
    return await addOrUpdateProject(project, "add");
  }

  static Future<List<dynamic>> updateProject(
      {required LAProject project}) async {
    return await addOrUpdateProject(project, "update");
  }

  static Future<List<dynamic>> addOrUpdateProject(
      LAProject project, String op) async {
    if (AppUtils.isDemo()) return [project.toJson()];
    Uri url = uri(env['BACKEND']!, "/api/v1/$op-project");
    Map<String, dynamic> projectJ = projectJsonWithGenConf(project);
    Map<String, dynamic> body = {'project': projectJ};

    Response response = await (op == "add" ? http.post : http.patch)(url,
        headers: {'Content-type': 'application/json'},
        body: utf8.encode(json.encode(body)));
    if (response.statusCode == 200) {
      return retrieveProjectList(response);
    } else {
      throw "Failed to $op project";
    }
  }

  static Future<List<dynamic>> addProjects(List<LAProject> projects) async {
    Uri url = uri(env['BACKEND']!, "/api/v1/add-projects");

    List<dynamic> projectsJ = [];
    for (var project in projects) {
      Map<String, dynamic> projectJ = projectJsonWithGenConf(project);
      projectsJ.add(projectJ);
    }
    Map<String, dynamic> body = {'projects': projectsJ};

    Response response = await http.post(url,
        headers: {'Content-type': 'application/json'},
        body: utf8.encode(json.encode(body)));
    if (response.statusCode == 200) {
      return retrieveProjectList(response);
    } else {
      throw "Failed to add projects";
    }
  }

  static Map<String, dynamic> projectJsonWithGenConf(LAProject project) {
    Map<String, dynamic> projectJ = project.toJson();
    Map<String, dynamic> projectGenJson = project.toGeneratorJson();
    projectJ['genConf'] = projectGenJson;
    return projectJ;
  }

  static Future<void> deleteProject({required LAProject project}) async {
    if (AppUtils.isDemo()) return;
    Uri url = uri(env['BACKEND']!, "/api/v1/delete-project");

    Map<String, dynamic> body = {'id': project.id};

    Response response = await http.delete(url,
        headers: {'Content-type': 'application/json'},
        body: utf8.encode(json.encode(body)));
    if (response.statusCode == 200) {
      return;
    } else {
      throw "Failed to delete project";
    }
  }

  static Future<void> termClose({required int port, required int pid}) async {
    if (AppUtils.isDemo()) return;
    Uri url = uri(env['BACKEND']!, "/api/v1/term-close");
    Response response = await http.post(url,
        headers: {'Content-type': 'application/json'},
        body: utf8.encode(json.encode({'port': port, 'pid': pid})));
    if (response.statusCode == 200) {
      return;
    }
    return;
  }
}
