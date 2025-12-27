import 'dart:async';

import '../model/crm.dart';
import '../model/database.dart';

class CrmDao {
  final dbProvider = DatabaseHelper.instance;

  //Adds new Todo records
  Future<int> create(Crm data) async {
    final db = await dbProvider.database;
    var result = db.insert("crm", data.toDatabaseJson());
    return result;
  }

  //
  Future<Crm?> findOne(int id) async {
    final db = await dbProvider.database;
    var data = await db.query('crm', where: 'id = ?', whereArgs: [id]);
    return data.isNotEmpty ? data.map((c) => Crm.fromDatabaseJson(c)).toList().first : null;
  }

  Future<List<Crm>> findAll() async {
    final db = await dbProvider.database;
    final List<Map<String, Object?>> results = await db.query('crm');
    return results.isNotEmpty ? results.map((c) => Crm.fromDatabaseJson(c)).toList() : [];
  }
}