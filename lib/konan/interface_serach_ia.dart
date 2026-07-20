import 'dart:async';
import 'dart:convert';

import 'package:cnmci/konan/services.dart';
import 'package:cnmci/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';

import 'beans/stats_bean_manager.dart';
import 'interface_view_entity.dart';
import 'objets/constants.dart';

class InterfaceSerachIa extends StatefulWidget {
  const InterfaceSerachIa({super.key});

  @override
  State<InterfaceSerachIa> createState() => _InterfaceSerachIa();
}

class _InterfaceSerachIa extends State<InterfaceSerachIa> {

  // ATTRIBUTES :
  List<dynamic> liste = [];
  List<StatsBeanManager> listeBean = [];
  TextEditingController requeteController = TextEditingController();
  late BuildContext dialogContext;
  bool flagSendData = false;
  bool flagServerResponse = false;


  // METHODS :
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

  List<Widget> processDataReturned(dynamic tab){
    List<Widget> retour = [];
    // Apply REGEX on it :
    String pattern = r'^[0-9]{10}$';
    RegExp regExp = RegExp(pattern);
    for(dynamic valeur in tab){
      // Put Number in BOLD
      var stringValue = '$valeur';
      // Launch RESEARCH
      if(regExp.hasMatch(stringValue)){
        retour.add(
            Text('$valeur',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black
            ),)
        );
      }
      else{
        retour.add(Text('$valeur'));
      }
    }
    return retour;
  }

  Future<void> lookForQuery() async {
    liste = [];
    try{
      var localToken = await MesServices().checkJwtExpiration();
      final url = Uri.parse('${dotenv.env['URL_BACKEND']}query');
      var response = await post(url,
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer $localToken'
          },
          body: jsonEncode({
            "question" : requeteController.text
          })
      ).timeout(const Duration(seconds: timeOutValue));
      if(response.statusCode == 200){
        final Map<String, dynamic> result = json.decode(response.body);
        //print('Taille : ${result.length}');
        // Browse this :

        //print('Taille tableaux : ${liste.length}');

        /*for(dynamic tab in liste){
          for(dynamic valeur in tab){
            print('élément : $valeur');
          }
          break;
        }

        print('1 er élément : ${liste[0]}');
        print('1 er élément : ${liste[0][0]}');*/
        flagSendData = false;
        setState(() {
          liste = result['result'].cast<dynamic>();
        });

        /*setState(() {
          liste = result.map((data) => data.cast<dynamic>()).toList();
        });*/
      }
      else{
        setState(() {
          liste = [];
        });
      }
    }
    catch(e){
      setState(() {
        liste = [];
      });
    }
    finally{
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

    lookForQuery();

    Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (!flagServerResponse) {
          Navigator.pop(dialogContext);
          timer.cancel();

          if (flagSendData) {
            displayToast('Impossible de traiter la demande');
          }
        }
      },
    );
  }

  void displayNumberResearch(String word){
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

    lookForNumber(word);

    Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (!flagServerResponse) {
          Navigator.pop(dialogContext);
          timer.cancel();

          if (!flagSendData) {
            // Ouvrir :
            statsBeanManager = listeBean[0];
            Navigator.push(context,
                MaterialPageRoute(builder: (context) {
                  return InterfaceViewEntity();
                })
            );
          }
          else{
            displayToast('Impossible de traiter la demande');
          }
        }
      },
    );
  }

  Future<void> lookForNumber(String wordToSearch) async {
    listeBean = [];
    try{
      var localToken = await MesServices().checkJwtExpiration();
      final url = Uri.parse('${dotenv.env['URL_BACKEND_STAT']}look-for-any-entity/$wordToSearch');
      var response = await get(url,
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer $localToken'
          }
      ).timeout(const Duration(seconds: timeOutValue));
      if(response.statusCode == 200){
        final List result = json.decode(response.body);
        listeBean = result.map((e) => StatsBeanManager.fromJson(e)).toList();
        flagSendData = false;
      }
      else{
        listeBean = [];
      }
    }
    catch(e){
      listeBean = [];
    }
    finally{
      flagServerResponse = false;
    }
  }

  @override
  void initState() {
    super.initState();

    requeteController.text = "";
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text('Recherche IA'
          )
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  margin: const EdgeInsets.only(top: 20, left: 10, right: 10),
                  //alignment: Alignment.center,
                  //width: MediaQuery.of(context).size.width * 0.40,
                  child: TextField(
                    minLines: 5,
                    maxLines: 15,
                    keyboardType: TextInputType.multiline,
                    controller: requeteController,
                    onChanged: (value){

                    },
                    decoration: InputDecoration(
                        labelText: 'Requête',
                        hintText: "Saisissez votre demande",
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
                margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                alignment: Alignment.topRight,
                child: ElevatedButton.icon(
                  style: ButtonStyle(
                      backgroundColor: WidgetStateColor.resolveWith((states) => Colors.blue)
                  ),
                  label: Text('Valider',
                      style: TextStyle(
                          color: Colors.white
                      )),
                  onPressed: () async {
                    if(requeteController.text.length >= 14) {
                      displayDataSending();
                    }
                    else{
                      displayToast('Svp renseignez au moins 14 cacractères !');
                    }
                  },
                  icon: const Icon(
                    Icons.search,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              Visibility(
                  visible: liste.isNotEmpty,
                  child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: liste.length, //listeChat.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            try {
                              for(dynamic valeur in liste[index]){
                                // Convert to String :
                                var stringValue = '$valeur';
                                // Apply REGEX on it :
                                String pattern = r'^[0-9]{10}$';
                                RegExp regExp = RegExp(pattern);
                                // Launch RESEARCH
                                if(regExp.hasMatch(stringValue)){
                                  displayNumberResearch(stringValue);
                                }
                              }
                            }
                            catch(e){
                              displayToast("Veuillez réessayer !");
                            }
                          },
                          child: Card(
                            color: Colors.brown[50],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: GestureDetector(
                              child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: processDataReturned(liste[index])
                                  )
                              ),
                            ),
                          ),
                        );
                      }
                  )
              )
            ],
          ),
        )
    );
  }

}