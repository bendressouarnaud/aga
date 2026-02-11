import 'dart:async';
import 'dart:io';

import 'package:cnmci/konan/beans/generic_data.dart';
import 'package:cnmci/konan/interface_prise_compagnon_photo.dart';
import 'package:cnmci/konan/local_data/niveau_equipement.dart';
import 'package:cnmci/konan/model/compagnon.dart';
import 'package:cnmci/konan/model/commune.dart';
import 'package:cnmci/konan/model/departement.dart';
import 'package:cnmci/konan/model/diplome.dart';
import 'package:cnmci/konan/model/metier.dart';
import 'package:cnmci/konan/model/niveau_etude.dart';
import 'package:cnmci/konan/model/pays.dart';
import 'package:cnmci/konan/model/sous_prefecture.dart';
import 'package:cnmci/konan/model/type_compte_bancaire.dart';
import 'package:cnmci/konan/model/type_document.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as https;

import '../getxcontroller/date_debut_activite_controller.dart';
import '../getxcontroller/date_delivre_controller.dart';
import '../getxcontroller/datecontroller.dart';
import '../main.dart';
import 'model/classe.dart';
import 'model/crm.dart';

class InterfaceCompagnonPersonne extends StatefulWidget {
  final int artisanId;
  final int entrepriseId;
  const InterfaceCompagnonPersonne({Key? key, required this.artisanId, required this.entrepriseId}) : super(key: key);

  @override
  State<InterfaceCompagnonPersonne> createState() => _InterfaceCompagnonPersonne();
}


class _InterfaceCompagnonPersonne extends State<InterfaceCompagnonPersonne> {

  // LINK :
  // https://api.flutter.dev/flutter/material/AlertDialog-class.html

  // A t t r i b u t e s  :
  TextEditingController nomController = TextEditingController();
  TextEditingController prenomController = TextEditingController();
  TextEditingController quartierResidenceController = TextEditingController();
  TextEditingController quartierCommuneController = TextEditingController();
  TextEditingController numeroPieceIdentiteController = TextEditingController();
  TextEditingController civiliteController = TextEditingController();
  TextEditingController communeController = TextEditingController();
  TextEditingController lieuNaissanceAutreController = TextEditingController();
  TextEditingController dateNaissanceController = TextEditingController();
  TextEditingController datePieceController = TextEditingController();
  TextEditingController nationaliteController = TextEditingController();
  TextEditingController statutMatrimonialController = TextEditingController();
  TextEditingController villeResidenceController = TextEditingController();
  TextEditingController adressePostaleController = TextEditingController();
  TextEditingController contact1Controller = TextEditingController();
  TextEditingController contact2Controller = TextEditingController();
  TextEditingController emailController = TextEditingController();

  TextEditingController specialiteController = TextEditingController();
  TextEditingController centreFormationController = TextEditingController();
  TextEditingController intituleFormationController = TextEditingController();


  TextEditingController regimetravailleurController = TextEditingController();
  TextEditingController regimeImpositionCommunaleController = TextEditingController();
  TextEditingController regimeImpositionEntrepriseController = TextEditingController();
  TextEditingController finFormationController = TextEditingController();
  TextEditingController diplomeObtenuController = TextEditingController();
  TextEditingController comptebancaireController = TextEditingController();
  TextEditingController typeDeCompteController = TextEditingController();
  TextEditingController chiffreAffaireController = TextEditingController();
  TextEditingController leTypeDocumentController = TextEditingController();
  TextEditingController pieceDelivreController = TextEditingController();
  TextEditingController cnpsController = TextEditingController();
  TextEditingController cmuController = TextEditingController();
  TextEditingController niveauEtudeController = TextEditingController();
  TextEditingController classeController = TextEditingController();
  TextEditingController diplomeController = TextEditingController();
  TextEditingController apprentissageMetierController = TextEditingController();
  TextEditingController metierController = TextEditingController();
  TextEditingController activitePrincipaleController = TextEditingController();
  TextEditingController activiteSecondaireController = TextEditingController();
  TextEditingController denominationController = TextEditingController();
  TextEditingController sigleController = TextEditingController();
  TextEditingController dateDebutCompagnonnageController = TextEditingController();
  TextEditingController villeCommuneController = TextEditingController();
  TextEditingController rccmCommuneController = TextEditingController();
  TextEditingController niveauEquipementController = TextEditingController();
  TextEditingController numeroImmatriculationController = TextEditingController();

  TextEditingController menuCountryDepartController = TextEditingController();
  TextEditingController menuDepartController = TextEditingController();
  TextEditingController menuDestinationController = TextEditingController();
  TextEditingController prixController = TextEditingController();

  final DateGetController _dateNaissanceController = Get.put(DateGetController());
  final DateDelivreGetController _datePieceDelivreController = Get.put(DateDelivreGetController());
  final DateDebutActiviteGetController _dateDebutCompagnonnageController = Get.put(DateDebutActiviteGetController());

  //
  bool initInterface = false;

  late bool _isLoading;
  // Initial value :
  //final _userRepository = UserRepository();
  late BuildContext dialogContext;
  bool flagSendData = false;
  bool closeAlertDialog = false;
  int retour = 0;
  //
  //final PublicationGetController _publicationController = Get.put(PublicationGetController());
  late https.Client client;
  //
  String? getToken = "";
  int id = 0;
  int idpub = 0;
  int keep_idpub = 0;
  String nationalite = "";
  late String ordernumber;
  String ipaddress = "";
  int milliseconds = 0;
  bool updatePubDate = false;
  bool updatePubHour = false;
  late BuildContext customContext;

  double spacingSteps = 40;
  int currentStep = 1;
  int choixDate = 0;

  int stepForPhoto = 0;

  late Crm leCrm;
  late Departement leDepartement;
  late SousPrefecture laSousPrefecture;
  late Pays laNationalite;
  late Commune laCommune;
  late Commune laVilleResidence;
  late String laCivilite;

  late GenericData leCentreFormation;
  late GenericData laFinFormation;
  late GenericData lApprentissageMetier;
  late TypeCompteBancaire leTypeDeCompte;
  late TypeDocument leTypeDocument;
  late Commune laPieceDelivre;
  late NiveauEtude leNiveauEtude;
  late Classe laClasse;
  late Diplome leDiplome;
  late Metier leMetier;
  late Metier laSpecialite;
  late Metier lActivitePrincipale;
  late Metier lActiviteSecondaire;
  late Commune laVilleCommune;
  late NiveauEquipement leNiveauEquipement;
  late GenericData leStatutCompagnon;
  late GenericData laLivraison;

  int artisanId = 0;

  final lesGenericLivraisons = [
    GenericData(libelle: 'Non', id: 0),
    GenericData(libelle: 'Oui', id: 1)
  ];
  final lesCivilites = [
    'M',
    'Mme',
    'Mlle'
  ];
  final lesStatutCompagnon = [
    GenericData(libelle: 'Nouveau', id: 0),
    GenericData(libelle: 'Renouvellement', id: 1)
  ];
  // GenericData
  final lesGenericData = [
    GenericData(libelle: 'Oui', id: 1),
    GenericData(libelle: 'Non', id: 0)
  ];
  final lesGenericComptabilite = [
    GenericData(libelle: 'Aucune', id: 0),
    GenericData(libelle: 'Comptabilité simplifiée', id: 1),
    GenericData(libelle: 'Comptabilité normale', id: 2)
  ];
  final lesGenericApprentissagea = [
    GenericData(libelle: 'Centre de Formation Professionnelle', id: 2),
    GenericData(libelle: 'Sur le tas', id: 1)
  ];
  //
  final lesNiveauEquipement = [
    NiveauEquipement(libelle: 'Précaire', id: 0),
    NiveauEquipement(libelle: 'Moyen', id: 1),
    NiveauEquipement(libelle: 'Bon', id: 2)
  ];

  // M E T H O D S
  void feedCompagnon() async{
    compagnonToManage = Compagnon(
        id: 0,
        nom: nomController.text,
        prenom: prenomController.text,
        civilite: laCivilite,
        date_naissance: dateNaissanceController.text,
        numero_immatriculation: numeroImmatriculationController.text.trim(),
        lieu_naissance_autre: lieuNaissanceAutreController.text,
        lieu_naissance: laCommune.id,
        nationalite: laNationalite.id,
        sexe: '',
        type_document: leTypeDocument.id,
        niveau_etude: leNiveauEtude.id,
        specialite: laSpecialite.id,
        classe: laClasse.id,
        diplome: leDiplome.id,
        apprentissage_metier: lApprentissageMetier.id,
        date_debut_compagnonnage: dateDebutCompagnonnageController.text,
        commune_residence: laVilleResidence.id,
        quartier_residence: quartierResidenceController.text,
        adresse_postal: adressePostaleController.text,
        numero_piece: numeroPieceIdentiteController.text,
        piece_delivre: laPieceDelivre.id,
        date_emission_piece: datePieceController.text,
        photo: "",
        photo_cni_recto: "",
        photo_cni_verso: "",
        photo_diplome: "",
        contact1: contact1Controller.text,
        contact2: contact2Controller.text,
        email: emailController.text,
        statut_kyc: 0,
        statut_paiement: 0,
        longitude: 0.0,
        latitude: 0.0,
        cnps: cnpsController.text,
        cmu: cmuController.text,
        artisan_id: widget.artisanId,
        entreprise_id:  widget.entrepriseId,
      millisecondes: DateTime.now().millisecondsSinceEpoch,
        statut_compagnon: leStatutCompagnon.id,
        livraisonCarte: laLivraison.id
    );

    final result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) {
      return const InterfacePriseCompagnonPhoto();
    }));

    // Close the DOORS :
    if (result != null) {
      // Request for Permission :
      forceLeave();
    }
  }

  // Leave :
  void forceLeave(){
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    leCrm = lesCrms.first;
    leDepartement = lesDepartements.first;
    laSousPrefecture = lesSousPrefectures.first;
    laCommune = lesCommunes.first;
    laVilleCommune = lesCommunes.first;
    laPieceDelivre = lesCommunes.first;
    laVilleResidence = lesCommunes.first;
    laCivilite = lesCivilites.first;
    laNationalite = lesPays.where((p) => p.id == 1).first; // Pick 'CÔTE d'IVOIRE' by DEFAULT
    leCentreFormation = lesGenericData.first;
    laFinFormation = lesGenericData.first;
    laSpecialite = lesMetiers.first;
    leTypeDeCompte = lesTypeCompteBancaires.first;
    leTypeDocument = lesTypeDocuments.first;
    leNiveauEtude = lesNiveauEtudes.first;
    laClasse = lesClasses.first;
    leDiplome = lesDiplomes.first;
    lApprentissageMetier = lesGenericApprentissagea.first;
    leMetier = lesMetiers.first;
    lActivitePrincipale = lesMetiers.first;
    lActiviteSecondaire = lesMetiers.first;
    leNiveauEquipement = lesNiveauEquipement.first;
    leStatutCompagnon = lesStatutCompagnon.first;
    laLivraison = lesGenericLivraisons.first;

    _dateNaissanceController.clear();
    _datePieceDelivreController.clear();
    _dateDebutCompagnonnageController.clear();

    // INIT FIELDS
    lieuNaissanceAutreController.text = "";
    quartierResidenceController.text = "";
    adressePostaleController.text = "";
    numeroPieceIdentiteController.text = "";
    contact1Controller.text = "";
    contact2Controller.text = "";
    emailController.text = "";
    cnpsController.text = "";
    cmuController.text = "";
    numeroImmatriculationController.text = "";

    communeController.text = laCommune.libelle;
    villeResidenceController.text = laVilleResidence.libelle;
    specialiteController.text = laSpecialite.libelle;
    pieceDelivreController.text = laPieceDelivre.libelle;
  }



  @override
  void dispose() {
    super.dispose();

    // Dispose
  }

  TextEditingController processData(DateGetController controller){
    dateNaissanceController = TextEditingController(
        text: controller.data.isNotEmpty ? controller.data[0] : '');
    return dateNaissanceController;
  }

  TextEditingController processDataDelivre(DateDelivreGetController controller){
    datePieceController = TextEditingController(
        text: controller.data.isNotEmpty ? controller.data[0] : '');
    return datePieceController;
  }

  TextEditingController processDateDebutApprentissage(DateDebutActiviteGetController controller){
    dateDebutCompagnonnageController  = TextEditingController(
        text: controller.data.isNotEmpty ? controller.data[0] : '');
    return dateDebutCompagnonnageController;
  }

  Future<void> _selectDate() async {
    choixDate = 0;
    final now = DateTime(1965, 1, 1, 00, 00);
    final initialDate = DateTime(2000, 1, 1, 00, 00);

    // Sélection de la date
    final selectedDate = await showDatePicker(
      locale: Locale(Platform.localeName.split("_").first, Platform.localeName.split("_").lastOrNull),
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: DateTime(2007, 12, 31, 00, 00)// DateTime.fromMillisecondsSinceEpoch(globalReservation!.fin),
    );
    if (selectedDate == null) return;
    _dateNaissanceController.addData(selectedDate);
  }

  Future<void> _selectDateDelivre() async {
    choixDate = 1;
    final now = DateTime(2015, 1, 2, 00, 00);
    final currentDate = DateTime.now();

    // Sélection de la date
    final selectedDate = await showDatePicker(
        locale: Locale(Platform.localeName.split("_").first, Platform.localeName.split("_").lastOrNull),
        context: context,
        initialDate: now,
        firstDate: now,
        lastDate: DateTime(currentDate.year, currentDate.month, currentDate.day, 00, 00)// DateTime.fromMillisecondsSinceEpoch(globalReservation!.fin),
    );
    if (selectedDate == null) return;
    _datePieceDelivreController.addData(selectedDate);
  }

  Future<void> _selectDateDebutCompagnonnage() async {
    choixDate = 1;
    final now = DateTime(2015, 1, 2, 00, 00);
    final currentDate = DateTime.now();

    // Sélection de la date
    final selectedDate = await showDatePicker(
        locale: Locale(Platform.localeName.split("_").first, Platform.localeName.split("_").lastOrNull),
        context: context,
        initialDate: now,
        firstDate: now,
        lastDate: DateTime(currentDate.year, currentDate.month, currentDate.day, 00, 00)// DateTime.fromMillisecondsSinceEpoch(globalReservation!.fin),
    );
    if (selectedDate == null) return;
    _dateDebutCompagnonnageController.addData(selectedDate);
  }

  void displayToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  Widget lesEtapes(){
    return Container(
      margin: const EdgeInsets.only(top: 17, left: 10, right: 10, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(left: spacingSteps, right: spacingSteps),
            child: Text('1',
              style: TextStyle(
                fontSize: 30,
                color: currentStep == 1 ? Colors.red : Colors.black,
                fontWeight: currentStep == 1 ? FontWeight.bold : FontWeight.normal,
              ),),
          ),
          Container(
              margin: EdgeInsets.only(left: spacingSteps, right: spacingSteps),
              child: Text('2',
                style: TextStyle(
                  fontSize: 30,
                  color: currentStep == 2 ? Colors.red : Colors.black,
                  fontWeight: currentStep == 2 ? FontWeight.bold : FontWeight.normal,
                ),)
          )
        ],
      ),
    );
  }

  Widget lesBoutons(){
    return SafeArea(child: Container(
      margin: EdgeInsets.only(top: defaultTargetPlatform == TargetPlatform.iOS ? 50 : 30, left: 10, right: 10, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            style: ButtonStyle(
                backgroundColor: WidgetStateColor.resolveWith((states) => Colors.blueGrey)
            ),
            label: const Text("Retour",
                style: TextStyle(
                    color: Colors.white
                )),
            onPressed: () {
              if(currentStep > 1){
                setState(() {
                  currentStep--;
                });
              }
              else{
                Navigator.pop(context);
              }
            },
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: Colors.white,
            ),
          ),
          ElevatedButton.icon(
            style: ButtonStyle(
                iconAlignment: IconAlignment.end,
                backgroundColor: WidgetStateColor.resolveWith((states) => Colors.brown)
            ),
            label: Text("Suivant",
                style: TextStyle(
                    color: Colors.white
                )
            ),
            onPressed: () async {

              // check on ville :
              if(nomController.text.trim().isEmpty || prenomController.text.trim().isEmpty
                  || dateNaissanceController.text.isEmpty || datePieceController.text.isEmpty ||
                  contact1Controller.text.trim().isEmpty || dateDebutCompagnonnageController.text.trim().isEmpty ||
                  (laCommune.id == 1 && lieuNaissanceAutreController.text.trim().isEmpty) ||
                  (leStatutCompagnon.id == 1 && numeroImmatriculationController.text.trim().isEmpty)
              ){
                displayToast('Veuillez renseigner les champs principaux');
                return;
              }
              feedCompagnon();
            },
            icon: Icon(Icons.arrow_forward_ios,
              size: 20,
              color: Colors.white,
            ),
          )
        ],
      ),
    ));
  }

  List<Widget> renseignementPersonne(){
    return [
      lesEtapes(),
      Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(top: 20, left: 10, right: 10),
        child: Divider(
          color: Colors.black,
          height: 5,
        ),
      ),

      Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(left: 10, right: 10, top: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: (MediaQuery.of(context).size.width / 2) - 20,
                child: DropdownSearch<GenericData>(
                  mode: Mode.form,
                  onChanged: (GenericData? value) => {
                    setState(() {
                      leStatutCompagnon = value!;
                    })
                  },
                  compareFn: (GenericData? a, GenericData? b){
                    if(a == null || b == null){
                      return false;
                    }
                    return a.id == b.id;
                  },
                  selectedItem: leStatutCompagnon,
                  itemAsString: (statut) => statut.libelle,
                  items: (filter, infiniteScrollProps) => lesStatutCompagnon,
                  decoratorProps: DropDownDecoratorProps(
                    decoration: InputDecoration(
                      labelText: 'Statut compagnon',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  popupProps: PopupProps.menu(
                    /*showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                              hintText: 'Rechercher'
                          )
                      ),*/
                      fit: FlexFit.loose,
                      constraints: BoxConstraints(
                          minHeight: 150,
                          maxHeight: 200
                      )
                  ),
                ),
              ),
              Visibility(
                  visible: leStatutCompagnon.id == 1,
                  child: SizedBox(
                    width: (MediaQuery.of(context).size.width / 2) - 20,
                    child: TextField(
                      keyboardType: TextInputType.text,
                      controller: numeroImmatriculationController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Numéro Immatriculation',
                      ),
                      style: const TextStyle(
                          height: 1.5
                      ),
                      textAlignVertical: TextAlignVertical.bottom,
                      textAlign: TextAlign.center,
                      textInputAction: TextInputAction.next,
                    ),
                  )
              )
            ],
          )
      ),

      Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(left: 10, right: 10, top: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: (MediaQuery.of(context).size.width / 2) - 20,
                child: DropdownSearch<GenericData>(
                  mode: Mode.form,
                  onChanged: (GenericData? value) => {
                    setState(() {
                      laLivraison = value!;
                    })
                  },
                  compareFn: (GenericData? a, GenericData? b){
                    if(a == null || b == null){
                      return false;
                    }
                    return a.id == b.id;
                  },
                  selectedItem: laLivraison,
                  itemAsString: (statut) => statut.libelle,
                  items: (filter, infiniteScrollProps) => lesGenericLivraisons,
                  decoratorProps: DropDownDecoratorProps(
                    decoration: InputDecoration(
                      labelText: 'Livraison des documents',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  popupProps: PopupProps.menu(
                    /*showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                              hintText: 'Rechercher'
                          )
                      ),*/
                      fit: FlexFit.loose,
                      constraints: BoxConstraints(
                          minHeight: 150,
                          maxHeight: 200
                      )
                  ),
                ),
              )
            ],
          )
      ),
      Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(top: 10, left: 10, right: 10),
        child: Divider(
          color: Colors.black,
          height: 5,
        ),
      ),

      Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(left: 10, right: 10, top: 25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: (MediaQuery.of(context).size.width / 2) - 20,
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      nomController.text = value;
                    });
                  },
                  keyboardType: TextInputType.name,
                  controller: nomController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: nomController.text.trim().isEmpty ?
                      Colors.red : Colors.black, width: 1.0),
                    ),
                    border: OutlineInputBorder(),
                    labelText: 'Nom',
                  ),
                  style: const TextStyle(
                      height: 1.5
                  ),
                  textAlignVertical: TextAlignVertical.bottom,
                  textAlign: TextAlign.center,
                  textInputAction: TextInputAction.next,
                ),
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width / 2) - 20,
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      prenomController.text = value;
                    });
                  },
                  keyboardType: TextInputType.name,
                  controller: prenomController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: prenomController.text.trim().isEmpty ?
                      Colors.red : Colors.black, width: 1.0),
                    ),
                    border: OutlineInputBorder(),
                    labelText: 'Prénom',
                  ),
                  style: const TextStyle(
                      height: 1.5,
                  ),
                  textAlignVertical: TextAlignVertical.bottom,
                  textAlign: TextAlign.center,
                  textInputAction: TextInputAction.next,
                ),
              )
            ],
          )
      ),
      Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DropdownMenu<String>(
                  width: (MediaQuery.of(context).size.width / 2) - 20,
                  menuHeight: 250,
                  initialSelection: laCivilite,
                  controller: civiliteController,
                  hintText: "Civilité",
                  requestFocusOnTap: false,
                  enableSearch: false,
                  enableFilter: false,
                  label: const Text('Civilité'),
                  // Initial Value
                  onSelected: (String? value) {
                    laCivilite = value!;
                  },
                  dropdownMenuEntries:
                  lesCivilites.map<DropdownMenuEntry<String>>((String menu) {
                    return DropdownMenuEntry<String>(
                        value: menu,
                        label: menu,
                        leadingIcon: Icon(Icons.person_outline));
                  }).toList()
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width / 2) - 20,
                child: DropdownSearch<Commune>(
                  mode: Mode.form,
                  onChanged: (Commune? value) => {
                    setState(() {
                      laCommune = value!;
                    })
                  },
                  compareFn: (Commune? a, Commune? b){
                    if(a == null || b == null){
                      return false;
                    }
                    return a.id == b.id;
                  },
                  selectedItem: laCommune,
                  itemAsString: (commune) => commune.libelle,
                  items: (filter, infiniteScrollProps) => lesCommunes,
                  decoratorProps: DropDownDecoratorProps(
                    decoration: InputDecoration(
                      labelText: 'Lieu naissance',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  popupProps: PopupProps.menu(
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                              hintText: 'Rechercher'
                          )
                      ),
                      fit: FlexFit.loose,
                      constraints: BoxConstraints(
                          minHeight: 300,
                          maxHeight: 400
                      )
                  ),
                ),
              )
              /*DropdownMenu<Commune>(
                  width: (MediaQuery.of(context).size.width / 2) - 20,
                  menuHeight: 250,
                  initialSelection: laCommune,
                  controller: communeController,
                  hintText: "Lieu naissance",
                  requestFocusOnTap: true,
                  enableSearch: true,
                  enableFilter: false,
                  label: const Text('Lieu naissance'),
                  // Initial Value
                  onSelected: (Commune? value) {
                    setState(() {
                      laCommune = value!;
                    });
                  },
                  dropdownMenuEntries:
                  lesCommunes.map<DropdownMenuEntry<Commune>>((Commune menu) {
                    return DropdownMenuEntry<Commune>(
                        value: menu,
                        label: menu.libelle,
                        leadingIcon: Icon(Icons.location_city));
                  }).toList()
              )*/
            ],
          )
      ),
      Visibility(
          visible: laCommune.id == 1,
          child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    lieuNaissanceAutreController.text = value;
                  });
                },
                keyboardType: TextInputType.text,
                controller: lieuNaissanceAutreController,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: lieuNaissanceAutreController.text.trim().isEmpty ?
                    Colors.red : Colors.black, width: 1.0),
                  ),
                  border: OutlineInputBorder(),
                  labelText: 'Lieu naissance Autre',
                ),
                style: const TextStyle(
                  height: 1.5,
                ),
                textAlignVertical: TextAlignVertical.bottom,
                textAlign: TextAlign.center,
                textInputAction: TextInputAction.next,
              )
          )
      ),
      Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: (MediaQuery.of(context).size.width / 2) - 20,
                child: ElevatedButton.icon(
                  style: ButtonStyle(
                      backgroundColor: WidgetStateColor.resolveWith((states) => Colors.brown)
                  ),
                  label: const Text("Né(e) le",
                      style: TextStyle(
                          color: Colors.white
                      )
                  ),
                  onPressed: () {
                    _selectDate();
                  },
                  icon: const Icon(
                    Icons.access_time_outlined,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width / 2) - 20,
                child: GetBuilder<DateGetController>(
                    builder: (DateGetController controller) {
                      return TextField(
                        enabled: false,
                        controller: processData(controller),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Date...',
                        ),
                        style: TextStyle(
                            height: 0.8
                        ),
                        textAlignVertical: TextAlignVertical.bottom,
                        textAlign: TextAlign.right,
                      );
                    }
                ),
              ),
            ],
          )
      ),
      Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(left: 10, right: 10, top: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DropdownMenu<Pays>(
                  width: (MediaQuery.of(context).size.width / 2) - 20,
                  menuHeight: 250,
                  initialSelection: laNationalite,
                  controller: nationaliteController,
                  hintText: "Nationalité",
                  requestFocusOnTap: false,
                  enableSearch: false,
                  enableFilter: false,
                  label: const Text('Nationalité'),
                  // Initial Value
                  onSelected: (Pays? value) {
                    laNationalite = value!;
                  },
                  dropdownMenuEntries:
                  lesPays.map<DropdownMenuEntry<Pays>>((Pays menu) {
                    return DropdownMenuEntry<Pays>(
                        value: menu,
                        label: menu.libelle,
                        leadingIcon: Icon(Icons.person_outline));
                  }).toList()
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width / 2) - 20,
                child: DropdownSearch<Commune>(
                  mode: Mode.form,
                  onChanged: (Commune? value) => {
                    laVilleResidence = value!
                  },
                  compareFn: (Commune? a, Commune? b){
                    if(a == null || b == null){
                      return false;
                    }
                    return a.id == b.id;
                  },
                  selectedItem: laVilleResidence,
                  itemAsString: (commune) => commune.libelle,
                  items: (filter, infiniteScrollProps) => lesCommunes,
                  decoratorProps: DropDownDecoratorProps(
                    decoration: InputDecoration(
                      labelText: 'Ville résidence',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  popupProps: PopupProps.menu(
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                              hintText: 'Rechercher'
                          )
                      ),
                      fit: FlexFit.loose,
                      constraints: BoxConstraints(
                          minHeight: 300,
                          maxHeight: 400
                      )
                  ),
                ),
              )
              /*DropdownMenu<Commune>(
                  width: (MediaQuery.of(context).size.width / 2) - 20,
                  menuHeight: 250,
                  initialSelection: laVilleResidence,
                  controller: villeResidenceController,
                  hintText: "Ville résidence",
                  requestFocusOnTap: true,
                  enableSearch: true,
                  enableFilter: false,
                  label: const Text('Ville résidence'),
                  // Initial Value
                  onSelected: (Commune? value) {
                    laVilleResidence = value!;
                  },
                  dropdownMenuEntries:
                  lesCommunes.map<DropdownMenuEntry<Commune>>((Commune menu) {
                    return DropdownMenuEntry<Commune>(
                        value: menu,
                        label: menu.libelle,
                        leadingIcon: Icon(Icons.location_city));
                  }).toList()
              )*/
            ],
          )
      ),
      Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: (MediaQuery.of(context).size.width / 2) - 20,
                child: TextField(
                  keyboardType: TextInputType.text,
                  controller: quartierResidenceController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Quartier résidence',
                  ),
                  style: const TextStyle(
                      height: 1.5
                  ),
                  textAlignVertical: TextAlignVertical.bottom,
                  textAlign: TextAlign.center,
                  textInputAction: TextInputAction.next,
                ),
              )
            ],
          )
      ),
      Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: (MediaQuery.of(context).size.width / 2) - 20,
                child: TextField(
                  keyboardType: TextInputType.text,
                  controller: adressePostaleController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Adresse postale',
                  ),
                  style: const TextStyle(
                      height: 1.5
                  ),
                  textAlignVertical: TextAlignVertical.bottom,
                  textAlign: TextAlign.center,
                  textInputAction: TextInputAction.next,
                ),
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width / 2) - 20,
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      contact1Controller.text = value;
                    });
                  },
                  keyboardType: TextInputType.phone,
                  controller: contact1Controller,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: contact1Controller.text.trim().isEmpty ?
                      Colors.red : Colors.black, width: 1.0),
                    ),
                    border: OutlineInputBorder(),
                    labelText: 'Contact 1',
                  ),
                  style: const TextStyle(
                      height: 1.5
                  ),
                  textAlignVertical: TextAlignVertical.bottom,
                  textAlign: TextAlign.center,
                  textInputAction: TextInputAction.next,
                ),
              )
            ],
          )
      ),
      Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: (MediaQuery.of(context).size.width / 2) - 20,
                child: TextField(
                  keyboardType: TextInputType.text,
                  controller: contact2Controller,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Contact 2',
                  ),
                  style: const TextStyle(
                      height: 1.5
                  ),
                  textAlignVertical: TextAlignVertical.bottom,
                  textAlign: TextAlign.center,
                  textInputAction: TextInputAction.next,
                ),
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width / 2) - 20,
                child: TextField(
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                  ),
                  style: const TextStyle(
                      height: 1.5
                  ),
                  textAlignVertical: TextAlignVertical.bottom,
                  textAlign: TextAlign.center,
                  textInputAction: TextInputAction.next,
                ),
              )
            ],
          )
      ),
      Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(top: 30, left: 10, right: 10),
        child: Divider(
          color: Colors.black,
          height: 5,
        ),
      ),
      Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DropdownMenu<NiveauEtude>(
                  width: (MediaQuery.of(context).size.width / 2) - 20,
                  menuHeight: 250,
                  initialSelection: leNiveauEtude,
                  controller: niveauEtudeController,
                  hintText: "Niveau d'étude",
                  requestFocusOnTap: false,
                  enableSearch: false,
                  enableFilter: false,
                  label: const Text('Niveau étude'),
                  // Initial Value
                  onSelected: (NiveauEtude? value) {
                    leNiveauEtude = value!;
                  },
                  dropdownMenuEntries:
                  lesNiveauEtudes.map<DropdownMenuEntry<NiveauEtude>>((NiveauEtude menu) {
                    return DropdownMenuEntry<NiveauEtude>(
                        value: menu,
                        label: menu.libelle,
                        leadingIcon: Icon(Icons.school));
                  }).toList()
              ),
              DropdownMenu<Classe>(
                  width: (MediaQuery.of(context).size.width / 2) - 20,
                  menuHeight: 250,
                  initialSelection: laClasse,
                  controller: classeController,
                  hintText: "La classe",
                  requestFocusOnTap: false,
                  enableSearch: false,
                  enableFilter: false,
                  label: const Text('Classe'),
                  // Initial Value
                  onSelected: (Classe? value) {
                    laClasse = value!;
                  },
                  dropdownMenuEntries:
                  lesClasses.map<DropdownMenuEntry<Classe>>((Classe menu) {
                    return DropdownMenuEntry<Classe>(
                        value: menu,
                        label: menu.libelle,
                        leadingIcon: Icon(Icons.school));
                  }).toList()
              )
            ],
          )
      ),
      Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DropdownMenu<Diplome>(
                  width: (MediaQuery.of(context).size.width / 2) - 20,
                  menuHeight: 250,
                  initialSelection: leDiplome,
                  controller: diplomeController,
                  hintText: "Diplôme obtenu",
                  requestFocusOnTap: false,
                  enableSearch: false,
                  enableFilter: false,
                  label: const Text('Diplôme obtenu'),
                  // Initial Value
                  onSelected: (Diplome? value) {
                    leDiplome = value!;
                  },
                  dropdownMenuEntries:
                  lesDiplomes.map<DropdownMenuEntry<Diplome>>((Diplome menu) {
                    return DropdownMenuEntry<Diplome>(
                        value: menu,
                        label: menu.libelle,
                        leadingIcon: Icon(Icons.school));
                  }).toList()
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width / 2) - 20,
                child: DropdownSearch<Metier>(
                  mode: Mode.form,
                  onChanged: (Metier? value) => {
                    laSpecialite = value!
                  },
                  compareFn: (Metier? a, Metier? b){
                    if(a == null || b == null){
                      return false;
                    }
                    return a.id == b.id;
                  },
                  selectedItem: laSpecialite,
                  itemAsString: (metier) => metier.libelle,
                  items: (filter, infiniteScrollProps) => lesMetiers,
                  decoratorProps: DropDownDecoratorProps(
                    decoration: InputDecoration(
                      labelText: 'Spécialité',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  popupProps: PopupProps.menu(
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                              hintText: 'Rechercher'
                          )
                      ),
                      fit: FlexFit.loose,
                      constraints: BoxConstraints(
                          minHeight: 300,
                          maxHeight: 400
                      )
                  ),
                ),
              )
            ],
          )
      ),
      Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
          child: DropdownMenu<GenericData>(
              width: MediaQuery.of(context).size.width,
              menuHeight: 250,
              initialSelection: lApprentissageMetier,
              controller: centreFormationController,
              hintText: "Apprentissage Metier",
              requestFocusOnTap: false,
              enableSearch: false,
              enableFilter: false,
              label: const Text('Apprentissage Metier'),
              // Initial Value
              onSelected: (GenericData? value) {
                setState(() {
                  lApprentissageMetier = value!;
                });
              },
              dropdownMenuEntries:
              lesGenericApprentissagea.map<DropdownMenuEntry<GenericData>>((GenericData menu) {
                return DropdownMenuEntry<GenericData>(
                    value: menu,
                    label: menu.libelle,
                    leadingIcon: Icon(Icons.work));
              }).toList()
          )
      ),
      Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: (MediaQuery.of(context).size.width / 2) - 20,
                child: ElevatedButton.icon(
                  style: ButtonStyle(
                      backgroundColor: WidgetStateColor.resolveWith((states) => Colors.brown)
                  ),
                  label: const Text("Date de Compagnonnage",
                      style: TextStyle(
                          color: Colors.white
                      )
                  ),
                  onPressed: () {
                    _selectDateDebutCompagnonnage();
                  },
                  icon: const Icon(
                    Icons.access_time_outlined,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width / 2) - 20,
                child: GetBuilder<DateDebutActiviteGetController>(
                    builder: (DateDebutActiviteGetController controller) {
                      return TextField(
                        enabled: false,
                        controller: processDateDebutApprentissage(controller),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Date...',
                        ),
                        style: TextStyle(
                            height: 0.8
                        ),
                        textAlignVertical: TextAlignVertical.bottom,
                        textAlign: TextAlign.right,
                      );
                    }
                ),
              ),
            ],
          )
      ),

      Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(top: 15, left: 10, right: 10),
        child: Divider(
          color: Colors.black,
          height: 5,
        ),
      ),
      Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DropdownMenu<TypeDocument>(
                  width: (MediaQuery.of(context).size.width / 2) - 20,
                  menuHeight: 250,
                  initialSelection: leTypeDocument,
                  controller: leTypeDocumentController,
                  hintText: "Type document",
                  requestFocusOnTap: false,
                  enableSearch: false,
                  enableFilter: false,
                  label: const Text('Type document'),
                  // Initial Value
                  onSelected: (TypeDocument? value) {
                    leTypeDocument = value!;
                  },
                  dropdownMenuEntries:
                  lesTypeDocuments.map<DropdownMenuEntry<TypeDocument>>((TypeDocument menu) {
                    return DropdownMenuEntry<TypeDocument>(
                        value: menu,
                        label: menu.libelle,
                        leadingIcon: Icon(Icons.person_outline));
                  }).toList()
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width / 2) - 20,
                child: TextField(
                  keyboardType: TextInputType.text,
                  controller: numeroPieceIdentiteController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Pièce identité',
                  ),
                  style: const TextStyle(
                      height: 1.5
                  ),
                  textAlignVertical: TextAlignVertical.bottom,
                  textAlign: TextAlign.center,
                  textInputAction: TextInputAction.next,
                ),
              )
            ],
          )
      ),
      Container(
        alignment: Alignment.topLeft,
        margin: EdgeInsets.only(top: 20, left: 10),
        width: MediaQuery.of(context).size.width,
        child: SizedBox(
          width: (MediaQuery.of(context).size.width / 2) - 20,
          child: DropdownSearch<Commune>(
            mode: Mode.form,
            onChanged: (Commune? value) => {
              laPieceDelivre = value!
            },
            compareFn: (Commune? a, Commune? b){
              if(a == null || b == null){
                return false;
              }
              return a.id == b.id;
            },
            selectedItem: laPieceDelivre,
            itemAsString: (commune) => commune.libelle,
            items: (filter, infiniteScrollProps) => lesCommunes,
            decoratorProps: DropDownDecoratorProps(
              decoration: InputDecoration(
                labelText: 'Pièce délivrée à',
                border: OutlineInputBorder(),
              ),
            ),
            popupProps: PopupProps.menu(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(
                        hintText: 'Rechercher'
                    )
                ),
                fit: FlexFit.loose,
                constraints: BoxConstraints(
                    minHeight: 300,
                    maxHeight: 400
                )
            ),
          ),
        )
        /*DropdownMenu<Commune>(
            width: (MediaQuery.of(context).size.width / 2) - 20,
            menuHeight: 250,
            initialSelection: laPieceDelivre,
            controller: pieceDelivreController,
            hintText: "Pièce délivrée à",
            requestFocusOnTap: true,
            enableSearch: true,
            enableFilter: false,
            label: const Text('Pièce délivrée à'),
            // Initial Value
            onSelected: (Commune? value) {
              laPieceDelivre = value!;
            },
            dropdownMenuEntries:
            lesCommunes.map<DropdownMenuEntry<Commune>>((Commune menu) {
              return DropdownMenuEntry<Commune>(
                  value: menu,
                  label: menu.libelle,
                  leadingIcon: Icon(Icons.location_city));
            }).toList()
        ),*/
      ),
      Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: (MediaQuery.of(context).size.width / 2) - 20,
                child: ElevatedButton.icon(
                  style: ButtonStyle(
                      backgroundColor: WidgetStateColor.resolveWith((states) => Colors.brown)
                  ),
                  label: const Text("Délivrée le",
                      style: TextStyle(
                          color: Colors.white
                      )
                  ),
                  onPressed: () {
                    _selectDateDelivre();
                  },
                  icon: const Icon(
                    Icons.access_time_outlined,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width / 2) - 20,
                child: GetBuilder<DateDelivreGetController>(
                    builder: (DateDelivreGetController controller) {
                      return TextField(
                        enabled: false,
                        controller: processDataDelivre(controller),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Date...',
                        ),
                        style: TextStyle(
                            height: 0.8
                        ),
                        textAlignVertical: TextAlignVertical.bottom,
                        textAlign: TextAlign.right,
                      );
                    }
                ),
              ),
            ],
          )
      ),
      Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(top: 30, left: 10, right: 10),
        child: Divider(
          color: Colors.black,
          height: 5,
        ),
      ),
      Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: (MediaQuery.of(context).size.width / 2) - 20,
                child: TextField(
                  keyboardType: TextInputType.text,
                  controller: cnpsController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Numéro CNPS',
                  ),
                  style: const TextStyle(
                      height: 1.5
                  ),
                  textAlignVertical: TextAlignVertical.bottom,
                  textAlign: TextAlign.center,
                  textInputAction: TextInputAction.next,
                ),
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width / 2) - 20,
                child: TextField(
                  keyboardType: TextInputType.text,
                  controller: cmuController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'CMU',
                  ),
                  style: const TextStyle(
                      height: 1.5
                  ),
                  textAlignVertical: TextAlignVertical.bottom,
                  textAlign: TextAlign.center,
                  textInputAction: TextInputAction.next,
                ),
              )
            ],
          )
      ),
      lesBoutons()
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(idpub == 0 ? 'Nouveau Compagnon' : 'Modification Compagnon'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: renseignementPersonne()
          ),
        )
    );
  }
}