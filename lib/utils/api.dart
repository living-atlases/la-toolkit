import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:la_toolkit/env/env.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/laServer.dart';
import 'package:la_toolkit/models/laVariableDesc.dart';
import 'package:la_toolkit/models/sshKey.dart';

class Api {
  static Future<String> genCasKey(int size) async {
    var url = "${Env.backend}api/v1/cas-gen/$size";
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      return jsonResponse["value"].toString();
    } else {
      return "";
    }
  }

  static void genSshConf(LAProject project) async {
    var url = "${Env.backend}api/v1/gen-ssh-conf";
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
    var url = "${Env.backend}api/v1/ssh-key-scan";
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

  static Future<String> genSshKey(String name) async {
    var url = "${Env.backend}api/v1/ssh-key-gen/$name";
    http
        .get(url)
        .then((response) => jsonDecode(response.body))
        .catchError((error) => {print(error)});
  }

  static Future<Map<String, dynamic>> testConnectivity(
      List<LAServer> servers) async {
    var url = "${Env.backend}api/v1/test-connectivity";
    var response = await http.post(url,
        headers: {'Content-type': 'application/json'},
        body: utf8.encode(json.encode({
          'servers': servers,
        })));
    if (response.statusCode == 200) {
      Map<String, dynamic> l = json.decode(response.body);
      return l;
    } else {
      return {};
    }
  }

  static Future<String> importSshKey(
      String name, String publicKey, String privateKey) async {
    var url = "${Env.backend}api/v1/ssh-key-import";

    var response = await http.post(url,
        headers: {'Content-type': 'application/json'},
        body: utf8.encode(json.encode({
          'name': name,
          'publicKey': publicKey,
          'privateKey': privateKey,
        })));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
  }
}
