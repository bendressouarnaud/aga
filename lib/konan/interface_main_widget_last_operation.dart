import 'package:cnmci/getxcontroller/derniere_operation_controller_x.dart';
import 'package:cnmci/konan/interface_view_apprenti.dart';
import 'package:cnmci/konan/interface_view_compagnon.dart';
import 'package:cnmci/konan/interface_view_entreprise.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

import '../main.dart';
import 'interface_view_artisan.dart';
import 'model/derniere_operation.dart';

class InterfaceMainWidgetLastOperation extends StatelessWidget {
  const InterfaceMainWidgetLastOperation({super.key});

  // This widget is the root of your application.
  String limitValue(String data){
    if(data.length > 20){
      return '${data.substring(0,20)}...';
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 5.0),
        SizedBox(
          //margin: EdgeInsets.only(left: 10.0, right: 10.0),
          width: 100.0,
          child: Divider(
            color: Colors.grey,
            thickness: 1.0,
          ),
        ),
        Container(
            margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0, bottom: 10.0),
            child: Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                            Icons.history_edu,
                            color: Colors.black
                        ),
                        SizedBox(width: 10.0),
                        Text(
                          'Dernières opérations',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(width: 10.0),
                                Text(
                                  '',// Voir tout
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 12.0,
                                  ),
                                )
                              ],
                            )
                        )
                      ],
                    ),

                    GetBuilder<DerniereOperationControllerX>(
                        builder: (derniereOperationControllerX){

                          var listeInitial = derniereOperationControllerX.data;
                          List<DerniereOperation> liste = [];
                          switch(listeInitial.length){
                            case 0:
                            case 1:
                            case 2:
                            case 3:
                              liste = listeInitial;
                              break;

                            default:
                              liste = listeInitial.sublist(0, 3);
                              break;
                          }
                          liste.sort((a,b) => b.id.compareTo(a.id));

                          return ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: liste.length,
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                    onTap: () {
                                      switch(liste[index].requesterType){
                                        case 'ART':
                                          Navigator.push(context,
                                              MaterialPageRoute(builder: (context) {
                                                // Update this :
                                                artisanToManage =
                                                    artisanControllerX.data.where(
                                                            (a) => a.id == liste[index].requesterId &&
                                                            liste[index].requesterType == 'ART').first;
                                                return InterfaceViewArtisan();
                                              })
                                          );
                                          break;
                                        case 'APP':
                                          Navigator.push(context,
                                              MaterialPageRoute(builder: (context) {
                                                // Update this :
                                                apprentiToManage =
                                                    apprentiControllerX.data.where(
                                                            (a) => a.id == liste[index].requesterId &&
                                                            liste[index].requesterType == 'APP').first;
                                                return InterfaceViewApprenti(apprenti: apprentiToManage);
                                              })
                                          );
                                          break;
                                        case 'COM':
                                          Navigator.push(context,
                                              MaterialPageRoute(builder: (context) {
                                                // Update this :
                                                compagnonToManage =
                                                    compagnonControllerX.data.where(
                                                            (a) => a.id == liste[index].requesterId &&
                                                            liste[index].requesterType == 'COM').first;
                                                return InterfaceViewCompagnon(compagnon: compagnonToManage);
                                              })
                                          );
                                          break;
                                        default:
                                          Navigator.push(context,
                                              MaterialPageRoute(builder: (context) {
                                                // Update this :
                                                entrepriseToManage =
                                                    entrepriseControllerX.data.where(
                                                            (a) => a.id == liste[index].requesterId &&
                                                            liste[index].requesterType == 'ENT').first;
                                                return InterfaceViewEntreprise(entreprise: entrepriseToManage);
                                              })
                                          );
                                          break;
                                      }
                                      /*Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                    // Update this :
                                    artisanToManage = listeAucunPaiement[index];
                                    return InterfaceViewArtisan();
                                  })
                              );*/
                                    },
                                    child: Card(
                                      color: Colors.blue[50],
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Row(
                                          children: [
                                            Card(
                                                color: Colors.orange[100],
                                                child: Padding(
                                                  padding: const EdgeInsets.all(6.0),
                                                  child: const Icon(
                                                      Icons.account_circle_outlined,
                                                      color: Colors.black
                                                  ),
                                                )
                                            ),

                                            const SizedBox(width: 3.0),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  limitValue(liste[index].libelle),
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 11.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  limitValue(liste[index].detail),
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 11.0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(width: 3.0),
                                            Expanded(
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    SizedBox(width: 10.0),
                                                    Card(
                                                      color: Colors.greenAccent,
                                                      child: Padding(
                                                          padding: const EdgeInsets.all(4.0),
                                                          child: Text(
                                                            liste[index].action == 0 ? 'Enregistré' :
                                                            liste[index].action == 1 ? 'Modifié' : 'Payé',
                                                            style: TextStyle(
                                                              color: Colors.black,
                                                              fontSize: 12.0,
                                                            ),
                                                          )
                                                      ),
                                                    )
                                                  ],
                                                )
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                );
                              }
                          );
                        }
                    )
                  ],
                ),
              ),
            )
        )
      ],
    );
  }
}