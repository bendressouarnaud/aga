import 'package:cnmci/konan/model/artisan.dart';
import 'package:cnmci/konan/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:money_formatter/money_formatter.dart';

import '../getxcontroller/artisan_controller_x.dart';
import '../main.dart';
import 'beans/daily_payment_bean.dart';
import 'interface_view_artisan.dart';
import 'objets/constants.dart';

class InterfaceHistoriqueArtisanStatut extends StatefulWidget {
  const InterfaceHistoriqueArtisanStatut({super.key});

  @override
  State<InterfaceHistoriqueArtisanStatut> createState() => _InterfaceHistoriqueArtisanStatut();
}

class _InterfaceHistoriqueArtisanStatut extends State<InterfaceHistoriqueArtisanStatut> {

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
  //
  bool requestToSearch = false;
  final TextEditingController _textController = TextEditingController();
  List<Artisan> listeAucunPaiement = [];
  List<Artisan> listeAucunPaiementCopie = [];
  List<Artisan> _filteredList = [];
  //late List<StatsBeanManager> _filteredList;



  // METHODS :
  String formatValue(int price) {
    MoneyFormatter fmf = MoneyFormatter(amount: price.toDouble());
    //
    return fmf.output.withoutFractionDigits;
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

  Widget getPaiementFiltered(int status) {
    return GetBuilder<ArtisanControllerX>(
        builder: (ArtisanControllerX controller)
    {
      listeAucunPaiement = !requestToSearch ?
        controller.data.where((a) => a.statut_paiement == status).toList() :
        listeAucunPaiementCopie;
      return listeAucunPaiement.isNotEmpty ?
      SingleChildScrollView(
          child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: listeAucunPaiement.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                          // Update this :
                          artisanToManage = listeAucunPaiement[index];
                          return InterfaceViewArtisan();
                        })
                    );
                  },
                  child: Card(
                    color: Colors.brown[50],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: GestureDetector(
                      /*onTap: (){

                            },*/
                      child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Container(
                                  margin: EdgeInsets.only(right: 10, left: 10),
                                  alignment: Alignment.topLeft,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween,
                                    children: [
                                      Text(MesServices().processEntityName(
                                          '${listeAucunPaiement[index]
                                              .nom} ${listeAucunPaiement[index]
                                              .prenom}',
                                          limitCharacterHisto),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold
                                        ),
                                      ),
                                      Text(listeAucunPaiement[index]
                                          .date_creation)
                                    ],
                                  )
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                    right: 10, left: 10, top: 5),
                                alignment: Alignment.topLeft,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceBetween,
                                  children: [
                                    Text(listeAucunPaiement[index].contact1),
                                    Text(listeAucunPaiement[index]
                                        .statut_paiement == 0 ? 'Non payé' :
                                    listeAucunPaiement[index].statut_paiement ==
                                        1 ? 'En cours' : 'Payé',
                                      style: TextStyle(
                                          color: listeAucunPaiement[index]
                                              .statut_paiement == 0
                                              ? Colors.red
                                              :
                                          listeAucunPaiement[index]
                                              .statut_paiement == 1 ? Colors
                                              .blueGrey : Colors.green,
                                          fontWeight: FontWeight.bold
                                      ),)
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                    right: 10, left: 10, top: 5),
                                alignment: Alignment.topLeft,
                                child: Divider(
                                  height: 3,
                                  color: Colors.black,
                                ),
                              ),
                              Container(
                                  margin: EdgeInsets.only(
                                      right: 10, left: 10, top: 5),
                                  alignment: Alignment.topLeft,
                                  child: Text.rich(
                                    TextSpan(
                                        text: 'Métier : ',
                                        //style: TextStyle(fontWeight: FontWeight.bold),
                                        children: <TextSpan>[
                                          TextSpan(text: MesServices()
                                              .processEntityName(
                                              lesMetiers
                                                  .where((m) =>
                                              m.id == listeAucunPaiement[index]
                                                  .activite_principale)
                                                  .first
                                                  .libelle,
                                              limitCharacterMetier),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)
                                          )
                                        ]
                                    ),
                                  )
                              ),
                              Container(
                                  margin: EdgeInsets.only(
                                      right: 10, left: 10, top: 5),
                                  alignment: Alignment.topLeft,
                                  child: Text.rich(
                                    TextSpan(
                                        text: 'Nationalité : ',
                                        //style: TextStyle(fontWeight: FontWeight.bold),
                                        children: <TextSpan>[
                                          TextSpan(text: lesPays
                                              .where((p) =>
                                          p.id == listeAucunPaiement[index]
                                              .nationalite)
                                              .first
                                              .libelle,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)
                                          )
                                        ]
                                    ),
                                  )
                              ),
                              Container(
                                  margin: EdgeInsets.only(
                                      right: 10, left: 10, top: 5),
                                  alignment: Alignment.topLeft,
                                  child: Text.rich(
                                    TextSpan(
                                        text: 'Commune résid. : ',
                                        children: <TextSpan>[
                                          TextSpan(text: lesCommunes
                                              .where((c) =>
                                          c.id == listeAucunPaiement[index]
                                              .commune_residence)
                                              .first
                                              .libelle,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)
                                          )
                                        ]
                                    ),
                                  )
                              )
                            ],
                          )

                        /*Row(
                                  children: [
                                    SizedBox(
                                      height: 120,
                                      width: 90,
                                      child: MesServices().displayFromLocalOrFirebase(controller.data[index].photo_artisan),
                                    ),
                                    Expanded(

                                    )
                                  ],
                                ),*/
                      ),
                    ),
                  ),
                );
              }
          )
      ) :
      Center(
        child: Text('Aucune donnée'),
      );
    });
    //return listeAucunPaiement;
  }

  void _filterLogListBySearchText(String searchText) {
    setState(() {
      listeAucunPaiementCopie = _filteredList
          .where(
              (data) => data.nom.toLowerCase().contains(searchText.trim().toLowerCase()) ||
              data.prenom.toLowerCase().contains(searchText.trim().toLowerCase()) ||
              data.contact1.contains(searchText.trim())
              // || data.metier.toLowerCase().contains(searchText.trim().toLowerCase()) ||
              //data.type.toLowerCase().contains(searchText.trim().toLowerCase())
      ).toList();
    });
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
            onDestinationSelected: (int index) {
              setState(() {
                requestToSearch = false;
                currentPageIndex = index;
              });
            },
            selectedIndex: currentPageIndex,
            destinations:[
              NavigationDestination(
                selectedIcon: Icon(Icons.dangerous_outlined), //Icon(Icons.announcement),
                icon: Icon(Icons.dangerous),//Icon(Icons.announcement_outlined),
                label: 'Aucun',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.money_sharp), //Icon(Icons.announcement),
                icon: Icon(Icons.money),//Icon(Icons.announcement_outlined),
                label: 'Paiement en cours',
              )
            ]
        ),
      appBar: AppBar(
        title: !requestToSearch ? Text(
          "Statut Paiement",
          textAlign: TextAlign.center,
        ) : Container(
          height: 40,
          decoration: BoxDecoration(
              color: const Color(0xffF5F5F5),
              borderRadius: BorderRadius.circular(5)),
          child: TextField(
            controller: _textController,
            decoration: InputDecoration(
              prefixIcon: IconButton(
                icon: Icon(
                  Icons.search_rounded,
                  color: Theme.of(context).primaryColorDark,
                ),
                onPressed: () => FocusScope.of(context).unfocus(),
              ),
              suffixIcon: IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: Theme.of(context).primaryColorDark,
                  ),
                  onPressed: () {
                    setState(() {
                      _textController.text = "";
                      _filterLogListBySearchText("");
                      requestToSearch = false;
                    });
                  }),
              hintText: 'Recherche...',
              border: InputBorder.none,
            ),
            onChanged: (value) => _filterLogListBySearchText(value),
            onSubmitted: (value) => _filterLogListBySearchText(value),
          ),
        ),
          actions: [
            Visibility(
                visible: !requestToSearch,
                child: IconButton(
                    onPressed: () {
                      setState(() {
                        _filteredList = listeAucunPaiement;
                        listeAucunPaiementCopie = listeAucunPaiement;
                        requestToSearch = true;
                      });
                    },
                    icon: const Icon(Icons.search, color: Colors.black)
                )
            )
          ]
      ),

      body: <Widget>[
        getPaiementFiltered(0),
        getPaiementFiltered(1)
      ][currentPageIndex]
    );

  }

}