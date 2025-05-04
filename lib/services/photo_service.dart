import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:uuid/uuid.dart';

class PhotoService {
  static final Uuid _uuid = const Uuid();

  /// Save photo file to local app directory AND gallery
  static Future<String?> savePhoto(File imageFile, String tripName) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final tripDir = Directory('${appDir.path}/$tripName');

      // Create trip folder if not exists
      if (!await tripDir.exists()) {
        await tripDir.create(recursive: true);
      }

      // Create unique filename
      final filename = '${_uuid.v4()}.jpg';
      final savedImagePath = '${tripDir.path}/$filename';
      final savedImageFile = await imageFile.copy(savedImagePath);

      // Save to gallery (creates album if needed)
      await GallerySaver.saveImage(
        savedImageFile.path,
        albumName: '36 Pics/$tripName',
      );

      return savedImageFile.path;
    } catch (e) {
      print('Error saving photo: $e');
      return null;
    }
  }
}
