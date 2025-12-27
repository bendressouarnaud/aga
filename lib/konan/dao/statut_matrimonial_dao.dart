import 'dart:async';

import '../model/database.dart';
import '../model/statut_matrimonial.dart';

class StatutMatrimonialDao {
  final dbProvider = DatabaseHelper.instance;

  //Adds new Todo records
  Future<int> create(StatutMatrimonial data) async {
    final db = await dbProvider.database;
    var result = db.insert("statut_matrimonial", data.toDatabaseJson());
    return result;
  }

  //
  Future<StatutMatrimonial?> findOne(int id) async {
    final db = await dbProvider.database;
    var data = await db.query('statut_matrimonial', where: 'id = ?', whereArgs: [id]);
    return data.isNotEmpty ? data.map((c) => StatutMatrimonial.fromDatabaseJson(c)).toList().first : null;
  }

  Future<List<StatutMatrimonial>> findAll() async {
    final db = await dbProvider.database;
    final List<Map<String, Object?>> results = await db.query('statut_matrimonial');
    return results.isNotEmpty ? results.map((c) => StatutMatrimonial.fromDatabaseJson(c)).toList() : [];
  }
}