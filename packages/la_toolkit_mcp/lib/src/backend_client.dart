import 'dart:convert';

import 'package:http/http.dart' as http;

/// A backend call that did not answer 200. Carries the path and body so the
/// agent sees what actually failed instead of a bare "request failed".
class BackendException implements Exception {
  BackendException(this.path, this.statusCode, this.body);

  final String path;
  final int statusCode;
  final String body;

  @override
  String toString() {
    final String shown = body.length > 500
        ? '${body.substring(0, 500)}…'
        : body;
    return 'LA Toolkit backend answered $statusCode to $path: $shown';
  }
}

/// Thin client over the la_toolkit_backend REST API (`config/routes.js`).
///
/// It only speaks the endpoints the Flutter app already uses, with the same
/// payloads, so the backend cannot tell an agent-driven deploy from one
/// started in the UI.
class BackendClient {
  BackendClient(this.baseUri, {http.Client? client, Duration? timeout})
    : _client = client ?? http.Client(),
      _timeout = timeout ?? const Duration(minutes: 5);

  /// e.g. `http://localhost:2010` (production image) or `http://localhost:1337`
  /// (backend running natively in dev).
  final Uri baseUri;
  final http.Client _client;
  final Duration _timeout;

  Uri _uri(String path) => baseUri.resolve('/api/v1/$path');

  Future<Object?> _get(String path) async {
    final http.Response r = await _client.get(_uri(path)).timeout(_timeout);
    return _decode(path, r);
  }

  Future<Object?> _send(String method, String path, Object? body) async {
    final http.Request req = http.Request(method, _uri(path))
      ..headers['Content-Type'] = 'application/json'
      ..body = json.encode(body);
    final http.Response r = await http.Response.fromStream(
      await _client.send(req).timeout(_timeout),
    );
    return _decode(path, r);
  }

  Object? _decode(String path, http.Response r) {
    if (r.statusCode != 200) {
      throw BackendException(path, r.statusCode, r.body);
    }
    if (r.body.isEmpty) return null;
    try {
      return json.decode(r.body);
    } on FormatException {
      // Several actions (the *-select ones, gen-ssh-conf) answer a bare 200.
      return r.body;
    }
  }

  /// Every portal, fully populated, hubs nested under `hubs`.
  Future<List<Map<String, dynamic>>> getProjects() async {
    final Map<String, dynamic> body =
        await _get('get-conf') as Map<String, dynamic>;
    return (body['projects'] as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> backendVersion() async =>
      await _get('get-backend-version') as Map<String, dynamic>;

  Future<Map<String, dynamic>> testConnectivity(List<dynamic> servers) async =>
      await _send('POST', 'test-connectivity', <String, Object?>{
            'servers': servers,
          })
          as Map<String, dynamic>;

  /// `df` over ssh on the project's servers (optionally only [names]).
  /// Read-only; the backend takes the names from its database.
  Future<List<Map<String, dynamic>>> diskUsage(
    String id, {
    List<String>? names,
  }) async {
    final Map<String, dynamic> r =
        await _send('POST', 'disk-usage', <String, Object?>{
              'id': id,
              if (names != null) 'names': names,
            })
            as Map<String, dynamic>;
    return (r['servers'] as List<dynamic>).cast<Map<String, dynamic>>();
  }

  /// The ssh keys the toolkit holds (`{name, missing, ...}`).
  Future<List<Map<String, dynamic>>> sshKeys() async {
    final Map<String, dynamic> r =
        await _get('ssh-key-scan') as Map<String, dynamic>;
    return (r['keys'] as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<void> alaInstallSelect(String version) =>
      _get('ala-install-select/${Uri.encodeComponent(version)}');

  Future<void> dockerComposeSelect(String version) =>
      _get('docker-compose-select/${Uri.encodeComponent(version)}');

  Future<void> generatorSelect(String version) =>
      _get('generator-select/${Uri.encodeComponent(version)}');

  /// Regenerates the inventories. The body is the raw `LA_*` map (the stored
  /// `genConf`), not an envelope: `gen.js` reads `LA_pkg_name` from it.
  Future<void> regenerateInventories(String id, Map<String, dynamic> genConf) =>
      _send('POST', 'gen/$id/false', genConf);

  Future<void> genSshConf({
    required String name,
    required String id,
    required List<dynamic> servers,
    required String user,
  }) => _send('POST', 'gen-ssh-conf', <String, Object?>{
    'name': name,
    'id': id,
    'servers': servers,
    'user': user,
  });

  /// Starts a detached run. Answers `{cmdEntry, port, ttydPid, deployPid}`.
  Future<Map<String, dynamic>> ansiblew({
    required String id,
    required String desc,
    required Map<String, dynamic> cmd,
  }) async =>
      await _send('POST', 'ansiblew', <String, Object?>{
            'id': id,
            'desc': desc,
            'cmd': cmd,
          })
          as Map<String, dynamic>;

  /// Kills a ttyd viewer. Only the viewer: the deploy it was tailing runs
  /// detached and keeps going.
  Future<void> termClose(int port, int pid) =>
      _send('POST', 'term-close', <String, Object?>{'port': port, 'pid': pid});

  Future<bool> deployStatus(String logsPrefix, String logsSuffix) async {
    final Map<String, dynamic> r =
        await _send('POST', 'deploy-status', <String, Object?>{
              'logsPrefix': logsPrefix,
              'logsSuffix': logsSuffix,
            })
            as Map<String, dynamic>;
    return r['running'] == true;
  }

  /// `{code, results, logs (base64), logsColorized (base64), running, duration?}`
  Future<Map<String, dynamic>> cmdResults({
    required String cmdHistoryEntryId,
    required String logsPrefix,
    required String logsSuffix,
  }) async =>
      await _send('POST', 'cmd-results', <String, Object?>{
            'cmdHistoryEntryId': cmdHistoryEntryId,
            'logsPrefix': logsPrefix,
            'logsSuffix': logsSuffix,
          })
          as Map<String, dynamic>;

  Future<bool> deployCancel(String logsPrefix, String logsSuffix) async {
    final Map<String, dynamic> r =
        await _send('POST', 'deploy-cancel', <String, Object?>{
              'logsPrefix': logsPrefix,
              'logsSuffix': logsSuffix,
            })
            as Map<String, dynamic>;
    return r['killed'] == true;
  }

  void close() => _client.close();
}
