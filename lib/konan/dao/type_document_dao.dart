import 'dart:async';

import '../model/database.dart';
import '../model/type_document.dart';

class TypeDocumentDao {
  final dbProvider = DatabaseHelper.instance;

  //Adds new Todo records
  Future<int> create(TypeDocument data) async {
    final db = await dbProvider.database;
    var result = db.insert("type_document", data.toDatabaseJson());
    return result;
  }

  //
  Future<TypeDocument?> findOne(int id) async {
    final db = await dbProvider.database;
    var data = await db.query('type_document', where: 'id = ?', whereArgs: [id]);
    return data.isNotEmpty ? data.map((c) => TypeDocument.fromDatabaseJson(c)).toList().first : null;
  }

  Future<List<TypeDocument>> findAll() async {
    final db = await dbProvider.database;
    final List<Map<String, Object?>> results = await db.query('type_document');
    return results.isNotEmpty ? results.map((c) => TypeDocument.fromDatabaseJson(c)).toList() : [];
  }
}