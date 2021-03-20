// import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'package:universal_html/html.dart' as html;
import 'package:universal_html/html.dart';

class FileUtils {
  static Future<String?> getYoRcJson() async {
    FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.multiple = false;
    uploadInput.draggable = true;
    uploadInput.click();

    String? content;
    uploadInput.onChange.listen((e) async {
      final files = uploadInput.files;
      var errorMessage = 'User canceled the picker or invalid file';
      if (files != null && files.length > 0) {
        final file = files[0];
        if (file.type == 'application/json' && file.name == '.yo-rc.json') {
          Uint8List? u8 = await _getHtmlFileContent(file);
          if (u8 != null) content = utf8.decode(u8);
        } else {
          throw (errorMessage);
        }
      } else {
        throw (errorMessage);
      }
    });
    // Wait til the reader ends
    while (content == null) {
      await new Future.delayed(const Duration(milliseconds: 100));
      if (content != null) {
        break;
      }
    }
    return content;
  }

  static Future<Uint8List?> _getHtmlFileContent(File blob) async {
    Uint8List? file;
    final reader = FileReader();
    reader.readAsDataUrl(blob.slice(0, blob.size, blob.type));
    reader.onLoadEnd.listen((event) {
      var r = reader.result.toString().split(",").last;
      Uint8List data = Base64Decoder().convert(r);
      file = data;
    }).onData((data) {
      var r = reader.result.toString().split(",").last;
      file = Base64Decoder().convert(r);
      // return file;
    });
    while (file == null) {
      await new Future.delayed(const Duration(milliseconds: 100));
      if (file != null) {
        break;
      }
    }
    return file;
  }
}
