import 'package:memofix/db/db_helper.dart';
import 'package:sqflite/sqflite.dart';

class DbService {
  Future<Database> getDatabase() => DatabaseHelper.database;
}
