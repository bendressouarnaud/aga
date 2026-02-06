import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:cnmci/konan/beans/generic_data.dart';
import 'package:cnmci/konan/interface_prise_artisan_photo.dart';
import 'package:cnmci/konan/local_data/niveau_equipement.dart';
import 'package:cnmci/konan/model/artisan.dart';
import 'package:cnmci/konan/model/commune.dart';
import 'package:cnmci/konan/model/departement.dart';
import 'package:cnmci/konan/model/diplome.dart';
import 'package:cnmci/konan/model/metier.dart';
import 'package:cnmci/konan/model/niveau_etude.dart';
import 'package:cnmci/konan/model/pays.dart';
import 'package:cnmci/konan/model/quartier.dart';
import 'package:cnmci/konan/model/sous_prefecture.dart';
import 'package:cnmci/konan/model/statut_matrimonial.dart';
import 'package:cnmci/konan/model/type_compte_bancaire.dart';
import 'package:cnmci/konan/model/type_document.dart';
import 'package:cnmci/konan/services.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as https;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

import '../getxcontroller/date_debut_activite_controller.dart';
import '../getxcontroller/date_delivre_controller.dart';
import '../getxcontroller/datecontroller.dart';
import '../main.dart';
import 'beans/message_response.dart';
import 'model/classe.dart';
import 'model/crm.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
as picker;

import 'objets/amountseparator.dart';
import 'objets/constants.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:flutter/services.dart';


class InterfaceArtisanPersonne extends StatefulWidget {
  const InterfaceArtisanPersonne({Key? key}) : super(key: key);

  @override
  State<InterfaceArtisanPersonne> createState() => _InterfaceArtisanPersonne();
}


class _InterfaceArtisanPersonne extends State<InterfaceArtisanPersonne> with WidgetsBindingObserver {

  // LINK :
  // https://api.flutter.dev/flutter/material/AlertDialog-class.html

  // A t t r i b u t e s  :
  TextEditingController crmController = TextEditingController();
  TextEditingController departementController = TextEditingController();
  TextEditingController sousPrefectureController = TextEditingController();
  TextEditingController nomController = TextEditingController();
  TextEditingController prenomController = TextEditingController();
  TextEditingController quartierResidenceController = TextEditingController();
  TextEditingController quartierCommuneController = TextEditingController();
  TextEditingController numeroRegistreController = TextEditingController();
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
  TextEditingController regimeSocialController = TextEditingController();
  TextEditingController regimetravailleurController = TextEditingController();
  TextEditingController regimeImpositionCommunaleController = TextEditingController();
  TextEditingController regimeImpositionEntrepriseController = TextEditingController();
  TextEditingController comptabiliteController = TextEditingController();
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
  TextEditingController dateDebutActiviteController = TextEditingController();
  TextEditingController villeCommuneController = TextEditingController();
  TextEditingController rccmCommuneController = TextEditingController();
  TextEditingController niveauEquipementController = TextEditingController();

  TextEditingController menuCountryDepartController = TextEditingController();
  TextEditingController menuDepartController = TextEditingController();
  TextEditingController menuDestinationController = TextEditingController();
  TextEditingController prixController = TextEditingController();

  final DateGetController _dateNaissanceController = Get.put(DateGetController());
  final DateDelivreGetController _datePieceDelivreController = Get.put(DateDelivreGetController());
  final DateDebutActiviteGetController _dateDebutActiviteController = Get.put(DateDebutActiviteGetController());

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
  late Quartier leQuartierActivite;
  late Quartier leQuartierSiege;
  late List<Quartier> lesQuartiersIndex;
  late StatutMatrimonial leStatutMatrimonial;
  late String laCivilite;
  late GenericData leRegimeSocial;
  late GenericData leStatutArtisan;
  late GenericData leRegimetravailleur;
  late GenericData leRegimeImpositionCommunale;
  late GenericData leRegimeImpositionEntreprise;
  late GenericData laComptabilite;
  late GenericData leCompteBancaire;
  late GenericData lApprentissageMetier;
  late TypeCompteBancaire leTypeDeCompte;
  late TypeDocument leTypeDocument;
  late Commune laPieceDelivre;
  late NiveauEtude leNiveauEtude;
  late Classe laClasse;
  late Diplome leDiplome;
  late Metier leMetier;
  late Metier lActivitePrincipale;
  late Metier lActiviteSecondaire;
  late Commune laVilleCommune;
  late NiveauEquipement leNiveauEquipement;
  //
  late List<Departement> lesDepartementsFiltre;
  late List<SousPrefecture> lesSousPrefectureFiltre;

  int artisanId = 0;

  final lesCivilites = [
    'M',
    'Mme',
    'Mlle'
  ];
  // GenericData
  final lesStatutArtisan = [
    GenericData(libelle: 'Nouveau', id: 0),
    GenericData(libelle: 'Renouvellement', id: 1)
  ];
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
  void feedArtisan() async{
    artisanToManage = Artisan(
        id: 0,
        nom: nomController.text,
        prenom: prenomController.text,
        civilite: laCivilite,
        date_naissance: dateNaissanceController.text,
        numero_registre: numeroRegistreController.text.trim(),
        lieu_naissance_autre: lieuNaissanceAutreController.text,
        lieu_naissance: laCommune.id,
        nationalite: laNationalite.id,
        statut_matrimonial: leStatutMatrimonial.id,
        type_document: leTypeDocument.id,
        niveau_etude: leNiveauEtude.id,
        formation: lApprentissageMetier.id,
        classe: laClasse.id,
        diplome: leDiplome.id,
        commune_residence: laVilleResidence.id,
        activite: leMetier.id,
        sexe: '',
        numero_piece: numeroPieceIdentiteController.text,
        piece_delivre: laPieceDelivre.id,
        date_emission_piece: datePieceController.text,
        metier: leMetier.id,
        quartier_residence: quartierResidenceController.text,
        adresse_postal: adressePostaleController.text,
        contact1: contact1Controller.text,
        contact2: contact2Controller.text,
        email: emailController.text,
        photo_artisan: "",
        photo_cni_recto: "",
        photo_cni_verso: "",
        photo_diplome: "",
        date_expiration_carte: '',
        statut_kyc: 0,
        statut_paiement: 0,
        longitude: 0.0,
        latitude: 0.0,
        regime_social: leRegimeSocial.id,
        regime_travailleur: leRegimetravailleur.id,
        regime_imposition_taxe_communale: leRegimeImpositionCommunale.id,
        regime_imposition_micro_entreprise: leRegimeImpositionEntreprise.id,
        comptabilite: laComptabilite.id,
        chiffre_affaire: int.parse(chiffreAffaireController.text.replaceAll(',', '')),
        cnps: cnpsController.text,
        cmu: cmuController.text,
        presence_compte_bancaire: leCompteBancaire.id,
        type_compte_bancaire: leTypeDeCompte.id,
        crm: leCrm.id,
        departement: leDepartement.id,
        sous_prefecture: laSousPrefecture.id,
        specialite: leMetier.id,
        activite_principale: lActivitePrincipale.id,
        activite_secondaire: lActiviteSecondaire.id,

        raison_social: denominationController.text,
        sigle: sigleController.text,
        date_creation: dateDebutActiviteController.text,
        commune_activite: laVilleCommune.id,
        quartier_activite: '',// quartierCommuneController.text,
        rccm: rccmCommuneController.text,
        niveau_equipement: leNiveauEquipement.id,
        millisecondes: DateTime.now().millisecondsSinceEpoch,
        quartier_activite_id: leQuartierActivite.id,
        statut_artisan: leStatutArtisan.id
    );

    final result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) {
      return const InterfacePriseArtisanPhoto();
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
    leQuartierSiege = lesQuartiers.first;
    laPieceDelivre = lesCommunes.first;
    laVilleResidence = lesCommunes.first;
    
    // Init QUARTIERS :
    lesQuartiersIndex = lesQuartiers.where((q) => q.idx == laVilleCommune.id).toList();
    leQuartierActivite = lesQuartiersIndex.first;
    
    laCivilite = lesCivilites.first;
    laNationalite = lesPays.where((p) => p.id == 1).first; // Pick 'CÔTE d'IVOIRE' by DEFAULT
    leStatutMatrimonial = lesStatutMatrimoniaux.first;
    leRegimeSocial = lesGenericData.first;
    leRegimetravailleur = lesGenericData.first;
    leRegimeImpositionCommunale = lesGenericData.first;
    leRegimeImpositionEntreprise = lesGenericData.first;
    leCompteBancaire = lesGenericData.first;
    laComptabilite = lesGenericComptabilite.first;
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
    leStatutArtisan = lesStatutArtisan.first;

    _dateNaissanceController.clear();
    _datePieceDelivreController.clear();
    _dateDebutActiviteController.clear();

    // INITIALIZATION for CAMERA
    //setUpCameraController();

    lesDepartementsFiltre = lesDepartements;
    lesSousPrefectureFiltre = lesSousPrefectures;

    // INIT fields:
    lieuNaissanceAutreController.text = "";
    numeroPieceIdentiteController.text = "";
    quartierResidenceController.text = "";
    adressePostaleController.text = "";
    contact1Controller.text = "";
    contact2Controller.text = "";
    emailController.text = "";
    chiffreAffaireController.text = "0";
    cnpsController.text = "";
    cmuController.text = "";
    denominationController.text = "";
    sigleController.text = "";
    quartierCommuneController.text = "";
    rccmCommuneController.text = "";
    numeroRegistreController.text = "";
    datePieceController.text = "";

    // INIT DROPDOWN's Controller text fields
    communeController.text = laCommune.libelle;
    villeResidenceController.text = laVilleResidence.libelle;
    pieceDelivreController.text = laPieceDelivre.libelle;
    metierController.text = leMetier.libelle;
    activitePrincipaleController.text = lActivitePrincipale.libelle;
    activiteSecondaireController.text = lActiviteSecondaire.libelle;
    villeCommuneController.text = laVilleCommune.libelle;

    // Call this to INITIALIZE :
    filtrerDepartement();
  }

  void refreshVilleActivite(Commune commune) {
    // Init QUARTIERS :
    laVilleCommune = commune; // Refresh
    setState(() {
      lesQuartiersIndex = lesQuartiers.where((q) => q.idx == commune.id).toList();
      if(lesQuartiersIndex.isNotEmpty) {
        leQuartierActivite = lesQuartiersIndex.first;
      }
    });
  }

  void filtrerDepartement(){
    setState(() {
      lesDepartementsFiltre = lesDepartements.where((d) => d.idx == leCrm.id).toList();
      leDepartement = lesDepartementsFiltre.first;
      filtrerSousPrefecture();
    });
  }

  void filtrerSousPrefecture(){
    setState(() {
      lesSousPrefectureFiltre = lesSousPrefectures.where((d) => d.idx == leDepartement.id).toList();
      laSousPrefecture = lesSousPrefectureFiltre.first;
    });
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

  TextEditingController processDateDebutActivite(DateDebutActiviteGetController controller){
    dateDebutActiviteController = TextEditingController(
        text: controller.data.isNotEmpty ? controller.data[0] : '');
    return dateDebutActiviteController;
  }

  Future<void> _selectDate() async {
    choixDate = 0;
    final now = DateTime(1940, 1, 1, 00, 00);
    final initialDate = DateTime(2000, 1, 1, 00, 00);

    // Sélection de la date
    final selectedDate = await showDatePicker(
      locale: Locale(Platform.localeName.split("_").first, Platform.localeName.split("_").lastOrNull),
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: DateTime(2008, 12, 31, 00, 00)// DateTime.fromMillisecondsSinceEpoch(globalReservation!.fin),
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

  Future<void> _selectDateDebutActivite() async {
    choixDate = 1;
    final now = DateTime(1950, 1, 2, 00, 00);
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
    _dateDebutActiviteController.addData(selectedDate);
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
          ),
          Container(
              margin: EdgeInsets.only(left: spacingSteps, right: spacingSteps),
              child: Text('3',
                style: TextStyle(
                  fontSize: 30,
                  color: currentStep == 3 ? Colors.red : Colors.black,
                  fontWeight: currentStep == 3 ? FontWeight.bold : FontWeight.normal,
                ),)
          ),
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
                backgroundColor: MaterialStateColor.resolveWith((states) => Colors.blueGrey)
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
              //
              if(currentStep == 1){
                if(nomController.text.trim().isEmpty || prenomController.text.trim().isEmpty
                    || dateNaissanceController.text.isEmpty || (leTypeDocument.id != 7 &&
                    (datePieceController.text.isEmpty || numeroPieceIdentiteController.text.isEmpty)) ||
                    contact1Controller.text.trim().isEmpty || chiffreAffaireController.text.trim().isEmpty ||
                    (laCommune.id == 1 && lieuNaissanceAutreController.text.trim().isEmpty) ||
                    (leStatutArtisan.id == 1 && numeroRegistreController.text.trim().isEmpty)
                ){
                  displayToast('Veuillez renseigner les champs principaux');
                  return;
                }
              }

              if(currentStep == 2 && dateDebutActiviteController.text.trim().isEmpty){
                displayToast('Veuillez renseigner la date de Début d\'activité');
                return;
              }

              if(currentStep < 2) {
                // Next STEP :
                setState(() {
                  currentStep++;
                });
              }
              else{
                // Try to SEND this OBJECT :
                feedArtisan();
              }
            },
            icon: Icon(
              currentStep < 2 ? Icons.arrow_forward_ios : Icons.send,
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
          padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DropdownMenu<Crm>(
                  width: (MediaQuery.of(context).size.width / 2) - 20,
                  menuHeight: 250,
                  initialSelection: leCrm,
                  controller: crmController,
                  hintText: "Crm",
                  requestFocusOnTap: false,
                  enableSearch: false,
                  enableFilter: false,
                  label: const Text('CRM'),
                  // Initial Value
                  onSelected: (Crm? value) {
                    leCrm = value!;
                    filtrerDepartement();
                  },
                  dropdownMenuEntries:
                  lesCrms.map<DropdownMenuEntry<Crm>>((Crm menu) {
                    return DropdownMenuEntry<Crm>(
                        value: menu,
                        label: menu.libelle,
                        leadingIcon: Icon(Icons.location_city));
                  }).toList()
              ),
              DropdownMenu<Departement>(
                  width: (MediaQuery.of(context).size.width / 2) - 20,
                  menuHeight: 250,
                  initialSelection: leDepartement,
                  controller: departementController,
                  hintText: "Département",
                  requestFocusOnTap: false,
                  enableSearch: false,
                  enableFilter: false,
                  label: const Text('Département'),
                  // Initial Value
                  onSelected: (Departement? value) {
                    leDepartement = value!;
                    filtrerSousPrefecture();
                  },
                  dropdownMenuEntries:
                  lesDepartementsFiltre.map<DropdownMenuEntry<Departement>>((Departement menu) {
                    return DropdownMenuEntry<Departement>(
                        value: menu,
                        label: menu.libelle,
                        leadingIcon: Icon(Icons.location_city));
                  }).toList()
              )
            ],
          )
      ),
      Container(
        alignment: Alignment.topLeft,
        margin: EdgeInsets.only(top: 20, left: 10),
        width: MediaQuery.of(context).size.width,
        child: DropdownMenu<SousPrefecture>(
            width: (MediaQuery.of(context).size.width / 2) - 20,
            menuHeight: 250,
            initialSelection: laSousPrefecture,
            controller: sousPrefectureController,
            hintText: "Sous-préfecture",
            requestFocusOnTap: false,
            enableSearch: false,
            enableFilter: false,
            label: const Text('Sous-préfecture'),
            // Initial Value
            onSelected: (SousPrefecture? value) {
              laSousPrefecture = value!;
            },
            dropdownMenuEntries:
            lesSousPrefectureFiltre.map<DropdownMenuEntry<SousPrefecture>>((SousPrefecture menu) {
              return DropdownMenuEntry<SousPrefecture>(
                  value: menu,
                  label: menu.libelle,
                  leadingIcon: Icon(Icons.location_city));
            }).toList()
        ),
      ),
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
                      leStatutArtisan = value!;
                    })
                  },
                  compareFn: (GenericData? a, GenericData? b){
                    if(a == null || b == null){
                      return false;
                    }
                    return a.id == b.id;
                  },
                  selectedItem: leStatutArtisan,
                  itemAsString: (statut) => statut.libelle,
                  items: (filter, infiniteScrollProps) => lesStatutArtisan,
                  decoratorProps: DropDownDecoratorProps(
                    decoration: InputDecoration(
                      labelText: 'Statut artisan',
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
                  visible: leStatutArtisan.id == 1,
                  child: SizedBox(
                    width: (MediaQuery.of(context).size.width / 2) - 20,
                    child: TextField(
                      keyboardType: TextInputType.text,
                      controller: numeroRegistreController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Numéro registre',
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
                    //laCommune = value!
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
      )
      ,
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
              DropdownMenu<StatutMatrimonial>(
                  width: (MediaQuery.of(context).size.width / 2) - 20,
                  menuHeight: 250,
                  initialSelection: leStatutMatrimonial,
                  controller: statutMatrimonialController,
                  hintText: "Statut matrimonial",
                  requestFocusOnTap: false,
                  enableSearch: false,
                  enableFilter: false,
                  label: const Text('Statut matri.'),
                  // Initial Value
                  onSelected: (StatutMatrimonial? value) {
                    leStatutMatrimonial = value!;
                  },
                  dropdownMenuEntries:
                  lesStatutMatrimoniaux.map<DropdownMenuEntry<StatutMatrimonial>>((StatutMatrimonial menu) {
                    return DropdownMenuEntry<StatutMatrimonial>(
                        value: menu,
                        label: menu.libelle,
                        leadingIcon: Icon(Icons.people_outline_outlined));
                  }).toList()
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
              ),
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
          padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DropdownMenu<GenericData>(
                  width: (MediaQuery.of(context).size.width / 2) - 20,
                  menuHeight: 250,
                  initialSelection: leRegimeSocial,
                  controller: regimeSocialController,
                  hintText: "Régime social",
                  requestFocusOnTap: false,
                  enableSearch: false,
                  enableFilter: false,
                  label: const Text('Régime social'),
                  // Initial Value
                  onSelected: (GenericData? value) {
                    leRegimeSocial = value!;
                  },
                  dropdownMenuEntries:
                  lesGenericData.map<DropdownMenuEntry<GenericData>>((GenericData menu) {
                    return DropdownMenuEntry<GenericData>(
                        value: menu,
                        label: menu.libelle,
                        leadingIcon: Icon(Icons.work));
                  }).toList()
              ),
              DropdownMenu<GenericData>(
                  width: (MediaQuery.of(context).size.width / 2) - 20,
                  menuHeight: 250,
                  initialSelection: leRegimetravailleur,
                  controller: regimetravailleurController,
                  hintText: "Régime travailleur",
                  requestFocusOnTap: false,
                  enableSearch: false,
                  enableFilter: false,
                  label: const Text('Régime travailleur'),
                  // Initial Value
                  onSelected: (GenericData? value) {
                    leRegimetravailleur = value!;
                  },
                  dropdownMenuEntries:
                  lesGenericData.map<DropdownMenuEntry<GenericData>>((GenericData menu) {
                    return DropdownMenuEntry<GenericData>(
                        value: menu,
                        label: menu.libelle,
                        leadingIcon: Icon(Icons.work));
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
              DropdownMenu<GenericData>(
                  width: (MediaQuery.of(context).size.width / 2) - 20,
                  menuHeight: 250,
                  initialSelection: leRegimeImpositionCommunale,
                  controller: regimeImpositionCommunaleController,
                  hintText: "Imposition taxe communale",
                  requestFocusOnTap: false,
                  enableSearch: false,
                  enableFilter: false,
                  label: const Text('Imposition taxe'),
                  // Initial Value
                  onSelected: (GenericData? value) {
                    leRegimeImpositionCommunale = value!;
                  },
                  dropdownMenuEntries:
                  lesGenericData.map<DropdownMenuEntry<GenericData>>((GenericData menu) {
                    return DropdownMenuEntry<GenericData>(
                        value: menu,
                        label: menu.libelle,
                        leadingIcon: Icon(Icons.money));
                  }).toList()
              ),
              DropdownMenu<GenericData>(
                  width: (MediaQuery.of(context).size.width / 2) - 20,
                  menuHeight: 250,
                  initialSelection: leRegimeImpositionEntreprise,
                  controller: regimeImpositionEntrepriseController,
                  hintText: "Imposition micro Entreprise",
                  requestFocusOnTap: false,
                  enableSearch: false,
                  enableFilter: false,
                  label: const Text('Imposition micro Ent.'),
                  // Initial Value
                  onSelected: (GenericData? value) {
                    leRegimeImpositionEntreprise = value!;
                  },
                  dropdownMenuEntries:
                  lesGenericData.map<DropdownMenuEntry<GenericData>>((GenericData menu) {
                    return DropdownMenuEntry<GenericData>(
                        value: menu,
                        label: menu.libelle,
                        leadingIcon: Icon(Icons.money));
                  }).toList()
              )
            ],
          )
      ),
      Container(
        alignment: Alignment.topLeft,
        margin: EdgeInsets.only(top: 20, left: 10),
        width: MediaQuery.of(context).size.width,
        child: DropdownMenu<GenericData>(
            width: (MediaQuery.of(context).size.width / 2) - 20,
            menuHeight: 250,
            initialSelection: laComptabilite,
            controller: comptabiliteController,
            hintText: "Comptabilité",
            requestFocusOnTap: false,
            enableSearch: false,
            enableFilter: false,
            label: const Text('Comptabilité'),
            // Initial Value
            onSelected: (GenericData? value) {
              laComptabilite = value!;
            },
            dropdownMenuEntries:
            lesGenericComptabilite.map<DropdownMenuEntry<GenericData>>((GenericData menu) {
              return DropdownMenuEntry<GenericData>(
                  value: menu,
                  label: menu.libelle,
                  leadingIcon: Icon(Icons.account_balance));
            }).toList()
        ),
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
          padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DropdownMenu<GenericData>(
                  width: (MediaQuery.of(context).size.width / 2) - 20,
                  menuHeight: 250,
                  initialSelection: leCompteBancaire,
                  controller: comptebancaireController,
                  hintText: "Possède compte bancaire",
                  requestFocusOnTap: false,
                  enableSearch: false,
                  enableFilter: false,
                  label: const Text('Compte bancaire ?'),
                  // Initial Value
                  onSelected: (GenericData? value) {
                    leCompteBancaire = value!;
                  },
                  dropdownMenuEntries:
                  lesGenericData.map<DropdownMenuEntry<GenericData>>((GenericData menu) {
                    return DropdownMenuEntry<GenericData>(
                        value: menu,
                        label: menu.libelle,
                        leadingIcon: Icon(Icons.money));
                  }).toList()
              ),
              DropdownMenu<TypeCompteBancaire>(
                  width: (MediaQuery.of(context).size.width / 2) - 20,
                  menuHeight: 250,
                  initialSelection: leTypeDeCompte,
                  controller: typeDeCompteController,
                  hintText: "Type de compte",
                  requestFocusOnTap: false,
                  enableSearch: false,
                  enableFilter: false,
                  label: const Text('Type de compte'),
                  // Initial Value
                  onSelected: (TypeCompteBancaire? value) {
                    leTypeDeCompte = value!;
                  },
                  dropdownMenuEntries:
                  lesTypeCompteBancaires.map<DropdownMenuEntry<TypeCompteBancaire>>((TypeCompteBancaire menu) {
                    return DropdownMenuEntry<TypeCompteBancaire>(
                        value: menu,
                        label: menu.libelle,
                        leadingIcon: Icon(Icons.account_balance));
                  }).toList()
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
            child: TextField(
              onChanged: (value) {
                setState(() {
                  chiffreAffaireController.text = value;
                });
              },
              keyboardType: TextInputType.numberWithOptions(decimal: false),
              controller: chiffreAffaireController,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                ThousandsSeparatorInputFormatter(),
              ],
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: chiffreAffaireController.text.trim().isEmpty ?
                  Colors.red : Colors.black, width: 1.0),
                ),
                border: OutlineInputBorder(),
                labelText: 'Chiffre d\'affaire',
              ),
              style: const TextStyle(
                  height: 1.5
              ),
              textAlignVertical: TextAlignVertical.bottom,
              textAlign: TextAlign.center,
              textInputAction: TextInputAction.next,
            ),
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
                    setState(() {
                      leTypeDocument = value!;
                    });
                  },
                  dropdownMenuEntries:
                  lesTypeDocuments.map<DropdownMenuEntry<TypeDocument>>((TypeDocument menu) {
                    return DropdownMenuEntry<TypeDocument>(
                        value: menu,
                        label: menu.libelle,
                        leadingIcon: Icon(Icons.person_outline));
                  }).toList()
              ),
              Visibility(
                visible: leTypeDocument.id != 7,
                child: SizedBox(
                  width: (MediaQuery.of(context).size.width / 2) - 20,
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        numeroPieceIdentiteController.text = value;
                      });
                    },
                    keyboardType: TextInputType.text,
                    controller: numeroPieceIdentiteController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: numeroPieceIdentiteController.text.trim().isEmpty ?
                        Colors.red : Colors.black, width: 1.0),
                      ),
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
              )
            ],
          )
      ),
      Visibility(
        visible: leTypeDocument.id != 7,
        child: Container(
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
        )
      ),
      Visibility(
          visible: leTypeDocument.id != 7,
          child: Container(
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
  List<Widget> renseignementFormation(){
    return [
      lesEtapes(),
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
              DropdownMenu<GenericData>(
                  width: (MediaQuery.of(context).size.width / 2) - 20,
                  menuHeight: 250,
                  initialSelection: lApprentissageMetier,
                  controller: apprentissageMetierController,
                  hintText: "Apprentissage métier",
                  requestFocusOnTap: false,
                  enableSearch: false,
                  enableFilter: false,
                  label: const Text('Apprentissage métier'),
                  // Initial Value
                  onSelected: (GenericData? value) {
                    lApprentissageMetier = value!;
                  },
                  dropdownMenuEntries:
                  lesGenericApprentissagea.map<DropdownMenuEntry<GenericData>>((GenericData menu) {
                    return DropdownMenuEntry<GenericData>(
                        value: menu,
                        label: menu.libelle,
                        leadingIcon: Icon(Icons.school));
                  }).toList()
              )
            ],
          )
      ),
      Container(
        alignment: Alignment.topLeft,
        margin: EdgeInsets.only(top: 20, left: 10, right: 10),
        width: MediaQuery.of(context).size.width,
        child: DropdownSearch<Metier>(
          mode: Mode.form,
          onChanged: (Metier? value) => {
            leMetier = value!
          },
          compareFn: (Metier? a, Metier? b){
            if(a == null || b == null){
              return false;
            }
            return a.id == b.id;
          },
          selectedItem: leMetier,
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
        )
        /*DropdownMenu<Metier>(
            width: (MediaQuery.of(context).size.width / 2) - 20,
            menuHeight: 250,
            initialSelection: leMetier,
            controller: metierController,
            hintText: "Spécialité",
            requestFocusOnTap: true,
            enableSearch: true,
            enableFilter: false,
            label: const Text('Spécialité'),
            // Initial Value
            onSelected: (Metier? value) {
              leMetier = value!;
            },
            dropdownMenuEntries:
            lesMetiers.map<DropdownMenuEntry<Metier>>((Metier menu) {
              return DropdownMenuEntry<Metier>(
                  value: menu,
                  label: menu.libelle,
                  leadingIcon: Icon(Icons.work_history));
            }).toList()
        ),*/
      ),
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
          padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
              width: (MediaQuery.of(context).size.width / 2) - 20,
              child:DropdownSearch<Metier>(
                    mode: Mode.form,
                    onChanged: (Metier? value) => {
                      lActivitePrincipale = value!
                    },
                    compareFn: (Metier? a, Metier? b){
                      if(a == null || b == null){
                        return false;
                      }
                      return a.id == b.id;
                    },
                    selectedItem: lActivitePrincipale,
                    itemAsString: (metier) => metier.libelle,
                    items: (filter, infiniteScrollProps) => lesMetiers,
                    decoratorProps: DropDownDecoratorProps(
                      decoration: InputDecoration(
                        labelText: 'Activité principale',
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
                  )
              )
              /*DropdownMenu<Metier>(
                  width: (MediaQuery.of(context).size.width / 2) - 20,
                  menuHeight: 250,
                  initialSelection: lActivitePrincipale,
                  controller: activitePrincipaleController,
                  hintText: "Activité principale",
                  requestFocusOnTap: true,
                  enableSearch: true,
                  enableFilter: false,
                  label: const Text('Activité principale'),
                  // Initial Value
                  onSelected: (Metier? value) {
                    lActivitePrincipale = value!;
                  },
                  dropdownMenuEntries:
                  lesMetiers.map<DropdownMenuEntry<Metier>>((Metier menu) {
                    return DropdownMenuEntry<Metier>(
                        value: menu,
                        label: menu.libelle,
                        leadingIcon: Icon(Icons.work));
                  }).toList()
              )*/,
              SizedBox(
                width: (MediaQuery.of(context).size.width / 2) - 20,
                child:DropdownSearch<Metier>(
                  mode: Mode.form,
                  onChanged: (Metier? value) => {
                    lActiviteSecondaire = value!
                  },
                  compareFn: (Metier? a, Metier? b){
                    if(a == null || b == null){
                      return false;
                    }
                    return a.id == b.id;
                  },
                  selectedItem: lActiviteSecondaire,
                  itemAsString: (metier) => metier.libelle,
                  items: (filter, infiniteScrollProps) => lesMetiers,
                  decoratorProps: DropDownDecoratorProps(
                    decoration: InputDecoration(
                      labelText: 'Activité secondaire',
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
                )
              ),
              /*DropdownMenu<Metier>(
                  width: (MediaQuery.of(context).size.width / 2) - 20,
                  menuHeight: 250,
                  initialSelection: lActiviteSecondaire,
                  controller: activiteSecondaireController,
                  hintText: "Activité secondaire",
                  requestFocusOnTap: true,
                  enableSearch: true,
                  enableFilter: false,
                  label: const Text('Activité secondaire'),
                  // Initial Value
                  onSelected: (Metier? value) {
                    lActiviteSecondaire = value!;
                  },
                  dropdownMenuEntries:
                  lesMetiers.map<DropdownMenuEntry<Metier>>((Metier menu) {
                    return DropdownMenuEntry<Metier>(
                        value: menu,
                        label: menu.libelle,
                        leadingIcon: Icon(Icons.work));
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
                  onChanged: (value) {
                    denominationController.text = value;
                  },
                  keyboardType: TextInputType.text,
                  controller: denominationController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1.0),
                    ),
                    border: OutlineInputBorder(),
                    labelText: 'Dénomination',
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
                  controller: sigleController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Sigle',
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
                child: ElevatedButton.icon(
                  style: ButtonStyle(
                      backgroundColor: WidgetStateColor.resolveWith((states) => Colors.brown)
                  ),
                  label: const Text("Date début activité",
                      style: TextStyle(
                          color: Colors.white
                      )
                  ),
                  onPressed: () {
                    _selectDateDebutActivite();
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
                        controller: processDateDebutActivite(controller),
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
          padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: (MediaQuery.of(context).size.width / 2) - 20,
                child: DropdownSearch<Commune>(
                  mode: Mode.form,
                  onChanged: (Commune? value) => {
                    //laCommune = value!
                    refreshVilleActivite(value!)
                    /*setState(() {
                      laVilleCommune = value!;
                    })*/
                  },
                  compareFn: (Commune? a, Commune? b){
                    if(a == null || b == null){
                      return false;
                    }
                    return a.id == b.id;
                  },
                  selectedItem: laVilleCommune,
                  itemAsString: (commune) => commune.libelle,
                  items: (filter, infiniteScrollProps) => lesCommunes,
                  decoratorProps: DropDownDecoratorProps(
                    decoration: InputDecoration(
                      labelText: 'Commune d\'activité',
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
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width / 2) - 20,
                child: DropdownSearch<Quartier>(
                  mode: Mode.form,
                  onChanged: (Quartier? value) => {
                    leQuartierActivite = value!
                  },
                  compareFn: (Quartier? a, Quartier? b){
                    if(a == null || b == null){
                      return false;
                    }
                    return a.id == b.id;
                  },
                  selectedItem: leQuartierActivite,
                  itemAsString: (commune) => commune.libelle,
                  items: (filter, infiniteScrollProps) => lesQuartiersIndex,
                  decoratorProps: DropDownDecoratorProps(
                    decoration: InputDecoration(
                      labelText: 'Quartier Activité',
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
              ),

              /*SizedBox(
                width: (MediaQuery.of(context).size.width / 2) - 20,
                child: TextField(
                  keyboardType: TextInputType.text,
                  controller: quartierCommuneController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Quartier',
                  ),
                  style: const TextStyle(
                      height: 1.5
                  ),
                  textAlignVertical: TextAlignVertical.bottom,
                  textAlign: TextAlign.center,
                  textInputAction: TextInputAction.next,
                ),
              )*/
            ],
          )
      ),
      Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: (MediaQuery.of(context).size.width / 2) - 20,
                child: TextField(
                  keyboardType: TextInputType.text,
                  controller: rccmCommuneController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'RCCM',
                  ),
                  style: const TextStyle(
                      height: 1.5
                  ),
                  textAlignVertical: TextAlignVertical.bottom,
                  textAlign: TextAlign.center,
                  textInputAction: TextInputAction.next,
                ),
              ),
              DropdownMenu<NiveauEquipement>(
                  width: (MediaQuery.of(context).size.width / 2) - 20,
                  menuHeight: 250,
                  initialSelection: leNiveauEquipement,
                  controller: niveauEquipementController,
                  hintText: "Niveau équipement",
                  requestFocusOnTap: false,
                  enableSearch: false,
                  enableFilter: false,
                  label: const Text('Niveau équipement'),
                  // Initial Value
                  onSelected: (NiveauEquipement? value) {
                    leNiveauEquipement = value!;
                  },
                  dropdownMenuEntries:
                  lesNiveauEquipement.map<DropdownMenuEntry<NiveauEquipement>>((NiveauEquipement menu) {
                    return DropdownMenuEntry<NiveauEquipement>(
                        value: menu,
                        label: menu.libelle,
                        leadingIcon: Icon(Icons.devices_other));
                  }).toList()
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
          title: Text(idpub == 0 ? 'Nouvel Artisan' : 'Modification Artisan'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children:
            currentStep == 1 ?
            renseignementPersonne() :
            renseignementFormation()
          ),
        )
    );
  }
}