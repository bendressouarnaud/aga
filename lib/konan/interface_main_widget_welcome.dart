import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:intl/intl.dart';

import '../getxcontroller/enrolement_paiement_controller_x.dart';

class InterfaceMainWidgetWelcome extends StatelessWidget {
  InterfaceMainWidgetWelcome({super.key});

  int encaissementDuJour = 0;
  int encaissementDuJourDHier = 0;
  int encaissementObjectif = 100000;

  // This widget is the root of your application.
  bool checkDateTime(DateTime currentDateTime, DateTime fromDatabase){
    return currentDateTime.year == fromDatabase.year &&
        currentDateTime.month == fromDatabase.month &&
        currentDateTime.day == fromDatabase.day;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
      child: Card(
        color: Colors.blue[900],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GetBuilder<EnrolementPaiementController>(
              builder: (enrolementPaiementControllerX){

                var listeDuJour = (enrolementPaiementControllerX.data.where((d) =>
                checkDateTime(DateTime.fromMillisecondsSinceEpoch(d.millisecondes),
                    DateTime.now()) == true && d.montant > 0)
                    .map((e) => e.montant).toList());
                encaissementDuJour = listeDuJour.isNotEmpty ? listeDuJour.reduce((a, b) => a + b) : 0;

                var listeDuJourHier = (enrolementPaiementControllerX.data.where((d) =>
                checkDateTime(DateTime.fromMillisecondsSinceEpoch(d.millisecondes),
                    (DateTime.now()).subtract(Duration(days: 1))) == true && d.montant > 0)
                    .map((e) => e.montant).toList());
                encaissementDuJourDHier = listeDuJourHier.isNotEmpty ? listeDuJourHier.reduce((a, b) => a + b) : 0;

                int pourcentageBrutePaiement = encaissementDuJourDHier > 0 ?
                ((encaissementDuJour / encaissementDuJourDHier)*100).round() : 0;

                double bruteObjectif = encaissementObjectif > 0 ?
                (encaissementDuJour*1.0 / encaissementObjectif) : 0.0;
                int pourcentageBruteObjectif = encaissementObjectif > 0 ?
                (bruteObjectif*100).round() : 0;

                final currencyFormat = NumberFormat.currency(
                  locale: 'fr_FR',
                  symbol: '',
                  decimalDigits: 0,
                );

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Card(
                            color: Colors.black12,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: const Icon(
                                  Icons.payments_rounded,
                                  color: Colors.white
                              ),
                            )
                        ),

                        const SizedBox(width: 3.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total encaissé aujourd\'hui',
                              style: TextStyle(
                                color: Colors.blue[200],
                                fontSize: 11.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Montant encaissé',
                              style: TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 11.0,
                              ),
                            ),
                          ],
                        ),
                        //const SizedBox(width: 3.0),
                        Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(width: 10.0),
                                Card(
                                  color: pourcentageBrutePaiement > 0 ? Colors.greenAccent :
                                  Colors.red[100],
                                  child: Padding(
                                      padding: const EdgeInsets.all(4.0),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 6.0, height: 40,),
                        Text.rich(
                          TextSpan(
                            text: currencyFormat.format(encaissementDuJour),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 20.0,
                            ),

                            children: [
                              TextSpan(
                                text: ' FCFA',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[200],
                                  fontSize: 12.0,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    Container(
                      padding: EdgeInsets.only(left: 10.0, right: 10.0),
                      child: LinearProgressIndicator(
                        value: bruteObjectif,
                        backgroundColor: Colors.blue[800],
                        color: Colors.greenAccent,
                      ),
                    ),
                    Container(
                        padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Objectif quotidien : 100 000 FCFA',
                              style: TextStyle(
                                color: Colors.blue[100],
                                fontSize: 12.0,
                              ),
                            ),
                            Text(
                              '$pourcentageBruteObjectif% atteint',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.0,
                              ),
                            )
                          ],
                        )
                    )
                  ],
                );
              }
          )
        ),
      ),
    );
  }
}