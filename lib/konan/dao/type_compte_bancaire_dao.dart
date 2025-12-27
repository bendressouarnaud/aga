import 'dart:async';

import '../model/database.dart';
import '../model/type_compte_bancaire.dart';

class TypeCompteBancaireDao {
  final dbProvider = DatabaseHelper.instance;

  //Adds new Todo records
  Future<int> create(TypeCompteBancaire data) async {
    final db = await dbProvider.database;
    var result = db.insert("type_compte_bancaire", data.toDatabaseJson());
    return result;
  }

  //
  Future<TypeCompteBancaire?> findOne(int id) async {
    final db = await dbProvider.database;
    var data = await db.query('type_compte_bancaire', where: 'id = ?', whereArgs: [id]);
    return data.isNotEmpty ? data.map((c) => TypeCompteBancaire.fromDatabaseJson(c)).toList().first : null;
  }

  Future<List<TypeCompteBancaire>> findAll() async {
    final db = await dbProvider.database;
    final List<Map<String, Object?>> results = await db.query('type_compte_bancaire');
    return results.isNotEmpty ? results.map((c) => TypeCompteBancaire.fromDatabaseJson(c)).toList() : [];
  }
}