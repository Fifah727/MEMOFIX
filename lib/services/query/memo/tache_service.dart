import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:memofix/models/TacheItem.dart';
import '../../db.dart';
import 'package:memofix/services/query/memo/image_service.dart';

class TacheService {
  final DbService _dbService = DbService();
  // utiliser dans une boucle pour all
  // Récupérer tous les mémos
  Future<List<TacheItem>> getTachesByMemo(int idMemo) async {
    final db = await _dbService.getDatabase();
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        "tache",
        where: "id_memo = ?",
        whereArgs: [idMemo],
      );
      return maps.map((map) => _mapToTacheItem(map)).toList();
    } catch (e) {
      print("Erreur lors de la lecture des taches du memo $idMemo : $e");
      return [];
    }
  }

  // ajout
  Future<int?> ajouterTache(TacheItem tache) async {
    final db = await _dbService.getDatabase();
    try {
      final idTache = await db.insert("tache", _TacheItemToMap(tache));
      print("Ajout effectuer");
      return idTache;
    } catch (e) {
      print("Erreur ajout tache : $e");
      return null;
    }
  }

  Future<bool> supprimerTache(int id_tache) async {
    final db = await _dbService.getDatabase();
    try {
      await db.delete('tache', where: 'id = ?', whereArgs: [id_tache]);
      print("Suppression effectuer");
      return true;
    } catch (e) {
      print("Erreur supp tache : $e");
      return false;
    }
  }

  // modif
  Future<bool> modifTache(TacheItem tache) async {
    final db = await _dbService.getDatabase();
    try {
      await db.update(
        'tache',
        _TacheItemToMap(tache),
        where: 'id = ?',
        whereArgs: [tache.id],
      );
      return true;
    } catch (e) {
      print("Erreur modif tache : $e");
      return false;
    }
  }

  // supp

  Future<bool> supprimerTacheByMemo(int id) async {
    final db = await _dbService.getDatabase();
    try {
      final taches = await getTachesByMemo(id);

      for (final t in taches) {
        await supprimerTache(t.id); // img.fileName = nom du fichier
      }

      await db.delete('tache', where: 'id_memo = ?', whereArgs: [id]);

      return true;
    } catch (e) {
      print("Erreur supp taches : $e");
      return false;
    }
  }

  // Récupérer tous les mémos
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

  bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  // Convertir Map en TacheItem
  TacheItem _mapToTacheItem(Map<String, dynamic> map) {
    return TacheItem(
      id: map['id'] is int
          ? map['id']
          : int.tryParse(map['id'].toString()) ?? 0,
      contenu: map['contenu']?.toString() ?? '',
      id_memo: map['id_memo'] is int
          ? map['id_memo']
          : int.tryParse(map['id_memo'].toString()) ?? 0,
      createdAt: _parseDate(map['createdAt']),
      fait: _parseBool(map['fait']),
    );
  }

  // ajout_memo
  Map<String, dynamic> _TacheItemToMap(TacheItem tache) {
    return {
      "contenu": tache.contenu,
      "id_memo": tache.id_memo,
      "fait": tache.fait ? "true" : "false",
      "createdAt": tache.createdAt.toIso8601String(),
    };
  }
}
