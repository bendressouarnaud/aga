import 'dart:async';

import '../model/quartier.dart';
import '../model/database.dart';

class QuartierDao {
  final dbProvider = DatabaseHelper.instance;

  //Adds new Todo records
  Future<int> create(Quartier data) async {
    final db = await dbProvider.database;
    var result = db.insert("quartier", data.toDatabaseJson());
    return result;
  }

  //
  Future<Quartier?> findOne(int id) async {
    final db = await dbProvider.database;
    var data = await db.query('quartier', where: 'id = ?', whereArgs: [id]);
    return data.isNotEmpty ? data.map((c) => Quartier.DatabaseToObject(c)).toList().first : null;
  }

  Future<List<Quartier>> findAllByCommuneId(int index) async {
    final db = await dbProvider.database;
    var data = await db.query('quartier', where: 'idx = ?', whereArgs: [index]);
    return data.isNotEmpty ? data.map((c) => Quartier.DatabaseToObject(c)).toList() : [];
  }

  Future<List<Quartier>> findAll() async {
    final db = await dbProvider.database;
    final List<Map<String, Object?>> results = await db.query('quartier');
    return results.isNotEmpty ? results.map((c) => Quartier.DatabaseToObject(c)).toList() : [];
  }
}