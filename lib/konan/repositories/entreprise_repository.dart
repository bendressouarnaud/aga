import '../dao/entreprise_dao.dart';
import '../model/entreprise.dart';

class EntrepriseRepository {
  final dao = EntrepriseDao();

  Future<int> insert(Entreprise data) => dao.create(data);
  Future<Entreprise?> findOne(int id) => dao.findOne(id);
  Future<int> update(Entreprise data) => dao.update(data);
  Future<List<Entreprise>> findAll() => dao.findAll();
}