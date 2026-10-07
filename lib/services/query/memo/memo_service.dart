import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:memofix/models/memo_item.dart';
import '../../db.dart';
import 'package:memofix/services/query/memo/image_service.dart';
import 'package:memofix/services/query/memo/tache_service.dart';
import 'package:memofix/services/query/memo/audio_service.dart';

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
      debugPrint("Erreur lors de la lecture des mémos : $e");
      return [];
    }
  }

  Future<int?> ajouterMemo(MemoItem memo) async {
    final db = await _dbService.getDatabase();
    try {
      final id_memo = await db.insert("memo", _memoItemToMap(memo));
      return id_memo;
    } catch (e) {
      debugPrint("Erreur ajout memo : $e");
      return null;
    }
  }

  Future<bool> supprimerMemo(int id) async {
    final db = await _dbService.getDatabase();
    final ImageService imageService = ImageService();
    final TacheService tacheService = TacheService();
    final AudioService audioService = AudioService();
    try {
      // suppression IMAHES par id_memo
      // bd + appData
      await imageService.supprimerImgByMemo(id);
      // suppression TACHES par id_memo
      await tacheService.supprimerTacheByMemo(id);

      // suppression AUDIO par id_memo
      await audioService.supprimerAudioByMemo(id);

      await db.delete('memo', where: 'id_m = ?', whereArgs: [id]);
      return true;
    } catch (e) {
      debugPrint("Erreur supp memo : $e");
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
      debugPrint("Erreur modif memo : $e");
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
      debugPrint("Erreur modif memo : $e");
      return false;
    }
  }

  bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
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
  MemoItem _mapToMemoItem(Map<String, dynamic> map) {
    return MemoItem(
      id: map['id_m'] is int
          ? map['id_m']
          : int.tryParse(map['id_m'].toString()) ?? 0,
      titre: map['titre']?.toString() ?? '',
      text: map['text']?.toString() ?? '',
      category: map['id_c'] is int
          ? map['id_c']
          : int.tryParse(map['id_c'].toString()) ?? 1,
      verrouille: _parseBool(map['verrouille']),
      isImportant: _parseBool(map['is_important']),
      createdAt: _parseDate(map['createdAt']),
      modifiedAt: _parseDate(map['modifiedAt']),
    );
  }

  // ajout_memo
  Map<String, dynamic> _memoItemToMap(MemoItem memo) {
    return {
      "titre": memo.titre,
      "text": memo.text,
      "id_c": memo.category,
      "verrouille": memo.verrouille ? "true" : "false",
      "is_important": memo.isImportant ? "true" : "false",
      "createdAt": memo.createdAt.toIso8601String(),
      "modifiedAt": memo.modifiedAt.toIso8601String(),
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
