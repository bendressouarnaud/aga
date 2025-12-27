import 'dart:async';

import '../model/departement.dart';
import '../model/database.dart';

class DepartementDao {
  final dbProvider = DatabaseHelper.instance;

  //Adds new Todo records
  Future<int> create(Departement data) async {
    final db = await dbProvider.database;
    var result = db.insert("departement", data.toDatabaseJson());
    return result;
  }

  //
  Future<Departement?> findOne(int id) async {
    final db = await dbProvider.database;
    var data = await db.query('departement', where: 'id = ?', whereArgs: [id]);
    return data.isNotEmpty ? data.map((c) => Departement.DatabaseToObject(c)).toList().first : null;
  }

  Future<List<Departement>> findAllByCrmId(int index) async {
    final db = await dbProvider.database;
    var data = await db.query('departement', where: 'idx = ?', whereArgs: [index]);
    return data.isNotEmpty ? data.map((c) => Departement.DatabaseToObject(c)).toList() : [];
  }

  Future<List<Departement>> findAll() async {
    final db = await dbProvider.database;
    final List<Map<String, Object?>> results = await db.query('departement');
    return results.isNotEmpty ? results.map((c) => Departement.DatabaseToObject(c)).toList() : [];
  }
}