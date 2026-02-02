import 'dart:convert';

import 'package:cnmci/konan/interface_compagnon_personne.dart';
import 'package:cnmci/konan/model/compagnon.dart';
import 'package:cnmci/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../getxcontroller/compagnon_controller_x.dart';
import '../interface_view_compagnon.dart';
import '../model/artisan.dart';
import '../model/entreprise.dart';
import '../objets/constants.dart';
import '../services.dart';

class HistoriqueCompagnon extends StatefulWidget {
  final Artisan? artisan;
  final Entreprise? entreprise;
  const HistoriqueCompagnon({super.key, this.artisan, this.entreprise});

  @override
  State<HistoriqueCompagnon> createState() => _HistoriqueCompagnon();
}

class _HistoriqueCompagnon extends State<HistoriqueCompagnon> {

  // ATTRIBUTES :
  final CompagnonControllerX _compagnonControllerX = Get.put(CompagnonControllerX());
  late BuildContext dialogContext;


  // METHODS :
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      /*appBar: widget.artisan != null ? AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text('Historique Compagnon'
          )
      ): AppBar(backgroundColor: Colors.white),*/
      floatingActionButton: (widget.artisan != null || widget.entreprise != null) ?
      FloatingActionButton.extended(
        onPressed: () async {
          // Send DATA :
          final result = await Navigator.push(context,
              MaterialPageRoute(builder: (context) {
                return InterfaceCompagnonPersonne(artisanId: widget.artisan != null ? widget.artisan!.id : 0,
                entrepriseId: widget.entreprise != null ? widget.entreprise!.id : 0,
                );
              })
          );
        },
        backgroundColor: Colors.brown,
        tooltip: 'Continuer',
        label: Text('Nouveau',
          style: const TextStyle(
              color: Colors.white
          ),
        ),
        icon: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ) :
      SizedBox(),
      body: returnList(),
    );
  }

  List<Compagnon> getList(List<Compagnon> data){
    if(widget.artisan != null){
      return data.where((a) => a.artisan_id == widget.artisan!.id).toList();
    }
    else if(widget.entreprise != null){
      return data.where((a) => a.entreprise_id == widget.entreprise!.id).toList();
    }
    else{
      return data;
    }
  }

  Widget returnList(){
    return GetBuilder<CompagnonControllerX>(
        builder: (CompagnonControllerX controller){

          // Filter :
          List<Compagnon> tampon = getList(controller.data);
          // Reduce :
          var currentData = tampon.isNotEmpty ? tampon.length > 10 ?
          tampon.sublist(0, 9) : tampon : [];

          return currentData.isNotEmpty ?
          SingleChildScrollView(
            child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: currentData.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                            return InterfaceViewCompagnon(compagnon: currentData[index]);
                          })
                      );
                    },
                    child: Card(
                      color: Colors.brown[50],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(MesServices().processEntityName('${currentData[index].nom} ${currentData[index].prenom}', limitCharacterHisto),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold
                                        ),
                                      ),
                                      Text(currentData[index].date_debut_compagnonnage)
                                    ],
                                  )
                              ),
                              Container(
                                margin: EdgeInsets.only(right: 10, left: 10, top: 5),
                                alignment: Alignment.topLeft,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(currentData[index].contact1),
                                    Text(currentData[index].statut_paiement == 0 ? 'Non payé' :
                                    currentData[index].statut_paiement == 1 ? 'En cours' : 'Payé',
                                      style: TextStyle(
                                          color: currentData[index].statut_paiement == 0 ? Colors.red :
                                          currentData[index].statut_paiement == 1 ? Colors.blueGrey : Colors.green,
                                          fontWeight: FontWeight.bold
                                      ),)
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(right: 10, left: 10, top: 5),
                                alignment: Alignment.topLeft,
                                child: Divider(
                                  height: 3,
                                  color: Colors.black,
                                ),
                              ),
                              Container(
                                  margin: EdgeInsets.only(right: 10, left: 10, top: 5),
                                  alignment: Alignment.topLeft,
                                  child: Text.rich(
                                    TextSpan(
                                        text: 'Métier : ',
                                        //style: TextStyle(fontWeight: FontWeight.bold),
                                        children: <TextSpan>[
                                          TextSpan(text: MesServices().processEntityName(
                                              lesMetiers.where((m) => m.id == currentData[index].specialite).first.libelle,
                                              limitCharacterMetier),
                                              style: TextStyle(fontWeight: FontWeight.bold)
                                          )
                                        ]
                                    ),
                                  )
                              ),
                              Container(
                                  margin: EdgeInsets.only(right: 10, left: 10, top: 5),
                                  alignment: Alignment.topLeft,
                                  child: Text.rich(
                                    TextSpan(
                                        text: 'Nationalité : ',
                                        //style: TextStyle(fontWeight: FontWeight.bold),
                                        children: <TextSpan>[
                                          TextSpan(text: lesPays.where((p) => p.id == currentData[index].nationalite).first.libelle,
                                              style: TextStyle(fontWeight: FontWeight.bold)
                                          )
                                        ]
                                    ),
                                  )
                              ),
                              Container(
                                  margin: EdgeInsets.only(right: 10, left: 10, top: 5),
                                  alignment: Alignment.topLeft,
                                  child: Text.rich(
                                    TextSpan(
                                        text: 'Commune résid. : ',
                                        children: <TextSpan>[
                                          TextSpan(text: lesCommunes.where((c) => c.id == currentData[index].commune_residence).first.libelle,
                                              style: TextStyle(fontWeight: FontWeight.bold)
                                          )
                                        ]
                                    ),
                                  )
                              )
                            ],
                          )
                        ),
                      ),
                    ),
                  );
                }
            ),
          ) :
          Container(
            margin: const EdgeInsets.all(10),
            child: Center(
              child: Text('Aucun Compagnon',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold)
              ),
            ),
          );
        }
    );
  }
}
