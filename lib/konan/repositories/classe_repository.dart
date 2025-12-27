
import 'package:cnmci/konan/model/classe.dart';
import '../dao/classe_dao.dart';

class ClasseRepository {
  final dao = ClasseDao();

  Future<int> insert(Classe data) => dao.create(data);
  Future<Classe?> findOne(int id) => dao.findOne(id);
  Future<List<Classe>> findAll() => dao.findAll();
}