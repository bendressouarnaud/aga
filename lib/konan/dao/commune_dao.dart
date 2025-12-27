import 'dart:async';

import '../model/commune.dart';
import '../model/database.dart';

class CommuneDao {
  final dbProvider = DatabaseHelper.instance;

  //Adds new Todo records
  Future<int> create(Commune data) async {
    final db = await dbProvider.database;
    var result = db.insert("commune", data.toDatabaseJson());
    return result;
  }

  //
  Future<Commune?> findOne(int id) async {
    final db = await dbProvider.database;
    var data = await db.query('commune', where: 'id = ?', whereArgs: [id]);
    return data.isNotEmpty ? data.map((c) => Commune.DatabaseToObject(c)).toList().first : null;
  }

  Future<List<Commune>> findAllBySousPrefectureId(int index) async {
    final db = await dbProvider.database;
    var data = await db.query('commune', where: 'idx = ?', whereArgs: [index]);
    return data.isNotEmpty ? data.map((c) => Commune.DatabaseToObject(c)).toList() : [];
  }

  Future<List<Commune>> findAll() async {
    final db = await dbProvider.database;
    final List<Map<String, Object?>> results = await db.query('commune');
    return results.isNotEmpty ? results.map((c) => Commune.DatabaseToObject(c)).toList() : [];
  }
}