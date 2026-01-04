import 'dart:convert';

import 'package:cnmci/konan/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:money_formatter/money_formatter.dart';

import 'beans/stats_bean.dart';
import 'objets/constants.dart';

class InterfaceControleManager extends StatefulWidget {
  const InterfaceControleManager({super.key});

  @override
  State<InterfaceControleManager> createState() => _InterfaceControleManager();
}

class _InterfaceControleManager extends State<InterfaceControleManager> {

  // A t t r i b u t e s  :
  int currentPageIndex = 0;

  // METHODS :
  String formatValue(int price) {
    MoneyFormatter fmf = MoneyFormatter(amount: price.toDouble());
    //
    return fmf.output.withoutFractionDigits;
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
                label: 'Stats',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.person), //Icon(Icons.announcement),
                icon: Icon(Icons.person_outline),//Icon(Icons.announcement_outlined),
                label: 'Art',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.people_alt), //Icon(Icons.announcement),
                icon: Icon(Icons.people_alt_outlined),//Icon(Icons.announcement_outlined),
                label: 'App',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.people_outline_outlined), //Icon(Icons.announcement),
                icon: Icon(Icons.people_outline),//Icon(Icons.announcement_outlined),
                label: 'Com',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.desk), //Icon(Icons.announcement),
                icon: Icon(Icons.desk_outlined),//Icon(Icons.announcement_outlined),
                label: 'Ent',
              )
            ]
        ),
      appBar: AppBar(
        title: const Text(
          "Statistiques",
          textAlign: TextAlign.left,
        ),
      ),

      body: FutureBuilder(
        future: Future.wait([getStatsBean()]),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot){
          if(snapshot.connectionState == ConnectionState.done && snapshot.hasData){
            // Process DATA from there :
            List<StatsBean> pickedData = snapshot.data[0];
            return SingleChildScrollView(
              child: ListView.builder(
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
            );
          }
          else{
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        })
    );

  }

}