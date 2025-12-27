import 'dart:async';

import 'package:cnmci/konan/model/artisan.dart';

import '../model/database.dart';
import '../model/user.dart';

class ArtisanDao {
  final dbProvider = DatabaseHelper.instance;

  //Adds new Todo records
  Future<int> create(Artisan data) async {
    final db = await dbProvider.database;
    var result = db.insert("artisan", data.toDatabaseJson());
    return result;
  }

  Future<Artisan?> findOne(int id) async {
    final db = await dbProvider.database;
    var data = await db.query('artisan', where: 'id = ?', whereArgs: [id]);
    return data.isNotEmpty ? data.map((c) => Artisan.fromDatabaseJson(c)).toList().first : null;
  }

  //
  Future<List<Artisan>> findAll() async {
    final db = await dbProvider.database;
    final List<Map<String, Object?>> results = await db.query('artisan');
    return results.isNotEmpty ? results.map((c) => Artisan.fromDatabaseJson(c)).toList() : [];
  }

  Future<int> update(Artisan data) async {
    final db = await dbProvider.database;
    var result = await db.update("artisan", data.toDatabaseJson(),
        where: "id = ?", whereArgs: [data.id]);
    return result;
  }
}