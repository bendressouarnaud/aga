import 'package:cnmci/konan/dao/commune_dao.dart';
import 'package:cnmci/konan/model/commune.dart';
import 'package:cnmci/konan/model/departement.dart';

class CommuneRepository {
  final dao = CommuneDao();

  Future<int> insert(Commune data) => dao.create(data);
  Future<Commune?> findOne(int id) => dao.findOne(id);
  Future<List<Commune>> findAll() => dao.findAll();
  Future<List<Commune>> findAllBySousPrefectureId(int index) => dao.findAllBySousPrefectureId(index);
}