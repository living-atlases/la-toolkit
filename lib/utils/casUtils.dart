import 'dart:convert';

import 'package:http/http.dart' as http;

class CASUtils {
  static Future<String> gen128CasKey() async {
    return _genCasKey(128);
  }

  static Future<String> gen256CasKey() async {
    return _genCasKey(256);
  }

  static Future<String> gen512CasKey() async {
    return await _genCasKey(512);
  }

  static Future<String> _genCasKey(int size) async {
    var url = "https://jsonplaceholder.typicode.com/posts/1";
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      return jsonResponse["title"].toString();
    } else {
      return "";
    }
  }
}
