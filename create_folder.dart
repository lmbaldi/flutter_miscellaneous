import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Folder {

  static Future<String> createFolder(String folderName) async {

    final Directory _appDocDir = await

    getApplicationDocumentsDirectory();

    final Directory _appDocDirFolder = Directory('${_appDocDir.path}/$folderName/');

    if (await _appDocDirFolder.exists()) {
      return _appDocDirFolder.path;
    } else {
      final Directory _appDocDirNewFolder = await _appDocDirFolder.create(
          recursive: true);
      return _appDocDirNewFolder.path;
    }
  }
}
