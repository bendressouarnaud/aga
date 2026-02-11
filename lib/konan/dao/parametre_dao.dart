import 'dart:async';

import '../model/database.dart';
import '../model/parametre.dart';

class ParametreDao {
  final dbProvider = DatabaseHelper.instance;

  //Adds new Todo records
  Future<int> create(Parametre data) async {
    final db = await dbProvider.database;
    var result = db.insert("parametre", data.toDatabaseJson());
    return result;
  }

  //
  Future<Parametre?> findUnique(int id) async {
    final db = await dbProvider.database;
    var data = await db.query('parametre', where: 'id = ?', whereArgs: [id]);
    return data.isNotEmpty ? data.map((c) => Parametre.fromDatabaseJson(c)).toList().first : null;
  }
}