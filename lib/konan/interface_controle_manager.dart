import 'dart:convert';

import 'package:cnmci/konan/search_entity_manager.dart';
import 'package:cnmci/konan/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:money_formatter/money_formatter.dart';

import 'beans/daily_payment_bean.dart';
import 'beans/stats_bean.dart';
import 'interface_controle_sermente.dart';
import 'objets/constants.dart';

class InterfaceControleManager extends StatefulWidget {
  const InterfaceControleManager({super.key});

  @override
  State<InterfaceControleManager> createState() => _InterfaceControleManager();
}

class _InterfaceControleManager extends State<InterfaceControleManager> {

  // A t t r i b u t e s  :
  int currentPageIndex = 0;
  List<Color> gradientColors = [
    Colors.cyan,
    Colors.blue
  ];
  late List<DailyPaymentBean> pickedDailyPayment;
  double maxAmount = 0.0;
  double tranche = 0;
  String maxAmountString ='';
  String tranche1 ='';
  String tranche2 ='';


  // METHODS :
  String formatValue(int price) {
    MoneyFormatter fmf = MoneyFormatter(amount: price.toDouble());
    //
    return fmf.output.withoutFractionDigits;
  }

  Future<List<DailyPaymentBean>> getDailyPayment() async {
    List<DailyPaymentBean> data = [];
    try{
      var localToken = await MesServices().checkJwtExpiration();
      final url = Uri.parse('${dotenv.env['URL_BACKEND_STAT']}get-daily-payment');
      var response = await get(url,
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer $localToken'
          }
      ).timeout(const Duration(seconds: timeOutValue));
      if(response.statusCode == 200){
        final List result = json.decode(response.body);
        data = result.map((e) => DailyPaymentBean.fromJson(e)).toList();
      }
    }
    catch(e){
      // Nothing to do :
      //print('Erreur : ${e.toString()}');
    }
    return data;
  }

  Future<List<StatsBean>> getStatsBean() async {
    List<StatsBean> data = [];
    try{
      var localToken = await MesServices().checkJwtExpiration();
      final url = Uri.parse('${dotenv.env['URL_BACKEND_STAT']}get-entities-stats');
      var response = await get(url,
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer $localToken'
          }
      ).timeout(const Duration(seconds: timeOutValue));
      if(response.statusCode == 200){
        final List result = json.decode(response.body);
        data = result.map((e) => StatsBean.fromJson(e)).toList();
      }
    }
    catch(e){
      // Nothing to do :
    }
    return data;
  }

  Icon getAppropriateIcon(String libelle){
    switch(libelle){
      case 'Artisans':
        return Icon(Icons.person,
          color: Colors.deepOrange,
        );

      case 'Apprentis':
        return Icon(Icons.people_alt,
          color: Colors.brown,
        );

      case 'Compagnons':
        return Icon(Icons.people_outline_outlined,
          color: Colors.blue,
        );

      default:
        return Icon(Icons.location_city,
          color: Colors.green,
        );
    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
        bottomNavigationBar: NavigationBar(
            indicatorShape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                )),
            onDestinationSelected: (int index) async {
              setState(() {
                currentPageIndex = index;
              });
            },
            selectedIndex: currentPageIndex,
            destinations:[
              NavigationDestination(
                selectedIcon: Icon(Icons.show_chart), //Icon(Icons.announcement),
                icon: Icon(Icons.show_chart_outlined),//Icon(Icons.announcement_outlined),
                label: 'Statistiques',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.checklist_outlined), //Icon(Icons.announcement),
                icon: Icon(Icons.checklist_rounded),//Icon(Icons.announcement_outlined),
                label: 'Contrôle',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.person_search_sharp), //Icon(Icons.announcement),
                icon: Icon(Icons.person_search_outlined),//Icon(Icons.announcement_outlined),
                label: 'Recherche',
              )
            ]
        ),
      appBar: AppBar(
        title: const Text(
          "Statistiques",
          textAlign: TextAlign.left,
        ),
      ),

      body: <Widget>[
        FutureBuilder(
          future: Future.wait([getStatsBean(), getDailyPayment()]),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot){
            if(snapshot.connectionState == ConnectionState.done && snapshot.hasData){
              // Process DATA from there :
              List<StatsBean> pickedData = snapshot.data[0];
              // Daily PAYMENT :
              pickedDailyPayment = snapshot.data[1];
              var listeTamp = pickedDailyPayment.map((p) => p.total).toList();
              listeTamp.sort();
              maxAmount = listeTamp.last;
              tranche = (maxAmount / 3);
              maxAmountString = (maxAmount * 100).toString();

              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 30,
                    ),
                    Text('Progression des paiements (10K)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                      fontSize: 16
                    ),),
                    AspectRatio(
                      aspectRatio: 1.70,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          right: 18,
                          left: 12,
                          top: 24,
                          bottom: 12,
                        ),
                        child: LineChart(
                            mainData()
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Text('Résumé des statistiques',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                          fontSize: 16
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: pickedData.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            width: MediaQuery.of(context).size.width ,
                            padding: EdgeInsets.all(7),
                            margin: EdgeInsets.all(7),
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8.0)
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(pickedData[index].libelle,
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(formatValue(pickedData[index].population),
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold
                                            )),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        getAppropriateIcon(pickedData[index].libelle)
                                      ],
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Frais attendus',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold
                                      ),),
                                    Text('${formatValue(pickedData[index].attendu)} f',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold
                                        )),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Frais réglés',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold
                                      ),),
                                    Text('${formatValue(pickedData[index].paye)} f',
                                        style: TextStyle(
                                            fontSize: 18,
                                            //fontWeight: FontWeight.bold,
                                            color: Colors.red
                                        )),
                                  ],
                                ),
                                Divider(
                                  height: 7,
                                  color: Colors.brown,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Taux recouvrement',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold
                                      ),),
                                    Row(
                                      children: [
                                        Text('${pickedData[index].pourcentage} %'),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Icon( pickedData[index].pourcentage < 50 ?
                                        Icons.show_chart : Icons.stacked_line_chart,
                                          color: pickedData[index].pourcentage < 50 ?
                                          Colors.red : Colors.green,
                                        )
                                      ],
                                    )
                                  ],
                                )
                              ],
                            ),
                          );
                        }
                    )
                  ],
                )
              );
            }
            else{
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }
        ),
        InterfaceControleSermente(),
        SearchEntityManager()
      ][currentPageIndex]
    );

  }


  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Colors.blueGrey,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Colors.green,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: [
            FlSpot(0, pickedDailyPayment[6].total),
            FlSpot(2, pickedDailyPayment[5].total),
            FlSpot(4, pickedDailyPayment[4].total),
            FlSpot(6, pickedDailyPayment[3].total),
            FlSpot(8, pickedDailyPayment[2].total),
            FlSpot(10, pickedDailyPayment[1].total),
            FlSpot(11, pickedDailyPayment[0].total),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withValues(alpha: 0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    String text = switch (value.toInt()) {
      0 => pickedDailyPayment[6].day,
      //2 => pickedDailyPayment[5].day,
      4 => pickedDailyPayment[4].day,
      //6 => pickedDailyPayment[3].day,
      8 => pickedDailyPayment[2].day,
      //10 => pickedDailyPayment[1].day,
      11 => pickedDailyPayment[0].day,
      // TODO: Handle this case.
      int() => ''
    };
    return SideTitleWidget(
      meta: meta,
      child: Text(text, style: style),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    String text = switch (value.toInt()) {
      1 => tranche.toStringAsFixed(1),
      3 => (tranche * 2).toStringAsFixed(1),
      5 => '$maxAmount',
      _ => '',
    };

    return Text(text, style: style, textAlign: TextAlign.left);
  }

}