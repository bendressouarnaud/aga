import 'dart:async';
import '../model/database.dart';
import '../model/requete_sql.dart';

class RequeteSqlDao {
  final dbProvider = DatabaseHelper.instance;

  //Adds new Todo records
  Future<int> create(RequeteSql data) async {
    final db = await dbProvider.database;
    var result = db.insert("requete_sql", data.toDatabaseJson());
    return result;
  }

  Future<List<RequeteSql>> findAll() async {
    final db = await dbProvider.database;
    final List<Map<String, Object?>> results = await db.query('requete_sql');
    return results.isNotEmpty ? results.map((c) => RequeteSql.fromDatabaseJson(c)).toList() : [];
  }
}