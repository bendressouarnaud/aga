
import 'package:cnmci/konan/model/crm.dart';

import '../dao/crm_dao.dart';
import '../dao/niveau_etude_dao.dart';
import '../model/niveau_etude.dart';

class NiveauEtudeRepository {
  final dao = NiveauEtudeDao();

  Future<int> insert(NiveauEtude data) => dao.create(data);
  Future<NiveauEtude?> findOne(int id) => dao.findOne(id);
  Future<List<NiveauEtude>> findAll() => dao.findAll();
}