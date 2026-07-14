import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';

import '../../main.dart';
import '../beans/message_response.dart';
import '../model/artisan.dart';
import '../objets/constants.dart';
import '../services.dart';

class CustomLinearProgressIndicator extends StatefulWidget {
  final List<Artisan> listeArtisanToSend;
  final double increment;

  const CustomLinearProgressIndicator({
    Key? key,
    required this.listeArtisanToSend,
    required this.increment
  }) : super(key: key);

  @override
  _CustomLinearProgressIndicatorState createState() => _CustomLinearProgressIndicatorState();
}


class _CustomLinearProgressIndicatorState extends State<CustomLinearProgressIndicator>{
  //late AnimationController controller;
  double cpt = 0.0;
  bool initTransfert = false;

  @override
  void initState() {
    Timer.periodic(
      const Duration(milliseconds: 500), (timer) {
        if(!initTransfert){
          initTransfert = true;
          timer.cancel();
          sendData();
        }
      },
    );
    super.initState();
  }

  void sendData() async {
    var localToken = await MesServices().checkJwtExpiration();
    for(Artisan artisan in widget.listeArtisanToSend){
      final url = Uri.parse('${dotenv.env['URL_BACKEND']}manage-artisanmobile');
      try {
        var response = await post(url,
            headers: {
              "Content-Type": "application/json",
              'Authorization': 'Bearer $localToken'
            },
            body: jsonEncode({
              "id" : 0,
              "civilite" : artisan.civilite,
              "nom" : artisan.nom,
              "prenom" : artisan.prenom,
              "date_naissance" : artisan.date_naissance,
              "lieu_naissance" : artisan.lieu_naissance.toString(),
              "lieu_naissance_autre" : artisan.lieu_naissance_autre,
              "nationalite" : artisan.nationalite.toString(),
              "cnps" : artisan.cnps,
              "cmu" : artisan.cmu,
              "chiffre_affaire" : artisan.chiffre_affaire,
              "presence_compte_bancaire" : artisan.presence_compte_bancaire,
              "type_compte_bancaire" : artisan.type_compte_bancaire,
              "regime_social" : artisan.regime_social,
              "regime_travailleur" : artisan.regime_travailleur,
              "regime_imposition_taxe_communale" : artisan.regime_imposition_taxe_communale,
              "regime_imposition_micro_entreprise" : artisan.regime_imposition_micro_entreprise,
              "comptabilite" : artisan.comptabilite,
              "sexe" : "",
              "statut_matrimonial" : artisan.statut_matrimonial.toString(),
              "type_document" : artisan.type_document.toString(),
              "numero_piece" : artisan.numero_piece,
              "piece_delivre" : artisan.piece_delivre.toString(),
              "date_emission_piece" : artisan.date_emission_piece,
              "niveau_etude" : artisan.niveau_etude.toString(),
              "formation" : artisan.formation.toString(),
              "classe" : artisan.classe.toString(),
              "diplome" : artisan.diplome.toString(),
              "ville_residence" : artisan.commune_residence.toString(),
              "quartier_residence" : artisan.quartier_residence,
              "adresse_postal" : artisan.adresse_postal,
              "contact1" : artisan.contact1,
              "contact2" : artisan.contact2,
              "email" : artisan.email,

              "photo_artisan" : artisan.photo_artisan,
              "photo_cni_recto" : artisan.photo_cni_recto,
              "photo_cni_verso" : artisan.photo_cni_verso,
              "photo_diplome" : artisan.photo_diplome,
              "photo_autre" : artisan.photoAutre,

              "longitude" : artisan.longitude.toString(),
              "latitude" : artisan.latitude.toString(),
              "crm" : artisan.crm,
              "departement" : artisan.departement,
              "sous_pref" : artisan.sous_prefecture,
              "activite_principale" : artisan.activite_principale,
              "activite_secondaire" : artisan.activite_secondaire,
              "raison_social" : artisan.raison_social,
              "sigle" : artisan.sigle,
              "date_creation" : artisan.date_creation,
              "ville_commune" : artisan.commune_activite.toString(),
              "quartier" : artisan.quartier_activite_id,
              "niveau_equipement" : artisan.niveau_equipement.toString(),
              "rccm" : artisan.rccm,
              "salarie_homme" : 0,
              "salarie_femme" : 0,
              "auxiliaire_homme" : 0,
              "auxiliaire_femme" : 0,
              "apprenti_homme" : 0,
              "apprenti_femme" : 0,
              "statut_artisan" : artisan.statut_artisan,
              "numero_registre" : artisan.numero_registre,
              "livraison_carte" : artisan.livraisonCarte == 1 ? true : false,
              "optin_mail": artisan.optinMail == 1 ? true : false,
              "optin_sms": artisan.optinSms == 1 ? true : false,
              "optin_whatsapp": 0,
              "regime_fiscal": artisan.regimeFiscal,
              "qualification": artisan.qualification,
              "synchronisation": 1
            })
        ).timeout(const Duration(seconds: timeOutValueEntite));

        if (response.statusCode == 200) {
          MessageResponse reponse = MessageResponse.fromJson(
              json.decode(response.body));
          Artisan artisanNew = Artisan(
              id: reponse.id,
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
              photoAutre: artisan.photoAutre,
              date_expiration_carte: '',
              statut_kyc: artisan.statut_kyc,
              statut_paiement: artisan.statut_paiement,
              longitude: artisan.longitude,
              latitude: artisan.latitude,
              regime_social: artisan.regime_social,
              regime_travailleur: artisan.regime_travailleur,
              regime_imposition_taxe_communale: artisan.regime_imposition_taxe_communale,
              regime_imposition_micro_entreprise: artisan.regime_imposition_micro_entreprise,
              comptabilite: artisan.comptabilite,
              chiffre_affaire: artisan.chiffre_affaire,
              cnps: artisan.cnps,
              cmu: artisan.cmu,
              presence_compte_bancaire: artisan.presence_compte_bancaire,
              type_compte_bancaire: artisan.type_compte_bancaire,
              crm: artisan.crm,
              departement: artisan.departement,
              sous_prefecture: artisan.sous_prefecture,

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
              statut_artisan: artisan.statut_artisan,
              livraisonCarte: artisan.livraisonCarte,
              optinMail: artisan.optinMail,
              optinSms: artisan.optinSms,
              optinWhatsapp: artisan.optinWhatsapp,
              regimeFiscal: artisan.regimeFiscal,
              qualification: artisan.qualification,
              statutLivraison: artisan.statutLivraison,
              print: artisan.print,
              synchronized: 1,

              confirmationLivraison: artisan.confirmationLivraison,
              photoSignatureLivraison: artisan.photoSignatureLivraison
          );
          // Persist the new ONE :
          artisanControllerX.addItem(artisanNew);
          // Delete the old one :
          artisanControllerX.deleteItem(artisan);
        }
        else if(response.statusCode == 404){
          // Delete the old one :
          artisanControllerX.deleteItem(artisan);
        }
        /*else{
          displayToast("Impossible de transmettre les données de l'Artisan !");
        }*/
      }
      finally {
        setState(() {
          cpt += widget.increment;
        });
      }
    }
    outil.updateSynchro(false);
  }

  @override
  Widget build(BuildContext context) {
    // Perform our
    return LinearProgressIndicator(
      value: cpt,
      semanticsLabel: 'Linear progress indicator',
    );
  }
}