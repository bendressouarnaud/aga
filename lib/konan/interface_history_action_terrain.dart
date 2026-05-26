import 'package:cnmci/getxcontroller/action_terrain_controller_x.dart';
import 'package:cnmci/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'interface_action_terrain.dart';

class InterfaceHistoryActionTerrain extends StatefulWidget {
  const InterfaceHistoryActionTerrain({super.key});

  @override
  State<InterfaceHistoryActionTerrain> createState() => _InterfaceHistoryActionTerrain();
}

class _InterfaceHistoryActionTerrain extends State<InterfaceHistoryActionTerrain> {

  // A t t r i b u t e s  :
  int currentPageIndex = 0;
  double maxAmount = 0.0;
  double tranche = 0;
  String maxAmountString ='';
  String tranche1 ='';
  String tranche2 ='';
  bool requestToSearch = false;



  // METHODS :
  Widget getData() {
    return GetBuilder<ActionTerrainControllerX>(
        builder: (ActionTerrainControllerX controller){

          return controller.data.isNotEmpty ?
          SingleChildScrollView(
              child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: controller.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                              return InterfaceActionTerrain(lActionTerrain: controller.data[index]);
                            }
                            )
                        );
                      },
                      child: Card(
                        color: Colors.brown[50],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
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
                                      child: Text(
                                        lesCommunes.where((c) => c.id == controller.data[index].communeId).first.libelle,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold
                                        ),)
                                  ),
                                  Container(
                                      margin: EdgeInsets.only(right: 10, left: 10),
                                      alignment: Alignment.topLeft,
                                      child: Text(lesQuartiers.where((c) => c.id == controller.data[index].quartierId).first.libelle,
                                        style: TextStyle(
                                            color: Colors.brown
                                        ),)
                                  ),
                                  Container(
                                      margin: EdgeInsets.only(right: 10, left: 10),
                                      alignment: Alignment.topLeft,
                                      child: Divider(
                                        height: 2,
                                      )
                                  ),
                                  Container(
                                      margin: EdgeInsets.only(right: 10, left: 10),
                                      alignment: Alignment.topRight,
                                      child: Text(controller.data[index].actif == 1 ? 'Actif' : 'Désactivé',
                                        style: TextStyle(
                                            color: controller.data[index].actif == 1 ? Colors.green : Colors.red,
                                            fontWeight: FontWeight.bold
                                        ),
                                      )
                                  ),
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
              )
          ) :
          Center(
            child: Text('Aucune donnée'),
          );
        }
      );
    //return listeAucunPaiement;
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
        body: getData(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) {
                  return InterfaceActionTerrain(lActionTerrain: null);
                }
                )
            );
          },
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        )
    );

  }

}