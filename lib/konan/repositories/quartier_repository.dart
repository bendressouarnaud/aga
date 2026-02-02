import '../dao/quartier_dao.dart';
import '../model/quartier.dart';

class QuartierRepository {
  final dao = QuartierDao();

  Future<int> insert(Quartier data) => dao.create(data);
  Future<Quartier?> findOne(int id) => dao.findOne(id);
  Future<List<Quartier>> findAll() => dao.findAll();
  Future<List<Quartier>> findAllByCommuneId(int index) => dao.findAllByCommuneId(index);
}