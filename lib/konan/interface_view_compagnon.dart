import 'dart:async';
import 'dart:convert';

import 'package:cnmci/getxcontroller/compagnon_controller_x.dart';
import 'package:cnmci/konan/model/compagnon.dart';
import 'package:cnmci/konan/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:http/http.dart';
import 'package:money_formatter/money_formatter.dart';

import '../main.dart';
import 'beans/enrolement_amount_to_pay.dart';
import 'beans/wave_payment_response.dart';
import 'objets/constants.dart';

class InterfaceViewCompagnon extends StatefulWidget{
  final Compagnon compagnon;
  const InterfaceViewCompagnon({Key? key, required this.compagnon}) : super(key: key);

  @override
  State<InterfaceViewCompagnon> createState() => _InterfaceViewCompagnon();
}

class _InterfaceViewCompagnon extends State<InterfaceViewCompagnon>{

  // A T T R I B U T E S :
  late BuildContext dialogContext;
  bool flagSendData = false;
  bool flagServerResponse = false;
  String paymentUrl = "";


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
            "id": widget.compagnon.id,
            "requester": "COM",
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
            "id": widget.compagnon.id,
            "requester": "COM",
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
      print('Exception **** : ${e.toString()}');
    }
    finally{
      flagServerResponse = false;
    }
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
            // Open WEBVIEW :
            localLink();
            /*Navigator.push(context,
                MaterialPageRoute(builder: (context) {
                  return WebviewPaymentWave(url: paymentUrl, client: widget.artisan.nom);
                })
            );*/
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(widget.compagnon.nom),
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
                                  child: MesServices().displayFromLocalOrFirebase(widget.compagnon.photo),
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
                                                  MesServices().processEntityName('${widget.compagnon.nom} ${widget.compagnon.prenom}', limitCharacter),
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  ),
                                                ),
                                                Text(widget.compagnon.date_debut_compagnonnage)
                                              ],
                                            )
                                        ),
                                        GetBuilder(
                                            builder: (CompagnonControllerX controllerX) {
                                              // Process :
                                              var currentCompagnon = controllerX.data.where(
                                                      (a) => a.id == widget.compagnon.id
                                              ).first;

                                              return Container(
                                                margin: EdgeInsets.only(right: 10, left: 10, top: 5),
                                                alignment: Alignment.topLeft,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(currentCompagnon.contact1),
                                                    Text(currentCompagnon.statut_paiement == 0 ? 'Non payé' :
                                                    currentCompagnon.statut_paiement == 1 ? 'En cours' : 'Payé',
                                                      style: TextStyle(
                                                          color: currentCompagnon.statut_paiement == 0 ? Colors.red :
                                                          currentCompagnon.statut_paiement == 1 ? Colors.blueGrey : Colors.green,
                                                          fontWeight: FontWeight.bold
                                                      ),)
                                                  ],
                                                ),
                                              );
                                            }
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
                                                  text: 'Mérier : ',
                                                  //style: TextStyle(fontWeight: FontWeight.bold),
                                                  children: <TextSpan>[
                                                    TextSpan(text: lesMetiers.where((m) => m.id == widget.compagnon.specialite).first.libelle,
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
                                                    TextSpan(text: lesPays.where((p) => p.id == widget.compagnon.nationalite).first.libelle,
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
                                                    TextSpan(text: lesCommunes.where((c) => c.id == widget.compagnon.commune_residence).first.libelle,
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
                          child: Text('Actions',
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
                        Visibility(
                          visible: false,
                            child: Container(
                            alignment: Alignment.topLeft,
                            margin: const EdgeInsets.only(right: 10, left: 10, top: 5),
                            padding: EdgeInsets.all(5),
                            //height: 30,
                            child: ElevatedButton.icon(
                                style: ButtonStyle(
                                    backgroundColor: WidgetStateColor.resolveWith((states) => Colors.deepOrangeAccent)
                                ),
                                label: Text("Modifier",
                                    style: const TextStyle(
                                        color: Colors.white
                                    )
                                ),
                                onPressed: () {

                                },
                                icon: Icon(
                                  Icons.person,
                                  size: 20,
                                  color: Colors.white,
                                )
                            )
                        )
                        ),
                        GetBuilder(
                            builder: (CompagnonControllerX controllerX) {
                              // Process :
                              var currentCompagnon = controllerX.data.where(
                                      (a) => a.id == widget.compagnon.id
                              ).first;
                              return Visibility(
                                  visible: currentCompagnon.statut_paiement == 0,
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
                              );
                            }
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