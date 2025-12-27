import 'dart:async';

import '../model/database.dart';
import '../model/niveau_etude.dart';

class NiveauEtudeDao {
  final dbProvider = DatabaseHelper.instance;

  //Adds new Todo records
  Future<int> create(NiveauEtude data) async {
    final db = await dbProvider.database;
    var result = db.insert("niveau_etude", data.toDatabaseJson());
    return result;
  }

  //
  Future<NiveauEtude?> findOne(int id) async {
    final db = await dbProvider.database;
    var data = await db.query('niveau_etude', where: 'id = ?', whereArgs: [id]);
    return data.isNotEmpty ? data.map((c) => NiveauEtude.fromDatabaseJson(c)).toList().first : null;
  }

  Future<List<NiveauEtude>> findAll() async {
    final db = await dbProvider.database;
    final List<Map<String, Object?>> results = await db.query('niveau_etude');
    return results.isNotEmpty ? results.map((c) => NiveauEtude.fromDatabaseJson(c)).toList() : [];
  }
}