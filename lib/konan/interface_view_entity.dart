import 'dart:async';
import 'dart:convert';

import 'package:cnmci/konan/model/artisan.dart';
import 'package:cnmci/konan/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:maps_launcher/maps_launcher.dart';

import '../main.dart';
import 'beans/enrolement_amount_to_pay.dart';
import 'beans/stats_bean_manager.dart';
import 'beans/wave_payment_response.dart';
import 'interface_artisan_personne.dart';
import 'interface_manage_amende.dart';
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

  void displayDataRequesting(){
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
    getAmountToPay();

    Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (!flagServerResponse) {
          Navigator.pop(dialogContext);
          timer.cancel();

          if (!flagSendData) {
            // Display QRCODE :
            MesServices().displayDialog(context, paymentUrl);
          }
        }
      },
    );
  }

  Future<void> getAmountToPay() async {
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
  }

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
          })
      ).timeout(const Duration(seconds: timeOutValue));
      if(response.statusCode == 200){
        WavePaymentResponse reponse = WavePaymentResponse.fromJson(
            json.decode(response.body));
        paymentUrl = reponse.wave_launch_url;
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text('Visualisation'),
          actions: [
            Visibility(
              visible: statsBeanManager.type == 'Artisans',
              child: IconButton(
                  onPressed: () {
                    displayEntityRequesting(statsBeanManager.id);
                  },
                  icon: Icon(Icons.edit, color: Colors.brown)
              ),
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
                        label: Text("Régularisation",
                            style: TextStyle(
                                color: Colors.white
                            )),
                        onPressed: () async {
                          displayDataRequesting();
                        },
                        icon: const Icon(
                          Icons.money,
                          size: 20,
                          color: Colors.white,
                        ),
                      )
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
                  margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  alignment: Alignment.topLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Visibility(
                        visible: statsBeanManager.paiement != 2,
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
              )
            ],
          ),
        )
    );
  }

}
