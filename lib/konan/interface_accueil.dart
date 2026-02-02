import 'dart:async';
import 'dart:convert';

import 'package:cnmci/konan/historique/historique_apprenti.dart';
import 'package:cnmci/konan/historique/historique_compagnon.dart';
import 'package:cnmci/konan/historique/historique_entreprise.dart';
import 'package:cnmci/konan/search_entity.dart';
import 'package:cnmci/konan/widget_accueil.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:http/http.dart';

import '../getxcontroller/internet_access_controller_x.dart';
import '../main.dart';
import 'historique/historique_artisan.dart';
import 'interface_controle_manager.dart';

class InterfaceAccueil extends StatefulWidget {
  const InterfaceAccueil({Key? key}) : super(key: key);

  @override
  State<InterfaceAccueil> createState() => _InterfaceAccueil();
}

class _InterfaceAccueil extends State<InterfaceAccueil> {

  // A t t r i b u t e s  :
  int currentPageIndex = 0;


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    // Dispose of the controller when the widget is disposed.
    artisanControllerX.dispose();
    apprentiControllerX.dispose();
    compagnonControllerX.dispose();
    entrepriseControllerX.dispose();
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
                selectedIcon: Icon(Icons.home), //Icon(Icons.announcement),
                icon: Icon(Icons.home_outlined),//Icon(Icons.announcement_outlined),
                label: 'Accueil',
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
          backgroundColor: Colors.white,
          title: const Text(
            "Accueil",
            textAlign: TextAlign.left,
          ),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              )
          ),
          actions: [
            Visibility(
                visible: globalUser!.profil == "ROLE_ADMINISTRATEUR_CONTROLE_MANAGER" ||
                    globalUser!.profil == "ROLE_SUPER_ADMIN" ||
                    globalUser!.profil == "ROLE_AGENT_CONTROLE_ASSERMENTE",
                child: IconButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                            return InterfaceControleManager();
                          })
                      );
                    },
                    icon: const Icon(Icons.manage_accounts, color: Colors.black)
                )
            ),
            Visibility(
              visible: currentPageIndex > 0,
                child: IconButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                            return SearchEntity(screen: currentPageIndex,);
                          })
                      );
                    },
                    icon: const Icon(Icons.search, color: Colors.black)
                )
            )
          ],
        ),
      body: <Widget>[
        WidgetAccueil(),
        HistoriqueArtisan(),
        HistoriqueApprenti(),
        HistoriqueCompagnon(),
        HistoriqueEntreprise()
      ][currentPageIndex]
    );
  }
}
