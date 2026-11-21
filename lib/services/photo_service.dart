import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';

class PhotoService {
  /// Copies developed photos into the system Photos library, filed into
  /// [albumName] when given. Returns how many were saved.
  static Future<int> exportToGallery(List<File> files, {String? albumName}) async {
    try {
      final toAlbum = albumName != null;
      if (!await Gal.hasAccess(toAlbum: toAlbum) &&
          !await Gal.requestAccess(toAlbum: toAlbum)) {
        return 0;
      }
    } catch (e) {
      debugPrint('Error requesting photo access: $e');
      return 0;
    }
    var saved = 0;
    for (final file in files) {
      try {
        await Gal.putImage(file.path, album: albumName);
        saved++;
      } catch (e) {
        debugPrint('Error exporting photo: $e');
      }
    }
    return saved;
  }
}
