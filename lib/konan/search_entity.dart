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
import 'package:get/get.dart';

import 'beans/search_response_data.dart';

class SearchEntity extends StatefulWidget {
  final int screen;
  const SearchEntity({super.key, required this.screen});

  @override
  State<SearchEntity> createState() => _SearchEntity();
}

class _SearchEntity extends State<SearchEntity> {

  // ATTRIBUTES :
  List<SearchResponseData> liste = [];
  /*final EntrepriseControllerX _entrepriseControllerX = Get.put(EntrepriseControllerX());
  late BuildContext dialogContext;*/


  // METHODS :
  List<SearchResponseData> lookForEntity(String textToSearch){
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
                metier: lesMetiers.where((m) => m.id == a.specialite).first.libelle,
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

      case 2:
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

      case 3:
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
    return liste;
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
                    setState(() {
                      lookForEntity(value);
                    });
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
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                                if(widget.screen == 1){
                                  // ARTISAN
                                  return InterfaceViewArtisan(
                                      artisan: artisanControllerX.data.where((a) => a.id == liste[index].id).first);
                                }
                                else if(widget.screen == 2){
                                  // APPRENTI
                                  return InterfaceViewApprenti(
                                      apprenti: apprentiControllerX.data.where((a) => a.id == liste[index].id).first);
                                }
                                else if(widget.screen == 3){
                                  // COMPAGNON
                                  return InterfaceViewCompagnon(
                                      compagnon: compagnonControllerX.data.where((a) => a.id == liste[index].id).first);
                                }
                                else{
                                  // ENTREPRISE
                                  return InterfaceViewEntreprise(
                                      entreprise: entrepriseControllerX.data.where((a) => a.id == liste[index].id).first);
                                }
                              })
                          );
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
                                        child: Text(liste[index].nom,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold
                                          ),
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
