import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker_web/file_picker_web.dart';
import 'package:universal_html/html.dart';

class FileUtils {
  static Future<String> getYoRcJson() async {
    File file = await FilePicker.getFile(allowedExtensions: ['json']);

    if (file != null &&
        file.type == 'application/json' &&
        file.name == '.yo-rc.json') {
      Uint8List s = await _getHtmlFileContent(file);
      return utf8.decode(s);
    } else {
      throw ('User canceled the picker or invalid file');
    }
  }

  // Adapted from
  // https://blogs.ashrithgn.com/a-simple-way-to-upload-a-file-to-server-from-flutter-web-app/
  static Future<Uint8List> _getHtmlFileContent(File blob) async {
    Uint8List file;
    final reader = FileReader();
    reader.readAsDataUrl(blob.slice(0, blob.size, blob.type));
    reader.onLoadEnd.listen((event) {
      var r = reader.result.toString().split(",").last;
      Uint8List data = Base64Decoder().convert(r);
      file = data;
    }).onData((data) {
      var r = reader.result.toString().split(",").last;
      var file = Base64Decoder().convert(r);
      return file;
    });
    while (file == null) {
      await new Future.delayed(const Duration(milliseconds: 1));
      if (file != null) {
        break;
      }
    }
    return file;
  }
}
