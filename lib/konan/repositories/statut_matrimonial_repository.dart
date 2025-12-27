import 'package:cnmci/konan/dao/statut_matrimonial_dao.dart';
import '../model/statut_matrimonial.dart';

class StatutMatrimonialRepository {
  final dao = StatutMatrimonialDao();

  Future<int> insert(StatutMatrimonial data) => dao.create(data);
  Future<StatutMatrimonial?> findOne(int id) => dao.findOne(id);
  Future<List<StatutMatrimonial>> findAll() => dao.findAll();
}