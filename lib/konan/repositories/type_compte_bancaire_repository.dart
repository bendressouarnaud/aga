
import 'package:cnmci/konan/dao/type_compte_bancaire_dao.dart';
import '../model/type_compte_bancaire.dart';

class TypeCompteBancaireRepository {
  final dao = TypeCompteBancaireDao();

  Future<int> insert(TypeCompteBancaire data) => dao.create(data);
  Future<TypeCompteBancaire?> findOne(int id) => dao.findOne(id);
  Future<List<TypeCompteBancaire>> findAll() => dao.findAll();
}