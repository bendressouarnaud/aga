import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cnmci/konan/services.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';

import '../main.dart';
import 'beans/generic_data.dart';
import 'beans/stats_bean_manager.dart';
import 'beans/stats_bean_quartier.dart';
import 'interface_view_data_assermente.dart';
import 'model/commune.dart';
import 'model/quartier.dart';
import 'objets/constants.dart';

class InterfaceControleSermente extends StatefulWidget {
  const InterfaceControleSermente({super.key});

  @override
  State<InterfaceControleSermente> createState() => _InterfaceControleSermente();
}

class _InterfaceControleSermente extends State<InterfaceControleSermente> {

  // A t t r i b u t e s  :
  int choixDate = 0;
  TextEditingController dateDebutController = TextEditingController();
  TextEditingController dateFinController = TextEditingController();
  late Commune laVilleActivite;
  late List<Quartier> lesQuartiersIndex;
  late Quartier leQuartierActivite;
  //
  late GenericData lePaiement;
  final lesGenericData = [
    GenericData(libelle: 'Aucun Paiement', id: 0),
    GenericData(libelle: 'Paiement en cours', id: 1),
    GenericData(libelle: 'Soldé', id: 2)
  ];
  late BuildContext dialogContext;
  bool flagSendData = false;
  bool flagServerResponse = false;
  bool closeAlertDialog = false;
  List<StatsBeanManager> liste = [];
  List<StatsBeanQuartier> listeQuartier = [];
  List<StatsBeanQuartier> listeQuartierCopie = [];


  // METHODS :
  @override
  void initState() {
    super.initState();

    laVilleActivite = lesCommunes.first;
    lesQuartiersIndex = lesQuartiers.where((q) => q.idx == laVilleActivite.id).toList();
    leQuartierActivite = lesQuartiersIndex.first;
    //
    lePaiement = lesGenericData.first;

    //
    var temp = DateTime.now();
    var day = temp.day < 10 ? '0${temp.day}' : '${temp.day}';
    var month = temp.month < 10 ? '0${temp.month}' : '${temp.month}';
    dateDebutController.text = '${temp.year}-$month-$day';
    dateFinController.text = '${temp.year}-$month-$day';
  }

  Future<void> requestForData(int idCommune) async {
    listeQuartier = [];
    try{
      var localToken = await MesServices().checkJwtExpiration();
      final url = Uri.parse('${dotenv.env['URL_BACKEND_STAT']}get-entities-from-quartier-ville/$idCommune');
      var response = await get(url,
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer $localToken'
          }
      ).timeout(const Duration(seconds: timeOutValue));
      if(response.statusCode == 200){
        final List result = json.decode(response.body);
        listeQuartier = result.map((e) => StatsBeanQuartier.fromJson(e)).toList();
        flagSendData = false;
      }
    }
    catch(e){
      // Nothing to do :
    }
    finally {
      flagServerResponse = false;
    }
  }

  Future<void> sendControlRequest() async {
    // Reset :
    liste = [];
    // First Call this :
    var localToken = await MesServices().checkJwtExpiration();
    final url = Uri.parse('${dotenv.env['URL_BACKEND_STAT']}agent-asserment-request');
    try {
      var response = await post(url,
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer $localToken'
          },
          body: jsonEncode({
            "debut" : dateDebutController.text,
            "fin" : dateFinController.text,
            "ville" : laVilleActivite.id,
            "quartier" : leQuartierActivite.id,
            "etat" : lePaiement.id
          })
      ).timeout(const Duration(seconds: timeOutValue));

      if (response.statusCode == 200) {
        final List result = json.decode(response.body);
        liste = result.map((e) => StatsBeanManager.fromJson(e)).toList();
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

  void displayDataFetching(int idCommune){
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

    requestForData(idCommune);

    Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (!flagServerResponse) {
          Navigator.pop(dialogContext);
          timer.cancel();

          if (!flagSendData) {

            if(listeQuartier.isNotEmpty){
              setState(() {
                listeQuartierCopie = listeQuartier.length > 30 ? listeQuartier.sublist(0, 29) : listeQuartier;
                listeQuartierCopie.sort((a,b) => b.total.compareTo(a.total));
              });
            }
            else{
              displayToast("Aucune donnée");
            }
          } else {
            displayToast('Traitement impossible');
          }
        }
      },
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

    sendControlRequest();

    Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (!flagServerResponse) {
          Navigator.pop(dialogContext);
          timer.cancel();

          if (!flagSendData) {
            displayToast(liste.isNotEmpty ?
            'Total : ${liste.length}' : 'Aucune donnée');

            // Open if NEEDED :
            if(liste.isNotEmpty){
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) {
                    return InterfaceViewDataAssermente(
                        liste: liste
                    );
                  })
              );
            }
          } else {
            displayToast('Traitement impossible');
          }
        }
      },
    );
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


  Future<void> _selectDate() async {
    final now = DateTime(2025, 12, 10, 00, 00);
    final initialDate = DateTime.now();//DateTime(2025, 12, 10, 00, 00);

    // Sélection de la date
    final selectedDate = await showDatePicker(
        locale: Locale(Platform.localeName.split("_").first, Platform.localeName.split("_").lastOrNull),
        context: context,
        initialDate: initialDate,
        firstDate: now,
        lastDate: DateTime.now()// DateTime.fromMillisecondsSinceEpoch(globalReservation!.fin),
    );
    if (selectedDate == null) return;

    // Process DATA :
    List<String> tp = selectedDate.toString().split(" ");
    String tpDate = tp[0] ;

    setState(() {
      if(choixDate == 0){
        dateDebutController = TextEditingController(
            text: tpDate);
      }
      else{
        dateFinController = TextEditingController(
            text: tpDate);
      }
    });
  }

  void refreshVilleActivite(Commune commune) {
    // Init QUARTIERS :
    laVilleActivite = commune; // Refresh
    setState(() {
      lesQuartiersIndex = lesQuartiers.where((q) => q.idx == commune.id).toList();
      if(lesQuartiersIndex.isNotEmpty) {
        leQuartierActivite = lesQuartiersIndex.first;
      }
    });
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: (MediaQuery.of(context).size.width / 2) - 20,
                      child: ElevatedButton.icon(
                        style: ButtonStyle(
                            backgroundColor: WidgetStateColor.resolveWith((states) => Colors.brown)
                        ),
                        label: const Text("Début",
                            style: TextStyle(
                                color: Colors.white
                            )
                        ),
                        onPressed: () {
                          choixDate = 0;
                          _selectDate();
                        },
                        icon: const Icon(
                          Icons.access_time_outlined,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(
                        width: (MediaQuery.of(context).size.width / 2) - 20,
                        child: TextField(
                          enabled: false,
                          controller: dateDebutController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Date...',
                          ),
                          style: TextStyle(
                              height: 0.8
                          ),
                          textAlignVertical: TextAlignVertical.bottom,
                          textAlign: TextAlign.right,
                        )
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: (MediaQuery.of(context).size.width / 2) - 20,
                      child: ElevatedButton.icon(
                        style: ButtonStyle(
                            backgroundColor: WidgetStateColor.resolveWith((states) => Colors.brown)
                        ),
                        label: const Text("Fin",
                            style: TextStyle(
                                color: Colors.white
                            )
                        ),
                        onPressed: () {
                          choixDate = 1;
                          _selectDate();
                        },
                        icon: const Icon(
                          Icons.access_time_outlined,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(
                        width: (MediaQuery.of(context).size.width / 2) - 20,
                        child: TextField(
                          enabled: false,
                          controller: dateFinController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Date...',
                          ),
                          style: TextStyle(
                              height: 0.8
                          ),
                          textAlignVertical: TextAlignVertical.bottom,
                          textAlign: TextAlign.right,
                        )
                    ),
                  ],
                ),

                SizedBox(
                  height: 30,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: DropdownMenu<GenericData>(
                      width: MediaQuery.of(context).size.width,
                      menuHeight: 250,
                      initialSelection: lePaiement,
                      //controller: civiliteController,
                      hintText: "Frais",
                      requestFocusOnTap: false,
                      enableSearch: false,
                      enableFilter: false,
                      label: const Text('Etat des frais'),
                      // Initial Value
                      onSelected: (GenericData? value) {
                        lePaiement = value!;
                      },
                      dropdownMenuEntries:
                      lesGenericData.map<DropdownMenuEntry<GenericData>>((GenericData menu) {
                        return DropdownMenuEntry<GenericData>(
                            value: menu,
                            label: menu.libelle,
                            leadingIcon: Icon(Icons.money));
                      }).toList()
                  ),
                ),

                SizedBox(
                  height: 25,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: DropdownSearch<Commune>(
                    mode: Mode.form,
                    onChanged: (Commune? value) => {
                      refreshVilleActivite(value!)
                    },
                    compareFn: (Commune? a, Commune? b){
                      if(a == null || b == null){
                        return false;
                      }
                      return a.id == b.id;
                    },
                    selectedItem: laVilleActivite,
                    itemAsString: (commune) => commune.libelle,
                    items: (filter, infiniteScrollProps) => lesCommunes,
                    decoratorProps: DropDownDecoratorProps(
                      decoration: InputDecoration(
                        labelText: 'Ville d\'activité',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    popupProps: PopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                            decoration: InputDecoration(
                                hintText: 'Rechercher'
                            )
                        ),
                        fit: FlexFit.loose,
                        constraints: BoxConstraints(
                            minHeight: 300,
                            maxHeight: 400
                        )
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),

                Visibility(
                    visible: lesQuartiersIndex.isNotEmpty,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: DropdownSearch<Quartier>(
                        mode: Mode.form,
                        onChanged: (Quartier? value) => {
                          leQuartierActivite = value!
                        },
                        compareFn: (Quartier? a, Quartier? b){
                          if(a == null || b == null){
                            return false;
                          }
                          return a.id == b.id;
                        },
                        selectedItem: leQuartierActivite,
                        itemAsString: (commune) => commune.libelle,
                        items: (filter, infiniteScrollProps) => lesQuartiersIndex,
                        decoratorProps: DropDownDecoratorProps(
                          decoration: InputDecoration(
                            labelText: 'Quartier d\'activité',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        popupProps: PopupProps.menu(
                            showSearchBox: true,
                            searchFieldProps: TextFieldProps(
                                decoration: InputDecoration(
                                    hintText: 'Rechercher'
                                )
                            ),
                            fit: FlexFit.loose,
                            constraints: BoxConstraints(
                                minHeight: 300,
                                maxHeight: 400
                            )
                        ),
                      ),
                    )
                ),
                SizedBox(
                  height: 20,
                ),

                SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  child: ElevatedButton.icon(
                    style: ButtonStyle(
                        backgroundColor: WidgetStateColor.resolveWith((states) => Colors.green)
                    ),
                    label: const Text("Afficher",
                        style: TextStyle(
                            color: Colors.white
                        )
                    ),
                    onPressed: () {
                      if(listeQuartierCopie.isNotEmpty) {
                        setState(() {
                          listeQuartierCopie = [];
                        });
                      }
                      displayDataFetching(laVilleActivite.id);
                    },
                    icon: const Icon(
                      Icons.display_settings,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),

                Visibility(
                    visible: lesQuartiersIndex.isNotEmpty,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      child: ElevatedButton.icon(
                        style: ButtonStyle(
                            backgroundColor: WidgetStateColor.resolveWith((states) => Colors.blue)
                        ),
                        label: const Text("Rechercher",
                            style: TextStyle(
                                color: Colors.white
                            )
                        ),
                        onPressed: () {
                          displayDataSending();
                        },
                        icon: const Icon(
                          Icons.search_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    )
                ),
                SizedBox(
                  height: 40
                ),
                Visibility(
                    visible: listeQuartierCopie.isNotEmpty,
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: listeQuartierCopie.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          color: Colors.brown[50],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              //mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(listeQuartierCopie[index].quartier),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(listeQuartierCopie[index].date),
                                    Text('${listeQuartierCopie[index].total}')
                                  ],
                                )
                              ],
                            )
                          )
                        );
                      },
                    )
                )
              ],
            ),
          )
        )
    );

  }

}