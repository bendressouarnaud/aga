
import 'package:cnmci/konan/model/crm.dart';

import '../dao/crm_dao.dart';
import '../dao/metier_dao.dart';
import '../model/metier.dart';

class MetierRepository {
  final dao = MetierDao();

  Future<int> insert(Metier data) => dao.create(data);
  Future<Metier?> findOne(int id) => dao.findOne(id);
  Future<List<Metier>> findAll() => dao.findAll();
}