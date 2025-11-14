// import 'package:file_picker/file_picker.dart';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;
import 'package:universal_html/html.dart';

class FileUtils {
  static Future<String?> getYoRcJson() async {
    final Completer<String> completer = Completer<String>();
    final FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.multiple = false;
    uploadInput.draggable = true;
    uploadInput.accept = 'application/json';
    uploadInput.required = true;

    const String errorMessage = 'User canceled the picker or invalid file';

    uploadInput.onAbort.listen((html.Event event) {
      debugPrint('On file upload abort');
      completer.completeError(errorMessage);
    });

    uploadInput.onMouseUp.first.then((html.MouseEvent e) async {
      await onChange(e, uploadInput, completer, errorMessage);
    });

    uploadInput.onEnded.listen((html.Event event) {
      debugPrint('On file upload ended');
      completer.completeError(errorMessage);
    });

    uploadInput.onError.listen((html.Event e) {
      debugPrint('On file upload error ($e)');
      completer.completeError(errorMessage);
    });

    // Trying to solve the cancel file dialog without success
    // https://stackoverflow.com/questions/4628544/how-to-detect-when-cancel-is-clicked-on-file-input?page=1&tab=active#tab-top
    uploadInput.onClick.listen((html.MouseEvent event) {
      debugPrint('Clicked');
      BodyElement().onFocus.first.then((html.Event event) {
//      BodyElement().onFocus.listen((event) {
        debugPrint(event.toString());
        completer.completeError(errorMessage);
      });
    });

    // this works better in safari
    uploadInput.addEventListener('change', (html.Event e) async {
      await onChange(e, uploadInput, completer, errorMessage);
    });
    /* // not add two listeners
    uploadInput.onChange.listen((e) async {
      await onChange(e, uploadInput, completer, errorMessage);
    }); */
    // document.body!.append(uploadInput);
/*    uploadInput.onClick.listen((event) {
//      document.body.onfocus.
    });*/
    uploadInput.click();

    final String content = await completer.future;

    uploadInput.remove();
    debugPrint('End of getYoRcJson');
    return content;
  }

  static Future<dynamic> onChange(
      html.Event e, html.FileUploadInputElement uploadInput, Completer<String> completer, String errorMessage) async {
    debugPrint(e.type);

    final List<html.File>? files = uploadInput.files;

    if (files != null && files.isNotEmpty) {
      final html.File file = files[0];
      if (file.type == 'application/json' && file.name == '.yo-rc.json') {
        final Uint8List? u8 = await _getHtmlFileContent(file, completer);
        if (u8 != null) {
          final String content = utf8.decode(u8);
          completer.complete(content);
        } else {
          debugPrint('error reading the .yo-rc.json');
          completer.completeError(errorMessage);
        }
      } else {
        debugPrint('error reading the .yo-rc.json');
        completer.completeError(errorMessage);
      }
    } else {
      debugPrint('No file selected');
      completer.completeError(errorMessage);
    }
  }

  static Future<Uint8List?> _getHtmlFileContent(File blob, completer) async {
    Uint8List? file;
    final html.FileReader reader = FileReader();
    reader.readAsDataUrl(blob.slice(0, blob.size, blob.type));
    reader.onError.listen((html.ProgressEvent error) => completer.completeError(error));
    reader.onLoadEnd.listen((html.ProgressEvent event) {
      final String r = reader.result.toString().split(',').last;
      final Uint8List data = const Base64Decoder().convert(r);
      file = data;
    }).onData((html.ProgressEvent data) {
      final String r = reader.result.toString().split(',').last;
      file = const Base64Decoder().convert(r);
      // return file;
    });
    while (file == null) {
      await Future.delayed(const Duration(milliseconds: 1000));
      if (file != null) {
        break;
      }
    }
    return file;
  }
}
