import 'dart:async';
import 'package:cnmci/konan/model/entreprise.dart';
import '../model/database.dart';

class EntrepriseDao {
  final dbProvider = DatabaseHelper.instance;

  //Adds new Todo records
  Future<int> create(Entreprise data) async {
    final db = await dbProvider.database;
    var result = db.insert("entreprise", data.toDatabaseJson());
    return result;
  }

  Future<Entreprise?> findOne(int id) async {
    final db = await dbProvider.database;
    var data = await db.query('entreprise', where: 'id = ?', whereArgs: [id]);
    return data.isNotEmpty ? data.map((c) => Entreprise.fromDatabaseJson(c)).toList().first : null;
  }

  //
  Future<List<Entreprise>> findAll() async {
    final db = await dbProvider.database;
    final List<Map<String, Object?>> results = await db.query('entreprise');
    return results.isNotEmpty ? results.map((c) => Entreprise.fromDatabaseJson(c)).toList() : [];
  }

  Future<int> update(Entreprise data) async {
    final db = await dbProvider.database;
    var result = await db.update("entreprise", data.toDatabaseJson(),
        where: "id = ?", whereArgs: [data.id]);
    return result;
  }
}