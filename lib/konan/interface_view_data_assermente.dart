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

class InterfaceViewDataAssermente extends StatefulWidget {
  final List<StatsBeanManager> liste;
  const InterfaceViewDataAssermente({super.key, required this.liste});

  @override
  State<InterfaceViewDataAssermente> createState() => _InterfaceViewDataAssermente();
}

class _InterfaceViewDataAssermente extends State<InterfaceViewDataAssermente> {

  // ATTRIBUTES :
  final TextEditingController _textController = TextEditingController();
  bool requestToSearch = false;
  late List<StatsBeanManager> _filteredList;


  // METHODS :
  @override
  void initState() {
    super.initState();

    _filteredList = widget.liste;
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

  void _filterLogListBySearchText(String searchText) {
    setState(() {
      _filteredList = widget.liste
          .where(
              (data) => data.nom.toLowerCase().contains(searchText.trim().toLowerCase()) ||
                  data.contact.contains(searchText.trim()) ||
                  data.metier.toLowerCase().contains(searchText.trim().toLowerCase()) ||
                  data.type.toLowerCase().contains(searchText.trim().toLowerCase())
          ).toList();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: !requestToSearch ? Text('Résultat'
          ) :
          Container(
            height: 40,
            decoration: BoxDecoration(
                color: const Color(0xffF5F5F5),
                borderRadius: BorderRadius.circular(5)),
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                prefixIcon: IconButton(
                  icon: Icon(
                    Icons.search_rounded,
                    color: Theme.of(context).primaryColorDark,
                  ),
                  onPressed: () => FocusScope.of(context).unfocus(),
                ),
                suffixIcon: IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    onPressed: () {
                      setState(() {
                        _textController.text = "";
                        _filterLogListBySearchText("");
                        requestToSearch = false;
                      });
                    }),
                hintText: 'Recherche...',
                border: InputBorder.none,
              ),
              onChanged: (value) => _filterLogListBySearchText(value),
              onSubmitted: (value) => _filterLogListBySearchText(value),
            ),
          ),
        actions: [
          Visibility(
              visible: !requestToSearch,
              child: IconButton(
                  onPressed: () {
                    setState(() {
                      requestToSearch = true;
                    });
                  },
                  icon: const Icon(Icons.search, color: Colors.black)
              )
          )
        ]
      ),
      body: SingleChildScrollView(
        child: SafeArea(
            child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: _filteredList.length, //listeChat.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      //print('Taille : ${liste.length}');
                      //print('Data : $index');
                      try {
                        if(_filteredList.isNotEmpty) {
                          statsBeanManager = _filteredList[index];
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                                return InterfaceViewEntity();
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
                                      MesServices().processEntityName(_filteredList[index].nom.toUpperCase(), limitCharacterEntity),
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    processIconToShow(_filteredList[index].datenrolement, _filteredList[index].paiement)
                                  ],
                                ),
                                Text(_filteredList[index].contact,
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                processDateLibelle(_filteredList[index].type, _filteredList[index].datenaissance),
                                Divider(
                                  height: 3,
                                ),
                                Text('Métier : ${_filteredList[index].metier}',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                                Text('Commune résid. : ${_filteredList[index].commune}',
                                  style: TextStyle(
                                      fontSize: 15
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(_filteredList[index].type,
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        getAppropriateIcon(_filteredList[index].type)
                                      ],
                                    ),
                                    Text(_filteredList[index].paiement == 0 ? 'Non payé' :
                                    _filteredList[index].paiement == 1 ? 'En cours' : 'Soldé',
                                      style: TextStyle(
                                          color: _filteredList[index].paiement == 0 ? Colors.red :
                                          _filteredList[index].paiement == 1 ? Colors.brown : Colors.green
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
      )
    );
  }

}
