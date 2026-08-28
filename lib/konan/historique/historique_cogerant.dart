import 'dart:async';
import 'dart:convert';

import 'package:cnmci/getxcontroller/cogerant_controller_x.dart';
import 'package:cnmci/getxcontroller/entreprise_controller_x.dart';
import 'package:cnmci/konan/interface_entreprise.dart';
import 'package:cnmci/konan/interface_view_entreprise.dart';
import 'package:cnmci/konan/model/co_gerant.dart';
import 'package:cnmci/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../interface_cogerant_personne.dart';
import '../objets/constants.dart';
import '../services.dart';

class HistoriqueCogerant extends StatefulWidget {
  final int entrepriseId;
  const HistoriqueCogerant({super.key, required this.entrepriseId});

  @override
  State<HistoriqueCogerant> createState() => _HistoriqueCogerant();
}

class _HistoriqueCogerant extends State<HistoriqueCogerant> {

  // ATTRIBUTES :
  late BuildContext dialogContext;
  final int limitBlocs = 30;


  // METHODS :
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text('Liste Cogérants'
          )
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Send DATA :
          Navigator.push(context,
              MaterialPageRoute(builder: (context) {
                return InterfaceCogerantPersonne(
                    coGerant: null,
                    entrepriseId: widget.entrepriseId
                );
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
    return GetBuilder<CogerantControllerX>(
        builder: (cogerantControllerX){
          
          var listGerantIds = gerantEntrepriseControllerX.data
              .where((ge) => ge.entreprise == widget.entrepriseId)
          .map((ge) => ge.coGerant).toList();

          List<CoGerant> currentData = cogerantControllerX.data.isNotEmpty ?
          cogerantControllerX.data
              .where((coGerant) => listGerantIds.contains(coGerant.id))
          .toList()
              : [];

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
                            return InterfaceCogerantPersonne(
                                coGerant: currentData[index],
                                entrepriseId: widget.entrepriseId
                            );
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
                                        Text(MesServices().processEntityName('${currentData[index].nom} ${currentData[index].prenom}', limitCharacterHisto),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),
                                        Text(currentData[index].dateNaissance)
                                      ],
                                    )
                                ),
                                Container(
                                  margin: EdgeInsets.only(right: 10, left: 10, top: 5),
                                  alignment: Alignment.topLeft,
                                  child: Text(currentData[index].contact1)
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
                                          text: 'Qualification : ',
                                          //style: TextStyle(fontWeight: FontWeight.bold),
                                          children: <TextSpan>[
                                            TextSpan(text: currentData[index].qualification,
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
                                            TextSpan(text: lesCommunes.where((c) => c.id == currentData[index].communeResidence).first.libelle,
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
              child: Text('Aucune cogérant',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold)
              ),
            ),
          );
        }
    );
  }
}
