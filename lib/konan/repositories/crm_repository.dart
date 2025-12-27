
import 'package:cnmci/konan/model/crm.dart';

import '../dao/crm_dao.dart';

class CrmRepository {
  final dao = CrmDao();

  Future<int> insert(Crm data) => dao.create(data);
  Future<Crm?> findOne(int id) => dao.findOne(id);
  Future<List<Crm>> findAll() => dao.findAll();
}