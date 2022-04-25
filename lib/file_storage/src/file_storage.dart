// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

enum ReaderType { string, byteList, stringList, file }

enum SaveFileDirType { simpleStorage, persistantStorage, autoRemoveStorage, remoteConfigStorage }

class FileStorage {
  static const TYPE_TO_DIR_MAP = <SaveFileDirType, String>{
    SaveFileDirType.simpleStorage: USER_STORAGE_DIR_NAME,
    SaveFileDirType.persistantStorage: PERSISTANT_STORAGE_DIR_NAME,
    SaveFileDirType.autoRemoveStorage: TEMP_FILE_DIR_NAME,
    SaveFileDirType.remoteConfigStorage: REMOTE_CONFIG_DIR_NAME,
  };

  static const String USER_STORAGE_DIR_NAME = 'user_storage';
  static const String PERSISTANT_STORAGE_DIR_NAME = 'persistant_storage';
  static const String TEMP_FILE_DIR_NAME = 'temp_storage';
  static const String REMOTE_CONFIG_DIR_NAME = 'remote_configs';
  static const Duration EXPIRATION_DURATION = Duration(days: 1);

  static Future<String> get localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  ///Method saves any file to cache [dir] in ApplicationDocumentsDirectory
  ///[dir] - name of sub dir in ApplicationDocumentsDirectory to create (can be null)
  ///[name] and [fileExtension] - name and extension of file, that will be stored in local storage,
  ///P.S. file extension without dot. (example: png)
  ///[data] - data can be String or Byte list (List<int>). Any other type will be converted to string. (cannot be null)
  ///
  Future<bool> cacheFile(
      {required SaveFileDirType globalDir,
      String? subDir,
      required String name,
      required String fileExtension,
      required dynamic data}) async {
    if (data == null) {
      return false;
    }

    try {
      final file = await _getFileCachedByName(
          subDirs: _getDir(globalDir, subDir),
          name: name,
          fileExtension: fileExtension,
          create: true);

      if (data is String) {
        await file.writeAsString(data);
      } else if (data is List<int>) {
        await file.writeAsBytes(data);
      } else {
        await file.writeAsString(data.toString());
      }
    } catch (e) {
      return false;
    }

    if (globalDir == SaveFileDirType.autoRemoveStorage) {
      _checkTempAndRemoveExpired();
    }

    return true;
  }

  ///Method returns typed data (String type) from file in [dir] in ApplicationDocumentsDirectory
  ///[dir] - name of sub dir in ApplicationDocumentsDirectory (can be null)
  ///[name] and [fileExtension] - name and extension of file, that stored in local storage,
  ///P.S. file extension without dot. (example: png)
  ///
  Future<String?> readCachedFileAsString(
      {required SaveFileDirType globalDir,
      String? subDir,
      required String name,
      required String fileExtension}) async {
    try {
      return _readCachedFile<String>(_getDir(globalDir, subDir), name, fileExtension);
    } catch (e) {
      return null;
    }
  }

  ///Method returns typed data (List<int> type) from file in [dir] in ApplicationDocumentsDirectory
  ///[dir] - name of sub dir in ApplicationDocumentsDirectory (can be null)
  ///[name] and [fileExtension] - name and extension of file, that stored in local storage,
  ///P.S. file extension without dot. (example: png)
  ///
  Future<List<int>?> readCachedFileAsByteList(
      {required SaveFileDirType globalDir,
      String? subDir,
      required String name,
      required String fileExtension}) async {
    try {
      return _readCachedFile<List<int>>(_getDir(globalDir, subDir), name, fileExtension);
    } catch (e) {
      return null;
    }
  }

  ///Method returns typed data (List<String> type) from file in [dir] in ApplicationDocumentsDirectory
  ///[dir] - name of sub dir in ApplicationDocumentsDirectory (can be null)
  ///[name] and [fileExtension] - name and extension of file, that stored in local storage,
  ///P.S. file extension without dot. (example: png)
  ///
  Future<List<String>?> readCachedFileAsStringList(
      {required SaveFileDirType globalDir,
      String? subDir,
      required String name,
      required String fileExtension}) async {
    try {
      return _readCachedFile<List<String>>(_getDir(globalDir, subDir), name, fileExtension);
    } catch (e) {
      return null;
    }
  }

  ///Method returns file from [dir] in ApplicationDocumentsDirectory
  ///[dir] - name of sub dir in ApplicationDocumentsDirectory (can be null)
  ///[name] and [fileExtension] - name and extension of file, that stored in local storage,
  ///P.S. file extension without dot. (example: png)
  ///
  Future<File?> getCachedFile(
      {required SaveFileDirType globalDir,
      String? subDir,
      required String? name,
      required String? fileExtension}) async {
    try {
      return _readCachedFile<File>(_getDir(globalDir, subDir), name, fileExtension);
    } catch (e) {
      return null;
    }
  }

  ///Method returns true if file in [dir] with [name] and [fileExtension] exists.
  ///Method returns false if file not exist in this directory
  ///[dir] - name of sub dir in ApplicationDocumentsDirectory (can be null)
  ///[name] and [fileExtension] - name and extension of file, that stored in local storage,
  ///P.S. file extension without dot. (example: png)
  ///
  Future<bool> checkFileExist(
      {required SaveFileDirType globalDir,
      String? subDir,
      required String? name,
      required String? fileExtension}) async {
    try {
      return await (await _getFileCachedByName(
              name: name,
              subDirs: _getDir(globalDir, subDir),
              fileExtension: fileExtension,
              create: false))
          .exists();
    } catch (e) {
      return false;
    }
  }

  ///Method saves any file to cache [TEMP_FILE_DIR_NAME] in ApplicationDocumentsDirectory
  ///Saved file will be auto-removed after [TEMP_FILE_DIR_NAME] Duration.
  ///Don't save here important configs or other usually used info.
  ///const dir is [TEMP_FILE_DIR_NAME]
  ///[fileName] and [fileExtension] - name and extension of file, that will be stored in local storage,
  ///P.S. file extension without dot. (example: png)
  ///[data] - data can be String or Byte list (List<int>). Any other type will be converted to string. (cannot be null)
  ///

  Future<void> deleteLocalFolder({required SaveFileDirType globalDir, String? subDir}) async {
    final path = await localPath;
    var directory = _getDir(globalDir, subDir);
    var folder = Directory('$path/$directory');
    if (!await folder.exists()) {
      return;
    }

    await folder.delete(recursive: true);
  }

  Future<bool> copyFileTo({
    required SaveFileDirType newGlobalDir,
    required String newName,
    required String newFileExtension,
    required File? currentFile,
    String? newSubDir,
  }) async {
    if (currentFile == null || !currentFile.existsSync()) {
      return false;
    }

    return cacheFile(
        globalDir: newGlobalDir,
        subDir: newSubDir,
        name: newName,
        fileExtension: newFileExtension,
        data: await currentFile.readAsBytes());
  }

  Future<void> clearTempStorage() async {
    await _clearFolder(TEMP_FILE_DIR_NAME);
  }

  Future<void> clearUserFiles() async {
    await _clearFolder(USER_STORAGE_DIR_NAME);
  }

  Future<void> clearRemoteConfigFiles() async {
    await _clearFolder(REMOTE_CONFIG_DIR_NAME);
  }

  void clearPersistantStorage() async {
    //RUN IT IF YOU KNOW WHAT YOU DO
    await _clearFolder(PERSISTANT_STORAGE_DIR_NAME);
  }

  Future<void> clearAll() async {
    await FileStorage().clearUserFiles();
    await FileStorage().clearTempStorage();
    await FileStorage().clearRemoteConfigFiles();
  }

  Future<bool> deleteLocalFile(
      {SaveFileDirType? globalDir,
      String? subDir,
      required String name,
      required String fileExtension}) async {
    try {
      File f = await _getFileCachedByName(
          name: name,
          subDirs: _getDir(globalDir, subDir),
          fileExtension: fileExtension,
          create: false);
      FileSystemEntity? deletedFile;

      if (await f.exists()) {
        deletedFile = await f.delete();
      }

      if (deletedFile != null && !(await deletedFile.exists())) {
        return true;
      }

      return false;
    } catch (e) {
      debugPrint(e.toString());
      var dir = _getDir(globalDir, subDir);
      debugPrint('can not delete file $name.$fileExtension in $dir');
      return false;
    }
  }

  String? _getDir(SaveFileDirType? globalDir, String? subDir) {
    if (globalDir == null) {
      return null;
    }

    if (subDir == null || subDir == '') {
      return TYPE_TO_DIR_MAP[globalDir];
    }

    return TYPE_TO_DIR_MAP[globalDir]! + '/' + subDir;
  }

  Future<void> _clearFolder(String dir) async {
    if (dir == null) {
      return;
    }

    final path = await localPath;
    var folder = Directory('$path/$dir');
    if (!await folder.exists()) {
      return;
    }

    var list = await folder.list().toList();

    for (FileSystemEntity f in list) {
      await f.delete(recursive: true);
    }
  }

  Future<T?> _readCachedFile<T>(String? dir, String? name, String? fileExtension) async {
    try {
      final file = await _getFileCachedByName(
          subDirs: dir, name: name, fileExtension: fileExtension, create: false);

      if (T == File) {
        return file as T;
      }
      if (T == String) {
        return (await file.readAsString()) as T;
      }
      //cause: https://github.com/flutter/flutter/pull/30921
      if (T == <int>[].runtimeType) {
        return (await file.readAsBytes()).toList() as T;
      }
      //cause: https://github.com/flutter/flutter/pull/30921
      if (T == <String>[].runtimeType) {
        return (await file.readAsLines()) as T;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<File> _getFileCachedByName(
      {required String? name,
      required String? fileExtension,
      String? subDirs,
      required bool create}) async {
    final path = await localPath;
    final dir = subDirs == null || subDirs == '' ? path : '$path/$subDirs';
    final fileName = fileExtension == null ? name : '$name.$fileExtension';

    if (create) {
      var newDir = await Directory(dir).create(recursive: true);

      return File('${newDir.path}/$fileName');
    }

    return File('$dir/$fileName');
  }

  Future<void> _checkTempAndRemoveExpired() async {
    final path = await localPath;
    var folder = Directory('$path/$TEMP_FILE_DIR_NAME');
    if (!await folder.exists()) {
      return;
    }

    var list = await folder.list().toList();

    for (FileSystemEntity f in list) {
      final FileStat s = await f.stat();
      final Duration difference = DateTime.now().difference(s.changed);
      if (difference.compareTo(EXPIRATION_DURATION) >= 0) {
        debugPrint('${f.toString()} deleted');
        await f.delete();
      }
    }
  }
}

class ErrorHandler {
  static Future<T> runSafe<T>(Future<T> Function() func) {
    final onDone = Completer<T>();
    runZoned(
      func,
      onError: (e, s) {
        if (!onDone.isCompleted) {
          onDone.completeError(e, s as StackTrace);
        }
      },
    ).then((result) {
      if (!onDone.isCompleted) {
        onDone.complete(result);
      }
    });
    return onDone.future;
  }
}
