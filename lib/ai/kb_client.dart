// Vendored from living-atlas-kb (https://github.com/living-atlases/kb),
// dart/lib/src/kb_client.dart. Keep in sync with upstream.

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'kb_config.dart';
import 'kb_models.dart';

/// REST client for the Living Atlas Knowledge Base API.
class KbClient {
  final KbConfig config;
  final http.Client _http;

  KbClient({required this.config, http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  /// Semantic search query — returns ranked context chunks.
  Future<QueryResponse> query(String question) async {
    final uri = Uri.parse('${config.baseUrl}/api/query');
    final response = await _http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'question': question,
        'collection': config.collection,
        'n_results': config.nResults,
      }),
    );
    if (response.statusCode != 200) {
      throw KbException('Query failed: ${response.statusCode} ${response.body}');
    }
    return QueryResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// List available collections with document counts.
  Future<List<CollectionInfo>> listCollections() async {
    final uri = Uri.parse('${config.baseUrl}/api/collections');
    final response = await _http.get(uri);
    if (response.statusCode != 200) {
      throw KbException('Collections failed: ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['collections'] as List)
        .map((e) => CollectionInfo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetch the repository manifest (orgs, repos, tier1) from the server.
  Future<ReposManifest> listRepos() async {
    final uri = Uri.parse('${config.baseUrl}/api/repos');
    final response = await _http.get(uri);
    if (response.statusCode != 200) {
      throw KbException('Repos failed: ${response.statusCode}');
    }
    return ReposManifest.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// RAG chat — streams text tokens from the server via SSE.
  ///
  /// Each yielded [String] is a text token. Throws [KbException] on error.
  /// [history] is the prior conversation as `[{role: user|assistant, content: ...}]`.
  Stream<String> chat(
    String question, {
    List<Map<String, String>> history = const [],
  }) async* {
    final uri = Uri.parse('${config.baseUrl}/api/chat');
    final request = http.Request('POST', uri)
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode({
        'question': question,
        'collection': config.collection,
        'n_results': config.nResults,
        'history': history,
      });

    final streamedResponse = await _http.send(request);
    if (streamedResponse.statusCode != 200) {
      throw KbException('Chat failed: ${streamedResponse.statusCode}');
    }

    final lineStream = streamedResponse.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    await for (final line in lineStream) {
      if (!line.startsWith('data: ')) continue;
      final payload = line.substring(6).trim();
      if (payload == '[DONE]') break;

      final Map<String, dynamic> event;
      try {
        event = jsonDecode(payload) as Map<String, dynamic>;
      } catch (_) {
        continue;
      }

      if (event.containsKey('error')) {
        throw KbException(event['error'] as String);
      }
      final token = event['token'] as String?;
      if (token != null && token.isNotEmpty) {
        yield token;
      }
    }
  }

  void dispose() => _http.close();
}

class KbException implements Exception {
  final String message;
  const KbException(this.message);

  @override
  String toString() => 'KbException: $message';
}
