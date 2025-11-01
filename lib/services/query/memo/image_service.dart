import 'package:flutter/rendering.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:memofix/models/ImageItem.dart';
import '../../db.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ImageService {
  final DbService _dbService = DbService();
  // Récupérer tous les mémos
  Future<List<ImageItem>> getImagesByMemo(int idMemo) async {
    final db = await _dbService.getDatabase();
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        "images",
        where: "id_memo = ?",
        whereArgs: [idMemo],
      );

      return maps.map((map) => _mapToImageItem(map)).toList();
    } catch (e) {
      print("Erreur lors de la lecture des images du memo $idMemo : $e");
      return [];
    }
  }

  Future<int?> ajouterImg(ImageItem image) async {
    final db = await _dbService.getDatabase();
    try {
      final idImage = await db.insert("images", _ImageItemToMap(image));
      return idImage;
    } catch (e) {
      print("Erreur ajout image : $e");
      return null;
    }
  }

  Future<void> deleteImage(String fileName) async {
    // 1️⃣ Récupérer le dossier de l'application
    //final appDir = await getApplicationDocumentsDirectory();
    // final memoImageDir = Directory('${appDir.path}/memos_images');

    // 2️⃣ Construire le chemin complet du fichier
    final file = File('$fileName');

    // 3️⃣ Vérifier si le fichier existe puis supprimer
    if (await file.exists()) {
      await file.delete();
      print('Image supprimée : $fileName');
    } else {
      print('Fichier non trouvé : $fileName');
    }
  }

  Future<bool> supprimerImgByMemo(int idMemo) async {
    final db = await _dbService.getDatabase();

    try {
      // 1️⃣ Récupérer toutes les images liées à ce memo
      final images = await getImagesByMemo(idMemo);

      // 2️⃣ Supprimer chaque fichier dans le dossier local
      for (final img in images) {
        debugPrint("Image appData supprimer");
        await deleteImage(img.nom_img); // img.fileName = nom du fichier
      }

      // 3️⃣ Supprimer les enregistrements dans la base
      await db.delete('images', where: 'id_memo = ?', whereArgs: [idMemo]);
      debugPrint("Image BD supprimer");

      return true;
    } catch (e) {
      print("Erreur suppression images du memo $idMemo : $e");
      return false;
    }
  }

  DateTime _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is int) {
      // si stocké en timestamp
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  // Convertir Map en MemoItem
  ImageItem _mapToImageItem(Map map) {
    return ImageItem(
      id: map['id'] as int,
      nom_img: map['nom_img'] as String? ?? '',
      date_ajout: _parseDate(map['date_ajout']),
      id_memo: map['id_memo'] as int,
    );
  }

  // ajout_memo
  Map<String, dynamic> _ImageItemToMap(ImageItem img) {
    return {
      "id_memo": img.id_memo,
      "nom_img": img.nom_img,
      "date_ajout": img.date_ajout.toIso8601String(),
    };
  }
}
