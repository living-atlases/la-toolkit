import 'dart:convert';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' show Response;

import '../models/app_state.dart';
import '../models/cmd_history_details.dart';
import '../models/cmd_history_entry.dart';
import '../models/deploy_cmd.dart';
import '../models/host_services_checks.dart';
import '../models/la_project.dart';
import '../models/la_server.dart';
import '../models/la_service_constants.dart';
import '../models/ssh_key.dart';
import '../redux/actions.dart';
import 'utils.dart';

class Api {
  static Future<String> genCasKey(int size) async {
    if (AppUtils.isDemo()) {
      return '';
    }
    final Uri url = AppUtils.uri(
      dotenv.env['BACKEND']!,
      '/api/v1/cas-gen/$size',
    );
    final Response response = await http.get(url);
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse =
          jsonDecode(response.body) as Map<String, dynamic>;
      return jsonResponse['value'].toString();
    } else {
      return '';
    }
  }

  static Future<void> genSshConf(
    LAProject project, [
    bool forceRoot = false,
  ]) async {
    if (AppUtils.isDemo()) {
      return;
    }
    final Uri url = AppUtils.uri(
      dotenv.env['BACKEND']!,
      '/api/v1/gen-ssh-conf',
    );
    final List<Map<String, dynamic>> servers =
        project.toJson()['servers'] as List<Map<String, dynamic>>;
    final String user = project.getVariableValue('ansible_user')!.toString();
    final Response response = await http.post(
      url,
      headers: <String, String>{'Content-type': 'application/json'},
      body: utf8.encode(
        json.encode(<String, Object>{
          'name': project.shortName,
          'id': project.id,
          'servers': servers,
          'user': forceRoot ? 'root' : user,
        }),
      ),
    );
    if (response.statusCode == 200) {
      return;
    }
  }

  static Future<List<SshKey>> sshKeysScan() async {
    if (AppUtils.isDemo()) {
      return <SshKey>[];
    }
    final Uri url = AppUtils.uri(
      dotenv.env['BACKEND']!,
      '/api/v1/ssh-key-scan',
    );
    final Response response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> l =
          (json.decode(response.body) as Map<String, dynamic>)['keys']
              as List<dynamic>;
      final List<SshKey> keys = List<SshKey>.from(
        l.map((dynamic k) {
          return SshKey.fromJson(k as Map<String, dynamic>);
        }),
      );
      return keys;
    } else {
      return List<SshKey>.empty();
    }
  }

  static Future<void> genSshKey(String name) async {
    if (AppUtils.isDemo()) {
      return;
    }
    final Uri url = AppUtils.uri(
      dotenv.env['BACKEND']!,
      '/api/v1/ssh-key-gen/$name',
    );
    http
        .get(url)
        .then((http.Response response) => jsonDecode(response.body))
        .catchError((dynamic error) => <void>{log(error.toString())});
  }

  static Future<Map<String, dynamic>> testConnectivity(
    List<LAServer> servers,
  ) async {
    if (AppUtils.isDemo()) {
      return <String, dynamic>{};
    }

    if (servers.isEmpty) {
      return <String, dynamic>{'servers': <dynamic>[]};
    }

    final Uri url = AppUtils.uri(
      dotenv.env['BACKEND']!,
      '/api/v1/test-connectivity',
    );
    try {
      final Response response = await http.post(
        url,
        headers: <String, String>{'Content-type': 'application/json'},
        body: utf8.encode(
          json.encode(<String, List<LAServer>>{'servers': servers}),
        ),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> l =
            json.decode(response.body) as Map<String, dynamic>;
        return l;
      } else {
        log('Error testing connectivity: HTTP ${response.statusCode}');
        return <String, dynamic>{'servers': <dynamic>[]};
      }
    } catch (e) {
      log('Error testing connectivity: $e');
      return <String, dynamic>{'servers': <dynamic>[]};
    }
  }

  static Future<void> importSshKey(
    String name,
    String publicKey,
    String privateKey,
  ) async {
    if (AppUtils.isDemo()) {
      return;
    }
    final Uri url = AppUtils.uri(
      dotenv.env['BACKEND']!,
      '/api/v1/ssh-key-import',
    );
    final Response response = await http.post(
      url,
      headers: <String, String>{'Content-type': 'application/json'},
      body: utf8.encode(
        json.encode(<String, String>{
          'name': name,
          'publicKey': publicKey,
          'privateKey': privateKey,
        }),
      ),
    );
    if (response.statusCode != 200) {
      return;
    }
  }

  static Future<void> saveConf(AppState state) async {
    final Map<String, dynamic> map = <String, dynamic>{
      for (final LAProject item in state.projects)
        item.id: item.toGeneratorJson(),
    };
    if (AppUtils.isDemo()) {
      return;
    }
    final Uri url = AppUtils.uri(dotenv.env['BACKEND']!, '/api/v1/save-conf');
    final Map<String, dynamic> stateJ = state.toJson();
    stateJ['projectsMap'] = map;
    try {
      final Response response = await http.post(
        url,
        headers: <String, String>{'Content-type': 'application/json'},
        body: utf8.encode(json.encode(stateJ)),
      );
      if (response.statusCode == 200) {
        return;
      } else {
        throw Exception(
          'Failed to save configuration (${response.reasonPhrase}))',
        );
      }
    } catch (e) {
      log(e.toString());
      throw Exception('Failed to save configuration ($e)');
    }
  }

  static Future<List<dynamic>> getConf() async {
    if (AppUtils.isDemo()) {
      return <dynamic>[];
    }
    final Uri url = AppUtils.uri(dotenv.env['BACKEND']!, '/api/v1/get-conf');

    final Response response = await http.get(url);
    if (response.statusCode == 200) {
      return retrieveProjectList(response);
    } else {
      throw Exception('Failed to load configuration');
    }
  }

  static List<dynamic> retrieveProjectList(http.Response response) {
    final Map<String, dynamic> stateRetrievedJ =
        json.decode(response.body) as Map<String, dynamic>;
    return stateRetrievedJ['projects'] as List<dynamic>;
  }

  static Future<void> alaInstallSelect(
    String version,
    Function(String) onError,
  ) async {
    const String userError = 'Error selecting that ala-install version';
    if (AppUtils.isDemo()) {
      return;
    }
    final Uri url = AppUtils.uri(
      dotenv.env['BACKEND']!,
      '/api/v1/ala-install-select/$version',
    );
    await http
        .get(url)
        .then(
          (http.Response response) => response.statusCode != 200
              ? onError(userError)
              : <String, dynamic>{},
        )
        .catchError((dynamic error) {
          log('ala-install select error $error');
          onError(userError);
        });
  }

  static Future<void> generatorSelect(
    String version,
    Function(String) onError,
  ) async {
    if (AppUtils.isDemo()) {
      return;
    }
    const String userError = 'Error installing that generator version';
    final Uri url = AppUtils.uri(
      dotenv.env['BACKEND']!,
      '/api/v1/generator-select/$version',
    );
    await http
        .get(url)
        .then(
          (http.Response response) => response.statusCode != 200
              ? onError(userError)
              : <String, dynamic>{},
        )
        .catchError((dynamic error) {
          log('generator select error $error');
          onError(userError);
        });
  }

  static Future<void> regenerateInv({
    required LAProject project,
    required Function(String) onError,
  }) async {
    if (AppUtils.isDemo()) {
      return;
    }
    final String id = project.isHub ? project.parent!.id : project.id;
    const String userError = 'Error generating your inventories';
    final Uri url = AppUtils.uri(
      dotenv.env['BACKEND']!,
      '/api/v1/gen/$id/false',
    );
    await http
        .get(url)
        .then(
          (http.Response response) => response.statusCode != 200
              ? onError(userError)
              : <String, dynamic>{},
        )
        .catchError((dynamic error) {
          log('regenerateInv select error $error');
          onError(userError);
        });
  }

  static Future<void> term({
    required Function(String cmd, int port, int ttydPid) onStart,
    required ErrorCallback onError,
    String? server,
    String? projectId,
  }) async {
    if (AppUtils.isDemo()) {
      onStart('', 2011, 1);
      return;
    }
    final Uri url = AppUtils.uri(dotenv.env['BACKEND']!, '/api/v1/term');
    Object? body;
    if (server != null && projectId != null) {
      body = utf8.encode(
        json.encode(<String, String>{'id': projectId, 'server': server}),
      );
    }
    http
        .post(
          url,
          headers: <String, String>{'Content-type': 'application/json'},
          body: body,
        )
        .then((http.Response response) {
          if (response.statusCode == 200) {
            final Map<String, dynamic> l =
                json.decode(response.body) as Map<String, dynamic>;
            onStart(l['cmd'] as String, l['port'] as int, l['ttydPid'] as int);
          } else {
            onError(response.statusCode);
          }
        });
  }

  static Future<void> termLogs({
    required CmdHistoryEntry cmd,
    required Function(String cmd, int port, int ttydPort) onStart,
    required ErrorCallback onError,
  }) async {
    if (AppUtils.isDemo()) {
      return;
    }
    final Uri url = AppUtils.uri(dotenv.env['BACKEND']!, '/api/v1/term-logs');
    http
        .post(
          url,
          headers: <String, String>{'Content-type': 'application/json'},
          body: utf8.encode(
            json.encode(<String, String>{
              'cmdHistoryEntryId': cmd.id,
              'logsPrefix': cmd.logsPrefix,
              'logsSuffix': cmd.logsSuffix,
            }),
          ),
        )
        .then((http.Response response) {
          if (response.statusCode == 200) {
            final Map<String, dynamic> l =
                json.decode(response.body) as Map<String, dynamic>;
            onStart(l['cmd'] as String, l['port'] as int, l['ttydPid'] as int);
          } else {
            onError(response.statusCode);
          }
        });
  }

  static Future<void> ansiblew(DeployProject action) async {
    if (AppUtils.isDemo()) {
      return;
    }
    final Uri url = AppUtils.uri(dotenv.env['BACKEND']!, '/api/v1/ansiblew');
    final String desc = action.cmd.desc;
    // use lists in ansiblew
    final DeployCmd cmdTr = action.cmd.copyWith();
    cmdTr.deployServices = cmdTr.deployServices
        .map((String name) => name == speciesLists ? 'lists' : name)
        .toList();
    doCmd(
      url: url,
      projectId: action.project.id,
      desc: desc,
      cmd: cmdTr.toJson(),
      action: action,
    );
  }

  static void doCmd({
    required Uri url,
    required String projectId,
    required String desc,
    required Map<String, dynamic> cmd,
    required DeployAction action,
  }) {
    http
        .post(
          url,
          headers: <String, String>{'Content-type': 'application/json'},
          body: utf8.encode(
            json.encode(<String, Object>{
              'id': projectId,
              'desc': desc,
              'cmd': cmd,
            }),
          ),
        )
        .then((http.Response response) {
          if (response.statusCode == 200) {
            final Map<String, dynamic> l =
                json.decode(response.body) as Map<String, dynamic>;
            action.onStart(
              CmdHistoryEntry.fromJson(l['cmdEntry'] as Map<String, dynamic>),
              l['port'] as int,
              l['ttydPid'] as int,
            );
          } else {
            action.onError(response.statusCode);
          }
        })
        .catchError((dynamic error) {
          log('cmd error $error');
          action.onError(1);
        });
  }

  static Future<CmdHistoryDetails?> getCmdResults({
    required String cmdHistoryEntryId,
    required String logsPrefix,
    required String logsSuffix,
  }) async {
    if (AppUtils.isDemo()) {
      return null;
    }
    final Uri url = AppUtils.uri(dotenv.env['BACKEND']!, '/api/v1/cmd-results');
    final Response response = await http.post(
      url,
      headers: <String, String>{'Content-type': 'application/json'},
      body: utf8.encode(
        json.encode(<String, dynamic>{
          'cmdHistoryEntryId': cmdHistoryEntryId,
          'logsPrefix': logsPrefix,
          'logsSuffix': logsSuffix,
        }),
      ),
    );
    if (response.statusCode == 200) {
      return CmdHistoryDetails.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    }
    return null;
  }

  static Future<String?> checkDirName({
    required String dirName,
    required String id,
  }) async {
    if (AppUtils.isDemo()) {
      return null;
    }
    final Uri url = AppUtils.uri(
      dotenv.env['BACKEND']!,
      '/api/v1/check-dir-name',
    );
    final Response response = await http.post(
      url,
      headers: <String, String>{'Content-type': 'application/json'},
      body: utf8.encode(
        json.encode(<String, String>{'dirName': dirName, 'id': id}),
      ),
    );
    if (response.statusCode == 200) {
      return (json.decode(response.body) as Map<String, dynamic>)['dirName']
          as String?;
    }
    return null;
  }

  static Future<String?> getBackendVersion() async {
    if (AppUtils.isDemo()) {
      return null;
    }
    final Uri url = AppUtils.uri(
      dotenv.env['BACKEND']!,
      '/api/v1/get-backend-version',
    );
    final Response response = await http.get(url);
    if (response.statusCode == 200) {
      return (json.decode(response.body) as Map<String, dynamic>)['version']
          as String?;
    } else {
      return null;
    }
  }

  static Future<void> preDeploy(DeployProject action) async {
    if (AppUtils.isDemo()) {
      return;
    }
    final Uri url = AppUtils.uri(dotenv.env['BACKEND']!, '/api/v1/pre-deploy');
    doCmd(
      url: url,
      projectId: action.project.id,
      desc: action.cmd.desc,
      cmd: action.cmd.toJson(),
      action: action,
    );
  }

  static Future<void> postDeploy(DeployProject action) async {
    if (AppUtils.isDemo()) {
      return;
    }
    final Uri url = AppUtils.uri(dotenv.env['BACKEND']!, '/api/v1/post-deploy');
    doCmd(
      url: url,
      projectId: action.project.id,
      desc: action.cmd.desc,
      cmd: action.cmd.toJson(),
      action: action,
    );
  }

  static Future<Map<String, dynamic>> checkHostServices(
    String projectId,
    HostsServicesChecks hostsServicesChecks,
  ) async {
    if (AppUtils.isDemo()) {
      return <String, dynamic>{};
    }
    final Uri url = AppUtils.uri(
      dotenv.env['BACKEND']!,
      '/api/v1/test-host-services',
    );
    final Response response = await http.post(
      url,
      headers: <String, String>{'Content-type': 'application/json'},
      body: utf8.encode(
        json.encode(<String, Object>{
          'projectId': projectId,
          'hostsServices': hostsServicesChecks.toJson(),
        }),
      ),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> l =
          json.decode(response.body) as Map<String, dynamic>;
      return l;
    } else {
      return <String, dynamic>{};
    }
  }

  static Future<Map<String, dynamic>> checkHostServicesWithStreaming(
    String projectId,
    HostsServicesChecks hostsServicesChecks,
  ) async {
    if (AppUtils.isDemo()) {
      return <String, dynamic>{};
    }
    final Uri url = AppUtils.uri(
      dotenv.env['BACKEND']!,
      '/api/v1/test-host-services-stream',
    );
    final Response response = await http.post(
      url,
      headers: <String, String>{'Content-type': 'application/json'},
      body: utf8.encode(
        json.encode(<String, Object>{
          'projectId': projectId,
          'hostsServices': hostsServicesChecks.toJson(),
        }),
      ),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> l =
          json.decode(response.body) as Map<String, dynamic>;
      return l;
    } else {
      return <String, dynamic>{};
    }
  }

  static Future<List<dynamic>> updateProject({
    required LAProject project,
  }) async {
    return addOrUpdateProject(project, 'update');
  }

  static Future<List<dynamic>> addOrUpdateProject(
    LAProject project,
    String op,
  ) async {
    if (AppUtils.isDemo()) {
      return <List<dynamic>>[project.toJson() as List<dynamic>];
    }
    final Uri url = AppUtils.uri(dotenv.env['BACKEND']!, '/api/v1/$op-project');
    final Map<String, dynamic> projectJ = projectJsonWithGenConf(project);
    final Map<String, dynamic> body = <String, dynamic>{'project': projectJ};
    final Response response = await (op == 'add' ? http.post : http.patch)(
      url,
      headers: <String, String>{'Content-type': 'application/json'},
      body: utf8.encode(json.encode(body)),
    );
    if (response.statusCode == 200) {
      return retrieveProjectList(response);
    } else {
      throw Exception('Failed to $op project');
    }
  }

  static Future<List<dynamic>> addProjects(List<LAProject> projects) async {
    final Uri url = AppUtils.uri(
      dotenv.env['BACKEND']!,
      '/api/v1/add-projects',
    );

    final List<dynamic> projectsJ = <dynamic>[];
    for (final LAProject project in projects) {
      final Map<String, dynamic> projectJ = projectJsonWithGenConf(project);
      projectsJ.add(projectJ);
    }
    final Map<String, dynamic> body = <String, dynamic>{'projects': projectsJ};

    final Response response = await http.post(
      url,
      headers: <String, String>{'Content-type': 'application/json'},
      body: utf8.encode(json.encode(body)),
    );
    if (response.statusCode == 200) {
      return retrieveProjectList(response);
    } else {
      throw Exception('Failed to add projects');
    }
  }

  static Map<String, dynamic> projectJsonWithGenConf(LAProject project) {
    final Map<String, dynamic> projectJ = project.toJson();
    final Map<String, dynamic> projectGenJson = project.toGeneratorJson();
    projectJ['genConf'] = projectGenJson;
    projectJ['parent'] = project.parent?.id;
    return projectJ;
  }

  static Future<List<dynamic>> deleteProject({
    required LAProject project,
  }) async {
    if (AppUtils.isDemo()) {
      return <dynamic>[];
    }
    final Uri url = AppUtils.uri(
      dotenv.env['BACKEND']!,
      '/api/v1/delete-project',
    );

    final Map<String, dynamic> body = <String, dynamic>{'id': project.id};

    final Response response = await http.delete(
      url,
      headers: <String, String>{'Content-type': 'application/json'},
      body: utf8.encode(json.encode(body)),
    );
    if (response.statusCode == 200) {
      return retrieveProjectList(response);
    } else {
      throw Exception('Failed to delete project');
    }
  }

  static Future<void> termClose({required int port, required int pid}) async {
    if (AppUtils.isDemo()) {
      return;
    }
    final Uri url = AppUtils.uri(dotenv.env['BACKEND']!, '/api/v1/term-close');
    final Response response = await http.post(
      url,
      headers: <String, String>{'Content-type': 'application/json'},
      body: utf8.encode(json.encode(<String, int>{'port': port, 'pid': pid})),
    );
    if (response.statusCode == 200) {
      return;
    }
    return;
  }

  static void deployBranding(BrandingDeploy action) {
    if (AppUtils.isDemo()) {
      return;
    }
    final Uri url = AppUtils.uri(
      dotenv.env['BACKEND']!,
      '/api/v1/branding-deploy',
    );
    doCmd(
      url: url,
      projectId: action.project.id,
      desc: action.cmd.desc,
      cmd: action.cmd.toJson(),
      action: action,
    );
  }

  static void pipelinesRun(PipelinesRun action) {
    if (AppUtils.isDemo()) {
      return;
    }
    final Uri url = AppUtils.uri(
      dotenv.env['BACKEND']!,
      '/api/v1/pipelines-run',
    );
    doCmd(
      url: url,
      projectId: action.project.id,
      desc: action.cmd.desc,
      cmd: action.cmd.toJson(),
      action: action,
    );
  }

  static Future<Map<String, String>> getServiceDetailsForVersionCheck(
    LAProject project,
  ) async {
    final Map<String, dynamic> services = project
        .getServiceDetailsForVersionCheck();
    if (AppUtils.isDemo()) {
      return <String, String>{};
    }
    final Uri url = AppUtils.uri(
      dotenv.env['BACKEND']!,
      '/api/v1/get-service-versions',
    );
    final Response response = await http.post(
      url,
      headers: <String, String>{'Content-type': 'application/json'},
      body: utf8.encode(
        json.encode(<String, Map<String, dynamic>>{'services': services}),
      ),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> l =
          json.decode(response.body) as Map<String, dynamic>;
      final Map<String, String> versions = l.map(
        (String key, dynamic value) =>
            MapEntry<String, String>(key, value.toString()),
      );
      // for (var element in l.keys) {
      // log("out: ${l[element]['out']}");
      // }
      return versions;
    } else {
      return <String, String>{};
    }
  }

  static Future<String> fetchDependencies() async {
    final Response response = await http.get(
      Uri.parse(
        'https://raw.githubusercontent.com/living-atlases/la-toolkit-backend/master/assets/dependencies.yaml',
      ),
    );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(
        'Failed to retrieve dependencies (${response.statusCode})',
      );
    }
  }

  static Future<Map<String, dynamic>> solrQuery(
    String projectId,
    String solrHost,
    String query,
  ) async {
    if (AppUtils.isDemo()) {
      return <String, dynamic>{};
    }
    final Uri url = AppUtils.uri(dotenv.env['BACKEND']!, '/api/v1/solr-query');
    try {
      // debugPrint('solrQuery: ($solrHost) $query');
      final Response response = await http.post(
        url,
        headers: <String, String>{'Content-type': 'application/json'},
        body: utf8.encode(
          json.encode(<String, Object>{
            'id': projectId,
            'sshHost': solrHost,
            'query': query,
          }),
        ),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse =
            jsonDecode(response.body) as Map<String, dynamic>;
        return jsonResponse;
      } else {
        throw Exception(
          "Failed to query solr '$query' (${response.reasonPhrase}))",
        );
      }
    } catch (e) {
      debugPrint('Error during solrQuery: $e');
      throw Exception("Failed to query solr '$query' ($e)");
    }
  }

  static Future<dynamic> solrRawQuery(
    String projectId,
    String solrHost,
    String query,
  ) async {
    if (AppUtils.isDemo()) {
      return <String, dynamic>{};
    }
    final Uri url = AppUtils.uri(dotenv.env['BACKEND']!, '/api/v1/solr-query');
    try {
      // debugPrint('solrRawQuery: ($solrHost) $query');
      final Response response = await http.post(
        url,
        headers: <String, String>{'Content-type': 'application/json'},
        body: utf8.encode(
          json.encode(<String, Object>{
            'id': projectId,
            'sshHost': solrHost,
            'query': query,
          }),
        ),
      );
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to query solr (${response.reasonPhrase}))');
      }
    } catch (e) {
      debugPrint('Error during solrQuery: $e');
      throw Exception('Failed to query solr ($e)');
    }
  }

  static Future<dynamic> mySqlQuery(
    String projectId,
    String mysqlHost,
    String db,
    String query,
  ) async {
    if (AppUtils.isDemo()) {
      return <String, dynamic>{};
    }
    final Uri url = AppUtils.uri(dotenv.env['BACKEND']!, '/api/v1/mysql-query');
    try {
      final Response response = await http.post(
        url,
        headers: <String, String>{'Content-type': 'application/json'},
        body: utf8.encode(
          json.encode(<String, Object>{
            'id': projectId,
            'sshHost': mysqlHost,
            'db': db,
            'query': query,
          }),
        ),
      );
      if (response.statusCode == 200) {
        final dynamic jsonResponse = jsonDecode(response.body) as dynamic;
        return jsonResponse;
      } else {
        throw Exception('Failed to query mysql (${response.reasonPhrase}))');
      }
    } catch (e) {
      debugPrint('Error during mySqlQuery: $e');
      throw Exception('Failed to query mysql ($e)');
    }
  }
}
