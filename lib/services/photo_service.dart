import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:gallery_saver/gallery_saver.dart';

class PhotoService {
  /// Copies developed photos into the system Photos library. Returns how many
  /// were saved.
  static Future<int> exportToGallery(List<File> files, String albumName) async {
    var saved = 0;
    for (final file in files) {
      try {
        final ok = await GallerySaver.saveImage(file.path, albumName: albumName);
        if (ok == true) saved++;
      } catch (e) {
        debugPrint('Error exporting photo: $e');
      }
    }
    return saved;
  }
}
