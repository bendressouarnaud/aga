import '../dao/co_gerant_dao.dart';
import '../model/co_gerant.dart';

class CoGerantRepository {
  final dao = CoGerantDao();

  Future<int> insert(CoGerant data) => dao.create(data);
  Future<CoGerant?> findOne(int id) => dao.findOne(id);
  Future<List<CoGerant>> findAll() => dao.findAll();
  Future<int> update(CoGerant data) => dao.update(data);
}