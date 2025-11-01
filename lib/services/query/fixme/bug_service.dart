// Méthodes
//getBugs,
//ajouterBug,
//updateBug,
//supprimerBug → correspond à MemoService.

// Objectifs / checklist → gestion via
//getObjectifs,
//ajouterObjectif,
//supprimerObjectif.

// Historique →
//getProgress
//ajouterProgress.

// La suppression du bug supprime automatiquement les objectifs et l’historique grâce aux ON DELETE CASCADE.

// Toutes les méthodes gèrent les exceptions et retournent soit l’ID, soit un booléen de succès.

import 'package:sqflite/sqflite.dart';
import 'dart:async';
import '../../db.dart';
import 'package:memofix/models/fixme/FixMeItems.dart';

class BugService {
  final DbService _dbService = DbService();

  // Récupérer tous les bugs
  Future<List<BugItem>> getBugs() async {
    final db = await _dbService.getDatabase();
    try {
      final List<Map<String, dynamic>> maps = await db.query("bug");
      return maps.map((map) => BugItem.fromMap(map)).toList();
    } catch (e) {
      print("Erreur lors de la lecture des bugs : $e");
      return [];
    }
  }

  // Ajouter un bug
  Future<int?> ajouterBug(BugItem bug) async {
    final db = await _dbService.getDatabase();
    try {
      final id_bug = await db.insert("bug", bug.toMap());
      return id_bug;
    } catch (e) {
      print("Erreur ajout bug : $e");
      return null;
    }
  }

  // Mettre à jour un bug
  Future<bool> updateBug(BugItem bug) async {
    final db = await _dbService.getDatabase();
    try {
      await db.update(
        'bug',
        bug.toMap(),
        where: 'id_bug = ?',
        whereArgs: [bug.id_bug],
      );
      return true;
    } catch (e) {
      print("Erreur update bug : $e");
      return false;
    }
  }

  // Supprimer un bug (et ses objectifs + historique grâce au cascade)
  Future<bool> supprimerBug(int id_bug) async {
    final db = await _dbService.getDatabase();
    try {
      // Les tables Objectif et BugProgress ont foreign key ON DELETE CASCADE
      await db.delete('bug', where: 'id_bug = ?', whereArgs: [id_bug]);
      return true;
    } catch (e) {
      print("Erreur suppression bug : $e");
      return false;
    }
  }

  // Récupérer les objectifs (checklist) d'un bug
  Future<List<ObjectifItem>> getObjectifs(int id_bug) async {
    final db = await _dbService.getDatabase();
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        "objectif",
        where: 'id_bug = ?',
        whereArgs: [id_bug],
      );
      return maps.map((map) => ObjectifItem.fromMap(map)).toList();
    } catch (e) {
      print("Erreur lecture objectifs : $e");
      return [];
    }
  }

  // Ajouter un objectif
  Future<int?> ajouterObjectif(ObjectifItem objectif) async {
    final db = await _dbService.getDatabase();
    try {
      final id_obj = await db.insert("objectif", objectif.toMap());
      return id_obj;
    } catch (e) {
      print("Erreur ajout objectif : $e");
      return null;
    }
  }

  // Supprimer un objectif
  Future<bool> supprimerObjectif(int id_obj) async {
    final db = await _dbService.getDatabase();
    try {
      await db.delete('objectif', where: 'id_obj = ?', whereArgs: [id_obj]);
      return true;
    } catch (e) {
      print("Erreur suppression objectif : $e");
      return false;
    }
  }

  // Récupérer l'historique d'un bug
  Future<List<BugProgressItem>> getProgress(int id_bug) async {
    final db = await _dbService.getDatabase();
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        "bug_progress",
        where: 'id_bug = ?',
        whereArgs: [id_bug],
      );
      return maps.map((map) => BugProgressItem.fromMap(map)).toList();
    } catch (e) {
      print("Erreur lecture historique : $e");
      return [];
    }
  }

  // Ajouter un événement dans l'historique
  Future<int?> ajouterProgress(BugProgressItem progress) async {
    final db = await _dbService.getDatabase();
    try {
      final id_progress = await db.insert("bug_progress", progress.toMap());
      return id_progress;
    } catch (e) {
      print("Erreur ajout historique : $e");
      return null;
    }
  }
}
