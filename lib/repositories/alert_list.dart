import 'dart:async';

import 'package:psenotifier/networking/db_provider.dart';
import 'package:psenotifier/models/alert.dart';

class AlertListRepository {
  DbProvider _provider = DbProvider.db;

  Future<int> createAlert(Alert alert) async {
    final db = await _provider.database;
    var raw = await db.rawInsert(
        "INSERT Into ${_provider.tableName} (symbol,price,isAbove,isEnable)"
            " VALUES (?,?,?,?)",
        [
          alert.symbol,
          alert.price,
          _boolToInt(alert.isAbove),
          _boolToInt(alert.isEnable)
        ]);
    return raw;
  }

  int _boolToInt(bool flag) {
    return flag ? 1 : 0;
  }

  Future<int> updateAlert(Alert alert) async {
    final db = await _provider.database;
    var res = await db.update(_provider.tableName, alert.toJson(),
        where: "id = ?", whereArgs: [alert.id]);
    return res;
  }

  Future<List<Alert>> getStockAlerts(String symbol) async {
    final db = await _provider.database;

    var res =
    await db.query(_provider.tableName, where: "symbol = ? ", whereArgs: [symbol]);

    List<Alert> list =
    res.isNotEmpty ? res.map((c) => Alert.fromJson(c)).toList() : [];
    return list;
  }

  Future<List<Alert>> getAllAlerts() async {
    final db = await _provider.database;
    var res = await db.query(_provider.tableName);
    List<Alert> list =
    res.isNotEmpty ? res.map((c) => Alert.fromJson(c)).toList() : [];
    return list;
  }

  Future<int> deleteAlert(int id) async {
    final db = await _provider.database;
    return db.delete(_provider.tableName, where: "id = ?", whereArgs: [id]);
  }
}