import 'dart:async';
import '../model/database.dart';
import '../model/gerant_entreprise.dart';

class GerantEntrepriseDao {
  final dbProvider = DatabaseHelper.instance;

  //Adds new Todo records
  Future<int> create(GerantEntreprise data) async {
    final db = await dbProvider.database;
    var result = db.insert("gerant_entreprise", data.toDatabaseJson());
    return result;
  }

  /*Future<int> update(GerantEntreprise data) async {
    final db = await dbProvider.database;
    var result = await db.update("gerant_entreprise", data.toDatabaseJson(),
        where: "id = ?", whereArgs: [data.id]);
    return result;
  }*/

  Future<List<GerantEntreprise>> findAll() async {
    final db = await dbProvider.database;
    final List<Map<String, Object?>> results = await db.query('gerant_entreprise');
    return results.isNotEmpty ? results.map((c) => GerantEntreprise.fromDatabaseJson(c)).toList() : [];
  }
}