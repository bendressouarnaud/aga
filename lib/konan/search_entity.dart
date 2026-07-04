import 'dart:convert';

import 'package:cnmci/konan/interface_view_apprenti.dart';
import 'package:cnmci/konan/interface_view_artisan.dart';
import 'package:cnmci/konan/interface_view_compagnon.dart';
import 'package:cnmci/konan/interface_view_entreprise.dart';
import 'package:cnmci/konan/services.dart';
import 'package:cnmci/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';

import 'beans/search_response_data.dart';
import 'beans/stats_bean_manager.dart';
import 'objets/constants.dart';

class SearchEntity extends StatefulWidget {
  final int screen;
  const SearchEntity({super.key, required this.screen});

  @override
  State<SearchEntity> createState() => _SearchEntity();
}

class _SearchEntity extends State<SearchEntity> {

  // ATTRIBUTES :
  List<SearchResponseData> liste = [];
  bool foreignData = false;


  // METHODS :
  void lookForEntity(String textToSearch) async{
    foreignData = false;
    liste = [];
    switch(widget.screen){
      case 1:
        liste = artisanControllerX.data.where(
            (a) => a.nom.toLowerCase().contains(textToSearch.trim().toLowerCase()) ||
                a.prenom.toLowerCase().contains(textToSearch.trim().toLowerCase()) ||
                a.contact1.contains(textToSearch.trim())
        ).toList()
        .map(
            (a) => SearchResponseData(
                nom: '${a.nom} ${a.prenom}',
                metier: lesMetiers.where((m) => m.id == a.activite_principale).first.libelle,
                date: a.date_naissance,
                contact: a.contact1,
                id: a.id
            )
        ).toList();
        break;

      case 2:
        // Apprentis
        liste = apprentiControllerX.data.where(
                (a) => a.nom.toLowerCase().contains(textToSearch.trim().toLowerCase()) ||
                a.prenom.toLowerCase().contains(textToSearch.trim().toLowerCase()) ||
                a.contact1.contains(textToSearch.trim())
        ).toList()
            .map(
                (a) => SearchResponseData(
                nom: '${a.nom} ${a.prenom}',
                metier: lesMetiers.where((m) => m.id == a.metier).first.libelle,
                date: a.date_naissance,
                contact: a.contact1,
                id: a.id
            )
        ).toList();
        break;

      case 3:
      // Compagnons
        liste = compagnonControllerX.data.where(
                (a) => a.nom.toLowerCase().contains(textToSearch.trim().toLowerCase()) ||
                a.prenom.toLowerCase().contains(textToSearch.trim().toLowerCase()) ||
                a.contact1.contains(textToSearch.trim())
        ).toList()
            .map(
                (a) => SearchResponseData(
                nom: '${a.nom} ${a.prenom}',
                metier: lesMetiers.where((m) => m.id == a.specialite).first.libelle,
                date: a.date_naissance,
                contact: a.contact1,
                id: a.id
            )
        ).toList();
        break;

      default:
      // Entreprises
        liste = entrepriseControllerX.data.where(
                (a) => a.denomination.toLowerCase().contains(textToSearch.trim().toLowerCase()) ||
                a.contact1.contains(textToSearch.trim())
        ).toList()
            .map(
                (a) => SearchResponseData(
                nom: a.denomination,
                metier: lesMetiers.where((m) => m.id == a.activite_principale).first.libelle,
                date: a.date_creation,
                contact: a.contact1,
                id: a.id
            )
        ).toList();
        break;
    }

    // From there, look on WEB :
    if(liste.isEmpty){
      try{
        var localToken = await MesServices().checkJwtExpiration();
        final url = Uri.parse('${dotenv.env['URL_BACKEND_STAT']}look-for-any-entity/$textToSearch');
        var response = await get(url,
            headers: {
              "Content-Type": "application/json",
              'Authorization': 'Bearer $localToken'
            }
        ).timeout(const Duration(seconds: timeOutValue));
        if(response.statusCode == 200){
          final List result = json.decode(response.body);
          setState(() {
            var listeTampon = result.map((e) => StatsBeanManager.fromJson(e)).toList();
            setState(() {
              if(listeTampon.isNotEmpty){
                liste = listeTampon.map((donnee) => SearchResponseData(
                    nom: donnee.nom,
                    metier: donnee.metier,
                    date: donnee.datenrolement,
                    contact: donnee.contact,
                    id: donnee.id
                )).toList();
                //
                foreignData = true;
              }
              else{
                liste = [];
              }
            });
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
    else{
      setState(() {
        // Just notify because the liste is full
      });
    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text('Recherche'
          )
      ),
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
                          if(!foreignData) {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                                  if (widget.screen == 1) {
                                    // ARTISAN
                                    artisanToManage = artisanControllerX.data
                                        .where((a) => a.id == liste[index].id)
                                        .first;
                                    return InterfaceViewArtisan();
                                  }
                                  else if (widget.screen == 2) {
                                    // APPRENTI
                                    return InterfaceViewApprenti(
                                        apprenti: apprentiControllerX.data
                                            .where((a) =>
                                        a.id == liste[index].id)
                                            .first);
                                  }
                                  else if (widget.screen == 3) {
                                    // COMPAGNON
                                    return InterfaceViewCompagnon(
                                        compagnon: compagnonControllerX.data
                                            .where((a) =>
                                        a.id == liste[index].id)
                                            .first);
                                  }
                                  else {
                                    // ENTREPRISE
                                    return InterfaceViewEntreprise(
                                        entreprise: entrepriseControllerX.data
                                            .where((a) =>
                                        a.id == liste[index].id)
                                            .first);
                                  }
                                })
                            );
                          }
                          else{
                            // Display SNACKBAR :
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Cette entité ne figure pas dans vos données. '
                                    'Elle a été enregistrée par une tierce personne.'),
                              ),
                            );
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
                                  children: [
                                    Container(
                                        margin: EdgeInsets.only(right: 10, left: 10),
                                        alignment: Alignment.topLeft,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(liste[index].nom,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold
                                              ),
                                            ),
                                            Visibility(
                                              visible: foreignData,
                                                child: Icon(
                                                  Icons.network_wifi,
                                                  color: Colors.red
                                                )
                                            )
                                          ],
                                        )
                                    ),
                                    Container(
                                        margin: EdgeInsets.only(right: 10, left: 10, top: 5),
                                        alignment: Alignment.topLeft,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(liste[index].contact,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold
                                              ),
                                            ),
                                            Text(liste[index].date)
                                          ],
                                        )
                                    ),
                                    Container(
                                        margin: EdgeInsets.only(right: 10, left: 10, top: 5),
                                        alignment: Alignment.topLeft,
                                        child: Text(liste[index].metier,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold
                                          ),)
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
