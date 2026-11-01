import 'dart:async';

import '../model/database.dart';
import '../model/enrolement_paiement.dart';

class EnrolementPaiementDao {
  final dbProvider = DatabaseHelper.instance;

  //Adds new Todo records
  Future<int> create(EnrolementPaiement data) async {
    final db = await dbProvider.database;
    var result = await db.rawInsert("""
    INSERT INTO enrolement_paiement (millisecondes, montant) VALUES (?, ?)""",
        [data.millisecondes, data.montant]);
    return result;
  }

  Future<List<EnrolementPaiement>> findAll() async {
    final db = await dbProvider.database;
    final List<Map<String, Object?>> results = await db.query('enrolement_paiement');
    return results.isNotEmpty ? results.map((c) => EnrolementPaiement.fromDatabaseJson(c)).toList() : [];
  }
}