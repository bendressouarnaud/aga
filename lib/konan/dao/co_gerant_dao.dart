import 'dart:async';
import 'package:cnmci/konan/model/co_gerant.dart';
import '../model/database.dart';

class CoGerantDao {
  final dbProvider = DatabaseHelper.instance;

  //Adds new Todo records
  Future<int> create(CoGerant data) async {
    final db = await dbProvider.database;
    var result = db.insert("co_gerant", data.toDatabaseJson());
    return result;
  }

  Future<CoGerant?> findOne(int id) async {
    final db = await dbProvider.database;
    var data = await db.query('co_gerant', where: 'id = ?', whereArgs: [id]);
    return data.isNotEmpty ? data.map((c) => CoGerant.fromDatabaseJson(c)).toList().first : null;
  }

  Future<List<CoGerant>> findAll() async {
    final db = await dbProvider.database;
    final List<Map<String, Object?>> results = await db.query('co_gerant');
    return results.isNotEmpty ? results.map((c) => CoGerant.fromDatabaseJson(c)).toList() : [];
  }

  Future<int> update(CoGerant data) async {
    final db = await dbProvider.database;
    var result = await db.update("co_gerant", data.toDatabaseJson(),
        where: "id = ?", whereArgs: [data.id]);
    return result;
  }
}