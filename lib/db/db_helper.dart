// -------------------------------
// MODE DÉVELOPPEMENT
// -------------------------------

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _dbName = 'memofix.db';
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDatabase();
    return _db!;
  }

  static Future<Database> initDatabase() async {
    // Copier la DB temporairement (sqflite ne peut pas lire directement depuis assets)
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = join(tempDir.path, _dbName);

    ByteData data = await rootBundle.load('assets/$_dbName');
    List<int> bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    await File(tempPath).writeAsBytes(bytes, flush: true);

    // 🔹 Ouvrir la base temporaire
    return await openDatabase(tempPath);
  }
}


// import 'dart:io';
// import 'package:flutter/services.dart';
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:flutter/foundation.dart';

// class DatabaseHelper {
//   static const _dbName = 'memofix.db';
//   static Database? _db;

//   static Future<Database> get database async {
//     if (_db != null) return _db!;
//     _db = await initDatabase();
//     return _db!;
//   }

//   static Future<Database> initDatabase() async {
//     // Obtenir le chemin du dossier de stockage local
//     Directory documentsDirectory = await getApplicationDocumentsDirectory();
//     String path = join(documentsDirectory.path, _dbName);
//     // Vérifier si le fichier existe déjà
//     if (!await File(path).exists()) {
//       // Copier le fichier depuis les assets
//       ByteData data = await rootBundle.load('assets/$_dbName');
//       List<int> bytes = data.buffer.asUint8List(
//         data.offsetInBytes,
//         data.lengthInBytes,
//       );
//       await File(path).writeAsBytes(bytes);
//     }
//     return await openDatabase(path);
//   }

  // [+tard]
  // static Future<Database> initDatabase() async {
  //   if (kDebugMode) {
  //     // Utiliser le répertoire externe pour le debug (accessible en écriture)
  //     Directory? externalDir = await getExternalStorageDirectory();
  //     Directory debugDir =
  //         externalDir ?? await getApplicationDocumentsDirectory();

  //     String debugPath = join(debugDir.path, 'debug_$_dbName');

  //     // Copier depuis assets si n'existe pas
  //     if (!await File(debugPath).exists()) {
  //       ByteData data = await rootBundle.load('assets/$_dbName');
  //       List<int> bytes = data.buffer.asUint8List();
  //       await File(debugPath).writeAsBytes(bytes);
  //       print('🚧 Debug: Copied DB to $debugPath');
  //     }

  //     print('🚧 Debug mode: Using database at $debugPath');
  //     return await openDatabase(debugPath);
  //   } else {
  //     // Production normale
  //     print(
  //       'Production mode: Using database at getApplicationDocumentsDirectory',
  //     );
  //     Directory documentsDirectory = await getApplicationDocumentsDirectory();
  //     String path = join(documentsDirectory.path, _dbName);

  //     if (!await File(path).exists()) {
  //       ByteData data = await rootBundle.load('assets/$_dbName');
  //       List<int> bytes = data.buffer.asUint8List();
  //       await File(path).writeAsBytes(bytes);
  //     }

  //     return await openDatabase(path);
  //   }
  // }
//}
