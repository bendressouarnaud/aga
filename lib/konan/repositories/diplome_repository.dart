import '../dao/diplome_dao.dart';
import '../model/diplome.dart';

class DiplomeRepository {
  final dao = DiplomeDao();

  Future<int> insert(Diplome data) => dao.create(data);
  Future<Diplome?> findOne(int id) => dao.findOne(id);
  Future<List<Diplome>> findAll() => dao.findAll();
}