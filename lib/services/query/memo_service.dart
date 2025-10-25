import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:memofix/models/MemoItem.dart';
import '../db.dart';

class MemoService {
  final DbService _dbService = DbService();
  // Récupérer tous les mémos
  Future<List<MemoItem>> getMemos() async {
    final db = await _dbService.getDatabase();
    try {
      final List<Map<String, dynamic>> maps = await db.query("memo");
      // Convertir chaque map en MemoItem
      return maps.map((map) => _mapToMemoItem(map)).toList();
    } catch (e) {
      print("Erreur lors de la lecture des mémos : $e");
      return [];
    }
  }

  Future<int?> ajouterMemo(MemoItem memo) async {
    final db = await _dbService.getDatabase();
    try {
      final id_memo = await db.insert("memo", _memoItemToMap(memo));
      return id_memo;
    } catch (e) {
      print("Erreur ajout memo : $e");
      return null;
    }
  }

  Future<bool> supprimerMemo(int id) async {
    final db = await _dbService.getDatabase();
    try {
      // suppression donnees autres tables : à faire +tard
      await db.delete('memo', where: 'id_m = ?', whereArgs: [id]);
      return true;
    } catch (e) {
      print("Erreur ajout memo : $e");
      return false;
    }
  }

  Future<bool> modifMemo(MemoItem memo) async {
    final db = await _dbService.getDatabase();
    try {
      await db.update(
        'memo',
        _memoItemToMap(memo),
        where: 'id_m = ?',
        whereArgs: [memo.id],
      );
      return true;
    } catch (e) {
      print("Erreur modif memo : $e");
      return false;
    }
  }

  Future<bool> important(MemoItem memo) async {
    final db = await _dbService.getDatabase();
    try {
      await db.update(
        'memo',
        {'is_important': memo.isImportant.toString()},
        where: 'id_m = ?',
        whereArgs: [memo.id],
      );
      return true;
    } catch (e) {
      print("Erreur modif memo : $e");
      return false;
    }
  }

  // Convertir Map en MemoItem
  MemoItem _mapToMemoItem(Map map) {
    return MemoItem(
      id: map['id_m'] as int,
      titre: map['titre'] as String? ?? '',
      text: map['contenu'] as String? ?? '',
      category: map['type'] as String? ?? 'default',
      isImportant: (map['is_important'] as String? ?? 'false') == "true",
      createdAt: DateTime.now(),
    );
  }

  // ajout_memo
  Map<String, dynamic> _memoItemToMap(MemoItem memo) {
    return {
      "titre": memo.titre,
      "contenu": memo.text,
      "type": memo.category,
      "is_important": memo.isImportant,
    };
  }

  // Helper pour parser DateTime
  DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();

    if (dateValue is String) {
      return DateTime.tryParse(dateValue) ?? DateTime.now();
    } else if (dateValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    } else if (dateValue is DateTime) {
      return dateValue;
    }

    return DateTime.now();
  }
}
