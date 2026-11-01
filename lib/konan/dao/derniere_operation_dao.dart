import 'dart:async';

import '../model/database.dart';
import '../model/derniere_operation.dart';
import '../model/enrolement_paiement.dart';

class DerniereOperationDao {
  final dbProvider = DatabaseHelper.instance;

  //Adds new Todo records
  Future<int> create(DerniereOperation data) async {
    final db = await dbProvider.database;
    var result = await db.rawInsert("""
    INSERT INTO derniere_operation (libelle, detail, action, requester_id, requester_type, millisecondes) 
    VALUES (?, ?, ?, ?, ?, ?)""",
        [data.libelle, data.detail, data.action, data.requesterId, data.requesterType, data.millisecondes]);
    return result;
  }

  Future<DerniereOperation?> findOne(int id) async {
    final db = await dbProvider.database;
    var data = await db.query('derniere_operation', where: 'id = ?', whereArgs: [id]);
    return data.isNotEmpty ? data.map((c) => DerniereOperation.fromDatabaseJson(c)).toList().first : null;
  }

  Future<DerniereOperation?> findOneByMilliseconde(int millisecondes) async {
    final db = await dbProvider.database;
    var data = await db.query('derniere_operation', where: 'millisecondes = ?', whereArgs: [millisecondes]);
    return data.isNotEmpty ? data.map((c) => DerniereOperation.fromDatabaseJson(c)).toList().first : null;
  }

  Future<List<DerniereOperation>> findAll() async {
    final db = await dbProvider.database;
    final List<Map<String, Object?>> results = await db.query('derniere_operation');
    return results.isNotEmpty ? results.map((c) => DerniereOperation.fromDatabaseJson(c)).toList() : [];
  }
}