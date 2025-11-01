import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:memofix/models/CategorieItem.dart';
import '../db.dart';

class CategorieService {
  final DbService _dbService = DbService();
  // Récupérer tous les mémos
  Future<List<CategorieItem>> getCategories() async {
    final db = await _dbService.getDatabase();
    try {
      final List<Map<String, dynamic>> maps = await db.query("categorie");
      // Convertir chaque map en CategorieItem
      return maps.map((map) => _mapToCategorieItem(map)).toList();
    } catch (e) {
      print("Erreur lors de la lecture des categories : $e");
      return [];
    }
  }

  // Convertir Map en MemoItem
  CategorieItem _mapToCategorieItem(Map map) {
    return CategorieItem(
      id_c: map['id_c'] as int,
      nom_c: map['nom_c'] as String? ?? '',
    );
  }

  // ajout_memo
  Map<String, dynamic> _CategorieItemToMap(CategorieItem memo) {
    return {"id_c": memo.id_c, "nom_c": memo.nom_c};
  }
}
