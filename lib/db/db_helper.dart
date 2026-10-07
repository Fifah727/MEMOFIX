import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Accès à la base SQLite locale.
///
/// Au premier lancement, la base vierge embarquée dans les assets est copiée
/// dans le dossier de documents de l'application.
class DatabaseHelper {
  const DatabaseHelper._();

  static const _dbName = 'memofix.db';
  static Future<Database>? _db;

  static Future<Database> get database => _db ??= initDatabase();

  static Future<Database> initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _dbName);

    if (!await File(path).exists()) {
      final data = await rootBundle.load('assets/db/$_dbName');
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      await File(path).writeAsBytes(bytes, flush: true);
    }
    return openDatabase(path);
  }
}
