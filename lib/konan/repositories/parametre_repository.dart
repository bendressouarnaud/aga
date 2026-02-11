
import '../dao/parametre_dao.dart';
import '../model/parametre.dart';

class ParametreRepository {
  final dao = ParametreDao();

  Future<int> insert(Parametre data) => dao.create(data);
  Future<Parametre?> findUnique(int id) => dao.findUnique(id);
}