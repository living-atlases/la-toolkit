import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

class FileUtils {
  static Future<String?> getYoRcJson() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      if (file.extension == 'json' && file.name == '.yo-rc.json') {
        Uint8List? s = file.bytes;
        if (s != null) {
          return utf8.decode(s);
        } else {
          print('Error reading the file ${file.name}');
        }
      } else {
        throw ('User canceled the picker or invalid file');
      }
    } else {
      // User canceled the picker
    }
  }
}
