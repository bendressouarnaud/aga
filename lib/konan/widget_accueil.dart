import 'dart:convert';

import 'package:cnmci/getxcontroller/apprenti_controller_x.dart';
import 'package:cnmci/getxcontroller/artisan_controller_x.dart';
import 'package:cnmci/getxcontroller/compagnon_controller_x.dart';
import 'package:cnmci/getxcontroller/entreprise_controller_x.dart';
import 'package:cnmci/konan/interface_main_widget_feature.dart';
import 'package:cnmci/konan/interface_main_widget_last_operation.dart';
import 'package:cnmci/konan/interface_main_widget_welcome.dart';
import 'package:cnmci/konan/repositories/user_repository.dart';
import 'package:cnmci/konan/services.dart';
import 'package:cnmci/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';

import 'model/user.dart';
import 'objets/constants.dart';

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

  /*Future<int> getAppropriateCrmId() async {
    if(globalUser!.crm == -1) {
      try {
        var localToken = await MesServices().checkJwtExpiration();
        final url = Uri.parse(
            '${dotenv.env['URL_BACKEND']}get-appropriate-crm');
        var response = await get(url,
            headers: {
              "Content-Type": "application/json",
              'Authorization': 'Bearer $localToken'
            }
        ).timeout(const Duration(seconds: timeOutValue));
        if (response.statusCode == 200) {
          var userCrmId = int.parse(response.body);
          User user = User(
              id: globalUser!.id,
              nom: globalUser!.nom,
              email: globalUser!.email,
              pwd: globalUser!.pwd,
              jwt: globalUser!.jwt,
              profil: globalUser!.profil,
              milliseconds: globalUser!.milliseconds,
              crm: userCrmId
          );
          // Refresh :
          globalUser = user;
          // Persist :
          var userRepository = UserRepository();
          userRepository.update(user);
          return 0;
        } else {
          // Server UNAVAILABLE :
          return -1;
        }
      }
      catch (e) {
        return -1;
      }
    }
    else{
      return globalUser!.crm;
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Réacutaliser :
          artisanControllerX.cleanAndRefreshData();
          apprentiControllerX.cleanAndRefreshData();
          compagnonControllerX.cleanAndRefreshData();
          entrepriseControllerX.cleanAndRefreshData();
        },
        backgroundColor: Colors.blue,
        tooltip: 'Continuer',
        label: Text('Rafraîchir',
          style: const TextStyle(
              color: Colors.white
          ),
        ),
        icon: const Icon(
          Icons.sync,
          color: Colors.white,
        ),
      ),*/
      body: SingleChildScrollView(
          child: Column(
            children: [
              InterfaceMainWidgetWelcome(),
              InterfaceMainWidgetFeature(),
              InterfaceMainWidgetLastOperation()
            ],
          )
      )
    );
  }

}