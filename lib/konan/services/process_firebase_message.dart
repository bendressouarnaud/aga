import 'package:cnmci/konan/model/artisan.dart';
import 'package:cnmci/konan/model/entreprise.dart';
import 'package:cnmci/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fl_chart/fl_chart.dart';

import '../model/apprenti.dart';
import '../model/compagnon.dart';

class FirebaseProcessMessage{

  // Attributes
  //late PromotionRepository repository;



  // Method
  void process(RemoteMessage message) async{

    int sujet = int.parse(message.data['sujet']);
    switch(sujet){
      case 1:
        if(message.data['type'] == "ART") {
          // Persist
          Artisan? artisan = artisanControllerX.data
              .where((a) => a.id == int.parse(message.data['entite']))
              .firstOrNull;
          if(artisan != null) {
            Artisan updateArtisan = Artisan(
                id: artisan.id,
                nom: artisan.nom,
                prenom: artisan.prenom,
                civilite: artisan.civilite,
                date_naissance: artisan.date_naissance,
                numero_registre: artisan.numero_registre,
                lieu_naissance_autre: artisan.lieu_naissance_autre,
                lieu_naissance: artisan.lieu_naissance,
                nationalite: artisan.nationalite,
                statut_matrimonial: artisan.statut_matrimonial,
                type_document: artisan.type_document,
                niveau_etude: artisan.niveau_etude,
                formation: artisan.formation,
                classe: artisan.classe,
                diplome: artisan.diplome,
                commune_residence: artisan.commune_residence,
                activite: artisan.activite,
                sexe: '',
                numero_piece: artisan.numero_piece,
                piece_delivre: artisan.piece_delivre,
                date_emission_piece: artisan.date_emission_piece,
                metier: artisan.metier,
                quartier_residence: artisan.quartier_residence,
                adresse_postal: artisan.adresse_postal,
                contact1: artisan.contact1,
                contact2: artisan.contact2,
                email: artisan.email,
                photo_artisan: artisan.photo_artisan,
                photo_cni_recto: artisan.photo_cni_recto,
                photo_cni_verso: artisan.photo_cni_verso,
                photo_diplome: artisan.photo_diplome,
                date_expiration_carte: '',
                statut_kyc: artisan.statut_kyc,
                statut_paiement: int.parse(message.data['statut']),
                longitude: artisan.longitude,
                latitude: artisan.latitude,
                regime_social: artisan.regime_social,
                regime_travailleur: artisan.regime_travailleur,
                regime_imposition_taxe_communale: artisan
                    .regime_imposition_taxe_communale,
                regime_imposition_micro_entreprise: artisan
                    .regime_imposition_micro_entreprise,
                comptabilite: artisan.comptabilite,
                chiffre_affaire: artisan.chiffre_affaire,
                cnps: artisan.cnps,
                cmu: artisan.cmu,
                presence_compte_bancaire: artisan.presence_compte_bancaire,
                type_compte_bancaire: artisan.type_compte_bancaire,
                crm: artisan.crm,
                departement: artisan.departement,
                sous_prefecture: artisan.sous_prefecture,

                specialite: artisan.specialite,
                activite_principale: artisan.activite_principale,
                activite_secondaire: artisan.activite_secondaire,
                raison_social: artisan.raison_social,
                sigle: artisan.sigle,
                date_creation: artisan.date_creation,
                commune_activite: artisan.commune_activite,
                quartier_activite: artisan.quartier_activite,
                rccm: artisan.rccm,
                niveau_equipement: artisan.niveau_equipement,
                millisecondes: artisan.millisecondes,
                quartier_activite_id: artisan.quartier_activite_id,
                statut_artisan: artisan.statut_artisan
            );
            //
            artisanControllerX.updateData(updateArtisan);
          }
        }
        else if(message.data['type'] == "APP") {
          Apprenti? apprenti = apprentiControllerX.data
              .where((a) => a.id == int.parse(message.data['entite']))
              .firstOrNull;
          if(apprenti != null) {
            Apprenti updateApprenti = Apprenti(
                id: apprenti.id,
                nom: apprenti.nom,
                prenom: apprenti.prenom,
                civilite: apprenti.civilite,
                date_naissance: apprenti.date_naissance,
                numero_immatriculation: apprenti.numero_immatriculation,
                lieu_naissance_autre: apprenti.lieu_naissance_autre,
                lieu_naissance: apprenti.lieu_naissance,
                nationalite: apprenti.nationalite,
                type_document: apprenti.type_document,
                niveau_etude: apprenti.niveau_etude,
                classe: apprenti.classe,
                diplome: apprenti.diplome,
                date_debut_apprentissage: apprenti.date_debut_apprentissage,
                commune_residence: apprenti.commune_residence,
                metier: apprenti.metier,
                sexe: '',
                numero_piece: apprenti.numero_piece,
                piece_delivre: apprenti.piece_delivre,
                date_emission_piece: apprenti.date_emission_piece,
                quartier_residence: apprenti.quartier_residence,
                adresse_postal: apprenti.adresse_postal,
                contact1: apprenti.contact1,
                contact2: apprenti.contact2,
                email: apprenti.email,
                photo: apprenti.photo,
                photo_cni_recto: apprenti.photo_cni_recto,
                photo_cni_verso: apprenti.photo_cni_verso,
                statut_kyc: 0,
                statut_paiement: int.parse(message.data['statut']),
                longitude: apprenti.longitude,
                latitude: apprenti.latitude,
                a_suivi_formation: apprenti.a_suivi_formation,
                centre_formation_metier: apprenti.centre_formation_metier,
                intitule_formation_metier: apprenti.intitule_formation_metier,
                formation_metier_terminee: apprenti.formation_metier_terminee,
                diplome_obtenu_metier: apprenti.diplome_obtenu_metier,
                cnps: apprenti.cnps,
                cmu: apprenti.cmu,
                artisan_id: apprenti.artisan_id,
                entreprise_id: apprenti.entreprise_id,
                millisecondes: apprenti.millisecondes,
                statut_apprenti: apprenti.statut_apprenti
            );
            apprentiControllerX.updateData(updateApprenti);
          }
        }
        else if(message.data['type'] == "COM") {
          Compagnon? compagnon = compagnonControllerX.data
              .where((a) => a.id == int.parse(message.data['entite']))
              .firstOrNull;
          if(compagnon != null) {
            Compagnon updateCompagnon = Compagnon(
                id: compagnon.id,
                nom: compagnon.nom,
                prenom: compagnon.prenom,
                civilite: compagnon.civilite,
                date_naissance: compagnon.date_naissance,
                numero_immatriculation: compagnon.numero_immatriculation,
                lieu_naissance_autre: compagnon.lieu_naissance_autre,
                lieu_naissance: compagnon.lieu_naissance,
                nationalite: compagnon.nationalite,
                sexe: '',
                type_document: compagnon.type_document,
                niveau_etude: compagnon.niveau_etude,
                specialite: compagnon.specialite,
                classe: compagnon.classe,
                diplome: compagnon.diplome,
                apprentissage_metier: compagnon.apprentissage_metier,
                date_debut_compagnonnage: compagnon.date_debut_compagnonnage,
                commune_residence: compagnon.commune_residence,
                quartier_residence: compagnon.quartier_residence,
                adresse_postal: compagnon.adresse_postal,
                numero_piece: compagnon.numero_piece,
                piece_delivre: compagnon.piece_delivre,
                date_emission_piece: compagnon.date_emission_piece,
                photo: compagnon.photo,
                photo_cni_recto: compagnon.photo_cni_recto,
                photo_cni_verso: compagnon.photo_cni_verso,
                photo_diplome: compagnon.photo_diplome,
                contact1: compagnon.contact1,
                contact2: compagnon.contact2,
                email: compagnon.email,
                statut_kyc: 0,
                statut_paiement: int.parse(message.data['statut']),
                longitude: compagnon.longitude,
                latitude: compagnon.latitude,
                cnps: compagnon.cnps,
                cmu: compagnon.cmu,
                artisan_id: compagnon.artisan_id,
                entreprise_id: compagnon.entreprise_id,
                millisecondes: compagnon.millisecondes,
                statut_compagnon: compagnon.statut_compagnon
            );
            compagnonControllerX.updateData(updateCompagnon);
          }
        }
        else {
          Entreprise entreprise = entrepriseControllerX.data
              .where((a) => a.id == int.parse(message.data['entite']))
              .first;
          Entreprise updateEntreprise = Entreprise(
              id: entreprise.id,
              crm: entreprise.crm,
              departement: entreprise.departement,
              sous_prefecture: entreprise.sous_prefecture,
              civilite: entreprise.civilite,
              nom: entreprise.nom,
              prenom: entreprise.prenom,
              date_naissance: entreprise.date_naissance,
              lieu_naissance: entreprise.lieu_naissance,
              lieu_naissance_autre: entreprise.lieu_naissance_autre,
              nationalite: entreprise.nationalite,
              statut_matrimonial: entreprise.statut_matrimonial,
              type_document: entreprise.type_document,
              numero_piece: entreprise.numero_piece,
              piece_delivre: entreprise.piece_delivre,
              date_emission_piece: entreprise.date_emission_piece,
              commune_residence: entreprise.commune_residence,
              quartier_residence: entreprise.quartier_residence,
              adresse_postal: entreprise.adresse_postal,
              contact1: entreprise.contact1,
              contact2: entreprise.contact2,
              email: entreprise.email,

              forme_juridique: entreprise.forme_juridique,
              activite_principale: entreprise.activite_principale,
              activite_secondaire: entreprise.activite_secondaire,
              denomination: entreprise.denomination,
              sigle: entreprise.sigle,
              date_creation: entreprise.date_creation,
              objet_social: entreprise.objet_social,
              rccm: entreprise.rccm,
              date_rccm: entreprise.date_rccm,
              capital_social: entreprise.capital_social,
              regime_fiscal: entreprise.regime_fiscal,
              duree_personne_morale: entreprise.duree_personne_morale,
              cnps_entreprise: entreprise.cnps_entreprise,
              compte_contribuable: entreprise.compte_contribuable,
              total_associe: entreprise.total_associe,
              commune_siege: entreprise.commune_siege,
              quartier_siege: entreprise.quartier_siege,
              lot: entreprise.lot,
              telephone: entreprise.telephone,
              statut_kyc: 0,
              statut_paiement: int.parse(message.data['statut']),
              longitude: entreprise.longitude,
              latitude: entreprise.latitude,
              millisecondes: entreprise.millisecondes,
              quartier_siege_id: entreprise.quartier_siege_id
          );
          entrepriseControllerX.updateData(updateEntreprise);
        }
        break;

      default:
        print("Contenu : ${message.data['message']}");
        break;
    }
  }

  String generateDateTimeFromDateTime(String date){
    // "2012-02-27T14+00:00"
    var tampon = date.split("/"); // 19/08/2025
    var localDatetime = DateTime.now();
    var t = '${tampon[2]}-${fillZero(int.parse(tampon[1]))}-${fillZero(int.parse(tampon[0]))}T00'
        '${generateNumberSigned(localDatetime.timeZoneOffset.isNegative)}${fillZero(localDatetime.timeZoneOffset.inHours)}:00';
    return t;
  }

  String generateNumberSigned(bool data){
    return data ? '-' : '+';
  }

  String fillZero(int data){
    return data < 10 ? '0$data' : data.toString();
  }

}