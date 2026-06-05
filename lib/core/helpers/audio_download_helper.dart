import 'dart:io';

import 'package:file_save_directory/file_save_directory.dart';

class AudioDownloadHelper {
  static Future<FileSaveResult> downloadAudio({
    required String sourcePath,
    required String suggestedName,
  }) async {
    final source = File(sourcePath);
    if (!source.existsSync()) {
      return FileSaveResult(
        success: false,
        error: 'Audio file not found',
        path: null,
      );
    }

    final extension = _fileExtension(sourcePath);
    final safeBase = _safeFileName(suggestedName);
    final fileName =
        extension.isNotEmpty ? '$safeBase$extension' : '$safeBase.m4a';

    final bytes = await source.readAsBytes();
    return FileSaveDirectory.instance.saveFile(
      fileName: fileName,
      fileBytes: bytes,
      location: SaveLocation.downloads,
      openAfterSave: false,
    );
  }

  static String _fileExtension(String path) {
    final dotIndex = path.lastIndexOf('.');
    if (dotIndex <= 0 || dotIndex == path.length - 1) return '';
    return path.substring(dotIndex);
  }

  static String _safeFileName(String name) {
    final trimmed = name.trim();
    final base = trimmed.isEmpty ? 'Recording' : trimmed;
    return base.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  }
}
