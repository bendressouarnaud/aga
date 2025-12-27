import 'package:cnmci/konan/model/commune.dart';
import 'package:cnmci/konan/model/compagnon.dart';
import 'package:cnmci/konan/model/crm.dart';
import 'package:cnmci/konan/model/departement.dart';
import 'package:cnmci/konan/model/metier.dart';
import 'package:cnmci/konan/model/niveau_etude.dart';
import 'package:cnmci/konan/model/sous_prefecture.dart';
import 'package:cnmci/konan/model/statut_matrimonial.dart';
import 'package:cnmci/konan/model/type_compte_bancaire.dart';
import 'package:cnmci/konan/model/user.dart';
import 'package:cnmci/konan/repositories/apprenti_repository.dart';
import 'package:cnmci/konan/repositories/compagnon_repository.dart';
import '../model/apprenti.dart';
import '../model/classe.dart';
import '../model/diplome.dart';
import '../model/pays.dart';
import '../model/type_document.dart';
import '../repositories/classe_repository.dart';
import '../repositories/commune_repository.dart';
import '../repositories/crm_repository.dart';
import '../repositories/departement_repository.dart';
import '../repositories/diplome_repository.dart';
import '../repositories/metier_repository.dart';
import '../repositories/niveau_etude_repository.dart';
import '../repositories/pays_repository.dart';
import '../repositories/sous_prefecture_repository.dart';
import '../repositories/statut_matrimonial_repository.dart';
import '../repositories/type_compte_bancaire_repository.dart';
import '../repositories/type_document_repository.dart';
import '../repositories/user_repository.dart';

class Outil {

  // A t t r i b u t e s :
  static final Outil _instance = Outil._internal();
  late UserRepository _userRepository = UserRepository();
  late CrmRepository _crmRepository;
  late DepartementRepository _departementRepository;
  late SousPrefectureRepository _sousPrefectureRepository;
  late CommuneRepository _communeRepository;
  late PaysRepository _paysRepository;
  late StatutMatrimonialRepository _statutMatrimonialRepository;
  late TypeCompteBancaireRepository _typeCompteBancaireRepository;
  late TypeDocumentRepository _typeDocumentRepository;
  late NiveauEtudeRepository _niveauEtudeRepository;
  late ClasseRepository _classeRepository;
  late DiplomeRepository _diplomeRepository;
  late MetierRepository _metierRepository;

  late ApprentiRepository _apprentiRepository;
  late CompagnonRepository _compagnonRepository;

  // M E T H O D S
  // using a factory is important because it promises to return _an_ object of this type but it doesn't promise to make a new one.
  factory Outil() {
    return _instance;
  }
  // This named constructor is the "real" constructor
  // It'll be called exactly once, by the static property assignment         above
  // it's also private, so it can only be called in this class
  Outil._internal() {
    // initialization logic
    _userRepository = UserRepository();
    _crmRepository = CrmRepository();
    _departementRepository = DepartementRepository();
    _sousPrefectureRepository = SousPrefectureRepository();
    _communeRepository = CommuneRepository();
    _paysRepository = PaysRepository();
    _statutMatrimonialRepository = StatutMatrimonialRepository();
    _typeCompteBancaireRepository = TypeCompteBancaireRepository();
    _typeDocumentRepository = TypeDocumentRepository();
    _niveauEtudeRepository = NiveauEtudeRepository();
    _classeRepository = ClasseRepository();
    _diplomeRepository = DiplomeRepository();
    _metierRepository = MetierRepository();

    _apprentiRepository = ApprentiRepository();
    _compagnonRepository = CompagnonRepository();
  }

  // APPRENTI
  Future<int> findAllApprentiByArtisan(int artisan) async{
    List<Apprenti> data = await _apprentiRepository.findAllByArtisanAndEntreprise(artisan, 0);
    return data.length;
  }

  Future<int> findAllApprentiByEntreprise(int id) async{
    List<Apprenti> data = await _apprentiRepository.findAllByArtisanAndEntreprise(0, id);
    return data.length;
  }

  // COMPAGNON
  Future<int> findAllCompagnonByArtisan(int artisan) async{
    List<Compagnon> data = await _compagnonRepository.findAllByArtisanAndEntreprise(artisan, 0);
    return data.length;
  }

  Future<int> findAllCompagnonByEntreprise(int id) async{
    List<Compagnon> data = await _compagnonRepository.findAllByArtisanAndEntreprise(0, id);
    return data.length;
  }

  // USER
  Future<User?> findUser() async{
    User? data = await _userRepository.findLocalUser();
    return data;
  }

  // PAYS
  Future<List<Pays>> findAllPays() async{
    List<Pays> data = await _paysRepository.findAll();
    return data;
  }
  // CRM
  Future<List<Crm>> findAllCrm() async{
    List<Crm> data = await _crmRepository.findAll();
    return data;
  }
  // DEPARTEMENT
  Future<List<Departement>> findAllDepartement() async{
    List<Departement> data = await _departementRepository.findAll();
    return data;
  }
  // SOUS-PREFECTURE
  Future<List<SousPrefecture>> findAllSousPrefecture() async{
    List<SousPrefecture> data = await _sousPrefectureRepository.findAll();
    return data;
  }
  // COMMUNE
  Future<List<Commune>> findAllCommune() async{
    List<Commune> data = await _communeRepository.findAll();
    return data;
  }
  // STATUT MATRIMONIAL
  Future<List<StatutMatrimonial>> findAllStatutMatrimonial() async{
    List<StatutMatrimonial> data = await _statutMatrimonialRepository.findAll();
    return data;
  }
  // TYPE COMPTE BANCAIRE
  Future<List<TypeCompteBancaire>> findAllTypeCompteBancaire() async{
    List<TypeCompteBancaire> data = await _typeCompteBancaireRepository.findAll();
    return data;
  }
  // TYPE DOCUMENT
  Future<List<TypeDocument>> findAllTypeDocument() async{
    List<TypeDocument> data = await _typeDocumentRepository.findAll();
    return data;
  }
  // NIVEAU ETUDE
  Future<List<NiveauEtude>> findAllNiveauEtude() async{
    List<NiveauEtude> data = await _niveauEtudeRepository.findAll();
    return data;
  }
  // CLASSE
  Future<List<Classe>> findAllClasse() async{
    List<Classe> data = await _classeRepository.findAll();
    return data;
  }
  // Diplome
  Future<List<Diplome>> findAllDiplome() async{
    List<Diplome> data = await _diplomeRepository.findAll();
    return data;
  }
  // METIER
  Future<List<Metier>> findAllMetier() async{
    List<Metier> data = await _metierRepository.findAll();
    return data;
  }
}