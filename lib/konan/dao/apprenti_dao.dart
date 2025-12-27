import 'dart:async';

import 'package:cnmci/konan/model/apprenti.dart';

import '../model/database.dart';

class ApprentiDao {
  final dbProvider = DatabaseHelper.instance;

  //Adds new Todo records
  Future<int> create(Apprenti data) async {
    final db = await dbProvider.database;
    var result = db.insert("apprenti", data.toDatabaseJson());
    return result;
  }

  Future<Apprenti?> findOne(int id) async {
    final db = await dbProvider.database;
    var data = await db.query('apprenti', where: 'id = ?', whereArgs: [id]);
    return data.isNotEmpty ? data.map((c) => Apprenti.fromDatabaseJson(c)).toList().first : null;
  }

  //
  Future<List<Apprenti>> findAllByArtisanAndEntreprise(int artisanId, int entrepriseId) async {
    final db = await dbProvider.database;
    final List<Map<String, Object?>> results =
      await db.query('apprenti', where: 'artisan_id = ? and entreprise_id = ?',
          whereArgs: [artisanId, entrepriseId]);
    return results.isNotEmpty ? results.map((c) => Apprenti.fromDatabaseJson(c)).toList() : [];
  }

  Future<List<Apprenti>> findAll() async {
    final db = await dbProvider.database;
    final List<Map<String, Object?>> results = await db.query('apprenti');
    return results.isNotEmpty ? results.map((c) => Apprenti.fromDatabaseJson(c)).toList() : [];
  }

  Future<int> update(Apprenti data) async {
    final db = await dbProvider.database;
    var result = await db.update("apprenti", data.toDatabaseJson(),
        where: "id = ?", whereArgs: [data.id]);
    return result;
  }
}