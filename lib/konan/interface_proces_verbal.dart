import 'dart:async';
import 'dart:convert';

import 'package:cnmci/konan/beans/generic_data.dart';
import 'package:cnmci/konan/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';

import 'beans/message_response.dart';
import 'factorise_widgets/custom_drop_down.dart';
import 'factorise_widgets/custom_drop_down_two_attributes.dart';
import 'factorise_widgets/custom_optin_checkbox.dart';
import 'factorise_widgets/custom_text_field.dart';
import 'objets/constants.dart';

class InterfaceProcesVerbal extends StatefulWidget {
  final String requesterType;
  final int requesterId;
  const InterfaceProcesVerbal({super.key, required this.requesterType, required this.requesterId});

  @override
  State<InterfaceProcesVerbal> createState() => _InterfaceProcesVerbal();
}

class _InterfaceProcesVerbal extends State<InterfaceProcesVerbal> {

  // A T T R I B U T E S :
  TextEditingController numeroPvController = TextEditingController();
  TextEditingController codeRecuController = TextEditingController();
  late GenericData delaiDeReglement;
  final lesGenericDataDelai = [
    GenericData(libelle: '7 jours', id: 0),
    GenericData(libelle: '15 jours', id: 1),
    GenericData(libelle: '22 jours', id: 2),
    GenericData(libelle: '30 jours', id: 3)
  ];
  bool defautImmatriculation = true;
  bool defautImmatriculationApprenti = false;
  bool defautImmatriculationCompagnon = false;
  bool codeTransmis = false;
  late BuildContext dialogContext;
  bool flagSendData = false;
  bool flagServerResponse = false;
  bool closeAlertDialog = false;
  String codeActivation = '';


  // M E T H O D S :
  @override
  void initState() {
    super.initState();

    delaiDeReglement = lesGenericDataDelai.first;
    //defautImmatriculation = widget.requesterType == 'ART' || widget.requesterType == 'ENT';
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

  void displayRequestingForProcesVerbalHandLing(){
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

    requestingForProcesVerbal();

    Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (!flagServerResponse) {
          Navigator.pop(dialogContext);
          timer.cancel();

          if (!flagSendData) {
            if(codeActivation.isEmpty){
              // Display FIELD to KEY the CODE received by CUSTOMER :
              setState(() {
                codeTransmis = true;
              });
            }
            else{
              // Close :
              Navigator.pop(context);
            }
          }
        }
      },
    );
  }

  Future<void> requestingForProcesVerbal() async
  {
    // First Call this :
    var localToken = await MesServices().checkJwtExpiration();
    final url = Uri.parse('${dotenv.env['URL_BACKEND']}manage-proces-verbal');
    try {
      var response = await post(url,
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer $localToken'
          },
          body: jsonEncode({
            "delai_reglement" : delaiDeReglement.id,
            "numero_pv" : numeroPvController.text,
            "defaut_immatriculation" : defautImmatriculation ? 1 : 0,
            "defaut_immatriculation_apprenti" : defautImmatriculationApprenti ? 1 : 0,
            "defaut_immatriculation_compagnon" : defautImmatriculationCompagnon ? 1 : 0,
            "code_activation" : codeActivation,
            "requester_id" : widget.requesterId,
            "requester_type" : widget.requesterType
          })
      ).timeout(const Duration(seconds: timeOutValue));

      if (response.statusCode == 200) {
        MessageResponse reponse = MessageResponse.fromJson(
            json.decode(response.body));
        if(reponse.http_status == 200){
          flagSendData = false;
        }
      } else {
        displayToast("Impossible de traiter la demande de PV");
      }
    } catch (e) {
      displayToast("Impossible de traiter les données : $e");
    } finally {
      flagServerResponse = false;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Procès verbal'),
      ),
      body: SingleChildScrollView(
          child: Column(
              children: [
                Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(top: 20, left: 10, right: 10),
                  width: MediaQuery.of(context).size.width,
                  child: CustomDropDown(
                    customWidth: MediaQuery.of(context).size.width,
                    customMenuHeight: 250,
                    defaultValue: delaiDeReglement,
                    hintText: 'Délai de règlement',
                    requestFocusOnTap: false,
                    enableSearch: false,
                    enableFilter: false,
                    label: 'Délai de règlement',
                    onSelected: (GenericData? value) {
                      setState(() {
                        delaiDeReglement = value!;
                      });
                    },
                    lesDonnees: lesGenericDataDelai,
                  )
                ),
                Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(top: 20, left: 10, right: 10),
                  width: MediaQuery.of(context).size.width,
                  child: CustomTextField(
                      textInputType: TextInputType.text,
                      textEditingController: numeroPvController,
                      labelText: 'Numéro de PV',
                      height: 1.5,
                      textAlignVertical: TextAlignVertical.bottom,
                      textAlign: TextAlign.center,
                      textInputAction: TextInputAction.next
                  ),
                ),

                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(top: 20, left: 10, right: 10),
                  child: Divider(
                    color: Colors.black,
                    height: 5,
                  ),
                ),

                Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(top: 15, left: 10, right: 10),
                  width: MediaQuery.of(context).size.width,
                  child: CustomOptinCheckBox(libelle: 'Défaut d\'immatriculation', valeur: defautImmatriculation, icone: Icons.login, couleur: Colors.red,
                    onChanged: (bool? value) {
                      setState(() {
                        defautImmatriculation = !defautImmatriculation;
                      });
                    }
                  )
                ),

                Visibility(
                    visible: widget.requesterType == 'ART' || widget.requesterType == 'ENT',
                    child: Container(
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.only(top: 15, left: 10, right: 10),
                        width: MediaQuery.of(context).size.width,
                        child: CustomOptinCheckBox(
                            libelle: 'Défaut d\'immatriculation des apprentis', valeur: defautImmatriculationApprenti,
                            icone: Icons.app_registration, couleur: Colors.orange,
                            onChanged: (bool? value) {
                              setState(() {
                                defautImmatriculationApprenti = !defautImmatriculationApprenti;
                              });
                            }
                        )
                    )
                ),

                Visibility(
                    visible: widget.requesterType == 'ART' || widget.requesterType == 'ENT',
                    child: Container(
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.only(top: 15, left: 10, right: 10),
                        width: MediaQuery.of(context).size.width,
                        child: CustomOptinCheckBox(
                            libelle: 'Défaut d\'immatriculation des compagnons', valeur: defautImmatriculationCompagnon,
                            icone: Icons.app_registration, couleur: Colors.brown,
                            onChanged: (bool? value) {
                              setState(() {
                                defautImmatriculationCompagnon = !defautImmatriculationCompagnon;
                              });
                            }
                        )
                    )
                ),

                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(top: 20, left: 10, right: 10),
                  child: Divider(
                    color: Colors.black,
                    height: 5,
                  ),
                ),

                Visibility(
                  visible: codeTransmis,
                    child: Container(
                      alignment: Alignment.topLeft,
                      margin: EdgeInsets.only(top: 20, left: 10, right: 10),
                      width: MediaQuery.of(context).size.width,
                      child: CustomTextField(
                          textInputType: TextInputType.phone,
                          textEditingController: codeRecuController,
                          labelText: 'Code reçu (SMS/Email)',
                          height: 1.5,
                          textAlignVertical: TextAlignVertical.bottom,
                          textAlign: TextAlign.center,
                          textInputAction: TextInputAction.next
                      ),
                    )
                ),

                Container(
                  margin: EdgeInsets.only(top: 20, left: 10, right: 10),
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Visibility(
                          visible: !codeTransmis,
                          child: ElevatedButton.icon(
                            style: ButtonStyle(
                                backgroundColor: WidgetStateColor.resolveWith((states) => Colors.blue)
                            ),
                            label: Text('Envoi SMS',
                                style: TextStyle(
                                    color: Colors.white
                                )
                            ),
                            onPressed: () async {
                              if(numeroPvController.text.trim().isNotEmpty) {
                                codeActivation = '';
                                displayRequestingForProcesVerbalHandLing();
                              }
                              else{
                                displayToast('Veuillez entrer le numéro de PV !');
                              }
                            },
                            icon: const Icon(
                              Icons.send,
                              size: 20,
                              color: Colors.white,
                            ),
                          )),
                      Visibility(
                          visible: codeTransmis,
                          child: ElevatedButton.icon(
                            style: ButtonStyle(
                                backgroundColor: WidgetStateColor.resolveWith((states) => Colors.green)
                            ),
                            label: Text('Validez',
                                style: TextStyle(
                                    color: Colors.white
                                )
                            ),
                            onPressed: () async {
                              if(codeRecuController.text.trim().isNotEmpty) {
                                codeActivation = codeRecuController.text;
                                displayRequestingForProcesVerbalHandLing();
                              }
                              else{
                                displayToast('Veuillez entrer le code d\'activation !');
                              }
                            },
                            icon: const Icon(
                              Icons.check_circle_outline,
                              size: 20,
                              color: Colors.white,
                            ),
                          ))
                    ],
                  )
                )

              ],
          )
      )
    );

  }

}