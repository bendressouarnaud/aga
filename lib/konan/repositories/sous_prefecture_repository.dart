import 'package:cnmci/konan/dao/sous_prefecture_dao.dart';
import 'package:cnmci/konan/model/sous_prefecture.dart';

class SousPrefectureRepository {
  final dao = SousPrefectureDao();

  Future<int> insert(SousPrefecture data) => dao.create(data);
  Future<SousPrefecture?> findOne(int id) => dao.findOne(id);
  Future<List<SousPrefecture>> findAll() => dao.findAll();
  Future<List<SousPrefecture>> findAllByDepartementId(int index) => dao.findAllByDepartementId(index);
}