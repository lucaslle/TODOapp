import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Lets the person choose a photo and keeps a private copy of it, so the
/// profile picture survives the gallery original being moved or deleted.
class ProfilePhotoService {
  const ProfilePhotoService();

  static const String _folderName = 'profile';
  static const int _maxSide = 768;
  static const int _quality = 85;

  /// Opens the gallery. Returns the path of the stored copy, or null when the
  /// person backed out.
  Future<String?> pickFromGallery() async {
    final XFile? picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: _maxSide.toDouble(),
      maxHeight: _maxSide.toDouble(),
      imageQuality: _quality,
    );
    if (picked == null) return null;

    final Directory documents = await getApplicationDocumentsDirectory();
    final Directory folder = Directory(p.join(documents.path, _folderName));
    await folder.create(recursive: true);

    final String extension = p.extension(picked.path).isEmpty
        ? '.jpg'
        : p.extension(picked.path);
    final String target = p.join(
      folder.path,
      'avatar_${DateTime.now().millisecondsSinceEpoch}$extension',
    );
    await File(picked.path).copy(target);
    await _deleteOtherPhotos(folder, keep: target);
    return target;
  }

  Future<void> delete(String? path) async {
    if (path == null) return;
    final File file = File(path);
    if (await file.exists()) await file.delete();
  }

  Future<void> _deleteOtherPhotos(Directory folder, {required String keep}) async {
    await for (final FileSystemEntity entity in folder.list()) {
      if (entity is File && entity.path != keep) await entity.delete();
    }
  }
}
