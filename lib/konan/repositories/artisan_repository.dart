import 'package:cnmci/konan/dao/artisan_dao.dart';
import 'package:cnmci/konan/dao/commune_dao.dart';
import 'package:cnmci/konan/model/commune.dart';
import 'package:cnmci/konan/model/departement.dart';

import '../model/artisan.dart';

class ArtisanRepository {
  final dao = ArtisanDao();

  Future<int> insert(Artisan data) => dao.create(data);
  Future<Artisan?> findOne(int id) => dao.findOne(id);
  Future<int> update(Artisan data) => dao.update(data);
  Future<List<Artisan>> findAll() => dao.findAll();
}