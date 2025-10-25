import 'package:sqflite/sqflite.dart';
import 'package:memofix/db/db_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

class DbService {
  // UTILISEZ DatabaseHelper au lieu d'openDatabase directement
  Future<Database> getDatabase() async {
    return await DatabaseHelper.database;
  }
}
