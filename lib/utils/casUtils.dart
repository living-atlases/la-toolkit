import 'api.dart';

class CASUtils {
  static Future<String> gen128CasKey() async {
    return Api.genCasKey(128);
  }

  static Future<String> gen256CasKey() async {
    return Api.genCasKey(256);
  }

  static Future<String> gen512CasKey() async {
    return await Api.genCasKey(512);
  }
}
