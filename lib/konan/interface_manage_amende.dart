import 'dart:async';
import 'dart:convert';

import 'package:cnmci/konan/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';

import 'beans/stats_bean_manager.dart';
import 'objets/amountseparator.dart';
import 'objets/constants.dart';

class InterfaceManageAmende extends StatefulWidget {
  final StatsBeanManager data;
  const InterfaceManageAmende({super.key, required this.data});

  @override
  State<InterfaceManageAmende> createState() => _InterfaceManageAmende();
}

class _InterfaceManageAmende extends State<InterfaceManageAmende> {

  // ATTRIBUTES :
  TextEditingController montantController = TextEditingController();
  TextEditingController commentaireController = TextEditingController();
  late BuildContext dialogContext;
  bool flagSendData = false;
  bool flagServerResponse = false;
  bool closeAlertDialog = false;



  // METHODS :
  @override
  void initState() {
    super.initState();
    montantController.text = "0";
    commentaireController.text = "";
  }

  String getAppropriatePrefixe(String libelle){
    switch(libelle){
      case 'Artisans':
        return "ART";

      case 'Apprentis':
        return "APP";

      case 'Compagnons':
        return "COM";

      default:
        return "ENT";
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

  Future<void> sendAmendeRequest() async {
    // First Call this :
    var localToken = await MesServices().checkJwtExpiration();
    final url = Uri.parse('${dotenv.env['URL_BACKEND_STAT']}manage-amende');
    try {
      var response = await post(url,
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer $localToken'
          },
          body: jsonEncode({
            "id" : 0,
            "montant" : int.parse(montantController.text.replaceAll(',', '')),
            "commentaire" : commentaireController.text,
            "entity_id" : widget.data.id,
            "entity_type" : getAppropriatePrefixe(widget.data.type)
          })
      ).timeout(const Duration(seconds: timeOutValue));

      if (response.statusCode == 200) {
        flagSendData = false;
      } else {
        displayToast("Une erreur est survenue lors du traitement");
      }
    } catch (e) {
      displayToast("Une erreur est survenue lors de la transmission des donnée : $e");
    } finally {
      flagServerResponse = false;
    }
  }

  void displayDataSending(){
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

    sendAmendeRequest();

    Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (!flagServerResponse) {
          Navigator.pop(dialogContext);
          timer.cancel();

          if (!flagSendData) {
            Navigator.pop(context, 1);
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text('Gestion amende'
          )
      ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 20, left: 10, right: 10),
                alignment: Alignment.center,
                //width: MediaQuery.of(context).size.width * 0.40,
                child: TextField(
                  keyboardType: TextInputType.numberWithOptions(decimal: false),
                  controller: montantController,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandsSeparatorInputFormatter(),
                  ],
                  onChanged: (value){

                  },
                  decoration: InputDecoration(
                      labelText: 'Montant',
                      hintText: "Saisissez ...",
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.black
                          )
                      )
                  ),
                  textAlign: TextAlign.center,
                  textInputAction: TextInputAction.next,
                )
              ),
              Container(
                margin: const EdgeInsets.only(top: 20, left: 10, right: 10),
                alignment: Alignment.center,
                //width: MediaQuery.of(context).size.width * 0.40,
                child: TextField(
                  minLines: 7,
                  maxLines: 15,
                  keyboardType: TextInputType.text,
                  controller: commentaireController,
                  onChanged: (value){

                  },
                  decoration: InputDecoration(
                      labelText: 'Commentaire',
                      hintText: "Saisissez un commentaire",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: Colors.black
                          )
                      )
                  ),
                  textInputAction: TextInputAction.done,
                )
              ),
              Container(
                  margin: const EdgeInsets.only(top: 20, left: 10, right: 10),
                  alignment: Alignment.topRight,
                  child: ElevatedButton.icon(
                    style: ButtonStyle(
                        iconAlignment: IconAlignment.end,
                        backgroundColor: WidgetStateColor.resolveWith((states) => Colors.brown)
                    ),
                    label: Text("Enregistrez",
                        style: TextStyle(
                            color: Colors.white
                        )
                    ),
                    onPressed: () async {
                      try{
                        int montantAPayer = int.parse(montantController.text.replaceAll(',', ''));
                        displayDataSending();
                      }
                      catch(e){
                        displayToast("Le montant saisi est incorrect !");
                      }
                    },
                    icon: Icon(
                      Icons.send,
                      size: 20,
                      color: Colors.white,
                    ),
                  )
              )
            ],
          ),
        )
    );
  }

}
