import 'dart:async';

import '../model/crm.dart';
import '../model/database.dart';
import '../model/diplome.dart';

class DiplomeDao {
  final dbProvider = DatabaseHelper.instance;

  //Adds new Todo records
  Future<int> create(Diplome data) async {
    final db = await dbProvider.database;
    var result = db.insert("diplome", data.toDatabaseJson());
    return result;
  }

  //
  Future<Diplome?> findOne(int id) async {
    final db = await dbProvider.database;
    var data = await db.query('diplome', where: 'id = ?', whereArgs: [id]);
    return data.isNotEmpty ? data.map((c) => Diplome.fromDatabaseJson(c)).toList().first : null;
  }

  Future<List<Diplome>> findAll() async {
    final db = await dbProvider.database;
    final List<Map<String, Object?>> results = await db.query('diplome');
    return results.isNotEmpty ? results.map((c) => Diplome.fromDatabaseJson(c)).toList() : [];
  }
}