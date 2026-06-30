import 'package:cnmci/konan/repositories/parametre_repository.dart';
import 'package:flutter/material.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';

import '../main.dart';
import 'model/parametre.dart';

class InterfaceParametre extends StatefulWidget {
  final Parametre? parametre;
  const InterfaceParametre({super.key, this.parametre});

  @override
  State<InterfaceParametre> createState() => _InterfaceParametre();
}

class _InterfaceParametre extends State<InterfaceParametre> {

  // ATTRIBUTES :
  final parametreRepository = ParametreRepository();
  int offlineStatus = 0;


  // METHODS :
  @override
  void initState() {
    super.initState();
    offlineStatus = widget.parametre != null ? widget.parametre!.param1 : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: Colors.white,
            centerTitle: true,
            title: Text('Paramètres')
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(left: 15, right: 15, top: 20),
                child: Text('Mode Offline',
                  style: TextStyle(
                    fontSize: 19
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 15, right: 15, top: 10),
                child: LiteRollingSwitch(
                  //initial value
                  width: 200,
                    value: widget.parametre != null ? widget.parametre?.param1 == 0 ? false : true : true,
                    textOn: 'Activé',
                    textOff: 'Désactivé',
                    colorOn: Colors.green,
                    colorOff: Colors.red,
                    iconOn: Icons.wifi,
                    iconOff: Icons.wifi_off,
                    textSize: 15.0,
                    onChanged: (bool state) {
                      //Use it to manage the different states
                      offlineStatus = state ? 1 : 0;
                    },
                    onTap: () {
                      // Nothing :
                    },
                    onDoubleTap: () {
                      // Nothing :
                    },
                    onSwipe: (){

                    }
                )
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                margin: EdgeInsets.only(left: 15, right: 15, top: 20),
                child: Divider(
                  height: 3,
                ),
              )
            ],
          ),
        ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () async {
          if(widget.parametre == null){
            // Insert :
            Parametre newParam = Parametre(id: 1,
                topicSubscription: 1, param1: offlineStatus, param2: 0, param3: '');
            outil.insertParameter(newParam);
          }
          else{
            Parametre updateParam = Parametre(id: 1,
                topicSubscription: widget.parametre!.topicSubscription,
                param1: offlineStatus,
                param2: widget.parametre!.param2,
                param3: widget.parametre!.param3);
            outil.updateParameter(updateParam);
          }
          // Leave
          Navigator.pop(context);
        },
        backgroundColor: Colors.blue,
        tooltip: 'Enregistrer',
        child: Icon(Icons.save,
          color: Colors.white,
        ),
      ),
    );
  }

}
