import 'dart:async';

import '../model/pays.dart';
import '../model/database.dart';

class PaysDao {
  final dbProvider = DatabaseHelper.instance;

  //Adds new Todo records
  Future<int> create(Pays data) async {
    final db = await dbProvider.database;
    var result = db.insert("pays", data.toDatabaseJson());
    return result;
  }

  //
  Future<Pays?> findOne(int id) async {
    final db = await dbProvider.database;
    var data = await db.query('pays', where: 'id = ?', whereArgs: [id]);
    return data.isNotEmpty ? data.map((c) => Pays.fromDatabaseJson(c)).toList().first : null;
  }

  Future<List<Pays>> findAll() async {
    final db = await dbProvider.database;
    final List<Map<String, Object?>> results = await db.query('pays');
    return results.isNotEmpty ? results.map((c) => Pays.fromDatabaseJson(c)).toList() : [];
  }
}