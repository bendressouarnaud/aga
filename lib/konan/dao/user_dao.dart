import 'dart:async';

import '../model/database.dart';
import '../model/user.dart';

class UserDao {
  final dbProvider = DatabaseHelper.instance;

  //Adds new Todo records
  Future<int> createUser(User user) async {
    final db = await dbProvider.database;
    var result = db.insert("user", user.toDatabaseJson());
    return result;
  }

  //
  Future<User?> findLocalUser() async {
    final db = await dbProvider.database;
    final List<Map<String, Object?>> results = await db.query('user');
    return results.isNotEmpty ? results.map((c) => User.fromDatabaseJson(c)).toList().first : null;
  }

  Future<int> update(User user) async {
    final db = await dbProvider.database;
    var result = await db.update("user", user.toDatabaseJson(),
        where: "id = ?", whereArgs: [user.id]);
    return result;
  }
}