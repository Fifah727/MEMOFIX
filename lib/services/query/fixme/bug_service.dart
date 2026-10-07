import 'package:flutter/foundation.dart';
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
import 'package:memofix/models/fixme/fixme_items.dart';

class BugService {
  final DbService _dbService = DbService();

  // Récupérer tous les bugs
  Future<List<BugItem>> getBugs() async {
    final db = await _dbService.getDatabase();
    try {
      final List<Map<String, dynamic>> maps = await db.query("bug");
      return maps.map((map) => BugItem.fromMap(map)).toList();
    } catch (e) {
      debugPrint("Erreur lors de la lecture des bugs : $e");
      return [];
    }
  }

  // Récupérer un bug
  Future<BugItem?> getBug(int id) async {
    final db = await _dbService.getDatabase();
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        "bug",
        where: 'id_bug = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        return BugItem.fromMap(maps.first);
      } else {
        return null;
      }
    } catch (e) {
      debugPrint("Erreur lors de la lecture du bug : $e");
      return null;
    }
  }

  // Récupérer l'historique d'un bug
  Future<List<String>> getCategories() async {
    final db = await _dbService.getDatabase();
    try {
      final List<Map<String, dynamic>> maps = await db.rawQuery(
        'SELECT DISTINCT categorie FROM bug WHERE categorie IS NOT NULL AND categorie != ""',
      );

      // Transformer le résultat en List<String>
      return maps.map((map) => map['categorie'] as String).toList();
    } catch (e) {
      debugPrint("Erreur lecture catégories : $e");
      return [];
    }
  }

  // Ajouter un bug
  Future<int?> ajouterBug(BugItem bug) async {
    final db = await _dbService.getDatabase();
    try {
      final id_bug = await db.insert("bug", bug.toMap());
      if (id_bug != null) debugPrint("Bug ajouté : ${bug.toMap()}");
      return id_bug;
    } catch (e) {
      debugPrint("Erreur ajout bug : $e");
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
      debugPrint("Bug modifié : ${bug.toMap()}");
      return true;
    } catch (e) {
      debugPrint("Erreur update bug : $e");
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
      debugPrint("Erreur suppression bug : $e");
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
      debugPrint("Erreur lecture objectifs : $e");
      return [];
    }
  }

  // Ajouter un objectif
  Future<int?> ajouterObjectif(ObjectifItem objectif) async {
    final db = await _dbService.getDatabase();
    try {
      final id_obj = await db.insert("objectif", objectif.toMap());
      debugPrint("Obj modifié : ${objectif.toMap()}");
      return id_obj;
    } catch (e) {
      debugPrint("Erreur ajout objectif : $e");
      return null;
    }
  }

  // Mettre à jour un objectif
  Future<bool> updateObj(ObjectifItem objectif) async {
    final db = await _dbService.getDatabase();
    try {
      await db.update(
        'objectif',
        objectif.toMap(),
        where: 'id_obj = ?',
        whereArgs: [objectif.id_obj],
      );
      debugPrint("Obj modifié : ${objectif.toMap()}");
      return true;
    } catch (e) {
      debugPrint("Erreur update objectif : $e");
      return false;
    }
  }

  // Supprimer un objectif
  Future<bool> supprimerObjectif(int id_obj) async {
    final db = await _dbService.getDatabase();
    try {
      await db.delete('objectif', where: 'id_obj = ?', whereArgs: [id_obj]);
      return true;
    } catch (e) {
      debugPrint("Erreur suppression objectif : $e");
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
      debugPrint("Erreur lecture historique : $e");
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
      debugPrint("Erreur ajout historique : $e");
      return null;
    }
  }

  Future<void> updateObjectifAndBugAvancement(ObjectifItem obj) async {
    final db = await _dbService.getDatabase();

    // 1️⃣ Mettre à jour l'objectif
    await db.update(
      'objectif',
      obj.toMap(),
      where: 'id_obj = ?',
      whereArgs: [obj.id_obj],
    );

    // 2️⃣ Récupérer tous les objectifs du bug
    final objectifs = await db.query(
      'objectif',
      where: 'id_bug = ?',
      whereArgs: [obj.id_bug],
    );

    if (objectifs.isEmpty) return;

    // 3️⃣ Calculer l'avancement : % d'objectifs faits
    final faits = objectifs.where((o) => o['statut'] == 'fait').length;
    final total = objectifs.length;
    final avancement = ((faits / total) * 100).toInt();

    // 4️⃣ Préparer la mise à jour du bug
    Map<String, dynamic> bugUpdate = {'avancement': avancement};

    // Si avancement = 100, on corrige le bug et on ajoute date_cloture
    if (avancement == 100) {
      bugUpdate['statut'] = 'corrigé';
      bugUpdate['date_cloture'] = DateTime.now().toIso8601String();
    }

    // 5️⃣ Mettre à jour le bug
    await db.update(
      'bug',
      bugUpdate,
      where: 'id_bug = ?',
      whereArgs: [obj.id_bug],
    );

    // 6️⃣ Ajouter un enregistrement dans bug_progress
    final progressItem = BugProgressItem(
      id_bug: obj.id_bug,
      date_modif: DateTime.now(),
      commentaire: faits == total
          ? 'Objectif "${obj.valeur_cible}" atteint. Objectifs terminés'
          : 'Objectif "${obj.valeur_cible}" atteint',
      avancement: avancement,
    );

    await db.insert('bug_progress', progressItem.toMap());

    debugPrint(
      "Objectif mis à jour et bug ${obj.id_bug} avancement = $avancement%",
    );
  }

  Future<void> relancerBug(BugItem bug) async {
    final db = await _dbService.getDatabase();

    await db.delete(
      'bug_progress',
      where: 'id_bug = ?',
      whereArgs: [bug.id_bug],
    );

    // dechecker les objectifs
    await db.update(
      'objectif',
      {'statut': 'en_cours'},
      where: 'id_bug = ?',
      whereArgs: [bug.id_bug],
    );

    bug.statut = "en_cours";
    bug.date_cloture = null;
    bug.avancement = 0;

    await db.update(
      'bug',
      bug.toMap(),
      where: 'id_bug = ?',
      whereArgs: [bug.id_bug],
    );

    await db.insert('bug_progress', {
      'id_bug': bug.id_bug,
      'date_modif': DateTime.now().toIso8601String(),
      'commentaire': 'Bug relancé, anciens objectifs supprimés',
      'avancement': 0,
    });

    debugPrint(
      "Bug #${bug.id_bug} relancé : statut remis à en_cours et objectifs supprimés",
    );
  }
}
