import 'dart:async';
import 'dart:convert';

import 'package:cnmci/getxcontroller/entreprise_controller_x.dart';
import 'package:cnmci/konan/dao/entreprise_dao.dart';
import 'package:cnmci/konan/historique/historique_compagnon.dart';
import 'package:cnmci/konan/model/artisan.dart';
import 'package:cnmci/konan/services.dart';
import 'package:cnmci/konan/webviews/webview_payment_wave.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:http/http.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../getxcontroller/apprenti_controller_x.dart';
import '../getxcontroller/compagnon_controller_x.dart';
import '../main.dart';
import 'beans/enrolement_amount_to_pay.dart';
import 'beans/wave_payment_response.dart';
import 'historique/historique_apprenti.dart';
import 'model/entreprise.dart';
import 'objets/constants.dart';

class InterfaceViewEntreprise extends StatefulWidget{
  final Entreprise entreprise;
  const InterfaceViewEntreprise({Key? key, required this.entreprise}) : super(key: key);

  @override
  State<InterfaceViewEntreprise> createState() => _InterfaceViewEntreprise();
}

class _InterfaceViewEntreprise extends State<InterfaceViewEntreprise>{

  // A T T R I B U T E S :
  late BuildContext dialogContext;
  bool flagSendData = false;
  bool flagServerResponse = false;
  String paymentUrl = "";
  int montantEntreprise = 0;


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
    var total = await outil.findAllApprentiByEntreprise(widget.entreprise.id);
    return total;
  }

  // Total COMPAGNONs
  Future<int> getTotalCompagnon() async{
    var total = await outil.findAllCompagnonByEntreprise(widget.entreprise.id);
    return total;
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
            "id": widget.entreprise.id,
            "requester": "ENT",
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
            "id": widget.entreprise.id,
            "requester": "ENT",
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
    if(montantEntreprise > 0) {
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
    else{
      displayToast('Frais de l\'Entreprise payés. Veuillez utilisez l\'interface de son collaborateur pour effectuer le paiement');
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
          title: Text(widget.entreprise.denomination),
        ),
        body: FutureBuilder(
            future: Future.wait([getAmountToPay(), getTotalApprenti(), getTotalCompagnon()]),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot){
              if(snapshot.connectionState == ConnectionState.done && snapshot.hasData){
                // Price to PAY :
                EnrolementAmountToPay sommeApayer = snapshot.data[0];
                montantEntreprise = sommeApayer.seul; // Refresh
                // Total APPRENTi :
                var totalApprenti = snapshot.data[1];
                // Total COMPAGNON :
                var totalCompagnon = snapshot.data[2];

                return SingleChildScrollView(
                  child: Column(
                      children: [
                        Card(
                          margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
                          child: Column(
                            children: [
                              Container(
                                  margin: EdgeInsets.only(right: 10, left: 10),
                                  alignment: Alignment.topLeft,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(MesServices().processEntityName(widget.entreprise.denomination, limitCharacter),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold
                                        ),
                                      ),
                                      Text(widget.entreprise.date_creation)
                                    ],
                                  )
                              ),
                              GetBuilder(
                                  builder: (EntrepriseControllerX controllerX) {
                                    // Process :
                                    var currentEntreprise = controllerX.data.where(
                                            (a) => a.id == widget.entreprise.id
                                    ).first;

                                    if(currentEntreprise.statut_paiement == 2){
                                      // Refresh :
                                      montantEntreprise = 0;
                                    }

                                    return Container(
                                      margin: EdgeInsets.only(right: 10, left: 10, top: 5),
                                      alignment: Alignment.topLeft,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(currentEntreprise.contact1),
                                          Text(currentEntreprise.statut_paiement == 0 ? 'Non payé' :
                                          currentEntreprise.statut_paiement == 1 ? 'En cours' : 'Payé',
                                            style: TextStyle(
                                                color: currentEntreprise.statut_paiement == 0 ? Colors.red :
                                                currentEntreprise.statut_paiement == 1 ? Colors.blueGrey : Colors.green,
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
                                          TextSpan(text: lesMetiers.where((m) => m.id == widget.entreprise.activite_principale).first.libelle,
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
                                          TextSpan(text: lesPays.where((p) => p.id == widget.entreprise.nationalite).first.libelle,
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
                                          TextSpan(text: lesCommunes.where((c) => c.id == widget.entreprise.commune_residence).first.libelle,
                                              style: TextStyle(fontWeight: FontWeight.bold)
                                          )
                                        ]
                                    ),
                                  )
                              )
                            ],
                          ),
                        ),

                        Container(
                          alignment: Alignment.topLeft,
                          margin: EdgeInsets.only(right: 10, left: 10, top: 25),
                          child: Text('Paiement',
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

                        Container(
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
                                SizedBox(
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
                              ],
                            )
                        ),

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
                                      return  HistoriqueApprenti(entreprise: widget.entreprise);
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
                                                              (a) => a.entreprise_id == widget.entreprise.id
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
                                      return  HistoriqueCompagnon(entreprise: widget.entreprise);
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
                                                              (a) => a.entreprise_id == widget.entreprise.id
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