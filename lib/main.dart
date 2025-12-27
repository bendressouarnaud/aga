import 'package:camera/camera.dart';
import 'package:cnmci/konan/interface_accueil.dart';
import 'package:cnmci/konan/model/compagnon.dart';
import 'package:cnmci/konan/model/artisan.dart';
import 'package:cnmci/konan/model/classe.dart';
import 'package:cnmci/konan/model/commune.dart';
import 'package:cnmci/konan/model/departement.dart';
import 'package:cnmci/konan/model/diplome.dart';
import 'package:cnmci/konan/model/entreprise.dart';
import 'package:cnmci/konan/model/metier.dart';
import 'package:cnmci/konan/model/pays.dart';
import 'package:cnmci/konan/model/sous_prefecture.dart';
import 'package:cnmci/konan/model/type_document.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'firebase_options.dart';
import 'getxcontroller/apprenti_controller_x.dart';
import 'getxcontroller/artisan_controller_x.dart';
import 'getxcontroller/compagnon_controller_x.dart';
import 'getxcontroller/entreprise_controller_x.dart';
import 'konan/interface_connexion.dart';
import 'konan/model/apprenti.dart';
import 'konan/model/crm.dart';
import 'konan/model/niveau_etude.dart';
import 'konan/model/statut_matrimonial.dart';
import 'konan/model/type_compte_bancaire.dart';
import 'konan/model/user.dart';
import 'konan/objets/outil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'konan/services/firebase_messaging_service.dart';
import 'konan/services/local_notifications_service.dart';
import 'main.dart';


// Attributes
final Outil outil = Outil();
User? globalUser;
late List<Pays> lesPays;
late List<Crm> lesCrms;
late List<Departement> lesDepartements;
late List<SousPrefecture> lesSousPrefectures;
late List<Commune> lesCommunes;
late List<StatutMatrimonial> lesStatutMatrimoniaux;
late List<TypeCompteBancaire> lesTypeCompteBancaires;
late List<TypeDocument> lesTypeDocuments;
late List<NiveauEtude> lesNiveauEtudes;
late List<Classe> lesClasses;
late List<Diplome> lesDiplomes;
late List<Metier> lesMetiers;
//late CameraDescription laCamera;
late Artisan artisanToManage;
late Apprenti apprentiToManage;
late Compagnon compagnonToManage;
late Entreprise entrepriseToManage;

late ArtisanControllerX artisanControllerX;
late ApprentiControllerX apprentiControllerX;
late CompagnonControllerX compagnonControllerX;
late EntrepriseControllerX entrepriseControllerX;


Future<void> main() async {

  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // Load environment DATA :
  await dotenv.load(fileName: "variable.env");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final localNotificationsService = LocalNotificationsService.intance();
  await localNotificationsService.init();
  final firebaseMessagingServcice = FirebaseMessagingService.instance();
  firebaseMessagingServcice.init(localNotificationsService: localNotificationsService);

  // Force Portrait Mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // Normal Portrait
    DeviceOrientation.portraitDown, // Upside-Down Portrait
  ]);

  // Init OBJECTS :
  artisanControllerX = Get.put(ArtisanControllerX());
  apprentiControllerX = Get.put(ApprentiControllerX());
  compagnonControllerX = Get.put(CompagnonControllerX());
  entrepriseControllerX = Get.put(EntrepriseControllerX());

  // Pick DATA :
  globalUser = await outil.findUser();
  lesPays = await outil.findAllPays();
  // Order :
  lesPays.sort((a,b) => a.libelle.compareTo(b.libelle));
  lesCrms = await outil.findAllCrm();
  // REMOVE 'AUCUN'
  lesCrms.removeWhere((c) => c.libelle.contains('AUCUN'));
  // Order :
  lesCrms.sort((a,b) => a.libelle.compareTo(b.libelle));
  lesDepartements = await outil.findAllDepartement();
  // Order :
  lesDepartements.sort((a,b) => a.libelle.compareTo(b.libelle));
  lesSousPrefectures = await outil.findAllSousPrefecture();
  // Order :
  lesSousPrefectures.sort((a,b) => a.libelle.compareTo(b.libelle));
  lesCommunes = await outil.findAllCommune();
  // Order :
  lesCommunes.sort((a,b) => a.libelle.compareTo(b.libelle));
  lesStatutMatrimoniaux = await outil.findAllStatutMatrimonial();
  lesTypeCompteBancaires = await outil.findAllTypeCompteBancaire();
  lesTypeDocuments = await outil.findAllTypeDocument();
  lesNiveauEtudes = await outil.findAllNiveauEtude();
  lesClasses = await outil.findAllClasse();
  lesDiplomes = await outil.findAllDiplome();
  // Order :
  lesDiplomes.sort((a,b) => a.libelle.compareTo(b.libelle));
  lesMetiers = await outil.findAllMetier();
  // Order :
  lesMetiers.sort((a,b) => a.libelle.compareTo(b.libelle));

  // Stop SPLASH SCREEN:
  FlutterNativeSplash.remove();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CNMCI',
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          DefaultMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate
        ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: lesPays.isNotEmpty ? const InterfaceAccueil() : const ConnexionView(),
    );
  }
}