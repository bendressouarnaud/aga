import 'package:cnmci/konan/dao/apprenti_dao.dart';

import '../model/apprenti.dart';

class ApprentiRepository {
  final dao = ApprentiDao();

  Future<int> insert(Apprenti data) => dao.create(data);
  Future<Apprenti?> findOne(int id) => dao.findOne(id);
  Future<int> update(Apprenti data) => dao.update(data);
  Future<List<Apprenti>> findAll() => dao.findAll();
  Future<List<Apprenti>> findAllByArtisanAndEntreprise(int artisanId, int entrepriseId) =>
      dao.findAllByArtisanAndEntreprise(artisanId, entrepriseId);
}