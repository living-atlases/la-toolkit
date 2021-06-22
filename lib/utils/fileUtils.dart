// import 'package:file_picker/file_picker.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:universal_html/html.dart' as html;
import 'package:universal_html/html.dart';

class FileUtils {
  static Future<String?> getYoRcJson() async {
    final completer = Completer<String>();
    FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.multiple = false;
    uploadInput.draggable = true;
    uploadInput.accept = 'application/json';
    uploadInput.required = true;

    var errorMessage = 'User canceled the picker or invalid file';

    uploadInput.onAbort.listen((event) {
      print('On file upload abort');
      completer.completeError(errorMessage);
    });

    uploadInput.onMouseUp.first.then((e) async {
      await onChange(e, uploadInput, completer, errorMessage);
    });

    uploadInput.onEnded.listen((event) {
      print('On file upload ended');
      completer.completeError(errorMessage);
    });

    uploadInput.onError.listen((e) {
      print('On file upload error ($e)');
      completer.completeError(errorMessage);
    });

    // Trying to solve the cancel file dialog without success
    // https://stackoverflow.com/questions/4628544/how-to-detect-when-cancel-is-clicked-on-file-input?page=1&tab=active#tab-top
    uploadInput.onClick.listen((event) {
      print('Clicked');
      BodyElement().onFocus.first.then((event) {
//      BodyElement().onFocus.listen((event) {
        print(event);
        completer.completeError(errorMessage);
      });
    });

    // this works better in safari
    uploadInput.addEventListener('change', (e) async {
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
    print('End of getYoRcJson');
    return content;
  }

  static Future onChange(html.Event e, html.FileUploadInputElement uploadInput,
      Completer<String> completer, String errorMessage) async {
    print(e.type);

    final files = uploadInput.files;

    if (files != null && files.isNotEmpty) {
      final file = files[0];
      if (file.type == 'application/json' && file.name == '.yo-rc.json') {
        Uint8List? u8 = await _getHtmlFileContent(file, completer);
        if (u8 != null) {
          String content = utf8.decode(u8);
          completer.complete(content);
        } else {
          print('error reading the .yo-rc.json');
          completer.completeError(errorMessage);
        }
      } else {
        print('error reading the .yo-rc.json');
        completer.completeError(errorMessage);
      }
    } else {
      print('No file selected');
      completer.completeError(errorMessage);
    }
  }

  static Future<Uint8List?> _getHtmlFileContent(File blob, completer) async {
    Uint8List? file;
    final reader = FileReader();
    reader.readAsDataUrl(blob.slice(0, blob.size, blob.type));
    reader.onError.listen((error) => completer.completeError(error));
    reader.onLoadEnd.listen((event) {
      var r = reader.result.toString().split(",").last;
      Uint8List data = const Base64Decoder().convert(r);
      file = data;
    }).onData((data) {
      var r = reader.result.toString().split(",").last;
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
