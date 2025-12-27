import 'dart:async';

import '../model/crm.dart';
import '../model/database.dart';
import '../model/metier.dart';

class MetierDao {
  final dbProvider = DatabaseHelper.instance;

  //Adds new Todo records
  Future<int> create(Metier data) async {
    final db = await dbProvider.database;
    var result = db.insert("metier", data.toDatabaseJson());
    return result;
  }

  //
  Future<Metier?> findOne(int id) async {
    final db = await dbProvider.database;
    var data = await db.query('metier', where: 'id = ?', whereArgs: [id]);
    return data.isNotEmpty ? data.map((c) => Metier.fromDatabaseJson(c)).toList().first : null;
  }

  Future<List<Metier>> findAll() async {
    final db = await dbProvider.database;
    final List<Map<String, Object?>> results = await db.query('metier');
    return results.isNotEmpty ? results.map((c) => Metier.fromDatabaseJson(c)).toList() : [];
  }
}