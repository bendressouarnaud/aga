import 'dart:async';
import 'dart:convert';

import 'package:cnmci/konan/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';

import '../main.dart';
import 'beans/historique_transaction.dart';
import 'beans/payment_livraison_status.dart';
import 'beans/regularisation_response.dart';
import 'objets/constants.dart';

class InterfaceResumeTransaction extends StatefulWidget {
  final HistoriqueTransaction historiqueTransaction;
  const InterfaceResumeTransaction({super.key, required this.historiqueTransaction});

  @override
  State<InterfaceResumeTransaction> createState() => _InterfaceResumeTransaction();
}

class _InterfaceResumeTransaction extends State<InterfaceResumeTransaction> {

  // A T T R I B U T E S :
  late BuildContext dialogContext;
  bool flagSendData = false;
  bool flagServerResponse = false;


  // M E T H O D S :
  void updateEntiteStatus(int statut){
    if(widget.historiqueTransaction.requesterType == 'ART'){
      var data = artisanControllerX.data.where((a) => a.id == widget.historiqueTransaction.requesterId).first;
      data.statut_paiement = statut;
      artisanControllerX.updateData(data);
    }
    else if(widget.historiqueTransaction.requesterType == 'APP'){
      var data = apprentiControllerX.data.where((a) => a.id == widget.historiqueTransaction.requesterId).first;
      data.statut_paiement = statut;
      apprentiControllerX.updateData(data);
    }
    else if(widget.historiqueTransaction.requesterType == 'COM'){
      var data = compagnonControllerX.data.where((a) => a.id == widget.historiqueTransaction.requesterId).first;
      data.statut_paiement = statut;
      compagnonControllerX.updateData(data);
    }
    else{
      var data =  entrepriseControllerX.data.where((a) => a.id == widget.historiqueTransaction.requesterId).first;
      data.statut_paiement = statut;
      entrepriseControllerX.updateData(data);
    }
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

  void displayWaintingForRegularisation(){
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

    makeRegularisationRequest();

    Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (!flagServerResponse) {
          Navigator.pop(dialogContext);
          timer.cancel();

          if (!flagSendData) {
            displayToast("La régularisation a été faite !");
            // Close :
            Navigator.pop(context);
          }
        }
      },
    );
  }

  // Pick PAYMENT STATUS :
  Future<void> makeRegularisationRequest() async {
    try{
      var localToken = await MesServices().checkJwtExpiration();
      var pathRequest = '${pickDate(widget.historiqueTransaction.millisecondes)}/should-not-exist/${widget.historiqueTransaction.transactionId}';
      final url = Uri.parse('${dotenv.env['URL_BACKEND']}get-regularisation-checkout/$pathRequest');
      var response = await get(url,
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer $localToken'
          }
      ).timeout(const Duration(seconds: timeOutValue));
      if(response.statusCode == 200){
        RegularisationResponse regularisationResponse = RegularisationResponse.fromJson(
            json.decode(response.body));
        if(regularisationResponse.statut > 0){
          flagSendData = false;
          // From there, update the status :
          updateEntiteStatus(regularisationResponse.statut);
        }else {
          displayToast(regularisationResponse.message);
        }
      }
      else {
        displayToast("Impossible de procéder à la régularisation !");
      }
    }
    catch(e){}
    finally{
      flagServerResponse = false;
    }
  }

  // Pick PAYMENT STATUS :
  Future<PaymentLivraisonStatus> checkIfTransactionSucceded() async {
    try{
      var localToken = await MesServices().checkJwtExpiration();
      final url = Uri.parse('${dotenv.env['URL_BACKEND']}get-transaction-status/${widget.historiqueTransaction.transactionId}');
      var response = await get(url,
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer $localToken'
          }
      ).timeout(const Duration(seconds: timeOutValue));
      if(response.statusCode == 200){
        PaymentLivraisonStatus paymentLivraisonStatus = PaymentLivraisonStatus.fromJson(json.decode(response.body));
        return paymentLivraisonStatus;
      }
      else{
        return PaymentLivraisonStatus(confirmationLivraison: 0, statutLivraison: 0, statutPaiement: -1);
      }
    }
    catch(e){
      return PaymentLivraisonStatus(confirmationLivraison: 0, statutLivraison: 0, statutPaiement: -1);
    }
  }

  String pickDate(int millisecondes){
    var tmp = DateTime.fromMillisecondsSinceEpoch(millisecondes);
    return '${tmp.year}-${addZero(tmp.month)}-${addZero(tmp.day)}';
  }

  String addZero(int valeur){
    return valeur > 9 ? '$valeur' : '0$valeur';
  }

  String pickHour(int millisecondes){
    var tmp = DateTime.fromMillisecondsSinceEpoch(millisecondes);
    return '${addZero(tmp.hour)}:${addZero(tmp.minute)}:${addZero(tmp.second)}';
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Résumé transaction'),
      ),
      body: FutureBuilder(
          future: Future.wait([checkIfTransactionSucceded()]),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot){
            if(snapshot.connectionState == ConnectionState.done && snapshot.hasData){

              PaymentLivraisonStatus paymentLivraisonStatus = snapshot.data[0];

              return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    //mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only(left: 15.0, right: 10.0, top: 10.0),
                        child: Text('Identité',
                          style: TextStyle(
                              fontFamily: 'Times New Roman',
                              fontSize: 17,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),

                      Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0, bottom: 10.0),
                          child: Card(
                              color: Colors.blue[50],
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text.rich(
                                        TextSpan(
                                            text: 'Entité : ',
                                            //style: TextStyle(fontWeight: FontWeight.bold),
                                            children: <TextSpan>[
                                              TextSpan(text: widget.historiqueTransaction.entite,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16
                                                ),
                                              )
                                            ]
                                        )
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Text.rich(
                                        TextSpan(
                                            text: 'Contact : ',
                                            //style: TextStyle(fontWeight: FontWeight.bold),
                                            children: <TextSpan>[
                                              TextSpan(text: widget.historiqueTransaction.contact,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16
                                                ),
                                              )
                                            ]
                                        )
                                    )
                                  ],
                                ),
                              )
                          )
                      ),

                      Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(left: 15.0, right: 10.0, top: 10.0),
                          child: Divider(
                            color: Colors.grey,
                            thickness: 1.0,
                          )
                      ),

                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only(left: 15.0, right: 10.0, top: 10.0),
                        child: Text('Détail transaction',
                          style: TextStyle(
                              fontFamily: 'Times New Roman',
                              fontSize: 17,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0, bottom: 10.0),
                          child: Card(
                              color: Colors.blue[50],
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text.rich(
                                        TextSpan(
                                            text: 'Montant : ',
                                            //style: TextStyle(fontWeight: FontWeight.bold),
                                            children: <TextSpan>[
                                              TextSpan(text: '${widget.historiqueTransaction.montant} FCFA',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16
                                                ),
                                              )
                                            ]
                                        )
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Text.rich(
                                        TextSpan(
                                            text: 'Date : ',
                                            //style: TextStyle(fontWeight: FontWeight.bold),
                                            children: <TextSpan>[
                                              TextSpan(text: pickDate(widget.historiqueTransaction.millisecondes),
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16
                                                ),
                                              )
                                            ]
                                        )
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Text.rich(
                                        TextSpan(
                                            text: 'Heure : ',
                                            //style: TextStyle(fontWeight: FontWeight.bold),
                                            children: <TextSpan>[
                                              TextSpan(text: pickHour(widget.historiqueTransaction.millisecondes),
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16
                                                ),
                                              )
                                            ]
                                        )
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Text.rich(
                                        TextSpan(
                                            text: 'Id. Transaction : ',
                                            //style: TextStyle(fontWeight: FontWeight.bold),
                                            children: <TextSpan>[
                                              TextSpan(text: widget.historiqueTransaction.transactionId,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16
                                                ),
                                              )
                                            ]
                                        )
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Row(
                                      children: [
                                        Text('Statut : '),
                                        Icon(paymentLivraisonStatus.statutPaiement > 0 ?
                                        Icons.check_circle_outline : Icons.cancel,
                                          color: paymentLivraisonStatus.statutPaiement > 0 ?
                                          Colors.green : Colors.red,)
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    Visibility(
                                        visible: paymentLivraisonStatus.statutPaiement == 0,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            ElevatedButton.icon(
                                              style: ButtonStyle(
                                                  iconAlignment: IconAlignment.end,
                                                  backgroundColor: WidgetStateColor.resolveWith((states) => Colors.brown)
                                              ),
                                              label: Text("Lancer la régularisation",
                                                  style: TextStyle(
                                                      color: Colors.white
                                                  )
                                              ),
                                              onPressed: () async {
                                                displayWaintingForRegularisation();
                                              },
                                              icon: Icon(
                                                Icons.send,
                                                size: 20,
                                                color: Colors.white,
                                              ),
                                            )
                                          ],
                                        )
                                    )
                                  ],
                                ),
                              )
                          )
                      ),
                    ],
                  )

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