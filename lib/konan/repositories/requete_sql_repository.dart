import 'package:cnmci/konan/dao/requete_sql_dao.dart';
import '../model/requete_sql.dart';

class RequeteSqlRepository {
  final dao = RequeteSqlDao();

  Future<int> insert(RequeteSql data) => dao.create(data);
  Future<List<RequeteSql>> findAll() => dao.findAll();
}