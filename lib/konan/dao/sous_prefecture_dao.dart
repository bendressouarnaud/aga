import 'dart:async';
import '../model/database.dart';
import '../model/sous_prefecture.dart';

class SousPrefectureDao {
  final dbProvider = DatabaseHelper.instance;

  //Adds new Todo records
  Future<int> create(SousPrefecture data) async {
    final db = await dbProvider.database;
    var result = db.insert("sous_prefecture", data.toDatabaseJson());
    return result;
  }

  //
  Future<SousPrefecture?> findOne(int id) async {
    final db = await dbProvider.database;
    var data = await db.query('sous_prefecture', where: 'id = ?', whereArgs: [id]);
    return data.isNotEmpty ? data.map((c) => SousPrefecture.DatabaseToObject(c)).toList().first : null;
  }

  Future<List<SousPrefecture>> findAllByDepartementId(int index) async {
    final db = await dbProvider.database;
    var data = await db.query('sous_prefecture', where: 'idx = ?', whereArgs: [index]);
    return data.isNotEmpty ? data.map((c) => SousPrefecture.DatabaseToObject(c)).toList() : [];
  }

  Future<List<SousPrefecture>> findAll() async {
    final db = await dbProvider.database;
    final List<Map<String, Object?>> results = await db.query('sous_prefecture');
    return results.isNotEmpty ? results.map((c) => SousPrefecture.DatabaseToObject(c)).toList() : [];
  }
}