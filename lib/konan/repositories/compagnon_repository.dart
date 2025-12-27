import 'package:cnmci/konan/dao/compagnon_dao.dart';

import '../model/compagnon.dart';

class CompagnonRepository {
  final dao = CompagnonDao();

  Future<int> insert(Compagnon data) => dao.create(data);
  Future<Compagnon?> findOne(int id) => dao.findOne(id);
  Future<int> update(Compagnon data) => dao.update(data);
  Future<List<Compagnon>> findAll() => dao.findAll();
  Future<List<Compagnon>> findAllByArtisanAndEntreprise(int artisanId, int entrepriseId) =>
      dao.findAllByArtisanAndEntreprise(artisanId, entrepriseId);
}