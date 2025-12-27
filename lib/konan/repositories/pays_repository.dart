import '../dao/pays_dao.dart';
import '../model/pays.dart';

class PaysRepository {
  final dao = PaysDao();

  Future<int> insert(Pays data) => dao.create(data);
  Future<Pays?> findOne(int id) => dao.findOne(id);
  Future<List<Pays>> findAll() => dao.findAll();
}