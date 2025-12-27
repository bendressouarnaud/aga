
import 'package:cnmci/konan/dao/type_compte_bancaire_dao.dart';
import '../dao/type_document_dao.dart';
import '../model/type_compte_bancaire.dart';
import '../model/type_document.dart';

class TypeDocumentRepository {
  final dao = TypeDocumentDao();

  Future<int> insert(TypeDocument data) => dao.create(data);
  Future<TypeDocument?> findOne(int id) => dao.findOne(id);
  Future<List<TypeDocument>> findAll() => dao.findAll();
}