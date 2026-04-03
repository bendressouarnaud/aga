import 'dart:async';
import 'dart:convert';

import 'package:cnmci/getxcontroller/apprenti_controller_x.dart';
import 'package:cnmci/konan/model/apprenti.dart';
import 'package:cnmci/konan/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:http/http.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import 'beans/enrolement_amount_to_pay.dart';
import 'beans/generic_data_amount.dart';
import 'beans/wave_payment_response.dart';
import 'interface_apprenti_personne.dart';
import 'objets/constants.dart';

class InterfaceViewApprenti extends StatefulWidget{
  final Apprenti apprenti;
  const InterfaceViewApprenti({Key? key, required this.apprenti}) : super(key: key);

  @override
  State<InterfaceViewApprenti> createState() => _InterfaceViewApprenti();
}

class _InterfaceViewApprenti extends State<InterfaceViewApprenti>{

  // A T T R I B U T E S :
  late BuildContext dialogContext;
  bool flagSendData = false;
  bool flagServerResponse = false;
  String paymentUrl = "";

  List<GenericDataAmount> lesGenericLivraisons = [
    GenericDataAmount(libelle: '3000 CFA', valeur: 3000, active: true),
    GenericDataAmount(libelle: '5000 CFA', valeur: 5000, active: true),
    GenericDataAmount(libelle: '10000 CFA', valeur: 10000, active: true),
    GenericDataAmount(libelle: '15000 CFA', valeur: 15000, active: true),
  ];
  int valeurParDefaut = 0;
  bool envoiLienPaiement = false;


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
            "id": widget.apprenti.id,
            "requester": "APP",
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
            "id": widget.apprenti.id,
            "requester": "APP",
            "amount": montant,
            "choix": choix,
          })
      ).timeout(const Duration(seconds: timeOutValue));
      if(response.statusCode == 200){
        WavePaymentResponse reponse = WavePaymentResponse.fromJson(
            json.decode(response.body));
        //print('Lien URL **** : ${reponse.wave_launch_url}');
        paymentUrl = reponse.wave_launch_url;
        if(envoiLienPaiement){
          sendNotificationToApprenti();
        }
        else{
          flagSendData = false;
        }
      }
    }
    catch(e){
      // Connexion PROBLEM :
      //print('Exception **** : ${e.toString()}');
    }
    finally{
      if(!envoiLienPaiement) {
        flagServerResponse = false;
      }
    }
  }

  // Send MAIL to 'APPRENTI' :
  void sendNotificationToApprenti() async {
    try{
      var localToken = await MesServices().checkJwtExpiration();
      final url = Uri.parse('${dotenv.env['URL_BACKEND']}send-wave-url-to-entity');
      var response = await post(url,
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer $localToken'
          },
          body: jsonEncode({
            "id": widget.apprenti.id,
            "requester": "APP",
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


  // Display different AMOUNTs :
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
                height: MediaQuery.of(context).size.height * 0.25,
                width: MediaQuery.of(context).size.width, // 400
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      RadioGroup<int>(
                          onChanged: (int? value) {
                            valeurParDefaut = value!;
                            Navigator.pop(dialogContext);
                            displayWaintingPayingInterface(valeurParDefaut, 0);
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
                      Container(
                        margin: EdgeInsets.only(bottom: 10),
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


  void displayWaintingPayingInterface(int montant, int choix){
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

    getPaymentUrl(montant, choix);

    Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (!flagServerResponse) {
          Navigator.pop(dialogContext);
          timer.cancel();

          if (!flagSendData) {
            if(!envoiLienPaiement) {
              localLink();
            }
          } else {
            displayToast('Traitement impossible *****');
          }
        }
      },
    );
  }

  void localLink() {
    MesServices().displayDialog(context, paymentUrl);
  }

  void forceLeave(){
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(widget.apprenti.nom),
        ),
        body: FutureBuilder(
            future: Future.wait([getAmountToPay()]),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot){
              if(snapshot.connectionState == ConnectionState.done && snapshot.hasData){
                // Price to PAY :
                EnrolementAmountToPay sommeApayer = snapshot.data[0];
                return SingleChildScrollView(
                  child: Column(
                      children: [
                        Card(
                          margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
                          child: Padding(
                              padding: EdgeInsets.all(5),
                            child: Row(
                              children: [
                                SizedBox(
                                  height: 120,
                                  width: 90,
                                  child: MesServices().displayFromLocalOrFirebase(widget.apprenti.photo),
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
                                                Text(MesServices().processEntityName(
                                                    '${widget.apprenti.nom} ${widget.apprenti.prenom}', limitCharacter),
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  ),
                                                ),
                                                Text(widget.apprenti.date_debut_apprentissage)
                                              ],
                                            )
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(right: 10, left: 10, top: 5),
                                          alignment: Alignment.topLeft,
                                          child: GetBuilder(
                                              builder: (ApprentiControllerX controllerX) {
                                                // Process :
                                                var currentApprenti = controllerX.data.where(
                                                        (a) => a.id == widget.apprenti.id
                                                ).first;

                                                return Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(currentApprenti.contact1),
                                                        Text(currentApprenti.statut_paiement == 0 ? 'Non payé' :
                                                        currentApprenti.statut_paiement == 1 ? 'En cours' : 'Payé',
                                                          style: TextStyle(
                                                              color: currentApprenti.statut_paiement == 0 ? Colors.red :
                                                              currentApprenti.statut_paiement == 1 ? Colors.blueGrey : Colors.green,
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
                                                    TextSpan(text: lesMetiers.where((m) => m.id == widget.apprenti.metier).first.libelle,
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
                                                    TextSpan(text: lesPays.where((p) => p.id == widget.apprenti.nationalite).first.libelle,
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
                                                    TextSpan(text: lesCommunes.where((c) => c.id == widget.apprenti.commune_residence).first.libelle,
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
                            )
                          )
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
                                          apprentiToManage = widget.apprenti;
                                          return InterfaceApprentiPersonne(
                                            artisanId: widget.apprenti.artisan_id,
                                            entrepriseId: widget.apprenti.entreprise_id,
                                            lApprenti: widget.apprenti,
                                          );
                                        })
                                    );

                                    // Close the DOORS :
                                    if (result != null) {
                                      displayToast("Vous pouvez afficher la donnée si vous le souhaitez !");
                                      forceLeave();
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
                                    if(widget.apprenti.contact1.isNotEmpty) {
                                      var url = Uri.parse(
                                          'tel:${widget.apprenti.contact1}');
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

                        GetBuilder(
                          builder: (ApprentiControllerX controllerX) {
                            // Process :
                            var currentApprenti = controllerX.data
                                .where(
                                    (a) => a.id == widget.apprenti.id
                            )
                                .first;
                            return Visibility(
                              visible: currentApprenti.statut_paiement < 2,
                              child: Container(
                                alignment: Alignment.topLeft,
                                margin: EdgeInsets.only(right: 10, left: 10, top: 35),
                                child: Text('Actions',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              )
                            );
                          }
                        ),

                        GetBuilder(
                            builder: (ApprentiControllerX controllerX) {
                              // Process :
                              var currentApprenti = controllerX.data
                                  .where(
                                      (a) => a.id == widget.apprenti.id
                              )
                                  .first;
                              return Visibility(
                                  visible: currentApprenti.statut_paiement < 2,
                                  child: Container(
                                    margin: EdgeInsets.only(right: 10, left: 10, top: 5),
                                    child: Divider(
                                      height: 3,
                                    ),
                                  ),
                              );
                            }
                        ),

                        GetBuilder(
                            builder: (ApprentiControllerX controllerX) {
                              // Process :
                              var currentApprenti = controllerX.data.where(
                                      (a) => a.id == widget.apprenti.id
                              ).first;
                              return Visibility(
                                visible: currentApprenti.statut_paiement < 2,
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
                                                displayAmount(sommeApayer.seul);
                                                //displayWaintingPayingInterface(sommeApayer.seul, 0);
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
                              );
                            }
                        ),

                        SizedBox(
                          height: 5,
                        ),

                        Visibility(
                            visible: widget.apprenti.statut_paiement < 2,
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
                        )
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