import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DbProvider {
  DbProvider._();

  static final DbProvider db = DbProvider._();

  Database _database;
  String tableName = 'Alert';

  Future<Database> get database async {
    if (_database != null) return _database;
    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "PseNotifierDB.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE $tableName ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "symbol TEXT,"
          "price REAL,"
          "isAbove INTEGER,"
          "isEnable INTEGER"
          ")");
    });
  }
}
