import 'dart:async';
import 'dart:convert';

import 'package:cnmci/getxcontroller/artisan_controller_x.dart';
import 'package:cnmci/getxcontroller/compagnon_controller_x.dart';
import 'package:cnmci/konan/historique/historique_compagnon.dart';
import 'package:cnmci/konan/model/artisan.dart';
import 'package:cnmci/konan/services.dart';
import 'package:cnmci/konan/webviews/webview_payment_wave.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../getxcontroller/apprenti_controller_x.dart';
import '../main.dart';
import 'beans/enrolement_amount_to_pay.dart';
import 'beans/wave_payment_response.dart';
import 'historique/historique_apprenti.dart';
import 'interface_artisan_personne.dart';
import 'objets/constants.dart';

class InterfaceViewArtisan extends StatefulWidget{
  const InterfaceViewArtisan({Key? key}) : super(key: key);

  @override
  State<InterfaceViewArtisan> createState() => _InterfaceViewArtisan();
}

class _InterfaceViewArtisan extends State<InterfaceViewArtisan>{

  // A T T R I B U T E S :
  late BuildContext dialogContext;
  bool flagSendData = false;
  bool flagServerResponse = false;
  String paymentUrl = "";
  bool displayQr = false;
  int montantArtisan = 0;
  int statutPaiement = 0;


  // M E T H O D S :
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

  String formatPrice(int price) {
    MoneyFormatter fmf = MoneyFormatter(amount: price.toDouble());
    //
    return fmf.output.withoutFractionDigits;
  }

  // Total APPRENTis
  Future<int> getTotalApprenti() async{
    var total = await outil.findAllApprentiByArtisan(artisanToManage.id);
    return total;
  }

  // Total COMPAGNONs
  Future<int> getTotalCompagnon() async{
    var total = await outil.findAllCompagnonByArtisan(artisanToManage.id);
    return total;
  }

  void displayWaintingForStatusPayment(){
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
        }
    );

    flagSendData = true;
    flagServerResponse = true;

    getStatusPayment();

    Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (!flagServerResponse) {
          Navigator.pop(dialogContext);
          timer.cancel();

          if (flagSendData) {
            // Open WEBVIEW :
            displayToast('Impossible d\'obtenir le statut');
          }
        }
      },
    );
  }

  // Pick PAYMENT STATUS :
  Future<void> getStatusPayment() async {
    // Reset :
    statutPaiement = 0;

    try{
      var localToken = await MesServices().checkJwtExpiration();
      final url = Uri.parse('${dotenv.env['URL_BACKEND']}get-status-payment');
      var response = await post(url,
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer $localToken'
          },
          body: jsonEncode({
            "id": artisanToManage.id,
            "requester": "ART",
          })
      ).timeout(const Duration(seconds: timeOutValue));
      if(response.statusCode == 200){
        statutPaiement = json.decode(response.body);
        if(statutPaiement != artisanToManage.statut_paiement){
          // Update this :
          Artisan updateArtisan = Artisan(
              id: artisanToManage.id,
              nom: artisanToManage.nom,
              prenom: artisanToManage.prenom,
              civilite: artisanToManage.civilite,
              date_naissance: artisanToManage.date_naissance,
              numero_registre: artisanToManage.numero_registre,
              lieu_naissance_autre: artisanToManage.lieu_naissance_autre,
              lieu_naissance: artisanToManage.lieu_naissance,
              nationalite: artisanToManage.nationalite,
              statut_matrimonial: artisanToManage.statut_matrimonial,
              type_document: artisanToManage.type_document,
              niveau_etude: artisanToManage.niveau_etude,
              formation: artisanToManage.formation,
              classe: artisanToManage.classe,
              diplome: artisanToManage.diplome,
              commune_residence: artisanToManage.commune_residence,
              activite: artisanToManage.activite,
              sexe: '',
              numero_piece: artisanToManage.numero_piece,
              piece_delivre: artisanToManage.piece_delivre,
              date_emission_piece: artisanToManage.date_emission_piece,
              metier: artisanToManage.metier,
              quartier_residence: artisanToManage.quartier_residence,
              adresse_postal: artisanToManage.adresse_postal,
              contact1: artisanToManage.contact1,
              contact2: artisanToManage.contact2,
              email: artisanToManage.email,
              photo_artisan: artisanToManage.photo_artisan,
              photo_cni_recto: artisanToManage.photo_cni_recto,
              photo_cni_verso: artisanToManage.photo_cni_verso,
              photo_diplome: artisanToManage.photo_diplome,
              date_expiration_carte: artisanToManage.date_expiration_carte,
              statut_kyc: artisanToManage.statut_kyc,
              statut_paiement: statutPaiement,
              longitude: artisanToManage.longitude,
              latitude: artisanToManage.latitude,
              regime_social: artisanToManage.regime_social,
              regime_travailleur: artisanToManage.regime_travailleur,
              regime_imposition_taxe_communale: artisanToManage.regime_imposition_taxe_communale,
              regime_imposition_micro_entreprise: artisanToManage.regime_imposition_micro_entreprise,
              comptabilite: artisanToManage.comptabilite,
              chiffre_affaire: artisanToManage.chiffre_affaire,
              cnps: artisanToManage.cnps,
              cmu: artisanToManage.cmu,
              presence_compte_bancaire: artisanToManage.presence_compte_bancaire,
              type_compte_bancaire: artisanToManage.type_compte_bancaire,
              crm: artisanToManage.crm,
              departement: artisanToManage.departement,
              sous_prefecture: artisanToManage.sous_prefecture,

              specialite: artisanToManage.specialite,
              activite_principale: artisanToManage.activite_principale,
              activite_secondaire: artisanToManage.activite_secondaire,
              raison_social: artisanToManage.raison_social,
              sigle: artisanToManage.sigle,
              date_creation: artisanToManage.date_creation,
              commune_activite: artisanToManage.commune_activite,
              quartier_activite: artisanToManage.quartier_activite,
              rccm: artisanToManage.rccm,
              niveau_equipement: artisanToManage.niveau_equipement,
              millisecondes: artisanToManage.millisecondes,
              quartier_activite_id: artisanToManage.quartier_activite_id,
              statut_artisan: artisanToManage.statut_artisan,
              livraisonCarte: artisanToManage.livraisonCarte
          );
          artisanControllerX.updateData(updateArtisan);
        }
        flagSendData = false;
      }
    }
    catch(e){}
    finally{
      flagServerResponse = false;
    }
  }

  Future<EnrolementAmountToPay> getAmountToPay() async {
    try{
      var localToken = await MesServices().checkJwtExpiration();
      final url = Uri.parse('${dotenv.env['URL_BACKEND']}get-amount');
      var response = await post(url,
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer $localToken'
          },
          body: jsonEncode({
            "id": artisanToManage.id,
            "requester": "ART",
          })
      ).timeout(const Duration(seconds: timeOutValue));
      if(response.statusCode == 200){
        EnrolementAmountToPay reponse = EnrolementAmountToPay.fromJson(
            json.decode(response.body));
        return reponse;
      } else {
        // Server UNAVAILABLE :
        return EnrolementAmountToPay(seul: 0, tout: 0);
      }
    }
    catch(e){
      // Connexion PROBLEM :
      //print('Exception : ${e.toString()}');
      return EnrolementAmountToPay(seul: 0, tout: 0);;
    }
  }

  void getPaymentUrl(int montant, int choix) async {
    try{
      var localToken = await MesServices().checkJwtExpiration();
      final url = Uri.parse('${dotenv.env['URL_BACKEND']}generate-wave-url');
      var response = await post(url,
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer $localToken'
          },
          body: jsonEncode({
            "id": artisanToManage.id,
            "requester": "ART",
            "amount": montant,
            "choix": choix,
          })
      ).timeout(const Duration(seconds: timeOutValue));
      if(response.statusCode == 200){
        WavePaymentResponse reponse = WavePaymentResponse.fromJson(
            json.decode(response.body));
        //print('Lien URL **** : ${reponse.wave_launch_url}');
        paymentUrl = reponse.wave_launch_url;
        flagSendData = false;
      }
    }
    catch(e){
      // Connexion PROBLEM :
      // print('Exception **** : ${e.toString()}');
    }
    finally{
      flagServerResponse = false;
    }
  }

  void displayWaintingPayingInterface(int montant, int choix){
    if(montantArtisan > 0) {
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
          }
      );

      flagSendData = true;
      flagServerResponse = true;

      getPaymentUrl(montant, choix);

      Timer.periodic(
        const Duration(seconds: 1),
            (timer) {
          if (!flagServerResponse) {
            Navigator.pop(dialogContext);
            timer.cancel();

            if (!flagSendData) {
              // Open WEBVIEW :
              localLink();
              /*Navigator.push(context,
                MaterialPageRoute(builder: (context) {
                  return WebviewPaymentWave(url: paymentUrl, client: artisanToManage.nom);
                })
            );*/
            } else {
              displayToast('Traitement impossible *****');
            }
          }
        },
      );
    }
    else{
      displayToast('Frais de l\'Artisan payés. Veuillez utilisez l\'interface de son collaborateur pour effectuer le paiement');
    }
  }

  void localLink() {
    MesServices().displayDialog(context, paymentUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(artisanToManage.nom),
          actions: [
            Visibility(
                visible: artisanToManage.statut_paiement != 2,
                child: IconButton(
                    onPressed: () {
                      displayWaintingForStatusPayment();
                    },
                    icon: Icon(Icons.sync
                        , color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    )
                )
            )
          ],
        ),
        body: FutureBuilder(
            future: Future.wait([getAmountToPay(), getTotalApprenti(), getTotalCompagnon()]),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot){
              if(snapshot.connectionState == ConnectionState.done && snapshot.hasData){
                // Price to PAY :
                EnrolementAmountToPay sommeApayer = snapshot.data[0];
                montantArtisan = sommeApayer.seul; // Refresh
                // Total APPRENTi :
                var totalApprenti = snapshot.data[1];
                // Total COMPAGNON :
                var totalCompagnon = snapshot.data[2];

                return SingleChildScrollView(
                  child: Column(
                      children: [
                        Card(
                          /*height: 130,
                          width: MediaQuery.of(context).size.width,*/
                          margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
                          child: Padding(
                              padding: EdgeInsets.all(5),
                            child: Row(
                              children: [
                                SizedBox(
                                  height: 120,
                                  width: 90,
                                  child: MesServices().displayFromLocalOrFirebase(artisanToManage.photo_artisan),
                                ),
                                Expanded(
                                    child: Column(
                                      children: [
                                        Container(
                                            margin: EdgeInsets.only(right: 10, left: 10),
                                            alignment: Alignment.topLeft,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  MesServices().processEntityName('${artisanToManage.nom} ${artisanToManage.prenom}', limitCharacter),
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  ),
                                                ),
                                                Text(artisanToManage.date_creation)
                                              ],
                                            )
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(right: 10, left: 10, top: 5),
                                          alignment: Alignment.topLeft,
                                          child: GetBuilder(
                                              builder: (ArtisanControllerX controllerX) {
                                                // Process :
                                                var currentArtisan = controllerX.data.where(
                                                        (a) => a.id == artisanToManage.id
                                                ).first;

                                                if(currentArtisan.statut_paiement == 2){
                                                  // Refresh :
                                                  montantArtisan = 0;
                                                }

                                                return Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(artisanToManage.contact1),
                                                        Text(currentArtisan.statut_paiement == 0 ? 'Non payé' :
                                                        currentArtisan.statut_paiement == 1 ? 'En cours' : 'Payé',
                                                          style: TextStyle(
                                                              color: currentArtisan.statut_paiement == 0 ? Colors.red :
                                                              currentArtisan.statut_paiement == 1 ? Colors.blueGrey : Colors.green,
                                                              fontWeight: FontWeight.bold
                                                          ),)
                                                      ],
                                                );
                                              }
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(right: 10, left: 10, top: 5),
                                          alignment: Alignment.topLeft,
                                          child: Divider(
                                            height: 3,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Container(
                                            margin: EdgeInsets.only(right: 10, left: 10, top: 5),
                                            alignment: Alignment.topLeft,
                                            child: Text.rich(
                                              TextSpan(
                                                  text: 'Métier : ',
                                                  //style: TextStyle(fontWeight: FontWeight.bold),
                                                  children: <TextSpan>[
                                                    TextSpan(text: lesMetiers.where((m) => m.id == artisanToManage.specialite).first.libelle,
                                                        style: TextStyle(fontWeight: FontWeight.bold)
                                                    )
                                                  ]
                                              ),
                                            )
                                        ),
                                        Container(
                                            margin: EdgeInsets.only(right: 10, left: 10, top: 5),
                                            alignment: Alignment.topLeft,
                                            child: Text.rich(
                                              TextSpan(
                                                  text: 'Nationalité : ',
                                                  //style: TextStyle(fontWeight: FontWeight.bold),
                                                  children: <TextSpan>[
                                                    TextSpan(text: lesPays.where((p) => p.id == artisanToManage.nationalite).first.libelle,
                                                        style: TextStyle(fontWeight: FontWeight.bold)
                                                    )
                                                  ]
                                              ),
                                            )
                                        ),
                                        Container(
                                            margin: EdgeInsets.only(right: 10, left: 10, top: 5),
                                            alignment: Alignment.topLeft,
                                            child: Text.rich(
                                              TextSpan(
                                                  text: 'Commune résid. : ',
                                                  children: <TextSpan>[
                                                    TextSpan(text: lesCommunes.where((c) => c.id == artisanToManage.commune_residence).first.libelle,
                                                        style: TextStyle(fontWeight: FontWeight.bold)
                                                    )
                                                  ]
                                              ),
                                            )
                                        )
                                      ],
                                    )
                                )
                              ],
                            ),
                          ),
                        ),

                        Container(
                          alignment: Alignment.topLeft,
                          margin: EdgeInsets.only(right: 10, left: 10, top: 25),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton.icon(
                                  style: ButtonStyle(
                                      backgroundColor: WidgetStateColor.resolveWith((states) => Colors.deepOrange)
                                  ),
                                  label: Text("Modifier",
                                      style: const TextStyle(
                                          color: Colors.white
                                      )
                                  ),
                                  onPressed: () async {
                                    setOriginFromCallArtisan = 0;
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
                                  },
                                  icon: Icon(
                                    Icons.edit,
                                    size: 20,
                                    color: Colors.white,
                                  )
                              ),
                              ElevatedButton.icon(
                                  style: ButtonStyle(
                                      backgroundColor: WidgetStateColor.resolveWith((states) => Colors.green)
                                  ),
                                  label: Text("Appeler",
                                      style: const TextStyle(
                                          color: Colors.white
                                      )
                                  ),
                                  onPressed: () async {
                                    if(artisanToManage.contact1.isNotEmpty) {
                                      var url = Uri.parse(
                                          'tel:${artisanToManage.contact1}');
                                      if (!await launchUrl(url, mode: LaunchMode
                                          .externalApplication)) {
                                        throw Exception(
                                            'Could not launch $url');
                                      }
                                    }
                                  },
                                  icon: Icon(
                                    Icons.call,
                                    size: 20,
                                    color: Colors.white,
                                  )
                              )
                            ],
                          ),
                        ),

                        Visibility(
                          visible: artisanToManage.statut_paiement < 2,
                            child: Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.only(right: 10, left: 10, top: 25),
                              child: Text('Paiement',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            )
                        ),

                        Visibility(
                            visible: artisanToManage.statut_paiement < 2,
                            child: Container(
                              margin: EdgeInsets.only(right: 10, left: 10, top: 5),
                              child: Divider(
                                height: 3,
                              ),
                            )
                        ),

                        Visibility(
                            visible: artisanToManage.statut_paiement < 2,
                            child: Container(
                                alignment: Alignment.topLeft,
                                margin: const EdgeInsets.only(right: 10, left: 10, top: 5),
                                padding: EdgeInsets.all(5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton.icon(
                                        style: ButtonStyle(
                                            backgroundColor: WidgetStateColor.resolveWith((states) => digiHmbColorDeep)
                                        ),
                                        label: Text("Payer",
                                            style: const TextStyle(
                                                color: Colors.white
                                            )
                                        ),
                                        onPressed: () {
                                          displayWaintingPayingInterface(sommeApayer.seul, 0);
                                        },
                                        icon: Icon(
                                          Icons.money,
                                          size: 20,
                                          color: Colors.white,
                                        )
                                    ),
                                    Text('${formatPrice(sommeApayer.seul)} F',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold
                                      ),
                                    )
                                  ],
                                )
                            )
                        ),

                        /*Container(
                            margin: const EdgeInsets.only(right: 10, left: 10, top: 5),
                            padding: EdgeInsets.all(5),
                            height: 120,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topRight,
                                  end: Alignment.bottomLeft,
                                  colors: [
                                    Colors.blue.shade100,
                                    Colors.brown.shade50,
                                  ],
                                ),
                                border: Border.all(
                                    color: Colors.black,
                                    width: 1
                                ),
                                //color: cardviewsousproduit,
                                borderRadius: BorderRadius.circular(16.0)
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: (){
                                    displayWaintingPayingInterface(sommeApayer.seul, 0);
                                  },
                                  child: SizedBox(
                                    //color: Colors.brown,
                                    //width: 92,
                                    height: 72,
                                    child: Column(
                                      children: [
                                        Icon(Icons.person,
                                          size: 50,
                                        ),
                                        Text('${formatPrice(sommeApayer.seul)} F')
                                      ],
                                    ),
                                  )
                                ),
                                ElevatedButton.icon(
                                    style: ButtonStyle(
                                        backgroundColor: WidgetStateColor.resolveWith((states) => digiHmbColorDeep)
                                    ),
                                    label: Text("Lancez-vous",
                                        style: const TextStyle(
                                            color: Colors.white
                                        )
                                    ),
                                    onPressed: () {
                                    },
                                    icon: Icon(
                                      Icons.navigate_next,
                                      size: 20,
                                      color: Colors.white,
                                    )
                                ),
                                GestureDetector(
                                  onTap: (){
                                    displayWaintingPayingInterface(sommeApayer.tout, 1);
                                  },
                                  child: SizedBox(
                                    //width: 92,
                                      height: 72,
                                      child: Column(
                                        children: [
                                          Icon(Icons.people_alt_outlined,
                                            size: 50,
                                          ),
                                          Text('${formatPrice(sommeApayer.tout)} F')
                                        ],
                                      )
                                  ),
                                )
                              ],
                            )
                        ),*/

                        Container(
                          alignment: Alignment.topLeft,
                          margin: EdgeInsets.only(right: 10, left: 10, top: 25),
                          child: Text('Gestion des équipes',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),

                        Container(
                          margin: EdgeInsets.only(right: 10, left: 10, top: 5),
                          child: Divider(
                            height: 3,
                          ),
                        ),

                        Card(
                            color: Colors.brown[50],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: GestureDetector(
                              onTap: (){
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                      return  HistoriqueApprenti(artisan: artisanToManage);
                                    })
                                );
                              },
                              child: Padding(
                                  padding: EdgeInsets.all(5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(Icons.people_alt,
                                      size: 50,
                                    ),
                                    Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('   Accéder ',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold
                                                )
                                            ),
                                            Row(
                                              children: [
                                                Text('   aux apprentis ',
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.bold
                                                    )
                                                ),
                                                GetBuilder(
                                                    builder: (ApprentiControllerX apprentiControllerX) {
                                                      // Process :
                                                      var totApprenti = apprentiControllerX.data.where(
                                                              (a) => a.artisan_id == artisanToManage.id
                                                      ).toList().length;

                                                      return Text('   ($totApprenti)',
                                                          style: TextStyle(
                                                              color: Colors.blue,
                                                              fontWeight: FontWeight.bold
                                                          )
                                                      );
                                                    }
                                                )
                                              ],
                                            )
                                          ],
                                        )
                                    )
                                  ],
                                ),
                              ),
                            )
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Card(
                            color: Colors.brown[50],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: GestureDetector(
                              onTap: (){
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                      return  HistoriqueCompagnon(artisan: artisanToManage);
                                    })
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.all(5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(Icons.people_alt,
                                      size: 50,
                                    ),
                                    Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('   Accéder ',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Text('   aux compagnons ',
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.bold
                                                    )
                                                ),
                                                GetBuilder(
                                                    builder: (CompagnonControllerX compagnonControllerX) {

                                                      // Process :
                                                      var totCompagnon = compagnonControllerX.data.where(
                                                              (a) => a.artisan_id == artisanToManage.id
                                                      ).toList().length;

                                                      return Text('   ($totCompagnon)',
                                                          style: TextStyle(
                                                              color: Colors.blue,
                                                              fontWeight: FontWeight.bold
                                                          )
                                                      );
                                                    }
                                                )
                                              ],
                                            )
                                          ],
                                        )
                                    )
                                  ],
                                ),
                              ),
                            )
                        ),

                        /*Visibility(
                          visible: displayQr,
                            child: QrImageView(
                              data: paymentUrl,
                              version: QrVersions.auto,
                              size: 280,
                              errorCorrectionLevel: QrErrorCorrectLevel.H,
                              backgroundColor: Colors.white,
                            )
                        )*/
                      ]
                  ),
                );
              }
              else{
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }
        )
    );
  }
}