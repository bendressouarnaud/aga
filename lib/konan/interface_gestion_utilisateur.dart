import 'dart:async';
import 'dart:convert';

import 'package:cnmci/konan/beans/generic_data.dart';
import 'package:cnmci/konan/model/commune.dart';
import 'package:cnmci/konan/services.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as https;

import '../main.dart';
import 'model/crm.dart';
import 'objets/constants.dart';


class InterfaceGestionUtilisateur extends StatefulWidget {
  const InterfaceGestionUtilisateur({Key? key}) : super(key: key);

  @override
  State<InterfaceGestionUtilisateur> createState() => _InterfaceGestionUtilisateur();
}


class _InterfaceGestionUtilisateur extends State<InterfaceGestionUtilisateur> with WidgetsBindingObserver {

  // LINK :
  // https://api.flutter.dev/flutter/material/AlertDialog-class.html

  // A t t r i b u t e s  :
  TextEditingController crmController = TextEditingController();
  TextEditingController nomController = TextEditingController();
  TextEditingController prenomController = TextEditingController();
  TextEditingController contact1Controller = TextEditingController();
  TextEditingController emailController = TextEditingController();

  //
  bool initInterface = false;

  late bool _isLoading;
  // Initial value :
  //final _userRepository = UserRepository();
  late BuildContext dialogContext;
  bool flagSendData = false;
  bool flagServerResponse = false;
  bool closeAlertDialog = false;
  int retour = 0;
  //
  //final PublicationGetController _publicationController = Get.put(PublicationGetController());
  late https.Client client;
  //
  String? getToken = "";
  int id = 0;
  int idpub = 0;
  int keep_idpub = 0;
  String nationalite = "";
  late String ordernumber;
  String ipaddress = "";
  int milliseconds = 0;
  bool updatePubDate = false;
  bool updatePubHour = false;
  late BuildContext customContext;

  double spacingSteps = 40;
  int currentStep = 1;
  int choixDate = 0;

  late Crm leCrm;
  late Commune laCommune;
  late GenericData leStatut;
  late GenericData leTypeCompte;

  // GenericData
  final lesStatut = [
    GenericData(libelle: 'Inactif', id: 0),
    GenericData(libelle: 'Actif', id: 1)
  ];
  final lesTypesComptes = [
    GenericData(libelle: 'Agent Enrôlement', id: 1),
    GenericData(libelle: 'Agent Enrôlement Lead', id: 2),
    GenericData(libelle: 'Agent Enrôlement Superviseur', id: 3),
    GenericData(libelle: 'Agent de contrôle', id: 10)
  ];

  // Leave :
  void forceLeave(){
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    leCrm = lesCrms.first;
    laCommune = lesCommunes.first;
    leStatut = lesStatut.first;
    leTypeCompte = lesTypesComptes.first;
  }

  @override
  void dispose() {
    super.dispose();

    // Dispose
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

  void displayWainting(){
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

    manageUser();

    Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (!flagServerResponse) {
          Navigator.pop(dialogContext);
          timer.cancel();

          if (!flagSendData) {
            // CLOSE :
            Navigator.pop(context);
          }
        }
      },
    );
  }

  Future<void> manageUser() async {
    try{
      var localToken = await MesServices().checkJwtExpiration();
      final url = Uri.parse('${dotenv.env['URL_BACKEND']}manage-user');
      var response = await https.post(url,
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer $localToken'
          },
          body: jsonEncode({
            "id": 0,
            "nom": nomController.text.trim(),
            "prenom": prenomController.text.trim(),
            "contact": contact1Controller.text.trim(),
            "email": emailController.text.trim(),
            "actif": leStatut.id,
            "profil_id": leTypeCompte.id,
            "partenaire_id": 3,
            "crm": leCrm.id,
          })
      ).timeout(const Duration(seconds: timeOutValue));
      if(response.statusCode == 200){
        flagSendData = false;
      }
    }
    catch(e){
      displayToast('Traitement impossible *****');
    }
    finally{
      flagServerResponse = false;
    }
  }

  Widget lesBoutons(){
    return SafeArea(child: Container(
      margin: EdgeInsets.only(top: defaultTargetPlatform == TargetPlatform.iOS ? 50 : 30, left: 10, right: 10, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Visibility(
              visible: false,
              child: ElevatedButton.icon(
                style: ButtonStyle(
                    backgroundColor: MaterialStateColor.resolveWith((states) => Colors.blueGrey)
                ),
                label: const Text("Retour",
                    style: TextStyle(
                        color: Colors.white
                    )),
                onPressed: () {
                  if(currentStep > 1){
                    setState(() {
                      currentStep--;
                    });
                  }
                  else{
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 20,
                  color: Colors.white,
                ),
              )
          ),
          ElevatedButton.icon(
            style: ButtonStyle(
                iconAlignment: IconAlignment.end,
                backgroundColor: WidgetStateColor.resolveWith((states) => Colors.brown)
            ),
            label: Text("Enregistrer",
                style: TextStyle(
                    color: Colors.white
                )
            ),
            onPressed: () async {
              //
              displayWainting();
            },
            icon: Icon(Icons.send,
              size: 20,
              color: Colors.white,
            ),
          )
        ],
      ),
    ));
  }

  List<Widget> renseignementPersonne(){
    return [
      Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(left: 10, right: 10, top: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: (MediaQuery.of(context).size.width / 2) - 20,
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      nomController.text = value;
                    });
                  },
                  keyboardType: TextInputType.name,
                  controller: nomController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: nomController.text.trim().isEmpty ?
                      Colors.red : Colors.black, width: 1.0),
                    ),
                    border: OutlineInputBorder(),
                    labelText: 'Nom',
                  ),
                  style: const TextStyle(
                      height: 1.5
                  ),
                  textAlignVertical: TextAlignVertical.bottom,
                  textAlign: TextAlign.center,
                  textInputAction: TextInputAction.next,
                ),
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width / 2) - 20,
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      prenomController.text = value;
                    });
                  },
                  keyboardType: TextInputType.name,
                  controller: prenomController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: prenomController.text.trim().isEmpty ?
                      Colors.red : Colors.black, width: 1.0),
                    ),
                    border: OutlineInputBorder(),
                    labelText: 'Prénom',
                  ),
                  style: const TextStyle(
                    height: 1.5,
                  ),
                  textAlignVertical: TextAlignVertical.bottom,
                  textAlign: TextAlign.center,
                  textInputAction: TextInputAction.next,
                ),
              )
            ],
          )
      ),
      Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.only(left: 10, right: 10, top: 15),
          child: DropdownMenu<GenericData>(
              width: MediaQuery.of(context).size.width,
              menuHeight: 250,
              initialSelection: leStatut,
              //controller: civiliteController,
              hintText: "Statut",
              requestFocusOnTap: false,
              enableSearch: false,
              enableFilter: false,
              label: const Text('Statut'),
              // Initial Value
              onSelected: (GenericData? value) {
                leStatut = value!;
              },
              dropdownMenuEntries:
              lesStatut.map<DropdownMenuEntry<GenericData>>((GenericData menu) {
                return DropdownMenuEntry<GenericData>(
                    value: menu,
                    label: menu.libelle,
                    leadingIcon: Icon(Icons.signal_wifi_statusbar_4_bar_sharp));
              }).toList()
          )
      ),
      Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.only(left: 10, right: 10, top: 15),
          child: DropdownMenu<Crm>(
              width: MediaQuery.of(context).size.width,
              menuHeight: 250,
              initialSelection: leCrm,
              //controller: civiliteController,
              hintText: "CRM",
              requestFocusOnTap: false,
              enableSearch: false,
              enableFilter: false,
              label: const Text('CRM'),
              // Initial Value
              onSelected: (Crm? value) {
                leCrm = value!;
              },
              dropdownMenuEntries:
              lesCrms.map<DropdownMenuEntry<Crm>>((Crm menu) {
                return DropdownMenuEntry<Crm>(
                    value: menu,
                    label: menu.libelle,
                    leadingIcon: Icon(Icons.location_city));
              }).toList()
          )
      ),
      Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.only(left: 10, right: 10, top: 15),
          child: DropdownMenu<GenericData>(
              width: MediaQuery.of(context).size.width,
              menuHeight: 250,
              initialSelection: leTypeCompte,
              //controller: civiliteController,
              hintText: "Type Compte",
              requestFocusOnTap: false,
              enableSearch: false,
              enableFilter: false,
              label: const Text('Type Compte'),
              // Initial Value
              onSelected: (GenericData? value) {
                leTypeCompte = value!;
              },
              dropdownMenuEntries:
              lesTypesComptes.map<DropdownMenuEntry<GenericData>>((GenericData menu) {
                return DropdownMenuEntry<GenericData>(
                    value: menu,
                    label: menu.libelle,
                    leadingIcon: Icon(Icons.type_specimen));
              }).toList()
          )
      ),
      Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: (MediaQuery.of(context).size.width / 2) - 20,
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      contact1Controller.text = value;
                    });
                  },
                  keyboardType: TextInputType.phone,
                  controller: contact1Controller,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: contact1Controller.text.trim().isEmpty ?
                      Colors.red : Colors.black, width: 1.0),
                    ),
                    border: OutlineInputBorder(),
                    labelText: 'Contact 1',
                  ),
                  style: const TextStyle(
                      height: 1.5
                  ),
                  textAlignVertical: TextAlignVertical.bottom,
                  textAlign: TextAlign.center,
                  textInputAction: TextInputAction.next,
                ),
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width / 2) - 20,
                child: TextField(
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                  ),
                  style: const TextStyle(
                      height: 1.5
                  ),
                  textAlignVertical: TextAlignVertical.bottom,
                  textAlign: TextAlign.center,
                  textInputAction: TextInputAction.next,
                ),
              )
            ],
          )
      ),
      lesBoutons()
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(idpub == 0 ? 'Nouvel utilisateur' : 'Modification utilisateur'),
        ),
        body: SingleChildScrollView(
          child: Column(
              children: renseignementPersonne()
          ),
        )
    );
  }
}