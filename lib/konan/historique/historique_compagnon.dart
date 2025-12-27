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

          return tampon.isNotEmpty ?
          SingleChildScrollView(
            child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: tampon.length, //listeChat.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                            return InterfaceViewCompagnon(compagnon: tampon[index]);
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
                          child: Row(
                            children: [
                              SizedBox(
                                height: 120,
                                width: 90,
                                child: MesServices().displayFromLocalOrFirebase(tampon[index].photo),
                              ),
                              Expanded(
                                  child: Column(
                                    children: [
                                      Container(
                                          margin: EdgeInsets.only(right: 10, left: 10),
                                          alignment: Alignment.topLeft,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(MesServices().processEntityName('${tampon[index].nom} ${tampon[index].prenom}', limitCharacter),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold
                                                ),
                                              ),
                                              Text(tampon[index].date_debut_compagnonnage)
                                            ],
                                          )
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(right: 10, left: 10, top: 5),
                                        alignment: Alignment.topLeft,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(tampon[index].contact1),
                                            Text(tampon[index].statut_paiement == 0 ? 'Non payé' :
                                            tampon[index].statut_paiement == 1 ? 'En cours' : 'Payé',
                                              style: TextStyle(
                                                  color: tampon[index].statut_paiement == 0 ? Colors.red :
                                                  tampon[index].statut_paiement == 1 ? Colors.blueGrey : Colors.green,
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
                                                  TextSpan(text: lesMetiers.where((m) => m.id == tampon[index].specialite).first.libelle,
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
                                                  TextSpan(text: lesPays.where((p) => p.id == tampon[index].nationalite).first.libelle,
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
                                                  TextSpan(text: lesCommunes.where((c) => c.id == tampon[index].commune_residence).first.libelle,
                                                      style: TextStyle(fontWeight: FontWeight.bold)
                                                  )
                                                ]
                                            ),
                                          )
                                      )
                                    ],
                                  )
                              )
                            ],
                          ),
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
