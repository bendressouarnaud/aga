import 'dart:convert';

import 'package:cnmci/getxcontroller/entreprise_controller_x.dart';
import 'package:cnmci/konan/historique/historique_artisan.dart';
import 'package:cnmci/konan/interface_entreprise.dart';
import 'package:cnmci/konan/interface_view_apprenti.dart';
import 'package:cnmci/konan/interface_view_artisan.dart';
import 'package:cnmci/konan/interface_view_compagnon.dart';
import 'package:cnmci/konan/interface_view_entreprise.dart';
import 'package:cnmci/konan/services.dart';
import 'package:cnmci/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';

import 'interface_view_entity.dart';
import 'beans/search_response_data.dart';
import 'beans/stats_bean_manager.dart';
import 'objets/constants.dart';

class SearchEntityManager extends StatefulWidget {
  const SearchEntityManager({super.key});

  @override
  State<SearchEntityManager> createState() => _SearchEntityManager();
}

class _SearchEntityManager extends State<SearchEntityManager> {

  // ATTRIBUTES :
  List<StatsBeanManager> liste = [];
  /*final EntrepriseControllerX _entrepriseControllerX = Get.put(EntrepriseControllerX());
  late BuildContext dialogContext;*/


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

  Future<void> lookForEntity(String wordToSearch) async {
    liste = [];
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
        setState(() {
          liste = result.map((e) => StatsBeanManager.fromJson(e)).toList();
        });
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      /*appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text('Recherche'
          )
      ),*/
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
              child: TextField(
                onChanged: (value){
                  if(value.trim().length > 2){
                    lookForEntity(value);
                  }
                  else{
                    // Hide history if needed
                    if(liste.isNotEmpty){
                      setState(() {
                        liste = [];
                      });
                    }
                  }
                },
                decoration: InputDecoration(
                  hintText: "Saisissez ...",
                    filled: true,
                    fillColor: Colors.grey.withOpacity(0.4),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none
                    )
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
                          //print('Taille : ${liste.length}');
                          //print('Data : $index');
                          try {
                            if(liste.isNotEmpty) {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                    return InterfaceViewEntity(
                                        data: liste[index]
                                    );
                                  })
                              );
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
                            /*onTap: (){

                      },*/
                            child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  /*mainAxisAlignment: MainAxisAlignment.start,*/
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          MesServices().processEntityName(liste[index].nom.toUpperCase(), limitCharacterEntity),
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),
                                        processIconToShow(liste[index].datenrolement, liste[index].paiement)
                                      ],
                                    ),
                                    Text(liste[index].contact,
                                      style: TextStyle(
                                          fontSize: 16,
                                      ),
                                    ),
                                    processDateLibelle(liste[index].type, liste[index].datenaissance),
                                    Divider(
                                      height: 3,
                                    ),
                                    Text('Métier : ${liste[index].metier}',
                                      style: TextStyle(
                                        fontSize: 15,
                                          fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    Text('Commune résid. : ${liste[index].commune}',
                                      style: TextStyle(
                                          fontSize: 15
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(liste[index].type,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            getAppropriateIcon(liste[index].type)
                                          ],
                                        ),
                                        Text(liste[index].paiement == 0 ? 'Non payé' :
                                        liste[index].paiement == 1 ? 'En cours' : 'Soldé',
                                        style: TextStyle(
                                          color: liste[index].paiement == 0 ? Colors.red :
                                          liste[index].paiement == 1 ? Colors.brown : Colors.green
                                        ),)
                                      ],
                                    )
                                  ],
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
