import 'dart:async';

import 'package:cnmci/konan/model/compagnon.dart';

import '../model/database.dart';

class CompagnonDao {
  final dbProvider = DatabaseHelper.instance;

  //Adds new Todo records
  Future<int> create(Compagnon data) async {
    final db = await dbProvider.database;
    var result = db.insert("compagnon", data.toDatabaseJson());
    return result;
  }

  Future<Compagnon?> findOne(int id) async {
    final db = await dbProvider.database;
    var data = await db.query('compagnon', where: 'id = ?', whereArgs: [id]);
    return data.isNotEmpty ? data.map((c) => Compagnon.fromDatabaseJson(c)).toList().first : null;
  }

  //
  Future<List<Compagnon>> findAllByArtisanAndEntreprise(int artisanId, int entrepriseId) async {
    final db = await dbProvider.database;
    final List<Map<String, Object?>> results =
      await db.query('compagnon', where: 'artisan_id = ? and entreprise_id = ?',
          whereArgs: [artisanId, entrepriseId]);
    return results.isNotEmpty ? results.map((c) => Compagnon.fromDatabaseJson(c)).toList() : [];
  }

  Future<List<Compagnon>> findAll() async {
    final db = await dbProvider.database;
    final List<Map<String, Object?>> results = await db.query('compagnon');
    return results.isNotEmpty ? results.map((c) => Compagnon.fromDatabaseJson(c)).toList() : [];
  }

  Future<int> update(Compagnon data) async {
    final db = await dbProvider.database;
    var result = await db.update("compagnon", data.toDatabaseJson(),
        where: "id = ?", whereArgs: [data.id]);
    return result;
  }
}