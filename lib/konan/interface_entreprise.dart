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
import 'package:cnmci/konan/model/entreprise.dart';
import 'package:cnmci/konan/model/metier.dart';
import 'package:cnmci/konan/model/niveau_etude.dart';
import 'package:cnmci/konan/model/pays.dart';
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
import '../getxcontroller/date_immatricualtion_controller.dart';
import '../getxcontroller/datecontroller.dart';
import '../getxcontroller/entreprise_controller_x.dart';
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
import 'package:geolocator/geolocator.dart';


class InterfaceEntreprise extends StatefulWidget {
  const InterfaceEntreprise({Key? key}) : super(key: key);

  @override
  State<InterfaceEntreprise> createState() => _InterfaceEntreprise();
}


class _InterfaceEntreprise extends State<InterfaceEntreprise> with WidgetsBindingObserver {

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
  TextEditingController ilotController = TextEditingController();
  TextEditingController telephonEntrepriseController = TextEditingController();
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
  TextEditingController capitalSocialController = TextEditingController();
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
  TextEditingController objetSocialController = TextEditingController();
  TextEditingController sigleController = TextEditingController();
  TextEditingController dateDebutActiviteController = TextEditingController();
  TextEditingController dateImmatriculationController = TextEditingController();
  TextEditingController villeCommuneController = TextEditingController();
  TextEditingController rccmController = TextEditingController();
  TextEditingController niveauEquipementController = TextEditingController();

  TextEditingController menuCountryDepartController = TextEditingController();
  TextEditingController menuDepartController = TextEditingController();
  TextEditingController menuDestinationController = TextEditingController();
  TextEditingController prixController = TextEditingController();
  // ENTREPRISE
  TextEditingController formeJuridiqueController = TextEditingController();
  TextEditingController regimeFiscalController = TextEditingController();
  TextEditingController dureePersonneMoraleController = TextEditingController();
  TextEditingController cnpsEntrepriseController = TextEditingController();
  TextEditingController compteContribuableController = TextEditingController();
  TextEditingController nombreAssocieController = TextEditingController();

  final DateGetController _dateNaissanceController = Get.put(DateGetController());
  final DateDelivreGetController _datePieceDelivreController = Get.put(DateDelivreGetController());
  final DateDebutActiviteGetController _dateDebutCreationController = Get.put(DateDebutActiviteGetController());
  final DateImmatricualtionController _dateImmatricualtionController = Get.put(DateImmatricualtionController());

  double _currentDiscreteSliderValue = 8.0;

  //
  bool initInterface = false;

  late bool _isLoading;
  // Initial value :
  //final _userRepository = UserRepository();
  late BuildContext dialogContext;
  bool flagSendData = false;
  bool flagServerResponse = false;
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

  double latitude = 0;
  double longitude = 0;
  double precisionGps = 0.0;
  bool streamGps = false;
  late StreamSubscription<Position> positionStream;

  int stepForPhoto = 0;

  late Crm leCrm;
  late Departement leDepartement;
  late SousPrefecture laSousPrefecture;
  late Pays laNationalite;
  late Commune laCommune;
  late Commune laVilleResidence;
  late StatutMatrimonial leStatutMatrimonial;
  late String laCivilite;
  late GenericData leRegimeSocial;
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
  // ENTREPRISE :
  late GenericData laFormeJuridique;
  late GenericData leRegimeFiscal;
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
  // FORME JURIDIQUE
  final lesFormesJuridiques = [
    GenericData(libelle: 'SARL', id: 1),
    GenericData(libelle: 'Sté copérative', id: 2),
    GenericData(libelle: 'GIE', id: 3)
  ];
  // REGIME FISCAUX
  final lesRegimesFiscaux = [
    GenericData(libelle: 'Taxe communale de l\'entreprenant', id: 1),
    GenericData(libelle: 'Taxe d\'Etat de l\'entreprenant', id: 2),
    GenericData(libelle: 'Autres', id: 3)
  ];


  // M E T H O D S
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Pause GPS if APPLICATION loses focus
    if(state == AppLifecycleState.inactive && streamGps){
      positionStream.pause();
    }
    else if(state == AppLifecycleState.resumed && streamGps){
      positionStream.resume();
    }
  }


  void displayDataSending(){
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          dialogContext = context;
          return PopScope(
              canPop: false,
              child: AlertDialog(
                  title: Text('Information'),
                  content: SizedBox(
                      height: 100,
                      child: Column(
                        children: [
                          Text('Veuillez patienter ...'),
                          const SizedBox(
                            height: 20,
                          ),
                          const SizedBox(
                              height: 30.0,
                              width: 30.0,
                              child:
                              CircularProgressIndicator(
                                valueColor:
                                AlwaysStoppedAnimation<
                                    Color>(Colors.blue),
                                strokeWidth: 3.0,
                              ))
                        ],
                      )
                  )
              )
          );
        });

    flagSendData = true;
    flagServerResponse = true;

    sendData();

    Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (!flagServerResponse) {
          Navigator.pop(dialogContext);
          timer.cancel();

          if (!flagSendData) {
            Navigator.pop(context);
          } else {
            displayToast('Traitement impossible');
          }
        }
      },
    );
  }


  Future<void> sendData() async {
    // First Call this :
    var localToken = await MesServices().checkJwtExpiration();
    final url = Uri.parse('${dotenv.env['URL_BACKEND']}manage-entreprisemobile');
    try {
      var response = await post(url,
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer $localToken'
          },
          body: jsonEncode(
              {
                "gerant_id": 0,
                "civilite": laCivilite,
                "nom": nomController.text,
                "prenom": prenomController.text,
                "date_naissance": dateNaissanceController.text,
                "lieu_naissance": laCommune.id.toString(),
                "lieu_naissance_autre": lieuNaissanceAutreController.text,
                "nationalite": laNationalite.id.toString(),
                "sexe": "",
                "statut_matrimonial": leStatutMatrimonial.id,
                "type_document": leTypeDocument.id.toString(),
                "numero_piece": numeroPieceIdentiteController.text,
                "piece_delivre": laPieceDelivre.id.toString(),
                "date_emission_piece": datePieceController.text,
                "ville_residence": laVilleResidence.id,
                "quartier_residence": quartierResidenceController.text,
                "adresse_postal": adressePostaleController.text,
                "contact1": contact1Controller.text,
                "contact2": contact2Controller.text,
                "email": emailController.text,
                "numero_id": 0,
                "numero_rea": "",
                "forme_juridique": laFormeJuridique.id,
                "activite_principale": lActivitePrincipale.id,
                "activite_secondaire": lActiviteSecondaire.id,
                "raison_social": denominationController.text,
                "sigle": sigleController.text,
                "objet_social": objetSocialController.text,
                "date_creation": dateDebutActiviteController.text,
                "rccm": rccmController.text,
                "date_rccm": dateImmatriculationController.text,
                "capital_social": int.parse(capitalSocialController.text.replaceAll(',', '')),
                "regime_fiscal": leRegimeFiscal.libelle,//.id.toString(),
                "nombre_associer": int.parse(nombreAssocieController.text.replaceAll(',', '')),
                "duree_personne_morale": int.parse(dureePersonneMoraleController.text),
                "numero_cnps": cnpsEntrepriseController.text,
                "compte_contribuable": compteContribuableController.text,
                "ilot_lot": ilotController.text,
                "contact_entreprise": telephonEntrepriseController.text,
                "adresse": adressePostaleController.text,
                "longitude": longitude,
                "latitude": latitude,
                "commune": laVilleCommune.id,
                "quartier": quartierCommuneController.text
          })
      ).timeout(const Duration(seconds: timeOutValue));

      if (response.statusCode == 200) {
        MessageResponse reponse = MessageResponse.fromJson(
            json.decode(response.body));
        entrepriseToManage = Entreprise(
            id: reponse.id,
            crm: leCrm.id,
            departement: leDepartement.id,
            sous_prefecture: laSousPrefecture.id,
            civilite: laCivilite,
            nom: nomController.text,
            prenom: prenomController.text,
            date_naissance: dateNaissanceController.text,
            lieu_naissance: laCommune.id,
            lieu_naissance_autre: lieuNaissanceAutreController.text,
            nationalite: laNationalite.id,
            statut_matrimonial: leStatutMatrimonial.id,
            type_document: leTypeDocument.id,
            numero_piece: numeroPieceIdentiteController.text,
            piece_delivre: laPieceDelivre.id,
            date_emission_piece: datePieceController.text,
            commune_residence: laVilleResidence.id,
            quartier_residence: quartierResidenceController.text,
            adresse_postal: adressePostaleController.text,
            contact1: contact1Controller.text,
            contact2: contact2Controller.text,
            email: emailController.text,

            forme_juridique: laFormeJuridique.id,
            activite_principale: lActivitePrincipale.id,
            activite_secondaire: lActiviteSecondaire.id,
            denomination: denominationController.text,
            sigle: sigleController.text,
            date_creation: dateDebutActiviteController.text,
            objet_social: objetSocialController.text,
            rccm: rccmController.text,
            date_rccm: dateImmatriculationController.text,
            capital_social: int.parse(capitalSocialController.text.replaceAll(',', '')),
            regime_fiscal: leRegimeFiscal.id,
            duree_personne_morale: int.parse(dureePersonneMoraleController.text),
            cnps_entreprise: cnpsEntrepriseController.text,
            compte_contribuable: compteContribuableController.text,
            total_associe: int.parse(nombreAssocieController.text),
            commune_siege: laVilleCommune.id,
            quartier_siege: quartierCommuneController.text,
            lot: ilotController.text,
            telephone: telephonEntrepriseController.text,
            statut_kyc: 0,
            statut_paiement: 0,
            longitude: longitude,
            latitude: latitude,
          millisecondes: DateTime.now().millisecondsSinceEpoch
        );
        entrepriseControllerX.addItem(entrepriseToManage);
        flagSendData = false;
      } else {
        displayToast("Impossible de synchroniser vos données");
      }
    } catch (e) {
      displayToast("Impossible de traiter les données : $e");
    } finally {
      streamGps = false;
      flagServerResponse = false;
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
    laNationalite = lesPays.first;
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

    // ENTREPRISE
    laFormeJuridique = lesFormesJuridiques.first;
    leRegimeFiscal = lesRegimesFiscaux.first;

    _dateNaissanceController.clear();
    _datePieceDelivreController.clear();
    _dateDebutCreationController.clear();
    _dateImmatricualtionController.clear();

    // INITIALIZATION for CAMERA
    //setUpCameraController();

    lesDepartementsFiltre = lesDepartements;
    lesSousPrefectureFiltre = lesSousPrefectures;

    // Set DEFAULT DATA :
    lieuNaissanceAutreController.text = "";
    numeroPieceIdentiteController.text = "";
    quartierResidenceController.text = "";
    adressePostaleController.text = "";
    contact1Controller.text = "";
    contact2Controller.text = "";
    emailController.text = "";
    emailController.text = "";
    denominationController.text = "";
    sigleController.text = "";
    objetSocialController.text = "";
    rccmController.text = "";
    capitalSocialController.text = "0";
    nombreAssocieController.text = "0";
    dureePersonneMoraleController.text = "0";
    cnpsEntrepriseController.text = "";
    compteContribuableController.text = "";
    ilotController.text = "";
    telephonEntrepriseController.text = "";
    adressePostaleController.text = "";
    quartierCommuneController.text = "";

    communeController.text = laCommune.libelle;
    villeResidenceController.text = laVilleResidence.libelle;
    pieceDelivreController.text = laPieceDelivre.libelle;
    activitePrincipaleController.text = lActivitePrincipale.libelle;
    activiteSecondaireController.text = lActiviteSecondaire.libelle;
    villeCommuneController.text = laVilleCommune.libelle;

    // Call this to INITIALIZE :
    filtrerDepartement();
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

    // In case BACK BUTTON is pressed :
    if(streamGps){
      streamGps = false;
      positionStream.cancel();
    }
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

  TextEditingController processDateImmatriculation(DateImmatricualtionController controller){
    dateImmatriculationController = TextEditingController(
        text: controller.data.isNotEmpty ? controller.data[0] : '');
    return dateImmatriculationController;
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

  Future<void> _selectDateCreation() async {
    choixDate = 1;
    final now = DateTime(2000, 1, 2, 00, 00);
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
    _dateDebutCreationController.addData(selectedDate);
  }

  Future<void> _selectDateImmatriculation() async {
    choixDate = 1;
    final now = DateTime(2000, 1, 2, 00, 00);
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
    _dateImmatricualtionController.addData(selectedDate);
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
              if(streamGps){
                positionStream.pause();
                positionStream.cancel();
                streamGps = false;
              }
              // Next :
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
              if(!streamGps) {
                if (currentStep == 2) {
                  if (capitalSocialController.text.trim().isEmpty) {
                    displayToast('Veuillez définir le CAPITAL SOCIAL !');
                    return;
                  }
                  else if (dureePersonneMoraleController.text.trim().isEmpty) {
                    displayToast('Veuillez définir la durée de la personne morale !');
                    return;
                  }
                  else if (nombreAssocieController.text.trim().isEmpty) {
                    displayToast('Veuillez définir le nombre d\'associés !');
                    return;
                  }
                }

                // check on ville :
                if (currentStep == 2) {
                  if (nomController.text.trim().isEmpty || prenomController.text.trim().isEmpty ||
                      dateNaissanceController.text.isEmpty || dateImmatriculationController.text.isEmpty ||
                      datePieceController.text.isEmpty ||
                      contact1Controller.text
                          .trim()
                          .isEmpty ||
                      (laCommune.id == 1 && lieuNaissanceAutreController.text
                          .trim()
                          .isEmpty) ||
                      denominationController.text
                          .trim()
                          .isEmpty || rccmController.text
                      .trim()
                      .isEmpty ||
                      compteContribuableController.text
                          .trim()
                          .isEmpty) {
                    displayToast('Veuillez renseigner les champs principaux');
                    return;
                  }
                }

                if (currentStep < 2) {
                  // Next STEP :
                  setState(() {
                    currentStep++;
                  });
                }
                else {
                  try {
                    var getstreamGpsData = await MesServices()
                        .determinePositionStream();
                    if (getstreamGpsData) {
                      setState(() {
                        streamGps = getstreamGpsData;
                      });

                      final LocationSettings locationSettings = LocationSettings(
                        accuracy: LocationAccuracy.high,
                      );

                      positionStream =
                          Geolocator.getPositionStream(
                              locationSettings: locationSettings).listen(
                                  (Position? position) {
                                if (position != null) {
                                  setState(() {
                                    latitude = position.latitude;
                                    longitude = position.longitude;
                                    precisionGps = double.parse(
                                        position.accuracy.toStringAsFixed(2));
                                    if (precisionGps < gpsPrecisionAccuracy ||
                                        precisionGps < _currentDiscreteSliderValue) {
                                      positionStream.cancel();

                                      // Send DATA :
                                      displayDataSending();
                                    }
                                  });
                                }
                              }
                          );
                    }
                    else {
                      displayToast('Veuillez autoriser le GPS !');
                    }
                  } catch (e) {
                    displayToast('Le GPS est obligatoire !');
                  }
                }
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

  List<Widget> renseignementGerant(){
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
        margin: EdgeInsets.only(top: 40, left: 10, right: 10),
        alignment: Alignment.topLeft,
        child: Text('Information Gérant',
          style: TextStyle(
            fontSize: 20,
            color: Colors.brown,
            fontWeight: FontWeight.bold
          ),
        ),
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
                  requestFocusOnTap: true,
                  enableSearch: true,
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
          padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
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
              )*/,
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
      lesBoutons()
    ];
  }
  List<Widget> renseignementEntreprise(){
    return [
      lesEtapes(),
      Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
          SizedBox(
            width: (MediaQuery.of(context).size.width / 2) - 20,
            child: DropdownMenu<GenericData>(
              menuHeight: 250,
              initialSelection: laFormeJuridique,
              controller: formeJuridiqueController,
              hintText: "Forme Juridique",
              requestFocusOnTap: false,
              enableSearch: false,
              enableFilter: false,
              label: const Text('Forme Juridique'),
              // Initial Value
              onSelected: (GenericData? value) {
                laFormeJuridique = value!;
              },
              dropdownMenuEntries:
              lesFormesJuridiques.map<DropdownMenuEntry<GenericData>>((GenericData menu) {
                return DropdownMenuEntry<GenericData>(
                    value: menu,
                    label: menu.libelle,
                    leadingIcon: Icon(Icons.school));
              }).toList()
              )
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
                child: DropdownSearch<Metier>(
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
                ),
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width / 2) - 20,
                child: DropdownSearch<Metier>(
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
                ),
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
                      denominationController.text = value;
                    });
                  },
                  keyboardType: TextInputType.text,
                  controller: denominationController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: denominationController.text.trim().isEmpty ?
                      Colors.red : Colors.black, width: 1.0),
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
                  onChanged: (value) {
                    setState(() {
                      sigleController.text = value;
                    });
                  },
                  keyboardType: TextInputType.text,
                  controller: sigleController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1.0),
                    ),
                    border: OutlineInputBorder(),
                    labelText: 'Sigle',
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
                  label: const Text("Date de création",
                      style: TextStyle(
                          color: Colors.white
                      )
                  ),
                  onPressed: () {
                    _selectDateCreation();
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
          padding: const EdgeInsets.only(left: 10, right: 10, top: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: (MediaQuery.of(context).size.width / 2) - 20,
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      objetSocialController.text = value;
                    });
                  },
                  keyboardType: TextInputType.text,
                  controller: objetSocialController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1.0),
                    ),
                    border: OutlineInputBorder(),
                    labelText: 'Objet social',
                  ),
                  style: const TextStyle(
                      height: 1.5
                  ),
                  textAlignVertical: TextAlignVertical.bottom,
                  textAlign: TextAlign.center,
                  textInputAction: TextInputAction.next,
                )
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width / 2) - 20,
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      rccmController.text = value;
                    });
                  },
                  keyboardType: TextInputType.text,
                  controller: rccmController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: rccmController.text.trim().isEmpty ?
                      Colors.red : Colors.black, width: 1.0),
                    ),
                    border: OutlineInputBorder(),
                    labelText: 'N° R.C.C.M.',
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
                  label: const Text("Date d'immatriculation",
                      style: TextStyle(
                          color: Colors.white
                      )
                  ),
                  onPressed: () {
                    _selectDateImmatriculation();
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
                child: GetBuilder<DateImmatricualtionController>(
                    builder: (DateImmatricualtionController controller) {
                      return TextField(
                        enabled: false,
                        controller: processDateImmatriculation(controller),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Date immat...',
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
          padding: const EdgeInsets.only(left: 10, right: 10, top: 17),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: (MediaQuery.of(context).size.width / 2) - 20,
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      capitalSocialController.text = value;
                    });
                  },
                  keyboardType: TextInputType.numberWithOptions(decimal: false),
                  controller: capitalSocialController,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandsSeparatorInputFormatter(),
                  ],
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: capitalSocialController.text.trim().isEmpty ?
                      Colors.red : Colors.black, width: 1.0),
                    ),
                    border: OutlineInputBorder(),
                    labelText: 'Capital social',
                  ),
                  style: const TextStyle(
                      height: 1.5
                  ),
                  textAlignVertical: TextAlignVertical.bottom,
                  textAlign: TextAlign.center,
                  textInputAction: TextInputAction.next,
                ),
              ),
              DropdownMenu<GenericData>(
                  width: (MediaQuery.of(context).size.width / 2) - 20,
                  menuHeight: 250,
                  initialSelection: leRegimeFiscal,
                  controller: regimeFiscalController,
                  hintText: "Régime fiscal",
                  requestFocusOnTap: false,
                  enableSearch: false,
                  enableFilter: false,
                  label: const Text('Régime fiscal'),
                  // Initial Value
                  onSelected: (GenericData? value) {
                    leRegimeFiscal = value!;
                  },
                  dropdownMenuEntries:
                  lesRegimesFiscaux.map<DropdownMenuEntry<GenericData>>((GenericData menu) {
                    return DropdownMenuEntry<GenericData>(
                        value: menu,
                        label: menu.libelle,
                        leadingIcon: Icon(Icons.location_city));
                  }).toList()
              )
            ],
          )
      ),
      Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(left: 10, right: 10, top: 17),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: (MediaQuery.of(context).size.width / 2) - 20,
                child: TextField(
                  maxLength: 2,
                  onChanged: (value) {
                    setState(() {
                      dureePersonneMoraleController.text = value;
                    });
                  },
                  keyboardType: TextInputType.numberWithOptions(decimal: false),
                  controller: dureePersonneMoraleController,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandsSeparatorInputFormatter(),
                  ],
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: dureePersonneMoraleController.text.trim().isEmpty ?
                      Colors.red : Colors.black, width: 1.0),
                    ),
                    border: OutlineInputBorder(),
                    labelText: 'Durée de la personne morale',
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
                      cnpsEntrepriseController.text = value;
                    });
                  },
                  keyboardType: TextInputType.text,
                  controller: cnpsEntrepriseController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1.0),
                    ),
                    border: OutlineInputBorder(),
                    labelText: 'N° CNPS Entreprise',
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
          padding: const EdgeInsets.only(left: 10, right: 10, top: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: (MediaQuery.of(context).size.width / 2) - 20,
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      compteContribuableController.text = value;
                    });
                  },
                  keyboardType: TextInputType.text,
                  controller: compteContribuableController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: compteContribuableController.text.trim().isEmpty ?
                      Colors.red : Colors.black, width: 1.0),
                    ),
                    border: OutlineInputBorder(),
                    labelText: 'N° Compte contribuable',
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
                  maxLength: 2,
                  onChanged: (value) {
                    setState(() {
                      nombreAssocieController.text = value;
                    });
                  },
                  keyboardType: TextInputType.numberWithOptions(decimal: false),
                  controller: nombreAssocieController,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandsSeparatorInputFormatter(),
                  ],
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: nombreAssocieController.text.trim().isEmpty ?
                      Colors.red : Colors.black, width: 1.0),
                    ),
                    border: OutlineInputBorder(),
                    labelText: 'Nombre d\'associés',
                  ),
                  style: const TextStyle(
                      height: 1.5
                  ),
                  textAlignVertical: TextAlignVertical.bottom,
                  textAlign: TextAlign.center,
                  textInputAction: TextInputAction.next,
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
                    laVilleCommune = value!
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
                      labelText: 'Ville/Commune',
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
                  initialSelection: laVilleCommune,
                  controller: villeCommuneController,
                  hintText: "Ville/Commune",
                  requestFocusOnTap: true,
                  enableSearch: true,
                  enableFilter: false,
                  label: const Text('Ville/Commune'),
                  // Initial Value
                  onSelected: (Commune? value) {
                    laVilleCommune = value!;
                  },
                  dropdownMenuEntries:
                  lesCommunes.map<DropdownMenuEntry<Commune>>((Commune menu) {
                    return DropdownMenuEntry<Commune>(
                        value: menu,
                        label: menu.libelle,
                        leadingIcon: Icon(Icons.location_city));
                  }).toList()
              )*/,
              SizedBox(
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
              )
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
                  controller: ilotController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'ILOT / LOT ',
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
                  controller: telephonEntrepriseController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Téléphone entrepr.',
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

      Visibility(
          visible: streamGps,
          child: Container(
            /*width: MediaQuery.of(context).size.width,*/
            margin: const EdgeInsets.only(left: 10, right: 10, top: 40),
            child: Text('Précision : $precisionGps m'),
          )
      ),
      Visibility(
          visible: streamGps,
          child: Slider(
              activeColor: Colors.brown,
              value: _currentDiscreteSliderValue,
              min: 5,
              divisions: 5,
              max: 20,
              onChanged: (double valeur){
                setState(() {
                  _currentDiscreteSliderValue = valeur;
                });
              }
          )
      ),
      Visibility(
          visible: streamGps,
          child: Container(
            margin: EdgeInsets.only(left: 10, right: 10, top: 20),
            child: Text('Précision minimale : $_currentDiscreteSliderValue m',
              style: TextStyle(
                  fontWeight: FontWeight.bold
              ),
            ),
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
          title: Text(idpub == 0 ? 'Nouvelle Entreprise' : 'Modification Entreprise'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children:
            currentStep == 1 ?
            renseignementGerant() :
            renseignementEntreprise()
          ),
        )
    );
  }
}