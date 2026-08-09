import 'package:cnmci/getxcontroller/action_terrain_controller_x.dart';
import 'package:cnmci/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'beans/proces_verbal_hisory_data.dart';
import 'interface_action_terrain.dart';

class InterfaceHistoryProcesVerbal extends StatelessWidget{
  final List<ProcesVerbalHisoryData> listeHistoPvData;
  InterfaceHistoryProcesVerbal({super.key, required this.listeHistoPvData});


  // A t t r i b u t e s  :



  // M E T H O D S :
  Widget getData() {
    return SingleChildScrollView(
        child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: listeHistoPvData.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  /*Navigator.push(context,
                      MaterialPageRoute(builder: (context) {
                        return InterfaceActionTerrain(lActionTerrain: controller.data[index]);
                      }
                      )
                  );*/
                },
                child: Card(
                  color: Colors.brown[50],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: GestureDetector(
                    child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Container(
                                margin: EdgeInsets.only(right: 10, left: 10),
                                alignment: Alignment.topLeft,
                                child: Row(
                                  children: [
                                    Text('Agent : '),
                                    Text(listeHistoPvData[index].agent,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold
                                      ),
                                    )
                                  ],
                                )
                            ),
                            Container(
                                margin: EdgeInsets.only(right: 10, left: 10),
                                alignment: Alignment.topLeft,
                                child: Row(
                                  children: [
                                    Text('Date PV : '),
                                    Text(listeHistoPvData[index].datePv,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold
                                      ),
                                    )
                                  ],
                                )
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
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text('Date Règlement : '),
                                    Text(listeHistoPvData[index].datePv,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        color: Colors.blue
                                      ),
                                    )
                                  ],
                                )
                            ),
                          ],
                        )
                    ),
                  ),
                ),
              );
            }
        )
    );
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Historique PV'),
      ),
        body: getData(),
    );

  }

}