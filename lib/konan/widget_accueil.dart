import 'package:cnmci/getxcontroller/apprenti_controller_x.dart';
import 'package:cnmci/getxcontroller/artisan_controller_x.dart';
import 'package:cnmci/getxcontroller/compagnon_controller_x.dart';
import 'package:cnmci/getxcontroller/entreprise_controller_x.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WidgetAccueil extends StatefulWidget {
  WidgetAccueil({Key? key}) : super(key: key);

  @override
  State<WidgetAccueil> createState() => _WidgetAccueil();
}

class _WidgetAccueil extends State<WidgetAccueil> {

  // ATTRIBUTES :
  int donnesDuJour = 0;
  int artisanDuJour = 0;
  int apprentiDuJour = 0;
  int compagnonDuJour = 0;
  int entrepriseDuJour = 0;

  // METHODS :
  bool checkDateTime(DateTime currentDateTime, DateTime fromDatabase){
    return currentDateTime.year == fromDatabase.year &&
        currentDateTime.month == fromDatabase.month &&
        currentDateTime.day == fromDatabase.day;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [

            Container(
              margin: EdgeInsets.only(top: 10),
              height: 450,
              child: GridView.count(
                primary: false,
                padding: const EdgeInsets.all(10),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                crossAxisCount: 2,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.brown[50],
                        borderRadius: BorderRadius.circular(8.0)
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.person,
                          size: 60,),
                        Text('Artisan',
                          style: TextStyle(
                              fontSize: 25
                          ),),
                        GetBuilder(
                            builder: (ArtisanControllerX dataX){

                              artisanDuJour = dataX.data.where((d) =>
                              checkDateTime(DateTime.fromMillisecondsSinceEpoch(d.millisecondes),
                                  DateTime.now()) == true).length;

                              donnesDuJour += artisanDuJour;
                              /*setState(() {
                                donnesDuJour += artisanDuJour;
                              });*/

                              return Text('${dataX.data.length}',
                                  style: TextStyle(
                                      fontSize: 25
                                  )
                              );
                            }
                        ),
                      ],
                    ),
                  ),
                  Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.brown[100],
                          borderRadius: BorderRadius.circular(8.0)
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.people_alt,
                            size: 60,),
                          Text('Apprenti',
                            style: TextStyle(
                                fontSize: 25
                            ),),
                          GetBuilder(
                              builder: (ApprentiControllerX dataX){

                                apprentiDuJour = dataX.data.where((d) =>
                                checkDateTime(DateTime.fromMillisecondsSinceEpoch(d.millisecondes),
                                    DateTime.now()) == true).length;

                                donnesDuJour += apprentiDuJour;
                                /*setState(() {
                                  donnesDuJour += apprentiDuJour;
                                });*/

                                return Text('${dataX.data.length}',
                                    style: TextStyle(
                                        fontSize: 25
                                    )
                                );
                              }
                          )
                        ],
                      )
                  ),
                  Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8.0)
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline_outlined,
                            size: 60,),
                          Text('Compagnon',
                            style: TextStyle(
                                fontSize: 25
                            ),),
                          GetBuilder(
                              builder: (CompagnonControllerX dataX){

                                compagnonDuJour = dataX.data.where((d) =>
                                checkDateTime(DateTime.fromMillisecondsSinceEpoch(d.millisecondes),
                                    DateTime.now()) == true).length;

                                donnesDuJour += compagnonDuJour;
                                /*setState(() {
                                  donnesDuJour += compagnonDuJour;
                                });*/

                                return Text('${dataX.data.length}',
                                    style: TextStyle(
                                        fontSize: 25
                                    )
                                );
                              }
                          )
                        ],
                      )
                  ),
                  Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.0)
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.warehouse,
                            size: 60,),
                          Text('Entreprise Art.',
                            style: TextStyle(
                                fontSize: 25
                            ),),
                          GetBuilder(
                              builder: (EntrepriseControllerX dataX){

                                entrepriseDuJour = dataX.data.where((d) =>
                                checkDateTime(DateTime.fromMillisecondsSinceEpoch(d.millisecondes),
                                    DateTime.now()) == true).length;

                                donnesDuJour += entrepriseDuJour;
                                /*setState(() {
                                  donnesDuJour += entrepriseDuJour;
                                });*/

                                return Text('${dataX.data.length}',
                                    style: TextStyle(
                                        fontSize: 25
                                    )
                                );
                              }
                          )
                        ],
                      )
                  )
                ],
              ),
            ),

            Container(
                width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(top: 10, left: 10, right: 10),
              child: Text('Statistiques du jour',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20
                )
              )
            ),

            Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                child: Divider(
                  height: 3,
                  color: Colors.black,
                )
            ),

            GetBuilder(
                builder: (ArtisanControllerX dataX){

                  artisanDuJour = dataX.data.where((d) =>
                  checkDateTime(DateTime.fromMillisecondsSinceEpoch(d.millisecondes),
                      DateTime.now()) == true).length;

                  return Container(
                      alignment: Alignment.topLeft,
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.only(top: 15, left: 10, right: 10),
                      child: Row(
                        children: [
                          Text('Artisan(s) : ',
                              style: TextStyle(
                                  fontSize: 20
                              )
                          ),Text('$artisanDuJour',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                              )
                          )
                        ],
                      )
                  );
                }
            ),

            GetBuilder(
                builder: (ApprentiControllerX dataX){

                  apprentiDuJour = dataX.data.where((d) =>
                  checkDateTime(DateTime.fromMillisecondsSinceEpoch(d.millisecondes),
                      DateTime.now()) == true).length;

                  return Container(
                      alignment: Alignment.topLeft,
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.only(top: 15, left: 10, right: 10),
                      child: Row(
                        children: [
                          Text('Apprenti(s) : ',
                              style: TextStyle(
                                  fontSize: 20
                              )
                          ),Text('$apprentiDuJour',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                              )
                          )
                        ],
                      )
                  );
                }
            ),

            GetBuilder(
                builder: (CompagnonControllerX dataX){

                  compagnonDuJour = dataX.data.where((d) =>
                  checkDateTime(DateTime.fromMillisecondsSinceEpoch(d.millisecondes),
                      DateTime.now()) == true).length;

                  return Container(
                      alignment: Alignment.topLeft,
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.only(top: 15, left: 10, right: 10),
                      child: Row(
                        children: [
                          Text('Compagnon(s) : ',
                              style: TextStyle(
                                  fontSize: 20
                              )
                          ),Text('$compagnonDuJour',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                              )
                          )
                        ],
                      )
                  );
                }
            ),

            GetBuilder(
                builder: (EntrepriseControllerX dataX){

                  entrepriseDuJour = dataX.data.where((d) =>
                  checkDateTime(DateTime.fromMillisecondsSinceEpoch(d.millisecondes),
                      DateTime.now()) == true).length;

                  return Container(
                      alignment: Alignment.topLeft,
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.only(top: 15, left: 10, right: 10),
                      child: Row(
                        children: [
                          Text('Entreprise(s) : ',
                              style: TextStyle(
                                  fontSize: 20
                              )
                          ),Text('$entrepriseDuJour',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                              )
                          )
                        ],
                      )
                  );
                }
            ),

          ],
        )
      )
    );
  }

}