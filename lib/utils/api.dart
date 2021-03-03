import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/laServer.dart';
import 'package:la_toolkit/models/laVariableDesc.dart';
import 'package:la_toolkit/models/sshKey.dart';
import 'package:la_toolkit/redux/actions.dart';
import 'package:la_toolkit/utils/utils.dart';

class Api {
  static Future<String> genCasKey(int size) async {
    if (AppUtils.isDemo()) return "";
    var url = "${env['BACKEND']}api/v1/cas-gen/$size";
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      return jsonResponse["value"].toString();
    } else {
      return "";
    }
  }

  static void genSshConf(LAProject project) async {
    if (AppUtils.isDemo()) return;
    var url = "${env['BACKEND']}api/v1/gen-ssh-conf";
    var servers = project.toJson()['servers'];
    var user =
        project.getVariable(LAVariableDesc.get("ansible_user").nameInt).value;
    var response = await http.post(url,
        headers: {'Content-type': 'application/json'},
        body: utf8.encode(json.encode({
          'name': project.shortName,
          'uuid': project.uuid,
          'servers': servers,
          'user': user
        })));
    if (response.statusCode == 200) {
      // var jsonResponse = jsonDecode(response.body);
    }
    return;
  }

  static Future<List<SshKey>> sshKeysScan() async {
    if (AppUtils.isDemo()) return [];
    var url = "${env['BACKEND']}api/v1/ssh-key-scan";
    var response = await http.get(url);
    if (response.statusCode == 200) {
      //print(response.body);
      Iterable l = json.decode(response.body)['keys'];
      List<SshKey> keys = List<SshKey>.from(l.map((k) {
        var kj = SshKey.fromJson(k);
        print(kj);
        return kj;
      }));
      return keys;
    } else {
      return List<SshKey>.empty();
    }
  }

  static Future<void> genSshKey(String name) async {
    if (AppUtils.isDemo()) return;
    var url = "${env['BACKEND']}api/v1/ssh-key-gen/$name";
    http
        .get(url)
        .then((response) => jsonDecode(response.body))
        .catchError((error) => {print(error)});
  }

  static Future<Map<String, dynamic>> testConnectivity(
      List<LAServer> servers) async {
    if (AppUtils.isDemo()) return {};
    var url = "${env['BACKEND']}api/v1/test-connectivity";
    var response = await http.post(url,
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
    var url = "${env['BACKEND']}api/v1/ssh-key-import";
    var response = await http.post(url,
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

  static Future<void> saveProjects(List<LAProject> projects) async {
    Map map = {for (var item in projects) item.uuid: item.toGeneratorJson()};
    if (AppUtils.isDemo()) return;
    var url = "${env['BACKEND']}api/v1/save-conf";
    await http.post(url,
        headers: {'Content-type': 'application/json'},
        body: utf8.encode(json.encode({
          'projects': map,
        })));
    return;
  }

  static Future<void> alaInstallSelect(String version) async {
    if (AppUtils.isDemo()) return;
    var url = "${env['BACKEND']}api/v1/ala-install-select/$version";
    http
        .get(url)
        .then((response) => jsonDecode(response.body))
        .catchError((error) => {print(error)});
  }

  static Future<void> term(
      {VoidCallback onStart, ErrorCallback onError}) async {
    if (AppUtils.isDemo()) return;
    var url = "${env['BACKEND']}api/v1/term";
    http.get(url).then((response) {
      if (response.statusCode == 200)
        onStart();
      else
        onError(response.statusCode);
    }).catchError((error) => {print(error)});
  }

  static Future<void> ansiblew(DeployProject action) async {
    if (AppUtils.isDemo()) return;
    var url = "${env['BACKEND']}api/v1/ansiblew";
    var cmd = {
      'uuid': action.project.uuid,
      'shortName': action.project.shortName,
      'deployServices': action.deployServices,
      'limitToServers': action.limitToServers,
      'tags': action.tags,
      'skipTags': action.skipTags,
      'onlyProperties': action.onlyProperties,
      'continueEvenIfFails': action.continueEvenIfFails,
      'debug': action.debug,
      'dryRun': action.dryRun
    };
    http
        .post(url,
            headers: {'Content-type': 'application/json'},
            body: utf8.encode(json.encode({'cmd': cmd})))
        .then((response) {
      if (response.statusCode == 200)
        action.onStart();
      else
        action.onError(response.statusCode);
    }).catchError((error) => {action.onError(error)});
  }
}
