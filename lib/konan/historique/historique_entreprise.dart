import 'dart:async';
import 'dart:convert';

import 'package:cnmci/getxcontroller/entreprise_controller_x.dart';
import 'package:cnmci/konan/interface_entreprise.dart';
import 'package:cnmci/konan/interface_view_entreprise.dart';
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

class HistoriqueEntreprise extends StatefulWidget {
  const HistoriqueEntreprise({super.key});

  @override
  State<HistoriqueEntreprise> createState() => _HistoriqueEntreprise();
}

class _HistoriqueEntreprise extends State<HistoriqueEntreprise> {

  // ATTRIBUTES :
  final EntrepriseControllerX _entrepriseControllerX = Get.put(EntrepriseControllerX());
  late BuildContext dialogContext;


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
          // Send DATA :
          final result = await Navigator.push(context,
              MaterialPageRoute(builder: (context) {
                return const InterfaceEntreprise();
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
    return GetBuilder<EntrepriseControllerX>(
        builder: (EntrepriseControllerX controller){

          return controller.data.isNotEmpty ?
          SingleChildScrollView(
            child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: controller.data.length, //listeChat.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                            return InterfaceViewEntreprise(entreprise: controller.data[index]);
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
                                        Text(MesServices().processEntityName(controller.data[index].denomination, limitCharacter),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),
                                        Text(controller.data[index].date_creation)
                                      ],
                                    )
                                ),
                                Container(
                                  margin: EdgeInsets.only(right: 10, left: 10, top: 5),
                                  alignment: Alignment.topLeft,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(controller.data[index].contact1),
                                      Text(controller.data[index].statut_paiement == 0 ? 'Non payé' :
                                      controller.data[index].statut_paiement == 1 ? 'En cours' : 'Payé',
                                        style: TextStyle(
                                            color: controller.data[index].statut_paiement == 0 ? Colors.red :
                                            controller.data[index].statut_paiement == 1 ? Colors.blueGrey : Colors.green,
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
                                          text: 'Activité princ. : ',
                                          //style: TextStyle(fontWeight: FontWeight.bold),
                                          children: <TextSpan>[
                                            TextSpan(text: lesMetiers.where((m) => m.id == controller.data[index].activite_principale).first.libelle,
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
                                          text: 'Quartier siège : ',
                                          //style: TextStyle(fontWeight: FontWeight.bold),
                                          children: <TextSpan>[
                                            TextSpan(text: controller.data[index].quartier_siege.trim().isNotEmpty ?
                                            controller.data[index].quartier_siege : "---",
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
                                            TextSpan(text: lesCommunes.where((c) => c.id == controller.data[index].commune_residence).first.libelle,
                                                style: TextStyle(fontWeight: FontWeight.bold)
                                            )
                                          ]
                                      ),
                                    )
                                )
                              ],
                            )
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
              child: Text('Aucune Entreprise',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold)
              ),
            ),
          );
        }
    );
  }
}
