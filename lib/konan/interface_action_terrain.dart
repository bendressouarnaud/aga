import 'dart:async';
import 'dart:convert';

import 'package:cnmci/konan/model/action_terrain.dart';
import 'package:cnmci/konan/model/commune.dart';
import 'package:cnmci/konan/model/quartier.dart';
import 'package:cnmci/konan/services.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';

import '../main.dart';
import 'beans/message_response.dart';
import 'objets/constants.dart';


class InterfaceActionTerrain extends StatefulWidget {
  final ActionTerrain? lActionTerrain;
  const InterfaceActionTerrain({Key? key, this.lActionTerrain}) : super(key: key);

  @override
  State<InterfaceActionTerrain> createState() => _InterfaceActionTerrain();
}


class _InterfaceActionTerrain extends State<InterfaceActionTerrain> with WidgetsBindingObserver {

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
  String? getToken = "";
  int id = 0;
  int idact = 0;
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

  late List<Quartier> lesQuartiersIndex;
  late Commune laCommune;
  late Quartier leQuartier;
  late String leChoix;

  final lesChoix = [
    'Oui',
    'Non'
  ];

  // Leave :
  void forceLeave(){
    Navigator.pop(context);
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

  @override
  void initState() {
    super.initState();
    if(widget.lActionTerrain == null) {
      laCommune = lesCommunes
          .where((c) => c.id == 498)
          .first; // YOPOUGON's id
      lesQuartiersIndex = lesQuartiers.where((q) => q.idx == 498).toList();
      // Pick 'QUARTIERS' from
      leQuartier = lesQuartiersIndex[6];
      leChoix = lesChoix.first;
    }
    else{
      laCommune = lesCommunes
          .where((c) => c.id == widget.lActionTerrain!.communeId)
          .first; // YOPOUGON's id
      lesQuartiersIndex = lesQuartiers.where((q) => q.idx == widget.lActionTerrain!.communeId).toList();
      // Pick 'QUARTIERS' from
      leQuartier = lesQuartiersIndex.where((q) => q.id == widget.lActionTerrain!.quartierId).first;
      leChoix = widget.lActionTerrain!.actif == 1 ? lesChoix.first : lesChoix.last;
    }
  }

  @override
  void dispose() {
    super.dispose();

    // Dispose
  }

  void refreshVilleActivite(Commune commune) {// Refresh
    laCommune = commune;
    setState(() {
      lesQuartiersIndex = lesQuartiers.where((q) => q.idx == commune.id).toList();
      if(lesQuartiersIndex.isNotEmpty) {
        leQuartier = lesQuartiersIndex.first;
      }
    });
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
              displayDataSending();
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
          margin: EdgeInsets.only(left: 10, right: 10, top: 15),
          child: DropdownMenu<Commune>(
              width: MediaQuery.of(context).size.width,
              menuHeight: 250,
              initialSelection: laCommune,
              hintText: "Commune",
              requestFocusOnTap: true,
              enableSearch: true,
              enableFilter: true,
              label: const Text('Commune'),
              // Initial Value
              onSelected: (Commune? value) {
                refreshVilleActivite(value!);
              },
              dropdownMenuEntries: lesCommunes.map<DropdownMenuEntry<Commune>>((Commune menu) {
                return DropdownMenuEntry<Commune>(
                    value: menu,
                    label: menu.libelle,
                    leadingIcon: Icon(Icons.location_city));
              }).toList()
          )
      ),
      Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.only(left: 10, right: 10, top: 15),
          child: DropdownMenu<Quartier>(
              width: MediaQuery.of(context).size.width,
              menuHeight: 250,
              initialSelection: leQuartier,
              //controller: civiliteController,
              hintText: "Quartier",
              requestFocusOnTap: true,
              enableSearch: true,
              enableFilter: true,
              label: const Text('Quartier'),
              // Initial Value
              onSelected: (Quartier? value) {
                leQuartier = value!;
              },
              dropdownMenuEntries:
              lesQuartiersIndex.map<DropdownMenuEntry<Quartier>>((Quartier menu) {
                return DropdownMenuEntry<Quartier>(
                    value: menu,
                    label: menu.libelle,
                    leadingIcon: Icon(Icons.location_city));
              }).toList()
          )
      ),
      Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.only(left: 10, right: 10, top: 15),
          child: DropdownMenu<String>(
              width: MediaQuery.of(context).size.width,
              menuHeight: 250,
              initialSelection: leChoix,
              //controller: civiliteController,
              hintText: "Choix",
              requestFocusOnTap: false,
              enableSearch: false,
              enableFilter: false,
              label: const Text('Choix'),
              // Initial Value
              onSelected: (String? value) {
                leChoix = value!;
              },
              dropdownMenuEntries:
              lesChoix.map<DropdownMenuEntry<String>>((String menu) {
                return DropdownMenuEntry<String>(
                    value: menu,
                    label: menu,
                    leadingIcon: Icon(Icons.check_circle));
              }).toList()
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
          title: Text(widget.lActionTerrain == null ? 'Nouvelle Action' : 'Modification Action'),
        ),
        body: SingleChildScrollView(
          child: Column(
              children: renseignementPersonne()
          ),
        )
    );
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

    sendActionData();

    Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (!flagServerResponse) {
          Navigator.pop(dialogContext);
          timer.cancel();

          if (!flagSendData) {
            Navigator.pop(context, 1);
          } else {
            displayToast('Traitement impossible');
          }
        }
      },
    );
  }

  Future<void> sendActionData() async {
    // First Call this :
    var localToken = await MesServices().checkJwtExpiration();
    final url = Uri.parse('${dotenv.env['URL_BACKEND_STAT']}manage-action-terrain');
    try {
      var response = await post(url,
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer $localToken'
          },
          body: jsonEncode({
            "id" : widget.lActionTerrain == null ? 0 : widget.lActionTerrain!.id,
            "commune" : laCommune.id,
            "quartier" : leQuartier.id,
            "choix" : leChoix == "Oui" ? 1 : 0
          })
      ).timeout(const Duration(seconds: timeOutValue));

      if (response.statusCode == 200) {
        MessageResponse reponse = MessageResponse.fromJson(
            json.decode(response.body));

        ActionTerrain actionTerrain = ActionTerrain(id: widget.lActionTerrain == null ? reponse.id : widget.lActionTerrain!.id,
            actif: leChoix == "Oui" ? 1 : 0, communeId: laCommune.id, quartierId: leQuartier.id);
        widget.lActionTerrain == null ? actionTerrainControllerX.addItem(actionTerrain) :
        actionTerrainControllerX.updateData(actionTerrain);
        flagSendData = false;
      } else {
        displayToast("Impossible de récupérer les données de références");
      }
    } catch (e) {
      displayToast("Impossible de traiter les données de référence : $e");
    } finally {
      flagServerResponse = false;
    }
  }
}