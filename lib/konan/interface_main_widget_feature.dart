import 'package:cnmci/getxcontroller/enrolement_paiement_controller_x.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

import '../getxcontroller/apprenti_controller_x.dart';
import '../getxcontroller/artisan_controller_x.dart';
import '../getxcontroller/compagnon_controller_x.dart';
import '../getxcontroller/entreprise_controller_x.dart';

class InterfaceMainWidgetFeature extends StatelessWidget {
  InterfaceMainWidgetFeature({super.key});

  int artisanDuJour = 0;
  int artisanDuJourDHier = 0;
  int apprentiDuJour = 0;
  int apprentiDuJourDHier = 0;
  int compagnonDuJour = 0;
  int compagnonDuJourDHier = 0;
  int entrepriseDuJour = 0;
  int entrepriseDuJourDHier = 0;
  int enrolementDuJour = 0;
  int enrolementDuJourDHier = 0;
  int paiementDuJour = 0;
  int paiementDuJourDHier = 0;

  // This widget is the root of your application.
  bool checkDateTime(DateTime currentDateTime, DateTime fromDatabase){
    return currentDateTime.year == fromDatabase.year &&
        currentDateTime.month == fromDatabase.month &&
        currentDateTime.day == fromDatabase.day;
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: EdgeInsets.only(left: 10.0, right: 10.0),
              width: (MediaQuery.of(context).size.width/2.0)-20,
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: GetBuilder<ArtisanControllerX>(
                      builder: (artisanControllerX){
                        artisanDuJour = artisanControllerX.data.where((d) =>
                        checkDateTime(DateTime.fromMillisecondsSinceEpoch(d.millisecondes),
                            DateTime.now()) == true).length;
                        // Process the day's before performance
                        artisanDuJourDHier = artisanControllerX.data.where((d) =>
                         checkDateTime(DateTime.fromMillisecondsSinceEpoch(d.millisecondes),
                            (DateTime.now()).subtract(Duration(days: 1))) == true).length;
                        //donnesDuJour += artisanDuJour;
                        int pourcentageBruteArtisan = artisanDuJourDHier > 0 ?
                        ((artisanDuJour / artisanDuJourDHier)*100).round() : 0;
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Card(
                                    color: Colors.blue[200],
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: const Icon(
                                          Icons.construction,
                                          size: 17,
                                          color: Colors.black
                                      ),
                                    )
                                ),
                                Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SizedBox(width: 10.0),
                                        Card(
                                          color: pourcentageBruteArtisan > 0 ? Colors.greenAccent : Colors.red[100],
                                          child: Padding(
                                              padding: const EdgeInsets.all(2.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(pourcentageBruteArtisan > 0 ? Icons.trending_up :
                                                    Icons.trending_flat,
                                                    color: Colors.black45,
                                                  ),
                                                  SizedBox(width: 10.0),
                                                  Text(
                                                    '+$pourcentageBruteArtisan%',
                                                    style: TextStyle(
                                                      color: Colors.black45,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  )
                                                ],
                                              )
                                          ),
                                        )
                                      ],
                                    )
                                )
                              ],
                            ),
                            SizedBox(height: 10.0),
                            Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.only(left: 5.0),
                              child: Text('$artisanDuJour',
                                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)
                              ),
                            ),
                            Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.only(left: 5.0),
                              child: Text('Artisan(s) / jour',
                                  style: TextStyle(fontSize: 13.0
                                  )
                              ),
                            ),
                            Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.only(left: 5.0),
                              child: Text('Total : ${artisanControllerX.data.length}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold
                                )
                              ),
                            )
                          ],
                        );
                      }
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 10.0, right: 10.0),
              width: (MediaQuery.of(context).size.width/2.0)-20,
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: GetBuilder<ApprentiControllerX>(
                      builder: (apprentiControllerX){
                        apprentiDuJour = apprentiControllerX.data.where((d) =>
                        checkDateTime(DateTime.fromMillisecondsSinceEpoch(d.millisecondes),
                            DateTime.now()) == true).length;
                        apprentiDuJourDHier = apprentiControllerX.data.where((d) =>
                        checkDateTime(DateTime.fromMillisecondsSinceEpoch(d.millisecondes),
                            (DateTime.now()).subtract(Duration(days: 1))) == true).length;
                        //donnesDuJour += artisanDuJour;
                        int pourcentageBruteApprenti = apprentiDuJourDHier > 0 ?
                        ((apprentiDuJour / apprentiDuJourDHier)*100).round() : 0;
                        //donnesDuJour += apprentiDuJour;
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Card(
                                    color: Colors.blue[200],
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: const Icon(
                                          Icons.school_outlined,
                                          size: 17,
                                          color: Colors.black
                                      ),
                                    )
                                ),
                                Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SizedBox(width: 10.0),
                                        Card(
                                          color: pourcentageBruteApprenti> 0 ? Colors.greenAccent : Colors.red[100],
                                          child: Padding(
                                              padding: const EdgeInsets.all(2.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon( pourcentageBruteApprenti> 0 ?
                                                  Icons.trending_up : Icons.trending_flat_outlined,
                                                    color: Colors.black45,
                                                  ),
                                                  SizedBox(width: 10.0),
                                                  Text(
                                                    '+$pourcentageBruteApprenti%',
                                                    style: TextStyle(
                                                      color: Colors.black45,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  )
                                                ],
                                              )
                                          ),
                                        )
                                      ],
                                    )
                                )
                              ],
                            ),
                            SizedBox(height: 10.0),
                            Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.only(left: 5.0),
                              child: Text('$apprentiDuJour',
                                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)
                              ),
                            ),
                            Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.only(left: 5.0),
                              child: Text('Apprenti(s) / jour',
                                  style: TextStyle(fontSize: 13.0
                                  )
                              ),
                            ),
                            Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.only(left: 5.0),
                              child: Text('Total : ${apprentiControllerX.data.length}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold
                                  )
                              ),
                            )
                          ],
                        );
                      }
                  )
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: EdgeInsets.only(left: 10.0, right: 10.0),
              width: (MediaQuery.of(context).size.width/2.0)-20,
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: GetBuilder<CompagnonControllerX>(
                      builder: (compagnonControllerX){
                        compagnonDuJour = compagnonControllerX.data.where((d) =>
                        checkDateTime(DateTime.fromMillisecondsSinceEpoch(d.millisecondes),
                            DateTime.now()) == true).length;
                        //donnesDuJour += compagnonDuJour;
                        compagnonDuJourDHier = compagnonControllerX.data.where((d) =>
                        checkDateTime(DateTime.fromMillisecondsSinceEpoch(d.millisecondes),
                            (DateTime.now()).subtract(Duration(days: 1))) == true).length;
                        //donnesDuJour += artisanDuJour;
                        int pourcentageBruteCompagnon = compagnonDuJourDHier > 0 ?
                        ((compagnonDuJour / compagnonDuJourDHier)*100).round() : 0;
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Card(
                                    color: Colors.blue[200],
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: const Icon(
                                          Icons.people_outline,
                                          size: 17,
                                          color: Colors.black
                                      ),
                                    )
                                ),
                                Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SizedBox(width: 10.0),
                                        Card(
                                          color: pourcentageBruteCompagnon> 0 ? Colors.greenAccent : Colors.red[100],
                                          child: Padding(
                                              padding: const EdgeInsets.all(2.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(pourcentageBruteCompagnon> 0 ?
                                                  Icons.trending_up : Icons.trending_flat_outlined,
                                                    color: Colors.black45,
                                                  ),
                                                  SizedBox(width: 10.0),
                                                  Text(
                                                    '+$pourcentageBruteCompagnon%',
                                                    style: TextStyle(
                                                      color: Colors.black45,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  )
                                                ],
                                              )
                                          ),
                                        )
                                      ],
                                    )
                                )
                              ],
                            ),
                            SizedBox(height: 10.0),
                            Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.only(left: 5.0),
                              child: Text('$compagnonDuJour',
                                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)
                              ),
                            ),
                            Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.only(left: 5.0),
                              child: Text('Compagnon(s) / jour',
                                  style: TextStyle(fontSize: 13.0
                                  )
                              ),
                            ),
                            Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.only(left: 5.0),
                              child: Text('Total : ${compagnonControllerX.data.length}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold
                                  )
                              ),
                            )
                          ],
                        );
                      }
                  )
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 10.0, right: 10.0),
              width: (MediaQuery.of(context).size.width/2.0)-20,
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: GetBuilder<EntrepriseControllerX>(
                      builder: (entrepriseControllerX){
                        entrepriseDuJour = entrepriseControllerX.data.where((d) =>
                        checkDateTime(DateTime.fromMillisecondsSinceEpoch(d.millisecondes),
                            DateTime.now()) == true).length;
                        //donnesDuJour += entrepriseDuJour;
                        entrepriseDuJourDHier = entrepriseControllerX.data.where((d) =>
                        checkDateTime(DateTime.fromMillisecondsSinceEpoch(d.millisecondes),
                            (DateTime.now()).subtract(Duration(days: 1))) == true).length;
                        //donnesDuJour += artisanDuJour;
                        int pourcentageBruteEntreprise = entrepriseDuJourDHier > 0 ?
                        ((entrepriseDuJour / entrepriseDuJourDHier)*100).round() : 0;
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Card(
                                    color: Colors.blue[200],
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: const Icon(
                                          Icons.house_siding_outlined,
                                          size: 17,
                                          color: Colors.black
                                      ),
                                    )
                                ),
                                Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SizedBox(width: 10.0),
                                        Card(
                                          color: pourcentageBruteEntreprise > 0 ? Colors.greenAccent :
                                          Colors.red[100],
                                          child: Padding(
                                              padding: const EdgeInsets.all(2.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(pourcentageBruteEntreprise > 0 ?
                                                  Icons.trending_up : Icons.trending_flat_outlined,
                                                    color: Colors.black45,
                                                  ),
                                                  SizedBox(width: 10.0),
                                                  Text(
                                                    '+$pourcentageBruteEntreprise%',
                                                    style: TextStyle(
                                                      color: Colors.black45,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  )
                                                ],
                                              )
                                          ),
                                        )
                                      ],
                                    )
                                )
                              ],
                            ),
                            SizedBox(height: 10.0),
                            Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.only(left: 5.0),
                              child: Text('$entrepriseDuJour',
                                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)
                              ),
                            ),
                            Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.only(left: 5.0),
                              child: Text('Entreprise(s) / jour',
                                  style: TextStyle(fontSize: 13.0
                                  )
                              ),
                            ),
                            Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.only(left: 5.0),
                              child: Text('Total : ${entrepriseControllerX.data.length}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold
                                  )
                              ),
                            )
                          ],
                        );
                      }
                  )
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: EdgeInsets.only(left: 10.0, right: 10.0),
              width: (MediaQuery.of(context).size.width/2.0)-20,
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: GetBuilder<EnrolementPaiementController>(
                      builder: (enrolementPaiementControllerX){

                        enrolementDuJour = enrolementPaiementControllerX.data.where((d) =>
                        checkDateTime(DateTime.fromMillisecondsSinceEpoch(d.millisecondes),
                            DateTime.now()) == true && d.montant == 0).length;

                        enrolementDuJourDHier = enrolementPaiementControllerX.data.where((d) =>
                        checkDateTime(DateTime.fromMillisecondsSinceEpoch(d.millisecondes),
                            (DateTime.now()).subtract(Duration(days: 1))) == true && d.montant == 0).length;
                        int pourcentageBruteEnrolement = enrolementDuJourDHier > 0 ?
                        ((enrolementDuJour / enrolementDuJourDHier)*100).round() : 0;

                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Card(
                                    color: Colors.orange[100],
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: const Icon(
                                          Icons.fingerprint,
                                          size: 17,
                                          color: Colors.black
                                      ),
                                    )
                                ),
                                Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SizedBox(width: 10.0),
                                        Card(
                                          color: pourcentageBruteEnrolement > 0 ? Colors.greenAccent :
                                          Colors.red[100],
                                          child: Padding(
                                              padding: const EdgeInsets.all(2.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [

                                                  Icon(
                                                    pourcentageBruteEnrolement > 0 ? Icons.trending_up :
                                                    Icons.trending_flat_rounded,
                                                    color: Colors.black45,
                                                  ),
                                                  SizedBox(width: 10.0),
                                                  Text(
                                                    '+$pourcentageBruteEnrolement%',
                                                    style: TextStyle(
                                                      color: Colors.black45,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  )
                                                ],
                                              )
                                          ),
                                        )
                                      ],
                                    )
                                )
                              ],
                            ),
                            SizedBox(height: 10.0),
                            Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.only(left: 5.0),
                              child: Text('$enrolementDuJour',
                                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)
                              ),
                            ),
                            Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.only(left: 5.0),
                              child: Text('Enrôlement(s) / jour',
                                  style: TextStyle(fontSize: 13.0
                                  )
                              ),
                            ),
                            Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.only(left: 5.0),
                              child: Text('Total : ${enrolementPaiementControllerX.data.where((d) =>
                              d.montant == 0).length}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold
                                  )
                              ),
                            )
                          ],
                        );
                      }
                  )
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 10.0, right: 10.0),
              width: (MediaQuery.of(context).size.width/2.0)-20,
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: GetBuilder<EnrolementPaiementController>(
                      builder: (enrolementPaiementControllerX){

                        paiementDuJour = enrolementPaiementControllerX.data.where((d) =>
                        checkDateTime(DateTime.fromMillisecondsSinceEpoch(d.millisecondes),
                            DateTime.now()) == true && d.montant > 0).length;

                        paiementDuJourDHier = enrolementPaiementControllerX.data.where((d) =>
                        checkDateTime(DateTime.fromMillisecondsSinceEpoch(d.millisecondes),
                            (DateTime.now()).subtract(Duration(days: 1))) == true && d.montant > 0).length;
                        int pourcentageBrutePaiement = paiementDuJourDHier > 0 ?
                        ((paiementDuJour / paiementDuJourDHier)*100).round() : 0;

                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Card(
                                    color: Colors.blue[100],
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: const Icon(
                                          Icons.sticky_note_2_outlined,
                                          size: 17,
                                          color: Colors.black
                                      ),
                                    )
                                ),
                                Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SizedBox(width: 10.0),
                                        Card(
                                          color: pourcentageBrutePaiement > 0 ? Colors.greenAccent :
                                          Colors.red[100],
                                          child: Padding(
                                              padding: const EdgeInsets.all(2.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [

                                                  Icon(
                                                    pourcentageBrutePaiement > 0 ? Icons.trending_up :
                                                    Icons.trending_flat_rounded,
                                                    color: Colors.black45,
                                                  ),
                                                  SizedBox(width: 10.0),
                                                  Text(
                                                    '+$pourcentageBrutePaiement%',
                                                    style: TextStyle(
                                                      color: Colors.black45,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  )
                                                ],
                                              )
                                          ),
                                        )
                                      ],
                                    )
                                )
                              ],
                            ),
                            SizedBox(height: 10.0),
                            Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.only(left: 5.0),
                              child: Text('$paiementDuJour',
                                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)
                              ),
                            ),
                            Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.only(left: 5.0),
                              child: Text('Paiement(s) / jour',
                                  style: TextStyle(fontSize: 13.0
                                  )
                              ),
                            ),
                            Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.only(left: 5.0),
                              child: Text('Total : ${enrolementPaiementControllerX.data.where((d) =>
                              d.montant > 0).length}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold
                                  ))
                            )
                          ],
                        );
                      }
                  )
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}