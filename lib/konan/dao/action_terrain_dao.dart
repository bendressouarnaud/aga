import 'dart:async';

import '../model/action_terrain.dart';
import '../model/database.dart';

class ActionTerrainDao {
  final dbProvider = DatabaseHelper.instance;

  //Adds new Todo records
  Future<int> create(ActionTerrain data) async {
    final db = await dbProvider.database;
    var result = db.insert("action_terrain", data.toDatabaseJson());
    return result;
  }

  //
  Future<List<ActionTerrain>> findAll() async {
    final db = await dbProvider.database;
    final List<Map<String, Object?>> results = await db.query('action_terrain');
    return results.isNotEmpty ? results.map((c) => ActionTerrain.fromDatabaseJson(c)).toList() : [];
  }

  Future<int> update(ActionTerrain data) async {
    final db = await dbProvider.database;
    var result = await db.update("action_terrain", data.toDatabaseJson(),
        where: "id = ?", whereArgs: [data.id]);
    return result;
  }
}