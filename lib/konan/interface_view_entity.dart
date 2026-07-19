import 'dart:async';
import 'dart:convert';

import 'package:cnmci/konan/model/artisan.dart';
import 'package:cnmci/konan/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:http/http.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

import '../getxcontroller/apprenti_controller_x.dart';
import '../getxcontroller/compagnon_controller_x.dart';
import '../main.dart';
import 'beans/enrolement_amount_to_pay.dart';
import 'beans/generic_data_amount.dart';
import 'beans/stats_bean_manager.dart';
import 'beans/wave_payment_response.dart';
import 'historique/historique_apprenti.dart';
import 'historique/historique_compagnon.dart';
import 'interface_apprenti_personne.dart';
import 'interface_artisan_personne.dart';
import 'interface_compagnon_personne.dart';
import 'interface_manage_amende.dart';
import 'interface_signature.dart';
import 'model/entreprise.dart';
import 'objets/constants.dart';

class InterfaceViewEntity extends StatefulWidget {
  //final StatsBeanManager data;
  const InterfaceViewEntity({super.key});

  @override
  State<InterfaceViewEntity> createState() => _InterfaceViewEntity();
}

class _InterfaceViewEntity extends State<InterfaceViewEntity> {

  // ATTRIBUTES :
  int localAmende = 0;
  late BuildContext dialogContext;
  bool flagSendData = false;
  bool flagServerResponse = false;
  bool closeAlertDialog = false;
  int amountToPay = 0;
  String paymentUrl = "";
  List<GenericDataAmount> lesGenericLivraisons = [
    GenericDataAmount(libelle: '3000 CFA', valeur: 3000, active: true),
    GenericDataAmount(libelle: '5000 CFA', valeur: 5000, active: true),
    GenericDataAmount(libelle: '10000 CFA', valeur: 10000, active: true),
    GenericDataAmount(libelle: '15000 CFA', valeur: 15000, active: true),
  ];
  int valeurParDefaut = 0;
  bool envoiLienPaiement = false;
  bool openLocalWaveApplication = false;
  bool paiementFraisLivraison = statsBeanManager.livraisonCarte == 1;


  // METHODS :
  @override
  void initState() {
    super.initState();

    localAmende = statsBeanManager.amende;
  }

  void displayToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void displayAmount(int amountToPay){
    // Depending on the amount to PAY, adjust the list :
    var amountsToDisplay = lesGenericLivraisons.where((amount) => amountToPay >= amount.valeur).toList();
    valeurParDefaut = amountsToDisplay.first.valeur;

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          dialogContext = context;
          return AlertDialog(
              title: Text('Sélectionner un montant'),
              content: SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.width, // 400
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      RadioGroup<int>(
                          onChanged: (int? value) {
                            valeurParDefaut = value!;
                            Navigator.pop(dialogContext);
                            displayDataRequesting(
                                paiementFraisLivraison ? (valeurParDefaut + 1500) : valeurParDefaut
                            );
                          },
                          child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: amountsToDisplay.length,
                              itemBuilder: (BuildContext context, int index) {
                                return ListTile(
                                  title: Text(amountsToDisplay[index].libelle,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20
                                    ),
                                  ),
                                  leading: Radio<int>(value: amountsToDisplay[index].valeur),
                                );
                              }
                          )
                      ),
                      SizedBox(
                        height: 25,
                      ),

                      Visibility(
                          visible: paiementFraisLivraison,
                          child: Text('+ 1.500 FCFA (Livraison)',
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold
                            ),
                          )
                      ),

                      Container(
                        margin: EdgeInsets.only(bottom: 10, top: 20),
                        child: ElevatedButton.icon(
                            style: ButtonStyle(
                                backgroundColor: WidgetStateColor.resolveWith((states) => Colors.orange)
                            ),
                            label: Text("Fermer",
                                style: const TextStyle(
                                    color: Colors.white
                                )
                            ),
                            onPressed: () {
                              Navigator.pop(dialogContext);
                            },
                            icon: Icon(
                              Icons.close,
                              size: 20,
                              color: Colors.white,
                            )
                        ),
                      )
                    ],
                  ),
                ),
              )
          );
        }
    );
  }

  void displayEntityRequesting(int id){
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          dialogContext = context;
          return PopScope(
              canPop: false,
              child: AlertDialog(
                  title: Text('Information'),
                  content: SizedBox(
                      height: 100,
                      child: Column(
                        children: [
                          Text('Veuillez patienter ...'),
                          const SizedBox(
                            height: 20,
                          ),
                          const SizedBox(
                              height: 30.0,
                              width: 30.0,
                              child:
                              CircularProgressIndicator(
                                valueColor:
                                AlwaysStoppedAnimation<
                                    Color>(Colors.blue),
                                strokeWidth: 3.0,
                              ))
                        ],
                      )
                  )
              )
          );
        });

    flagSendData = true;
    flagServerResponse = true;
    getArtisanData(id);

    Timer.periodic(
      const Duration(seconds: 1),
          (timer) async {
        if (!flagServerResponse) {
          Navigator.pop(dialogContext);
          timer.cancel();

          if (!flagSendData) {
            setOriginFromCallArtisan = 1;
            final result = await Navigator.push(context,
                MaterialPageRoute(builder: (context) {
                  return InterfaceArtisanPersonne(lArtisan: artisanToManage);
                })
            );

            // Close the DOORS :
            if (result != null) {
              // Refresh :
              setState(() {});
            }
          }
          else{
            displayToast('Impossible d\'accéder aux données !');
          }
        }
      },
    );
  }

  Future<void> getArtisanData(int id) async {
    try{
      var localToken = await MesServices().checkJwtExpiration();
      final url = Uri.parse('${dotenv.env['URL_BACKEND']}get-artisan-from-mobile/$id');
      var response = await get(url,
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer $localToken'
          }
      ).timeout(const Duration(seconds: timeOutValue));
      if(response.statusCode == 200){
        artisanToManage = Artisan.fromDatabaseJson(json.decode(response.body));
        flagSendData = false;
      }
    }
    catch(e){
      // Connexion PROBLEM :
    }
    finally{
      flagServerResponse = false;
    }
  }

  void sendRegularisation() async {
    try{
      var localToken = await MesServices().checkJwtExpiration();
      final url = Uri.parse('${dotenv.env['URL_BACKEND']}regularisation');
      var response = await post(url,
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer $localToken'
          },
          body: jsonEncode({
            "contact": statsBeanManager.contact,
            "entite": getAppropriatePrefix(statsBeanManager.type)
          })
      ).timeout(const Duration(seconds: timeOutValue));
      if(response.statusCode == 200){
        flagSendData = false;
      }
    }
    catch(e){
      // Connexion PROBLEM :
    }
    finally{
      if(!envoiLienPaiement) {
        flagServerResponse = false;
      }
    }
  }

  void displayWaitingForRegularisation(){
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          dialogContext = context;
          return PopScope(
              canPop: false,
              child: AlertDialog(
                  title: Text('Information'),
                  content: SizedBox(
                      height: 100,
                      child: Column(
                        children: [
                          Text('Veuillez patienter ...'),
                          const SizedBox(
                            height: 20,
                          ),
                          const SizedBox(
                              height: 30.0,
                              width: 30.0,
                              child:
                              CircularProgressIndicator(
                                valueColor:
                                AlwaysStoppedAnimation<
                                    Color>(Colors.blue),
                                strokeWidth: 3.0,
                              ))
                        ],
                      )
                  )
              )
          );
        });

    flagSendData = true;
    flagServerResponse = true;
    sendRegularisation();

    Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (!flagServerResponse) {
          Navigator.pop(dialogContext);
          timer.cancel();
        }
      },
    );
  }

  void displayDataRequesting(int amountSelected){
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          dialogContext = context;
          return PopScope(
              canPop: false,
              child: AlertDialog(
                  title: Text('Information'),
                  content: SizedBox(
                      height: 100,
                      child: Column(
                        children: [
                          Text('Veuillez patienter ...'),
                          const SizedBox(
                            height: 20,
                          ),
                          const SizedBox(
                              height: 30.0,
                              width: 30.0,
                              child:
                              CircularProgressIndicator(
                                valueColor:
                                AlwaysStoppedAnimation<
                                    Color>(Colors.blue),
                                strokeWidth: 3.0,
                              ))
                        ],
                      )
                  )
              )
          );
        });

    flagSendData = true;
    flagServerResponse = true;
    amountToPay = 0;
    //getAmountToPay();
    getPaymentUrl(amountSelected);

    Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (!flagServerResponse) {
          Navigator.pop(dialogContext);
          timer.cancel();

          if (!flagSendData) {
            if(openLocalWaveApplication){
              //
              openLocalWaveApplication = false;
              openWaveApplication();
            }
            else if(!envoiLienPaiement) {
              // Display QRCODE :
              MesServices().displayDialog(context, paymentUrl);
            }
          }
        }
      },
    );
  }

  void openWaveApplication() async{
    final Uri url = Uri.parse(paymentUrl);
    await launchUrl(url);
  }

  /*Future<void> getAmountToPay() async {
    try{
      var localToken = await MesServices().checkJwtExpiration();
      final url = Uri.parse('${dotenv.env['URL_BACKEND']}get-amount');
      var response = await post(url,
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer $localToken'
          },
          body: jsonEncode({
            "id": statsBeanManager.id,
            "requester": getAppropriatePrefix(statsBeanManager.type),
          })
      ).timeout(const Duration(seconds: timeOutValue));
      if(response.statusCode == 200){
        EnrolementAmountToPay reponse = EnrolementAmountToPay.fromJson(
            json.decode(response.body));
        amountToPay = reponse.seul;
      }
    }
    catch(e){
      // Connexion PROBLEM :
    }
    finally{
      if(amountToPay == 0) {
        // Stop EVERYTHING :
        flagServerResponse = false;
      }
      else{
        getPaymentUrl(amountToPay);
      }
    }
  }*/

  void getPaymentUrl(int montant) async {
    try{
      var localToken = await MesServices().checkJwtExpiration();
      final url = Uri.parse('${dotenv.env['URL_BACKEND']}generate-wave-url');
      var response = await post(url,
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer $localToken'
          },
          body: jsonEncode({
            "id": statsBeanManager.id,
            "requester": getAppropriatePrefix(statsBeanManager.type),
            "amount": montant,
            "choix": 0,
            "payment_type": paiementFraisLivraison ? 2 : 0
          })
      ).timeout(const Duration(seconds: timeOutValue));
      if(response.statusCode == 200){
        WavePaymentResponse reponse = WavePaymentResponse.fromJson(
            json.decode(response.body));
        paymentUrl = reponse.wave_launch_url;
        if(envoiLienPaiement){
          sendNotificationToEntity();
        }
        else{
          flagSendData = false;
        }
      }
    }
    catch(e){
      // Connexion PROBLEM :
    }
    finally{
      if(!envoiLienPaiement) {
        flagServerResponse = false;
      }
    }
  }

  void sendNotificationToEntity() async {
    try{
      var localToken = await MesServices().checkJwtExpiration();
      final url = Uri.parse('${dotenv.env['URL_BACKEND']}send-wave-url-to-entity');
      var response = await post(url,
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer $localToken'
          },
          body: jsonEncode({
            "id": statsBeanManager.id,
            "requester": getAppropriatePrefix(statsBeanManager.type),
            "url": paymentUrl
          })
      ).timeout(const Duration(seconds: timeOutValue));
      if(response.statusCode == 200){
        flagSendData = false;
      }
    }
    catch(e){}
    finally{
      flagServerResponse = false;
    }
  }

  Icon processIconToShow(String date, int paiement){
    String dateCreation = '${date}T00+00:00';
    DateTime dateTimeCreation = DateTime.parse(dateCreation);
    DateTime dateTimeNow = DateTime.now();
    int difference = dateTimeNow.difference(dateTimeCreation).inDays;
    if(paiement == 2){
      return Icon(Icons.check,
          color: Colors.green);
    }
    else{
      return Icon(difference >= 90 ? Icons.calendar_month : Icons.timer_sharp,
          color: difference >= 90 ? Colors.red : Colors.orange);
    }
  }

  Text processDateLibelle(String type, String date){
    return Text('Date ${ type == 'Entreprises' ? 'création' : 'naiss.' } : $date');
  }

  Icon getAppropriateIcon(String libelle){
    switch(libelle){
      case 'Artisans':
        return Icon(Icons.person,
          color: Colors.deepOrange,
        );

      case 'Apprentis':
        return Icon(Icons.people_alt,
          color: Colors.brown,
        );

      case 'Compagnons':
        return Icon(Icons.people_outline_outlined,
          color: Colors.blue,
        );

      default:
        return Icon(Icons.location_city,
          color: Colors.green,
        );
    }
  }

  String getAppropriatePrefix(String libelle){
    switch(libelle){
      case 'Artisans':
        return 'ART';

      case 'Apprentis':
        return 'APP';

      case 'Compagnons':
        return 'COM';

      default:
        return 'ENT';
    }
  }

  Artisan generatePartialArtisan(){
    return Artisan(
        id: statsBeanManager.id,
        nom: '',
        prenom: '',
        civilite: '',
        date_naissance: '',
        numero_registre: '',
        lieu_naissance_autre: '',
        lieu_naissance: 0,
        nationalite: 0,
        statut_matrimonial: 0,
        type_document: 0,
        niveau_etude: 0,
        formation: 0,
        classe: 0,
        diplome: 0,
        commune_residence: 0,
        activite: 0,
        sexe: '',
        numero_piece: '',
        piece_delivre: 0,
        date_emission_piece: '',
        metier: 0,
        quartier_residence: '',
        adresse_postal: '',
        contact1: '',
        contact2: '',
        email: '',
        photo_artisan: '',
        photo_cni_recto: '',
        photo_cni_verso: '',
        photo_diplome: '',
        photoAutre: '',
        date_expiration_carte: '',
        statut_kyc: 0,
        statut_paiement: 0,
        longitude: 0.0,
        latitude: 0.0,
        regime_social: 0,
        regime_travailleur: 0,
        regime_imposition_taxe_communale: 0,
        regime_imposition_micro_entreprise: 0,
        comptabilite: 0,
        chiffre_affaire: 0,
        cnps: '',
        cmu: '',
        presence_compte_bancaire: 0,
        type_compte_bancaire: 0,
        crm: 0,
        departement: 0,
        sous_prefecture: 0,

        activite_principale: 0,
        activite_secondaire: '',
        raison_social: '',
        sigle: '',
        date_creation: '',
        commune_activite: 0,
        quartier_activite: '',
        rccm: '',
        niveau_equipement: 0,
        millisecondes: 0,
        quartier_activite_id: 0,
        statut_artisan: 0,
        livraisonCarte: 0,
        optinMail: 0,
        optinSms: 0,
        optinWhatsapp: 0,
        regimeFiscal: 0,
        qualification: '',
        statutLivraison: 0,
        print: 0,
        synchronized: 1,

        confirmationLivraison: 0,
        photoSignatureLivraison: ''
    );
  }

  Entreprise generatePartialEntreprise(){
    return Entreprise(
        id: statsBeanManager.id,
        crm: 0,
        departement: 0,
        sous_prefecture: 0,
        civilite: '',
        nom: '',
        prenom: '',
        date_naissance: '',
        lieu_naissance: 0,
        lieu_naissance_autre: '',
        nationalite: 0,
        statut_matrimonial: 0,
        type_document: 0,
        numero_piece: '',
        piece_delivre: 0,
        date_emission_piece: '',
        commune_residence: 0,
        quartier_residence: '',
        adresse_postal: '',
        contact1: '',
        contact2: '',
        email: '',

        forme_juridique: 0,
        activite_principale: 0,
        activite_secondaire: 0,
        denomination: '',
        sigle: '',
        date_creation: '',
        objet_social: '',
        rccm: '',
        date_rccm: '',
        capital_social: 0,
        regime_fiscal: 0,
        duree_personne_morale: 0,
        cnps_entreprise: '',
        compte_contribuable: '',
        total_associe: 0,
        commune_siege: 0,
        quartier_siege: '',
        lot: '',
        telephone: '',
        statut_kyc: 0,
        statut_paiement: 0,
        longitude: 0.0,
        latitude: 0.0,
        millisecondes: DateTime.now().millisecondsSinceEpoch,
        quartier_siege_id: 0,
        livraisonCarte: 0,

        photoCniRecto: '',
        photoCniVerso: '',
        photoRegistreCommerce: '',
        photoDfe: '',
        qualification: '',

        statutLivraison: 0,
        confirmationLivraison: 0,
        photoSignatureLivraison: ''
    );
  }

  @override
  Widget build(BuildContext context) {

    // Refresh :
    totalExterneApprenti = statsBeanManager.totalApprenti;
    totalExterneCompagnon = statsBeanManager.totalCompagnon;

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text('Visualisation'),
          actions: [

            Visibility(
              visible: statsBeanManager.paiement == 2 &&
                  statsBeanManager.statutLivraison == 1 &&
                  statsBeanManager.confirmationLivraison == 0,
              child: IconButton(
                  onPressed: () async {
                    final result = await Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                          return InterfaceSignature(id: statsBeanManager.id,
                              requester: getAppropriatePrefix(statsBeanManager.type),
                              operationType: 1
                          );
                        })
                    );

                    // Close the DOORS :
                    if (result != null) {
                      // Refresh :
                      setState(() {
                        statsBeanManager = StatsBeanManager(
                            id: statsBeanManager.id,
                            nom: statsBeanManager.nom,
                            contact: statsBeanManager.contact,
                            datenaissance: statsBeanManager.datenaissance,
                            metier: statsBeanManager.metier,
                            paiement: statsBeanManager.paiement,
                            commune: statsBeanManager.commune,
                            type: statsBeanManager.type,
                            image: statsBeanManager.image,
                            datenrolement: statsBeanManager.datenrolement,
                            quartier: statsBeanManager.quartier,
                            amende: statsBeanManager.amende,
                            latitude: statsBeanManager.latitude,
                            longitude: statsBeanManager.longitude,
                            montant: statsBeanManager.montant,
                            // 13/07/2026
                            statutLivraison: 1,
                            confirmationLivraison: 1,
                            livraisonCarte: statsBeanManager.livraisonCarte,
                            totalApprenti: statsBeanManager.totalApprenti,
                            totalCompagnon: statsBeanManager.totalCompagnon
                        );
                      });
                    }
                  },
                  icon: Icon(Icons.waving_hand, color: Colors.green)
              ),
            ),

            Visibility(
              visible: statsBeanManager.type == 'Artisans' && globalUser!.profil != "ROLE_AGENT_ENROLEMENT",
              child: IconButton(
                  onPressed: () {
                    displayEntityRequesting(statsBeanManager.id);
                  },
                  icon: Icon(Icons.edit, color: Colors.brown)
              ),
            ),

            Visibility(
                visible: statsBeanManager.type != 'Compagnons' && globalUser!.profil != "ROLE_AGENT_ENROLEMENT",
                child: IconButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                            return InterfaceSignature(id: statsBeanManager.id,
                                requester: getAppropriatePrefix(statsBeanManager.type),
                                operationType: 0
                            );
                          })
                      );
                    },
                    icon: Icon(Icons.draw
                      , color: Colors.black,
                      fontWeight: FontWeight.bold,
                    )
                )
            ),
            IconButton(
                onPressed: () async {
                  if(statsBeanManager.contact.isNotEmpty) {
                    var url = Uri.parse(
                        'tel:${statsBeanManager.contact}');
                    if (!await launchUrl(url, mode: LaunchMode
                        .externalApplication)) {
                    throw Exception(
                    'Could not launch $url');
                    }
                  }
                  else{
                    displayToast('Contact indisponible !');
                  }
                },
                onLongPress: () {
                  // Call for REGULARISATION :
                  if(globalUser!.profil == "ROLE_SUPER_ADMIN") {
                    displayWaitingForRegularisation();
                  }
                },
                icon: Icon(Icons.call, color: Colors.blue)
            )
          ]
      ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 20, left: 10, right: 10),
                alignment: Alignment.center,
                //width: MediaQuery.of(context).size.width * 0.40,
                child: SizedBox(
                  height: 230,
                  width: 180,
                  child: MesServices().displayFromLocalOrFirebase(statsBeanManager.image),
                )
              ),
              Container(
                  margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  alignment: Alignment.topLeft,
                  child: Divider(
                    height: 7,
                    thickness: 3,
                    color: Colors.brown,
                  )
              ),
              Container(
                margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                alignment: Alignment.topLeft,
                child: Text.rich(
                  TextSpan(
                    text: 'Nom : ',
                      //style: TextStyle(fontWeight: FontWeight.bold),
                      children: <TextSpan>[
                        TextSpan(text: MesServices().processEntityName(statsBeanManager.nom.toUpperCase(), limitCharacterEntity),
                            style: TextStyle(fontWeight: FontWeight.bold)
                        )
                      ]
                  ),
                )
              ),
              Container(
                margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                alignment: Alignment.topLeft,
                child: Text.rich(
                  TextSpan(
                    text: 'Contact : ',
                      children: <TextSpan>[
                        TextSpan(text: statsBeanManager.contact,
                            style: TextStyle(fontWeight: FontWeight.bold)
                        )
                      ]
                  ),
                )
              ),
              Container(
                margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                alignment: Alignment.topLeft,
                child: Text.rich(
                  TextSpan(
                    text: 'Date naissance : ',
                      children: <TextSpan>[
                        TextSpan(text: statsBeanManager.datenaissance,
                            style: TextStyle(fontWeight: FontWeight.bold)
                        )
                      ]
                  ),
                )
              ),
              Container(
                margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                alignment: Alignment.topLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text.rich(
                      TextSpan(
                          text: 'Date enrôlement : ',
                          children: <TextSpan>[
                            TextSpan(text: statsBeanManager.datenrolement,
                                style: TextStyle(fontWeight: FontWeight.bold)
                            )
                          ]
                      ),
                    ),
                    processIconToShow(statsBeanManager.datenrolement, statsBeanManager.paiement)
                  ],
                )
              ),
              Container(
                  margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  alignment: Alignment.topLeft,
                  child: Text.rich(
                    TextSpan(
                        text: 'Métier : ',
                        children: <TextSpan>[
                          TextSpan(text: statsBeanManager.metier,
                              style: TextStyle(fontWeight: FontWeight.bold)
                          )
                        ]
                    ),
                  )
              ),
              Container(
                  margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  alignment: Alignment.topLeft,
                  child: Divider(
                    height: 5,
                  )
              ),
              Container(
                  margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  alignment: Alignment.topLeft,
                  child: Text.rich(
                    TextSpan(
                        text: 'Commune : ',
                        children: <TextSpan>[
                          TextSpan(text: statsBeanManager.commune,
                              style: TextStyle(fontWeight: FontWeight.bold)
                          )
                        ]
                    ),
                  )
              ),
              Container(
                  margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  alignment: Alignment.topLeft,
                  child: Text.rich(
                    TextSpan(
                        text: 'Quartier : ',
                        children: <TextSpan>[
                          TextSpan(text: statsBeanManager.quartier,
                              style: TextStyle(fontWeight: FontWeight.bold)
                          )
                        ]
                    ),
                  )
              ),
              Container(
                  margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  alignment: Alignment.topLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(statsBeanManager.type,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          getAppropriateIcon(statsBeanManager.type)
                        ],
                      ),
                      Text(statsBeanManager.paiement == 0 ? 'Non payé' :
                      statsBeanManager.paiement == 1 ? 'En cours' : 'Soldé',
                        style: TextStyle(
                            color: statsBeanManager.paiement == 0 ? Colors.red :
                            statsBeanManager.paiement == 1 ? Colors.brown : Colors.green
                        ),)
                    ],
                  )
              ),
              Container(
                  margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  alignment: Alignment.center,
                  child: Visibility(
                      visible: statsBeanManager.paiement != 2,
                      child: ElevatedButton.icon(
                        style: ButtonStyle(
                            backgroundColor: WidgetStateColor.resolveWith((states) => Colors.green)
                        ),
                        label: Text("Régularisation (${statsBeanManager.montant} CFA)",
                            style: TextStyle(
                                color: Colors.white
                            )),
                        onLongPress: () {
                          openLocalWaveApplication = true;
                          displayAmount(statsBeanManager.montant);
                        },
                        onPressed: () async {
                          displayAmount(statsBeanManager.montant);
                          //displayDataRequesting();
                        },
                        icon: const Icon(
                          Icons.money,
                          size: 20,
                          color: Colors.white,
                        ),
                      )
                  )
              ),

              SizedBox(
                height: 5,
              ),

              Visibility(
                  visible: statsBeanManager.paiement != 2 &&
                      (statsBeanManager.livraisonCarte == 1 && statsBeanManager.statutLivraison == 0),
                  child: CheckboxListTile(
                    title: const Text('Paiement frais Livraison'),
                    value: paiementFraisLivraison,
                    onChanged: (bool? value) {
                      setState(() {
                        paiementFraisLivraison = !paiementFraisLivraison;
                      });
                    },
                    secondary: const Icon(Icons.share,
                      color: Colors.orange,
                    ),
                  )
              ),

              Visibility(
                  visible: statsBeanManager.paiement < 2,
                  child: CheckboxListTile(
                    title: const Text('Envoi lien de paiement'),
                    value: envoiLienPaiement,
                    onChanged: (bool? value) {
                      setState(() {
                        envoiLienPaiement = !envoiLienPaiement;
                      });
                    },
                    secondary: const Icon(Icons.send),
                  )
              ),
              Container(
                  margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  alignment: Alignment.topLeft,
                  child: Divider(
                    height: 5
                  )
              ),
              Container(
                  margin: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 30),
                  alignment: Alignment.topLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Visibility(
                        visible: statsBeanManager.paiement != 2 && globalUser!.profil != "ROLE_AGENT_ENROLEMENT",
                          child: ElevatedButton.icon(
                            style: ButtonStyle(
                                backgroundColor: WidgetStateColor.resolveWith((states) => Colors.blueGrey)
                            ),
                            label: Text("Amende ($localAmende)",
                                style: TextStyle(
                                    color: Colors.white
                                )),
                            onPressed: () async {
                              final result = await Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                    return InterfaceManageAmende(
                                        data: statsBeanManager
                                    );
                                  })
                              );
                              // Refresh :
                              if (result != null) {
                                // Request for Permission :
                                setState(() {
                                  // Replace this by a call from API :
                                  localAmende++;
                                });
                              }
                            },
                            icon: const Icon(
                              Icons.money,
                              size: 20,
                              color: Colors.white,
                            ),
                          )
                      ),
                      Visibility(
                        visible: statsBeanManager.latitude > 0,
                          child: ElevatedButton.icon(
                            style: ButtonStyle(
                                iconAlignment: IconAlignment.end,
                                backgroundColor: WidgetStateColor.resolveWith((states) => Colors.brown)
                            ),
                            label: Text("Affichez",
                                style: TextStyle(
                                    color: Colors.white
                                )
                            ),
                            onPressed: () async {
                              MapsLauncher.launchCoordinates(statsBeanManager.latitude, statsBeanManager.longitude,
                              statsBeanManager.nom);
                            },
                            icon: Icon(
                              Icons.gps_fixed,
                              size: 20,
                              color: Colors.white,
                            ),
                          )
                      ),
                    ],
                  )
              ),
              /*Container(
                  margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  alignment: Alignment.topLeft,
                  child: Divider(
                      height: 5
                  )
              ),*/

              Visibility(
                  visible: statsBeanManager.type == 'Artisans' || statsBeanManager.type == 'Entreprises',
                  child: Container(
                    alignment: Alignment.topLeft,
                    margin: EdgeInsets.only(right: 10, left: 10, top: 10),
                    child: Text('Gestion des équipes',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.lightBlue
                      ),
                    ),
                  )
              ),

              Visibility(
                  visible: statsBeanManager.type == 'Artisans' || statsBeanManager.type == 'Entreprises',
                  child: Container(
                    margin: EdgeInsets.only(right: 10, left: 10, top: 5),
                    child: Divider(
                      height: 3,
                    ),
                  )
              ),

              Visibility(
                  visible: statsBeanManager.type == 'Artisans' || statsBeanManager.type == 'Entreprises',
                  child: SafeArea(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              addingExterneApprenti = true;
                              final result = await Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                    if(statsBeanManager.type == 'Artisans') {
                                      return InterfaceApprentiPersonne(
                                        artisanId: generatePartialArtisan().id,
                                        entrepriseId: 0,
                                      );
                                    }
                                    else{
                                      return InterfaceApprentiPersonne(
                                        artisanId: 0,
                                        entrepriseId: generatePartialEntreprise().id,
                                      );
                                    }
                                  })
                              );

                              if (result != null) {
                                // We can INCREMENT :
                                setState(() {
                                  totalExterneApprenti++;
                                });
                              }
                              else{
                                addingExterneApprenti = false;
                              }
                            },
                            child: Container(
                              width: (MediaQuery.of(context).size.width / 2) - 20,
                              margin: EdgeInsets.all(10),
                              padding: EdgeInsets.all(5),
                              height: 100,
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topRight,
                                    end: Alignment.bottomLeft,
                                    colors: [
                                      Colors.red.shade50,
                                      Colors.blue.shade100
                                    ],
                                  ),
                                  //color: Colors.brown[100],
                                  borderRadius: BorderRadius.circular(8.0)
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.people_alt,
                                    size: 50,
                                  ),
                                  Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text('Apprentis',
                                            style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold
                                            ),
                                          ),
                                          Text('   ($totalExterneApprenti)',
                                              style: TextStyle(
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.bold
                                              )
                                          )
                                        ],
                                      )
                                  )
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              addingExterneCompagnon = true;
                              final result = await Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                    if(statsBeanManager.type == 'Artisans') {
                                      return InterfaceCompagnonPersonne(
                                          artisanId: generatePartialArtisan().id,
                                          entrepriseId: 0,
                                          compagnon: null
                                      );
                                    }
                                    else{
                                      return InterfaceCompagnonPersonne(
                                          artisanId: 0,
                                          entrepriseId: generatePartialEntreprise().id,
                                          compagnon: null
                                      );
                                      return HistoriqueCompagnon(
                                          entreprise: generatePartialEntreprise());
                                    }
                                  })
                              );

                              if (result != null) {
                                // We can INCREMENT :
                                setState(() {
                                  totalExterneCompagnon++;
                                });
                              }
                              else{
                                addingExterneCompagnon = false;
                              }
                            },
                            child: Container(
                              width: (MediaQuery.of(context).size.width / 2) - 20,
                              margin: EdgeInsets.all(10),
                              padding: EdgeInsets.all(5),
                              height: 100,
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topRight,
                                    end: Alignment.bottomLeft,
                                    colors: [
                                      Colors.blue.shade100,
                                      Colors.red.shade50,
                                    ],
                                  ),
                                  //color: Colors.brown[100],
                                  borderRadius: BorderRadius.circular(8.0)
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.people_outline,
                                    size: 50,
                                  ),
                                  Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text('Compagnons',
                                            style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold
                                            ),
                                          ),
                                          Text('   ($totalExterneCompagnon)',
                                              style: TextStyle(
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.bold
                                              )
                                          )
                                        ],
                                      )
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                  )
              )
            ],
          ),
        )
    );
  }

}
