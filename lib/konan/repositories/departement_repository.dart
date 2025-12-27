import 'package:cnmci/konan/model/departement.dart';
import '../dao/departement_dao.dart';

class DepartementRepository {
  final dao = DepartementDao();

  Future<int> insert(Departement data) => dao.create(data);
  Future<Departement?> findOne(int id) => dao.findOne(id);
  Future<List<Departement>> findAll() => dao.findAll();
  Future<List<Departement>> findAllByCrmId(int index) => dao.findAllByCrmId(index);
}