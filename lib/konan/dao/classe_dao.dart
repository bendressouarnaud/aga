import 'dart:async';

import '../model/classe.dart';
import '../model/database.dart';

class ClasseDao {
  final dbProvider = DatabaseHelper.instance;

  //Adds new Todo records
  Future<int> create(Classe data) async {
    final db = await dbProvider.database;
    var result = db.insert("classe", data.toDatabaseJson());
    return result;
  }

  //
  Future<Classe?> findOne(int id) async {
    final db = await dbProvider.database;
    var data = await db.query('classe', where: 'id = ?', whereArgs: [id]);
    return data.isNotEmpty ? data.map((c) => Classe.fromDatabaseJson(c)).toList().first : null;
  }

  Future<List<Classe>> findAll() async {
    final db = await dbProvider.database;
    final List<Map<String, Object?>> results = await db.query('classe');
    return results.isNotEmpty ? results.map((c) => Classe.fromDatabaseJson(c)).toList() : [];
  }
}