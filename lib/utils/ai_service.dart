import 'dart:convert';

import 'package:http/http.dart' as http;

class AiService {
  static const String _baseUrl = 'http://localhost:2011/api/v1';

  /// Query the AI knowledge base
  /// Returns a map with:
  /// - answer: the formatted answer from the KB
  /// - sources: list of source citations
  /// - contextUsed: the context information that was used
  /// - timestamp: when the query was processed
  static Future<Map<String, dynamic>> query({
    required String question,
    String? projectId,
    bool includeContext = true,
    int topK = 5,
  }) async {
    try {
      final http.Response response = await http
          .post(
            Uri.parse('$_baseUrl/ai/query'),
            headers: <String, String>{'Content-Type': 'application/json'},
            body: jsonEncode(<String, dynamic>{
              'question': question,
              'projectId': projectId,
              'includeContext': includeContext,
              'topK': topK,
            }),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timeout'),
          );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 400) {
        throw Exception('Invalid question');
      } else if (response.statusCode == 404) {
        throw Exception('Project not found');
      } else if (response.statusCode == 500) {
        throw Exception('Server error - ChromaDB might not be available');
      } else {
        throw Exception('Query failed with status ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Connection error: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  /// Check if the AI service is available
  static Future<bool> isAvailable() async {
    try {
      // Try a simple query to check if backend is responding
      await query(question: 'ping', includeContext: false);
      return true;
    } catch (_) {
      return false;
    }
  }
}
