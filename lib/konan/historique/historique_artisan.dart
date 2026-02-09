import 'dart:async';
import 'dart:convert';

import 'package:cnmci/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart';

import '../../getxcontroller/apprenti_controller_x.dart';
import '../../getxcontroller/artisan_controller_x.dart';
import '../interface_artisan_personne.dart';
import '../interface_view_artisan.dart';
import '../objets/constants.dart';
import '../services.dart';

class HistoriqueArtisan extends StatefulWidget {
  const HistoriqueArtisan({super.key});

  @override
  State<HistoriqueArtisan> createState() => _HistoriqueArtisan();
}

class _HistoriqueArtisan extends State<HistoriqueArtisan> {

  // ATTRIBUTES :
  final ArtisanControllerX _artisanControllerX = Get.put(ArtisanControllerX());
  late BuildContext dialogContext;
  final int limitBlocs = 30;


  // METHODS :
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      /*appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text('Historique Art.'
          )
      ),*/
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Open :
          setOriginFromCallArtisan = 0;
          final result = await Navigator.push(context,
              MaterialPageRoute(builder: (context) {
                return const InterfaceArtisanPersonne(lArtisan: null,);
              })
          );
        },
        backgroundColor: Colors.brown,
        tooltip: 'Continuer',
        label: Text('Nouveau',
          style: const TextStyle(
              color: Colors.white
          ),
        ),
        icon: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: returnList(),
    );
  }

  Widget returnList(){
    return GetBuilder<ArtisanControllerX>(
        builder: (ArtisanControllerX controller){

          var currentData = controller.data.isNotEmpty ?
          controller.data.length > limitBlocs ?
          controller.data.sublist(0, (limitBlocs - 1)) : controller.data : [];

          return currentData.isNotEmpty ?
          SingleChildScrollView(
            child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: currentData.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                            // Update this :
                            artisanToManage = currentData[index];
                            return InterfaceViewArtisan();
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
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(MesServices().processEntityName('${currentData[index].nom} ${currentData[index].prenom}',
                                          limitCharacterHisto),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold
                                        ),
                                      ),
                                      Text(currentData[index].date_creation)
                                    ],
                                  )
                              ),
                              Container(
                                margin: EdgeInsets.only(right: 10, left: 10, top: 5),
                                alignment: Alignment.topLeft,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(currentData[index].contact1),
                                    Text(currentData[index].statut_paiement == 0 ? 'Non payé' :
                                    currentData[index].statut_paiement == 1 ? 'En cours' : 'Payé',
                                      style: TextStyle(
                                          color: currentData[index].statut_paiement == 0 ? Colors.red :
                                          currentData[index].statut_paiement == 1 ? Colors.blueGrey : Colors.green,
                                          fontWeight: FontWeight.bold
                                      ),)
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(right: 10, left: 10, top: 5),
                                alignment: Alignment.topLeft,
                                child: Divider(
                                  height: 3,
                                  color: Colors.black,
                                ),
                              ),
                              Container(
                                  margin: EdgeInsets.only(right: 10, left: 10, top: 5),
                                  alignment: Alignment.topLeft,
                                  child: Text.rich(
                                    TextSpan(
                                        text: 'Métier : ',
                                        //style: TextStyle(fontWeight: FontWeight.bold),
                                        children: <TextSpan>[
                                          TextSpan(text: MesServices().processEntityName(
                                              lesMetiers.where((m) => m.id == currentData[index].specialite).first.libelle,
                                              limitCharacterMetier),
                                              style: TextStyle(fontWeight: FontWeight.bold)
                                          )
                                        ]
                                    ),
                                  )
                              ),
                              Container(
                                  margin: EdgeInsets.only(right: 10, left: 10, top: 5),
                                  alignment: Alignment.topLeft,
                                  child: Text.rich(
                                    TextSpan(
                                        text: 'Nationalité : ',
                                        //style: TextStyle(fontWeight: FontWeight.bold),
                                        children: <TextSpan>[
                                          TextSpan(text: lesPays.where((p) => p.id == currentData[index].nationalite).first.libelle,
                                              style: TextStyle(fontWeight: FontWeight.bold)
                                          )
                                        ]
                                    ),
                                  )
                              ),
                              Container(
                                  margin: EdgeInsets.only(right: 10, left: 10, top: 5),
                                  alignment: Alignment.topLeft,
                                  child: Text.rich(
                                    TextSpan(
                                        text: 'Commune résid. : ',
                                        children: <TextSpan>[
                                          TextSpan(text: lesCommunes.where((c) => c.id == currentData[index].commune_residence).first.libelle,
                                              style: TextStyle(fontWeight: FontWeight.bold)
                                          )
                                        ]
                                    ),
                                  )
                              )
                            ],
                          )

                          /*Row(
                            children: [
                              SizedBox(
                                height: 120,
                                width: 90,
                                child: MesServices().displayFromLocalOrFirebase(controller.data[index].photo_artisan),
                              ),
                              Expanded(

                              )
                            ],
                          ),*/
                        ),
                      ),
                    ),
                  );
                }
            ),
          ) :
          Container(
            margin: const EdgeInsets.all(10),
            child: Center(
              child: Text('Aucun Artisan',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold)
              ),
            ),
          );
        }
    );
  }
}
