import '../dao/derniere_operation_dao.dart';
import '../model/derniere_operation.dart';

class DerniereOperationRepository {
  final dao = DerniereOperationDao();

  Future<int> insert(DerniereOperation data) => dao.create(data);
  Future<DerniereOperation?> findOne(int id) => dao.findOne(id);
  Future<DerniereOperation?> findOneByMilliseconde(int milliseconde) => dao.findOneByMilliseconde(milliseconde);
  Future<List<DerniereOperation>> findAll() => dao.findAll();
}