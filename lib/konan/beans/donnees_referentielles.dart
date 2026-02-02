import 'package:cnmci/konan/model/classe.dart';
import 'package:cnmci/konan/model/commune.dart';
import 'package:cnmci/konan/model/crm.dart';
import 'package:cnmci/konan/model/departement.dart';
import 'package:cnmci/konan/model/diplome.dart';
import 'package:cnmci/konan/model/metier.dart';
import 'package:cnmci/konan/model/niveau_etude.dart';
import 'package:cnmci/konan/model/pays.dart';
import 'package:cnmci/konan/model/quartier.dart';
import 'package:cnmci/konan/model/sous_prefecture.dart';
import 'package:cnmci/konan/model/statut_matrimonial.dart';
import 'package:cnmci/konan/model/type_compte_bancaire.dart';
import 'package:cnmci/konan/model/type_document.dart';

class DonneesReferentielles {

  // A t t r i b u t e s  :
  final List<Crm> crm;
  final List<Departement> departement;
  final List<SousPrefecture> sous_prefecture;
  final List<Commune> commune;
  final List<Quartier> quartier;
  final List<Pays> pays;
  final List<StatutMatrimonial> statut_matrimonial;
  final List<TypeCompteBancaire> type_compte_bancaire;
  final List<TypeDocument> type_document;
  final List<NiveauEtude> niveau_etude;
  final List<Classe> classe;
  final List<Diplome> diplome;
  final List<Metier> metier;

  // M e t h o d s  :
  DonneesReferentielles({required this.crm, required this.departement, required this.sous_prefecture, required this.commune,
    required this.pays, required this.statut_matrimonial, required this.type_compte_bancaire, required this.type_document,
    required this.niveau_etude, required this.classe, required this.diplome, required this.metier,
    required this.quartier});
  factory DonneesReferentielles.fromJson(Map<String, dynamic> json) {
    return DonneesReferentielles(
      crm: List<dynamic>.from(json['crm']).map((i) => Crm.fromDatabaseJson(i)).toList(),
      departement: List<dynamic>.from(json['departement']).map((i) => Departement.fromDatabaseJson(i)).toList(),
      sous_prefecture: List<dynamic>.from(json['sous_prefecture']).map((i) => SousPrefecture.fromDatabaseJson(i)).toList(),
      commune: List<dynamic>.from(json['commune']).map((i) => Commune.fromDatabaseJson(i)).toList(),
      quartier: List<dynamic>.from(json['quartier']).map((i) => Quartier.fromDatabaseJson(i)).toList(),
      pays: List<dynamic>.from(json['pays']).map((i) => Pays.fromDatabaseJson(i)).toList(),
      statut_matrimonial: List<dynamic>.from(json['statut_matrimonial']).map((i) => StatutMatrimonial.fromDatabaseJson(i)).toList(),
      type_compte_bancaire: List<dynamic>.from(json['type_compte_bancaire']).map((i) => TypeCompteBancaire.fromDatabaseJson(i)).toList(),
      type_document: List<dynamic>.from(json['type_document']).map((i) => TypeDocument.fromDatabaseJson(i)).toList(),
      niveau_etude: List<dynamic>.from(json['niveau_etude']).map((i) => NiveauEtude.fromDatabaseJson(i)).toList(),
      classe: List<dynamic>.from(json['classe']).map((i) => Classe.fromDatabaseJson(i)).toList(),
      diplome: List<dynamic>.from(json['diplome']).map((i) => Diplome.fromDatabaseJson(i)).toList(),
      metier: List<dynamic>.from(json['metier']).map((i) => Metier.fromDatabaseJson(i)).toList(),
    );
  }
}