import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

class MemoImageService {
  /// Crée un dossier pour stocker toutes les images de mémo
  Future<Directory> _getMemoImageDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final memoImageDir = Directory('${appDir.path}/memos_images');
    if (!(await memoImageDir.exists())) {
      await memoImageDir.create(recursive: true);
    }
    return memoImageDir;
  }

  /// sélectionne une image et la sauvegarde localement
  Future<File?> pickAndSaveImage(String path) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return null;

    final dir = await _getMemoImageDir();

    // Récupère l'extension d'origine du fichier
    final extension = p.extension(pickedFile.path);

    // Crée un nom de fichier unique avec la même extension
    final fileName = '${DateTime.now().millisecondsSinceEpoch}$extension';

    final savedImage = await File(
      pickedFile.path,
    ).copy('${dir.path}/$fileName');

    return savedImage;
  }

  /// Supprime une image localement
  Future<void> deleteImage(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Récupère le chemin complet du dossier d’images
  Future<String> getImageFolderPath() async {
    final dir = await _getMemoImageDir();
    return dir.path;
  }
}
