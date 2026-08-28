import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:io' as io;
import 'package:cnmci/konan/beans/generic_data.dart';
import 'package:cnmci/konan/interface_prise_entreprise_photo.dart';
import 'package:cnmci/konan/local_data/niveau_equipement.dart';
import 'package:cnmci/konan/model/co_gerant.dart';
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
import 'interface_prise_cogerant_photo.dart';
import 'model/classe.dart';
import 'model/crm.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;

import 'model/quartier.dart';
import 'objets/amountseparator.dart';
import 'objets/constants.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

class InterfaceCogerantPersonne extends StatefulWidget {
  final CoGerant? coGerant;
  final int entrepriseId;
  const InterfaceCogerantPersonne({
    Key? key,
    required this.coGerant,
    required this.entrepriseId,
  }) : super(key: key);

  @override
  State<InterfaceCogerantPersonne> createState() =>
      _InterfaceCogerantPersonne();
}

class _InterfaceCogerantPersonne extends State<InterfaceCogerantPersonne>
    with WidgetsBindingObserver {
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
  TextEditingController qualificationController = TextEditingController();
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
  TextEditingController regimeImpositionCommunaleController =
      TextEditingController();
  TextEditingController regimeImpositionEntrepriseController =
      TextEditingController();
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

  final DateGetController _dateNaissanceController = Get.put(
    DateGetController(),
  );
  final DateDelivreGetController _datePieceDelivreController = Get.put(
    DateDelivreGetController(),
  );
  final DateDebutActiviteGetController _dateDebutCreationController = Get.put(
    DateDebutActiviteGetController(),
  );
  final DateImmatricualtionController _dateImmatricualtionController = Get.put(
    DateImmatricualtionController(),
  );

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
  bool initCommuneActivite = false;
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
  late Quartier leQuartierActivite;
  late List<Quartier> lesQuartiersIndex;
  late NiveauEquipement leNiveauEquipement;
  // ENTREPRISE :
  late GenericData laFormeJuridique;
  late GenericData leRegimeFiscal;
  //
  late List<Departement> lesDepartementsFiltre;
  late List<SousPrefecture> lesSousPrefectureFiltre;
  late GenericData laLivraison;
  late List<Commune> lesCommunesActivite;

  int artisanId = 0;

  final lesGenericLivraisons = [
    GenericData(libelle: 'Non', id: 0),
    GenericData(libelle: 'Oui', id: 1),
  ];
  final lesCivilites = ['M', 'Mme', 'Mlle'];
  // GenericData
  final lesGenericData = [
    GenericData(libelle: 'Oui', id: 1),
    GenericData(libelle: 'Non', id: 0),
  ];
  final lesGenericComptabilite = [
    GenericData(libelle: 'Aucune', id: 0),
    GenericData(libelle: 'Comptabilité simplifiée', id: 1),
    GenericData(libelle: 'Comptabilité normale', id: 2),
  ];
  final lesGenericApprentissagea = [
    GenericData(libelle: 'Centre de Formation Professionnelle', id: 2),
    GenericData(libelle: 'Sur le tas', id: 1),
  ];
  //
  final lesNiveauEquipement = [
    NiveauEquipement(libelle: 'Précaire', id: 0),
    NiveauEquipement(libelle: 'Moyen', id: 1),
    NiveauEquipement(libelle: 'Bon', id: 2),
  ];
  // FORME JURIDIQUE
  final lesFormesJuridiques = [
    GenericData(libelle: 'SARL', id: 1),
    GenericData(libelle: 'Sté copérative', id: 2),
    GenericData(libelle: 'GIE', id: 3),
  ];
  // REGIME FISCAUX
  final lesRegimesFiscaux = [
    GenericData(libelle: 'Taxe communale de l\'entreprenant', id: 1),
    GenericData(libelle: 'Taxe d\'Etat de l\'entreprenant', id: 2),
    GenericData(libelle: 'Autres', id: 3),
  ];

  // M E T H O D S
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Pause GPS if APPLICATION loses focus
    if (state == AppLifecycleState.inactive && streamGps) {
      positionStream.pause();
    } else if (state == AppLifecycleState.resumed && streamGps) {
      positionStream.resume();
    }
  }

  void displayDataSending() {
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
                  const SizedBox(height: 20),
                  const SizedBox(
                    height: 30.0,
                    width: 30.0,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      strokeWidth: 3.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    flagSendData = true;
    flagServerResponse = true;

    sendData();

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!flagServerResponse) {
        Navigator.pop(dialogContext);
        timer.cancel();

        if (!flagSendData) {
          Navigator.pop(context, 1);
        } else {
          displayToast('Traitement impossible');
        }
      }
    });
  }

  Future<void> sendData() async {
    // First Call this :
    var localToken = await MesServices().checkJwtExpiration();
    final url = Uri.parse(
      '${dotenv.env['URL_BACKEND']}manage-cogerant-mobile',
    );
    try {
      var response = await post(
        url,
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $localToken',
        },
        body: jsonEncode({
          "id": widget.coGerant!.id,
          "entreprise_id": widget.entrepriseId,
          "civilite": laCivilite,
          "nom": nomController.text,
          "prenom": prenomController.text,
          "date_naissance": dateNaissanceController.text,
          "lieu_naissance": laCommune.id,
          "lieu_naissance_autre": lieuNaissanceAutreController.text,
          "nationalite": laNationalite.id,
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

          "photo_cni_recto": "",
          "photo_cni_verso": "",
          "qualification": qualificationController.text,
        }),
      ).timeout(const Duration(seconds: timeOutValue));

      if (response.statusCode == 200) {
        CoGerant coGerant = CoGerant(
            id: widget.coGerant!.id,
            civilite: laCivilite,
            nom: nomController.text,
            prenom: prenomController.text,
            dateNaissance: dateNaissanceController.text,
            lieuNaissance: laCommune.id,
            lieuNaissanceAutre: lieuNaissanceAutreController.text,
            nationalite: laNationalite.id,
            statutMatrimonial: leStatutMatrimonial.id,
            typeDocument: leTypeDocument.id,
            numeroPiece: numeroPieceIdentiteController.text,
            pieceDelivre: laPieceDelivre.id,
            dateEmissionPiece: datePieceController.text,
            communeResidence: laVilleResidence.id,
            quartierResidence: quartierResidenceController.text,
            adressePostal: adressePostaleController.text,
            contact1: contact1Controller.text,
            contact2: contact2Controller.text,
            email: emailController.text,
            qualification: qualificationController.text,
            livraisonCarte: laLivraison.id,
            pieceIdentiteRecto: widget.coGerant!.pieceIdentiteRecto,
            pieceIdentiteVerso: widget.coGerant!.pieceIdentiteVerso,
            optinMail: widget.coGerant == null ? 0 : widget.coGerant!.optinMail,
            optinSms: widget.coGerant == null ? 0 : widget.coGerant!.optinSms,
            optinWhatsapp: widget.coGerant == null
                ? 0
                : widget.coGerant!.optinWhatsapp,
            signature: ''
        );
        cogerantControllerX.updateData(coGerant);
        flagSendData = false;
      } else {
        displayToast("Impossible de synchroniser vos données");
      }
    } catch (e) {
      displayToast("Impossible de traiter les données : $e");
    } finally {
      flagServerResponse = false;
    }
  }

  void feedCoGerant() async {
    coGerantToManage = CoGerant(
      id: widget.coGerant == null ? 0 : widget.coGerant!.id,
      civilite: laCivilite,
      nom: nomController.text,
      prenom: prenomController.text,
      dateNaissance: dateNaissanceController.text,
      lieuNaissance: laCommune.id,
      lieuNaissanceAutre: lieuNaissanceAutreController.text,
      nationalite: laNationalite.id,
      statutMatrimonial: leStatutMatrimonial.id,
      typeDocument: leTypeDocument.id,
      numeroPiece: numeroPieceIdentiteController.text,
      pieceDelivre: laPieceDelivre.id,
      dateEmissionPiece: datePieceController.text,
      communeResidence: laVilleResidence.id,
      quartierResidence: quartierResidenceController.text,
      adressePostal: adressePostaleController.text,
      contact1: contact1Controller.text,
      contact2: contact2Controller.text,
      email: emailController.text,
      qualification: qualificationController.text,
      livraisonCarte: laLivraison.id,
      pieceIdentiteRecto: '',
      pieceIdentiteVerso: '',
      optinMail: widget.coGerant == null ? 0 : widget.coGerant!.optinMail,
      optinSms: widget.coGerant == null ? 0 : widget.coGerant!.optinSms,
      optinWhatsapp: widget.coGerant == null
          ? 0
          : widget.coGerant!.optinWhatsapp,
      signature: '',
    );

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return InterfacePriseCogerantPhoto(entrepriseId: widget.entrepriseId);
        },
      ),
    );

    // Close the DOORS :
    if (result != null) {
      // Request for Permission :
      forceLeave();
    }
  }

  // Leave :
  void forceLeave() {
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();

    // Init this :
    lesCommunesActivite = lesCommunes;

    if (widget.coGerant != null) {
      idpub = widget.coGerant!.id;

      // GERANT :
      laLivraison = lesGenericLivraisons
          .where((c) => c.id == widget.coGerant!.livraisonCarte)
          .first;
      nomController.text = widget.coGerant!.nom;
      prenomController.text = widget.coGerant!.prenom;
      laCivilite = widget.coGerant!.civilite;
      laCommune = lesCommunes
          .where((c) => c.id == widget.coGerant!.lieuNaissance)
          .first;
      lieuNaissanceAutreController.text = widget.coGerant!.lieuNaissanceAutre;
      dateNaissanceController.text = widget.coGerant!.dateNaissance;
      laNationalite = lesPays
          .where((p) => p.id == widget.coGerant!.nationalite)
          .first;
      leStatutMatrimonial = lesStatutMatrimoniaux
          .where((s) => s.id == widget.coGerant!.statutMatrimonial)
          .first;
      laVilleResidence = lesCommunes
          .where((c) => c.id == widget.coGerant!.communeResidence)
          .first;
      quartierResidenceController.text = widget.coGerant!.quartierResidence;
      adressePostaleController.text = widget.coGerant!.adressePostal;
      contact1Controller.text = widget.coGerant!.contact1;
      contact2Controller.text = widget.coGerant!.contact2;
      leTypeDocument = lesTypeDocuments
          .where((t) => t.id == widget.coGerant!.typeDocument)
          .first;
      numeroPieceIdentiteController.text = widget.coGerant!.numeroPiece;
      laPieceDelivre = lesCommunes
          .where((c) => c.id == widget.coGerant!.pieceDelivre)
          .first;
      qualificationController.text = widget.coGerant!.qualification;
    } else {
      laCommune = lesCommunes.first;
      laVilleCommune = lesCommunes.first;
      laPieceDelivre = lesCommunes.first;
      laVilleResidence = lesCommunes.first;

      // Init QUARTIERS :
      lesQuartiersIndex = lesQuartiers
          .where((q) => q.idx == laVilleCommune.id)
          .toList();
      leQuartierActivite = lesQuartiersIndex.first;

      laCivilite = lesCivilites.first;
      laNationalite = lesPays
          .where((p) => p.id == 1)
          .first; // Pick 'CÔTE d'IVOIRE' by DEFAULT
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
      laLivraison = lesGenericLivraisons.first;

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
      qualificationController.text = "";

      communeController.text = laCommune.libelle;
      villeResidenceController.text = laVilleResidence.libelle;
      pieceDelivreController.text = laPieceDelivre.libelle;
      activitePrincipaleController.text = lActivitePrincipale.libelle;
      activiteSecondaireController.text = lActiviteSecondaire.libelle;
      villeCommuneController.text = laVilleCommune.libelle;
    }
  }

  @override
  void dispose() {
    super.dispose();

    // In case BACK BUTTON is pressed :
    if (streamGps) {
      streamGps = false;
      positionStream.cancel();
    }
  }

  TextEditingController processData(DateGetController controller) {
    dateNaissanceController = TextEditingController(
      text: controller.data.isNotEmpty
          ? controller.data[0]
          : widget.coGerant != null
          ? widget.coGerant!.dateNaissance
          : '',
    );
    return dateNaissanceController;
  }

  TextEditingController processDataDelivre(
    DateDelivreGetController controller,
  ) {
    datePieceController = TextEditingController(
      text: controller.data.isNotEmpty
          ? controller.data[0]
          : widget.coGerant != null
          ? widget.coGerant!.dateEmissionPiece
          : '',
    );
    return datePieceController;
  }

  Future<void> _selectDate() async {
    choixDate = 0;
    final now = DateTime(1940, 1, 1, 00, 00);
    final initialDate = DateTime(2000, 1, 1, 00, 00);

    // Sélection de la date
    final selectedDate = await showDatePicker(
      locale: Locale(
        Platform.localeName.split("_").first,
        Platform.localeName.split("_").lastOrNull,
      ),
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: DateTime(
        2007,
        12,
        31,
        00,
        00,
      ), // DateTime.fromMillisecondsSinceEpoch(globalReservation!.fin),
    );
    if (selectedDate == null) return;
    _dateNaissanceController.addData(selectedDate);
  }

  Future<void> _selectDateDelivre() async {
    choixDate = 1;
    final now = DateTime(2005, 1, 2, 00, 00);
    final currentDate = DateTime.now();

    // Sélection de la date
    final selectedDate = await showDatePicker(
      locale: Locale(
        Platform.localeName.split("_").first,
        Platform.localeName.split("_").lastOrNull,
      ),
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
        00,
        00,
      ), // DateTime.fromMillisecondsSinceEpoch(globalReservation!.fin),
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
      locale: Locale(
        Platform.localeName.split("_").first,
        Platform.localeName.split("_").lastOrNull,
      ),
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
        00,
        00,
      ), // DateTime.fromMillisecondsSinceEpoch(globalReservation!.fin),
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
      locale: Locale(
        Platform.localeName.split("_").first,
        Platform.localeName.split("_").lastOrNull,
      ),
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
        00,
        00,
      ), // DateTime.fromMillisecondsSinceEpoch(globalReservation!.fin),
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
      fontSize: 16.0,
    );
  }

  void refreshVilleActivite(Commune commune) {
    // Init QUARTIERS :
    laVilleCommune = commune; // Refresh
    setState(() {
      lesQuartiersIndex = lesQuartiers
          .where((q) => q.idx == commune.id)
          .toList();
      if (lesQuartiersIndex.isNotEmpty) {
        leQuartierActivite = lesQuartiersIndex.first;
      }
    });
  }

  Widget lesEtapes() {
    return Container(
      margin: const EdgeInsets.only(top: 17, left: 10, right: 10, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(left: spacingSteps, right: spacingSteps),
            child: Text(
              '1',
              style: TextStyle(
                fontSize: 30,
                color: currentStep == 1 ? Colors.red : Colors.black,
                fontWeight: currentStep == 1
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: spacingSteps, right: spacingSteps),
            child: Text(
              '2',
              style: TextStyle(
                fontSize: 30,
                color: currentStep == 2 ? Colors.red : Colors.black,
                fontWeight: currentStep == 2
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget lesBoutons() {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.only(
          top: defaultTargetPlatform == TargetPlatform.iOS ? 50 : 30,
          left: 10,
          right: 10,
          bottom: 20,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              style: ButtonStyle(
                backgroundColor: WidgetStateColor.resolveWith(
                  (states) => Colors.blueGrey,
                ),
              ),
              label: const Text(
                "Retour",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                if (streamGps) {
                  positionStream.pause();
                  positionStream.cancel();
                  streamGps = false;
                }
                // Next :
                if (currentStep > 1) {
                  setState(() {
                    currentStep--;
                  });
                } else {
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
                backgroundColor: WidgetStateColor.resolveWith(
                  (states) => Colors.brown,
                ),
              ),
              label: Text("Suivant", style: TextStyle(color: Colors.white)),
              onPressed: () async {
                if (!streamGps) {
                  if (nomController.text.trim().isEmpty ||
                      prenomController.text.trim().isEmpty ||
                      dateNaissanceController.text.isEmpty ||
                      datePieceController.text.isEmpty ||
                      contact1Controller.text.trim().isEmpty ||
                      (laCommune.id == 1 &&
                          lieuNaissanceAutreController.text.trim().isEmpty)) {
                    displayToast('Veuillez renseigner les champs principaux');
                    return;
                  }

                  // Try to SEND this OBJECT :
                  feedCoGerant();
                }
              },
              icon: Icon(
                currentStep < 2 ? Icons.arrow_forward_ios : Icons.send,
                size: 20,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> renseignementGerant() {
    return [
      lesEtapes(),
      Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(top: 10, left: 10, right: 10),
        child: Divider(color: Colors.black, height: 5),
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
                    borderSide: BorderSide(
                      color: nomController.text.trim().isEmpty
                          ? Colors.red
                          : Colors.black,
                      width: 1.0,
                    ),
                  ),
                  border: OutlineInputBorder(),
                  labelText: 'Nom',
                ),
                style: const TextStyle(height: 1.5),
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
                    borderSide: BorderSide(
                      color: prenomController.text.trim().isEmpty
                          ? Colors.red
                          : Colors.black,
                      width: 1.0,
                    ),
                  ),
                  border: OutlineInputBorder(),
                  labelText: 'Prénom',
                ),
                style: const TextStyle(height: 1.5),
                textAlignVertical: TextAlignVertical.bottom,
                textAlign: TextAlign.center,
                textInputAction: TextInputAction.next,
              ),
            ),
          ],
        ),
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
              dropdownMenuEntries: lesCivilites.map<DropdownMenuEntry<String>>((
                String menu,
              ) {
                return DropdownMenuEntry<String>(
                  value: menu,
                  label: menu,
                  leadingIcon: Icon(Icons.person_outline),
                );
              }).toList(),
            ),
            SizedBox(
              width: (MediaQuery.of(context).size.width / 2) - 20,
              child: DropdownSearch<Commune>(
                mode: Mode.form,
                onChanged: (Commune? value) => {
                  setState(() {
                    laCommune = value!;
                  }),
                },
                compareFn: (Commune? a, Commune? b) {
                  if (a == null || b == null) {
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
                    decoration: InputDecoration(hintText: 'Rechercher'),
                  ),
                  fit: FlexFit.loose,
                  constraints: BoxConstraints(minHeight: 300, maxHeight: 400),
                ),
              ),
            ),
          ],
        ),
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
                borderSide: BorderSide(
                  color: lieuNaissanceAutreController.text.trim().isEmpty
                      ? Colors.red
                      : Colors.black,
                  width: 1.0,
                ),
              ),
              border: OutlineInputBorder(),
              labelText: 'Lieu naissance Autre',
            ),
            style: const TextStyle(height: 1.5),
            textAlignVertical: TextAlignVertical.bottom,
            textAlign: TextAlign.center,
            textInputAction: TextInputAction.next,
          ),
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
              child: ElevatedButton.icon(
                style: ButtonStyle(
                  backgroundColor: WidgetStateColor.resolveWith(
                    (states) => Colors.brown,
                  ),
                ),
                label: const Text(
                  "Né(e) le",
                  style: TextStyle(color: Colors.white),
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
                    style: TextStyle(height: 0.8),
                    textAlignVertical: TextAlignVertical.bottom,
                    textAlign: TextAlign.right,
                  );
                },
              ),
            ),
          ],
        ),
      ),

      Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
        child: TextField(
          keyboardType: TextInputType.text,
          controller: qualificationController,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 1.0),
            ),
            border: OutlineInputBorder(),
            labelText: 'Qualification',
          ),
          style: const TextStyle(height: 1.5),
          textAlignVertical: TextAlignVertical.bottom,
          textAlign: TextAlign.center,
          textInputAction: TextInputAction.next,
        ),
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
              dropdownMenuEntries: lesPays.map<DropdownMenuEntry<Pays>>((
                Pays menu,
              ) {
                return DropdownMenuEntry<Pays>(
                  value: menu,
                  label: menu.libelle,
                  leadingIcon: Icon(Icons.person_outline),
                );
              }).toList(),
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
              dropdownMenuEntries: lesStatutMatrimoniaux
                  .map<DropdownMenuEntry<StatutMatrimonial>>((
                    StatutMatrimonial menu,
                  ) {
                    return DropdownMenuEntry<StatutMatrimonial>(
                      value: menu,
                      label: menu.libelle,
                      leadingIcon: Icon(Icons.people_outline_outlined),
                    );
                  })
                  .toList(),
            ),
          ],
        ),
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
                onChanged: (Commune? value) => {laVilleResidence = value!},
                compareFn: (Commune? a, Commune? b) {
                  if (a == null || b == null) {
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
                    decoration: InputDecoration(hintText: 'Rechercher'),
                  ),
                  fit: FlexFit.loose,
                  constraints: BoxConstraints(minHeight: 300, maxHeight: 400),
                ),
              ),
            ),
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
            SizedBox(
              width: (MediaQuery.of(context).size.width / 2) - 20,
              child: TextField(
                keyboardType: TextInputType.text,
                controller: quartierResidenceController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Quartier résidence',
                ),
                style: const TextStyle(height: 1.5),
                textAlignVertical: TextAlignVertical.bottom,
                textAlign: TextAlign.center,
                textInputAction: TextInputAction.next,
              ),
            ),
          ],
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
              child: TextField(
                keyboardType: TextInputType.text,
                controller: adressePostaleController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Adresse postale',
                ),
                style: const TextStyle(height: 1.5),
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
                    borderSide: BorderSide(
                      color: contact1Controller.text.trim().isEmpty
                          ? Colors.red
                          : Colors.black,
                      width: 1.0,
                    ),
                  ),
                  border: OutlineInputBorder(),
                  labelText: 'Contact 1',
                ),
                style: const TextStyle(height: 1.5),
                textAlignVertical: TextAlignVertical.bottom,
                textAlign: TextAlign.center,
                textInputAction: TextInputAction.next,
              ),
            ),
          ],
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
                controller: contact2Controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Contact 2',
                ),
                style: const TextStyle(height: 1.5),
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
                style: const TextStyle(height: 1.5),
                textAlignVertical: TextAlignVertical.bottom,
                textAlign: TextAlign.center,
                textInputAction: TextInputAction.next,
              ),
            ),
          ],
        ),
      ),
      Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(top: 30, left: 10, right: 10),
        child: Divider(color: Colors.black, height: 5),
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
              dropdownMenuEntries: lesTypeDocuments
                  .map<DropdownMenuEntry<TypeDocument>>((TypeDocument menu) {
                    return DropdownMenuEntry<TypeDocument>(
                      value: menu,
                      label: menu.libelle,
                      leadingIcon: Icon(Icons.person_outline),
                    );
                  })
                  .toList(),
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
                style: const TextStyle(height: 1.5),
                textAlignVertical: TextAlignVertical.bottom,
                textAlign: TextAlign.center,
                textInputAction: TextInputAction.next,
              ),
            ),
          ],
        ),
      ),
      Container(
        alignment: Alignment.topLeft,
        margin: EdgeInsets.only(top: 20, left: 10),
        width: MediaQuery.of(context).size.width,
        child: SizedBox(
          width: (MediaQuery.of(context).size.width / 2) - 20,
          child: DropdownSearch<Commune>(
            mode: Mode.form,
            onChanged: (Commune? value) => {laPieceDelivre = value!},
            compareFn: (Commune? a, Commune? b) {
              if (a == null || b == null) {
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
                decoration: InputDecoration(hintText: 'Rechercher'),
              ),
              fit: FlexFit.loose,
              constraints: BoxConstraints(minHeight: 300, maxHeight: 400),
            ),
          ),
        ),
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
                  backgroundColor: WidgetStateColor.resolveWith(
                    (states) => Colors.brown,
                  ),
                ),
                label: const Text(
                  "Délivrée le",
                  style: TextStyle(color: Colors.white),
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
                    style: TextStyle(height: 0.8),
                    textAlignVertical: TextAlignVertical.bottom,
                    textAlign: TextAlign.right,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      lesBoutons(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(idpub == 0 ? 'Nouveau Cogérant' : 'Modification Cogérant'),
        actions: [
          Visibility(
            visible: widget.coGerant != null,
            child: IconButton(
              onPressed: () {
                displayDataSending();
              },
              icon: Icon(Icons.save_as_outlined, color: Colors.brown),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(children: renseignementGerant()),
      ),
    );
  }
}
