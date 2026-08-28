import '../dao/gerant_entreprise_dao.dart';
import '../model/entreprise.dart';
import '../model/gerant_entreprise.dart';

class GerantEntrepriseRepository {
  final dao = GerantEntrepriseDao();

  Future<int> insert(GerantEntreprise data) => dao.create(data);
  Future<List<GerantEntreprise>> findAll() => dao.findAll();
}