import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:la_toolkit_core/models/la_project.dart';
import 'package:la_toolkit_core/models/la_server.dart';
import 'package:la_toolkit_mcp/la_toolkit_mcp.dart';
import 'package:test/test.dart';

/// The binary's stdout is the MCP channel, and the core models print while
/// they load a project. This drives the same entry point the binary uses and
/// checks nothing but JSON-RPC reaches stdout.
void main() {
  test('backend from --backend, then the environment, then 2010', () {
    expect(
      backendUri(<String>['--backend', 'http://h:1337'], <String, String>{}),
      Uri.parse('http://h:1337'),
    );
    expect(
      backendUri(<String>[], <String, String>{
        'LA_TOOLKIT_BACKEND': 'http://e:1',
      }),
      Uri.parse('http://e:1'),
    );
    expect(
      backendUri(<String>[], <String, String>{}),
      Uri.parse('http://localhost:2010'),
    );
  });

  test(
    'model logging goes to the log, never to the protocol channel',
    () async {
      final LAProject p = LAProject(
        longName: 'Portal',
        shortName: 'portal',
        domain: 'example.com',
        generatorRelease: '1.8.33',
        dockerComposeRelease: 'v1.9.0',
      );
      final LAServer s = LAServer(
        name: 'vm-1',
        ip: '10.0.0.1',
        projectId: p.id,
      );
      p.upsertServer(s);
      p.assign(s, <String>['collectory']);
      final Map<String, dynamic> stored =
          json.decode(json.encode(p.toJson())) as Map<String, dynamic>;

      final http.Client client = MockClient((http.Request r) async {
        Object? body;
        switch (r.url.path) {
          case '/api/v1/get-conf':
            body = <String, dynamic>{
              'projects': <dynamic>[stored],
            };
          case '/api/v1/ssh-key-scan':
            body = <String, dynamic>{'keys': <dynamic>[]};
          case '/api/v1/get-backend-version':
            body = <String, dynamic>{'version': '1.7.1'};
          default:
            return http.Response('Not Found', 404);
        }
        return http.Response(json.encode(body), 200);
      });

      final StreamController<List<int>> stdin = StreamController<List<int>>();
      final StreamController<List<int>> stdout = StreamController<List<int>>();
      final StringBuffer log = StringBuffer();
      final List<String> lines = <String>[];
      final Completer<Map<String, dynamic>> answer =
          Completer<Map<String, dynamic>>();
      stdout.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((String line) {
            lines.add(line);
            final Map<String, dynamic> m =
                json.decode(line) as Map<String, dynamic>;
            if (m['id'] == 2 && !answer.isCompleted) answer.complete(m);
          });

      final LaToolkitMcpServer server = serveStdio(
        backend: Uri.parse('http://toolkit:2010'),
        input: stdin.stream,
        output: stdout.sink,
        log: log,
        client: client,
      );
      void send(Map<String, dynamic> m) =>
          stdin.add(utf8.encode('${json.encode(m)}\n'));
      send(<String, dynamic>{
        'jsonrpc': '2.0',
        'id': 1,
        'method': 'initialize',
        'params': <String, dynamic>{
          'protocolVersion': '2025-06-18',
          'capabilities': <String, dynamic>{},
          'clientInfo': <String, dynamic>{'name': 't', 'version': '0'},
        },
      });
      send(<String, dynamic>{
        'jsonrpc': '2.0',
        'method': 'notifications/initialized',
      });
      send(<String, dynamic>{
        'jsonrpc': '2.0',
        'id': 2,
        'method': 'tools/call',
        'params': <String, dynamic>{
          'name': 'la_lint_project',
          'arguments': <String, dynamic>{'project': 'portal'},
        },
      });

      final Map<String, dynamic> r = await answer.future.timeout(
        const Duration(seconds: 30),
      );
      final Map<String, dynamic> result = r['result'] as Map<String, dynamic>;
      expect(result['isError'], isNot(true), reason: json.encode(result));
      final String text =
          ((result['content'] as List<dynamic>).single
                  as Map<String, dynamic>)['text']
              as String;
      expect(text, contains("You don't have any SSH key"));

      expect(log.toString(), isNotEmpty, reason: 'the models did print');
      for (final String line in lines) {
        expect(
          (json.decode(line) as Map<String, dynamic>)['jsonrpc'],
          '2.0',
          reason: line,
        );
      }
      await server.shutdown();
      await stdin.close();
    },
  );
}
