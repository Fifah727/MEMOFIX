import 'package:flutter/rendering.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:memofix/models/AudioItem.dart';
import '../../db.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AudioService {
  final DbService _dbService = DbService();

  Future<AudioItem?> getSingleAudioByMemo(int idMemo) async {
    final db = await _dbService.getDatabase();
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        "audio",
        where: "id_memo = ?",
        whereArgs: [idMemo],
        limit: 1,
      );
      if (maps.isNotEmpty) {
        return _mapToAudioItem(maps.first);
      }
      print("Audio single recuperer");
      return null;
    } catch (e) {
      print("Erreur lecture audio unique : $e");
      return null;
    }
  }

  Future<List<AudioItem>> getAudiosByMemo(int idMemo) async {
    final db = await _dbService.getDatabase();
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        "audio",
        where: "id_memo = ?",
        whereArgs: [idMemo],
      );

      return maps.map((map) => _mapToAudioItem(map)).toList();
    } catch (e) {
      print("Erreur lors de la lecture des audios du memo $idMemo : $e");
      return [];
    }
  }

  Future<int?> ajouterAudio(AudioItem Audio) async {
    final db = await _dbService.getDatabase();
    try {
      final idAudio = await db.insert("audio", _AudioItemToMap(Audio));
      print(
        "2 - Bd : Audio ajouter avec succes avec id_memo: ${Audio.id_memo}",
      );
      return idAudio;
    } catch (e) {
      print("Erreur ajout Audio : $e");
      return null;
    }
  }

  Future<void> deleteAudio(String fileName) async {
    // 2️⃣ Construire le chemin complet du fichier
    final file = File('$fileName');
    print("Filename dans deleteAudio :${fileName} ");

    // 3️⃣ Vérifier si le fichier existe puis supprimer
    if (await file.exists()) {
      await file.delete();
    } else {
      print('Fichier non trouvé : $fileName');
    }
  }

  Future<bool> supprimerAudioByMemo(int idMemo) async {
    final db = await _dbService.getDatabase();

    try {
      // 1️⃣ Récupérer toutes les audios liées à ce memo
      final audios = await getAudiosByMemo(idMemo);

      // 2️⃣ Supprimer chaque fichier dans le dossier local
      for (final Audio in audios) {
        debugPrint("1 - Audio appData supprimer");
        await deleteAudio(Audio.nom);
      }

      // 3️⃣ Supprimer les enregistrements dans la base
      await db.delete('audio', where: 'id_memo = ?', whereArgs: [idMemo]);
      debugPrint("2 - Audio BD supprimer avec id_memo : ${idMemo}");

      return true;
    } catch (e) {
      print("Erreur suppression audios du memo $idMemo : $e");
      return false;
    }
  }

  // Convertir Map en MemoItem
  AudioItem _mapToAudioItem(Map map) {
    return AudioItem(
      id: map['id'] as int,
      nom: map['nom'] as String? ?? '',
      id_memo: map['id_memo'] as int,
    );
  }

  // ajout_memo
  Map<String, dynamic> _AudioItemToMap(AudioItem Audio) {
    return {"nom": Audio.nom, "id_memo": Audio.id_memo};
  }
}
