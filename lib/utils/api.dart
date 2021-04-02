import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/cmdHistoryDetails.dart';
import 'package:la_toolkit/models/cmdHistoryEntry.dart';
import 'package:la_toolkit/models/hostServicesChecks.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/laServer.dart';
import 'package:la_toolkit/models/postDeployCmd.dart';
import 'package:la_toolkit/models/preDeployCmd.dart';
import 'package:la_toolkit/models/sshKey.dart';
import 'package:la_toolkit/redux/actions.dart';
import 'package:la_toolkit/utils/utils.dart';

class Api {
  static Future<String> genCasKey(int size) async {
    if (AppUtils.isDemo()) return "";
    Uri url = Uri.http(env['BACKEND']!, "/api/v1/cas-gen/$size");
    Response response = await http.get(url);
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse["value"].toString();
    } else {
      return "";
    }
  }

  static void genSshConf(LAProject project) async {
    if (AppUtils.isDemo()) return;
    Uri url = Uri.http(env['BACKEND']!, "/api/v1/gen-ssh-conf");
    List<Map<String, dynamic>> servers = project.toJson()['servers'];
    String user = project.getVariableValue("ansible_user")!.toString();
    print(user);
    Response response = await http.post(url,
        headers: {'Content-type': 'application/json'},
        body: utf8.encode(json.encode({
          'name': project.shortName,
          'uuid': project.uuid,
          'servers': servers,
          'user': user.toString()
        })));
    if (response.statusCode == 200) {}
    // errors.dart:187 Uncaught (in promise) Error: Expected a value of type 'Map<String, dynamic>', but got one of type 'List<Map<String, dynamic>>'
    return;
  }

  static Future<List<SshKey>> sshKeysScan() async {
    if (AppUtils.isDemo()) return [];
    Uri url = Uri.http(env['BACKEND']!, "/api/v1/ssh-key-scan");
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
    Uri url = Uri.http(env['BACKEND']!, "/api/v1/ssh-key-gen/$name");
    http
        .get(url)
        .then((response) => jsonDecode(response.body))
        .catchError((error) => {print(error)});
  }

  static Future<Map<String, dynamic>> testConnectivity(
      List<LAServer> servers) async {
    if (AppUtils.isDemo()) return {};
    Uri url = Uri.http(env['BACKEND']!, "/api/v1/test-connectivity");
    Response response = await http.post(url,
        headers: {'Content-type': 'application/json'},
        body: utf8.encode(json.encode({
          'servers': servers,
        })));
    if (response.statusCode == 200) {
      Map<String, dynamic> l = json.decode(response.body);
      l.keys.forEach((element) {
        // print("out: ${l[element]['out']}");
      });
      return l;
    } else {
      return {};
    }
  }

  static Future<void> importSshKey(
      String name, String publicKey, String privateKey) async {
    if (AppUtils.isDemo()) return;
    Uri url = Uri.http(env['BACKEND']!, "/api/v1/ssh-key-import");
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
      for (LAProject item in state.projects) item.uuid: item.toGeneratorJson()
    };
    if (AppUtils.isDemo()) return;
    Uri url = Uri.http(env['BACKEND']!, "/api/v1/save-conf");
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

  static Future<String> getConf() async {
    if (AppUtils.isDemo()) return "";
    Uri url = Uri.http(env['BACKEND']!, "/api/v1/get-conf");

    Response response = await http.get(url);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw "Failed to load configuration";
    }
  }

  static Future<void> alaInstallSelect(
      String version, Function(String) onError) async {
    const userError = 'Error selecting that ala-install version';
    if (AppUtils.isDemo()) return;
    Uri url = Uri.http(env['BACKEND']!, "/api/v1/ala-install-select/$version");
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
    Uri url = Uri.http(env['BACKEND']!, "/api/v1/generator-select/$version");
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
      {required String uuid, required Function(String) onError}) async {
    if (AppUtils.isDemo()) return;
    const userError = 'Error generating your inventories';
    Uri url = Uri.http(env['BACKEND']!, "/api/v1/gen/$uuid/false");
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
      {required VoidCallback onStart,
      required ErrorCallback onError,
      String? server,
      String? projectUuid}) async {
    if (AppUtils.isDemo()) {
      onStart();
      return;
    }
    Uri url = Uri.http(env['BACKEND']!, "/api/v1/term");
    Object? body;
    if (server != null && projectUuid != null) {
      body = utf8.encode(json.encode({'uuid': projectUuid, 'server': server}));
    }
    http
        .post(url, headers: {'Content-type': 'application/json'}, body: body)
        .then((response) => response.statusCode == 200
            ? onStart()
            : onError(response.statusCode))
        .catchError((error) => {print(error)});
  }

  static Future<void> termLogs(
      {required CmdHistoryEntry cmd,
      required VoidCallback onStart,
      required ErrorCallback onError}) async {
    if (AppUtils.isDemo()) return;
    Uri url = Uri.http(env['BACKEND']!, "/api/v1/term-logs");
    http
        .post(url,
            headers: {'Content-type': 'application/json'},
            body: utf8.encode(json.encode(
                {'logsPrefix': cmd.logsPrefix, 'logsSuffix': cmd.logsSuffix})))
        .then((response) => response.statusCode == 200
            ? onStart()
            : onError(response.statusCode))
        .catchError((error) => {print(error)});
  }

  static Future<void> ansiblew(DeployProject action) async {
    if (AppUtils.isDemo()) return;
    Uri url = Uri.http(env['BACKEND']!, "/api/v1/ansiblew");
    Object cmd = cmdToObj(action);
    doCmd(url, cmd, action);
  }

  static void doCmd(Uri url, Object cmd, DeployProject action) {
    http
        .post(url,
            headers: {'Content-type': 'application/json'},
            body: utf8.encode(json.encode({'cmd': cmd})))
        .then((response) {
      if (response.statusCode == 200) {
        Map<String, dynamic> l = json.decode(response.body);
        action.onStart(l['cmd'], l['logsPrefix'], l['logsSuffix'], l['invDir']);
      } else
        action.onError(response.statusCode);
    }).catchError((error) {
      print(error);
      action.onError(error);
    });
  }

  static dynamic cmdToObj(DeployProject action) {
    Object cmd = {
      'uuid': action.project.uuid,
      'shortName': action.project.shortName,
      'dirName': action.project.dirName,
      'deployServices': action.cmd.deployServices,
      'limitToServers': action.cmd.limitToServers,
      'tags': action.cmd.tags,
      'skipTags': action.cmd.skipTags,
      'onlyProperties': action.cmd.onlyProperties,
      'continueEvenIfFails': action.cmd.continueEvenIfFails,
      'debug': action.cmd.debug,
      'dryRun': action.cmd.dryRun
    };
    return cmd;
  }

  static Future<CmdHistoryDetails?> getAnsiblewResults(
      {required String logsPrefix, required String logsSuffix}) async {
    if (AppUtils.isDemo()) return null;
    Uri url = Uri.http(env['BACKEND']!, "/api/v1/ansiblew-results");
    Response response = await http.post(url,
        headers: {'Content-type': 'application/json'},
        body: utf8.encode(
            json.encode({'logsPrefix': logsPrefix, 'logsSuffix': logsSuffix})));
    if (response.statusCode == 200) {
      return CmdHistoryDetails.fromJson(json.decode(response.body));
    }
    return null;
  }

  static Future<String?> checkDirName(
      {required String dirName, required String uuid}) async {
    if (AppUtils.isDemo()) return null;
    Uri url = Uri.http(env['BACKEND']!, "/api/v1/check-dir-name");
    Response response = await http.post(url,
        headers: {'Content-type': 'application/json'},
        body: utf8.encode(json.encode({'dirName': dirName, 'uuid': uuid})));
    if (response.statusCode == 200) {
      return json.decode(response.body)['dirName'];
    }
    return null;
  }

  static Future<String?> getBackendVersion() async {
    if (AppUtils.isDemo()) return null;
    Uri url = Uri.http(env['BACKEND']!, "/api/v1/get-backend-version");
    Response response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body)['version'];
    } else {
      return null;
    }
  }

  static Future<void> preDeploy(DeployProject action) async {
    if (AppUtils.isDemo()) return;
    Uri url = Uri.http(env['BACKEND']!, "/api/v1/pre-deploy");
    var cmd = cmdToObj(action);
    cmd['tags'] = (action.cmd as PreDeployCmd).preTags;
    cmd['services'] = [];
    doCmd(url, cmd, action);
  }

  static Future<void> postDeploy(DeployProject action) async {
    if (AppUtils.isDemo()) return;
    Uri url = Uri.http(env['BACKEND']!, "/api/v1/post-deploy");
    var cmd = cmdToObj(action);
    cmd['services'] = [];
    var postDeployCmd = action.cmd as PostDeployCmd;
    cmd['tags'] = postDeployCmd.postTags;
    if (postDeployCmd.configurePostfix) {
      PostDeployCmd.postDeployVariables.forEach((varName) {
        setCmdVar(action.project, cmd, varName);
      });
    }
    doCmd(url, cmd, action);
  }

  static void setCmdVar(LAProject project, cmd, String varName) {
    cmd[varName] = project.getVariableValue(varName)!.toString();
  }

  static Future<Map<String, dynamic>> checkHostServices(
      HostsServicesChecks hostsServicesChecks) async {
    if (AppUtils.isDemo()) return {};
    Uri url = Uri.http(env['BACKEND']!, "/api/v1/test-host-services");
    Response response = await http.post(url,
        headers: {'Content-type': 'application/json'},
        body: utf8.encode(json.encode({
          'hostsServices': hostsServicesChecks.toJson(),
        })));
    if (response.statusCode == 200) {
      Map<String, dynamic> l = json.decode(response.body);
      l.keys.forEach((element) {
        // print("out: ${l[element]['out']}");
      });
      return l;
    } else {
      return {};
    }
  }
}
