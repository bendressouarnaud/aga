import '../dao/enrolement_paiement_dao.dart';
import '../model/enrolement_paiement.dart';

class EnrolementPaiementRepository {
  final dao = EnrolementPaiementDao();

  Future<int> insert(EnrolementPaiement data) => dao.create(data);
  Future<List<EnrolementPaiement>> findAll() => dao.findAll();
}