import 'dart:async';
import 'dart:convert';

import 'package:cnmci/konan/interface_accueil.dart';
import 'package:cnmci/konan/model/apprenti.dart';
import 'package:cnmci/konan/model/artisan.dart';
import 'package:cnmci/konan/model/classe.dart';
import 'package:cnmci/konan/model/commune.dart';
import 'package:cnmci/konan/model/compagnon.dart';
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
import 'package:cnmci/konan/repositories/classe_repository.dart';
import 'package:cnmci/konan/repositories/commune_repository.dart';
import 'package:cnmci/konan/repositories/crm_repository.dart';
import 'package:cnmci/konan/repositories/departement_repository.dart';
import 'package:cnmci/konan/repositories/diplome_repository.dart';
import 'package:cnmci/konan/repositories/metier_repository.dart';
import 'package:cnmci/konan/repositories/niveau_etude_repository.dart';
import 'package:cnmci/konan/repositories/pays_repository.dart';
import 'package:cnmci/konan/repositories/sous_prefecture_repository.dart';
import 'package:cnmci/konan/repositories/statut_matrimonial_repository.dart';
import 'package:cnmci/konan/repositories/type_compte_bancaire_repository.dart';
import 'package:cnmci/konan/repositories/type_document_repository.dart';
import 'package:cnmci/konan/repositories/user_repository.dart';
import 'package:cnmci/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:http/http.dart';

import '../getxcontroller/internet_access_controller_x.dart';
import 'beans/accountsigninresponse.dart';
import 'beans/donnees_referentielles.dart';
import 'model/crm.dart';
import 'model/user.dart';
import 'objets/constants.dart';

class ConnexionView extends StatefulWidget {
  const ConnexionView({Key? key}) : super(key: key);

  @override
  State<ConnexionView> createState() => _ConnexionViewState();
}

class _ConnexionViewState extends State<ConnexionView> {
  final UserRepository _userRepository = UserRepository();
  final CrmRepository _crmRepository = CrmRepository();
  final DepartementRepository _departementRepository = DepartementRepository();
  final SousPrefectureRepository _sousPrefectureRepository = SousPrefectureRepository();
  final CommuneRepository _communeRepository = CommuneRepository();
  final PaysRepository _paysRepository = PaysRepository();
  final StatutMatrimonialRepository _statutMatrimonialRepository = StatutMatrimonialRepository();
  final TypeCompteBancaireRepository _typeCompteBancaireRepository = TypeCompteBancaireRepository();
  final TypeDocumentRepository _typeDocumentRepository = TypeDocumentRepository();
  final NiveauEtudeRepository _niveauEtudeRepository = NiveauEtudeRepository();
  final ClasseRepository _classeRepository = ClasseRepository();
  final DiplomeRepository _diplomeRepository = DiplomeRepository();
  final MetierRepository _metierRepository = MetierRepository();

  TextEditingController emailController = TextEditingController();
  TextEditingController pwdController = TextEditingController();
  FocusNode focusNode = FocusNode();
  bool flagSendData = false;
  bool flagCredentialsApproved = false;
  bool flagServerResponse = false;
  late BuildContext dialogContext;
  String numeroTelephone = "";
  bool passwordVisible = true;
  bool reseauDisponible = true;
  late String jwtToken;

  @override
  void initState() {
    passwordVisible = true;
    super.initState();
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

  void requestForNotificationPermission() async{
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging
        .getNotificationSettings();
    if (settings.authorizationStatus !=
        AuthorizationStatus.authorized) {
      // Request for it :
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if(settings.authorizationStatus != AuthorizationStatus.authorized) {
        Fluttertoast.showToast(
            msg: 'Certaines fonctionnalités risquent de ne point fonctionner !',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
      openScreen();
      //
    }
    else{
      openScreen();
    }
  }

  void openScreen(){
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
                      ))));
        });

    flagCredentialsApproved = false;
    flagSendData = true;
    flagServerResponse = true;

    //sendLoginRequest();
    generateTokenSuscription();

    Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (!flagServerResponse) {
          Navigator.pop(dialogContext);
          timer.cancel();

          if (!flagSendData) {
            if(flagCredentialsApproved) {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(builder:
                      (context) =>
                      InterfaceAccueil()
                  )
              );
            }
          } else {
            displayToast('Connexion impossible');
          }
        }
      },
    );
  }

  void generateTokenSuscription() async {
    String? getToken = '';
    try {
      getToken = await FirebaseMessaging.instance.getToken();
    } catch (e) {}
    sendLoginRequest(getToken!);
  }

  Future<void> sendLoginRequest(String token) async {
    final url = Uri.parse('${dotenv.env['URL_BACKEND']}authentification-mobile');
    try {
      var response = await post(url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "identifiant": emailController.text,
            "motdepasse": pwdController.text,
            "fcm": token,
          })
      ).timeout(const Duration(seconds: timeOutValue));
      if (response.statusCode == 200) {
        AccountSignInResponse donnee =  AccountSignInResponse.fromJson(json.decode(response.body));
        // Ici, adapte selon la réponse de ton backend
        User user = User(
          id: donnee.data.id,
          nom: donnee.data.name + ' ' + donnee.data.firstname,
          email: emailController.text,
          pwd: pwdController.text,
          jwt: donnee.data.token,
          profil: donnee.data.profil,
          milliseconds: DateTime.now().millisecondsSinceEpoch
        );
        globalUser = user;
        jwtToken = donnee.data.token;
        _userRepository.insertUser(user);

        // SAve other DATA :
        try {
          for (Artisan artisan in donnee.artisans) {
            //
            artisanControllerX.addItemWithNoNotification(artisan);
          }
          for (Apprenti apprenti in donnee.apprentis) {
            //
            apprentiControllerX.addItemWithNoNotification(apprenti);
          }
          for (Compagnon compagnon in donnee.compagnons) {
            //
            compagnonControllerX.addItemWithNoNotification(compagnon);
          }
          for (Entreprise entreprise in donnee.entreprises) {
            //
            entrepriseControllerX.addItemWithNoNotification(entreprise);
          }
        }
        catch(e){
          // Nothong to do :
        }

        flagCredentialsApproved = true;
      } else {
        displayToast("Identifiants incorrects");
      }
    } catch (e) {
      flagCredentialsApproved = false;
      displayToast("Impossible de traiter la demande **** $e");
    } finally {
      if(!flagCredentialsApproved){
        flagServerResponse = false;
        flagSendData = false;
      }
      else{
        getDonneeReferentielle(jwtToken);
      }
    }
  }


  Future<void> getDonneeReferentielle(String token) async {
    final url = Uri.parse('${dotenv.env['URL_BACKEND']}get-donnees-references');
    try {
      var response = await get(url,
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token'
          }).timeout(const Duration(seconds: timeOutValue));

      if (response.statusCode == 200) {
        DonneesReferentielles donnee =  DonneesReferentielles.fromJson(json.decode(response.body));
        // CRM :
        for(Crm crm in donnee.crm){
          _crmRepository.insert(crm);
        }
        lesCrms.addAll(donnee.crm);
        // DEPARTEMENT :
        for(Departement dt in donnee.departement){
          _departementRepository.insert(dt);
        }
        lesDepartements.addAll(donnee.departement);
        // SOUS-PREFECTURE :
        for(SousPrefecture dt in donnee.sous_prefecture){
          _sousPrefectureRepository.insert(dt);
        }
        lesSousPrefectures.addAll(donnee.sous_prefecture);
        // COMMUNE :
        for(Commune dt in donnee.commune){
          _communeRepository.insert(dt);
        }
        lesCommunes.addAll(donnee.commune);
        // PAYS :
        for(Pays dt in donnee.pays){
          _paysRepository.insert(dt);
        }
        lesPays.addAll(donnee.pays);
        // STATUT MATRIMONIAL :
        for(StatutMatrimonial dt in donnee.statut_matrimonial){
          _statutMatrimonialRepository.insert(dt);
        }
        lesStatutMatrimoniaux.addAll(donnee.statut_matrimonial);
        // type compte bancaire :
        for(TypeCompteBancaire dt in donnee.type_compte_bancaire){
          _typeCompteBancaireRepository.insert(dt);
        }
        lesTypeCompteBancaires.addAll(donnee.type_compte_bancaire);
        // type compte bancaire :
        for(TypeDocument dt in donnee.type_document){
          _typeDocumentRepository.insert(dt);
        }
        lesTypeDocuments.addAll(donnee.type_document);
        // niveau_etude :
        for(NiveauEtude dt in donnee.niveau_etude){
          _niveauEtudeRepository.insert(dt);
        }
        lesNiveauEtudes.addAll(donnee.niveau_etude);
        // classe :
        for(Classe dt in donnee.classe){
          _classeRepository.insert(dt);
        }
        lesClasses.addAll(donnee.classe);
        // diplome :
        for(Diplome dt in donnee.diplome){
          _diplomeRepository.insert(dt);
        }
        lesDiplomes.addAll(donnee.diplome);
        // metier :
        for(Metier dt in donnee.metier){
          _metierRepository.insert(dt);
        }
        lesMetiers.addAll(donnee.metier);
        flagSendData = false;
      } else {
        displayToast("Impossible de récupérer les données de références");
      }
    } catch (e) {
      displayToast("Impossible de traiter les données de référence : $e");
    } finally {
      flagServerResponse = false;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SizedBox.expand(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text('Se connecter',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      height: 80,
                      margin:
                          const EdgeInsets.only(top: 15, left: 20, right: 20),
                      child: TextField(
                        /*maxLength: 50,*/
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'Email...',
                        ),
                        textInputAction: TextInputAction.next,
                        style: const TextStyle(fontSize: 17),
                      ),
                    ),
                    Container(
                      height: 70,
                      margin:
                          const EdgeInsets.only(top: 15, left: 20, right: 20),
                      child: TextField(
                        maxLength: 15,
                        obscureText: passwordVisible,
                        controller: pwdController,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: 'Mot de passe...',
                            suffixIcon: IconButton(
                              icon: Icon(passwordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () {
                                setState(
                                  () {
                                    passwordVisible = !passwordVisible;
                                  },
                                );
                              },
                            )),
                        textInputAction: TextInputAction.done,
                        style: const TextStyle(fontSize: 17),
                      ),
                    ),
                    /*Container(
                      margin: const EdgeInsets.only(top: 25, left: 20, right: 20),
                      child: GestureDetector(
                        onTap: (){
                          if(reseauDisponible) {
                            if(emailController.text.trim().isEmpty){
                              displayToast('Svp Renseigner l\'email');
                            }
                            else{
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
                                                ))));
                                  });

                              flagSendData = true;
                              flagServerResponse = true;

                              //sendPasswordForgottenRequest();

                              Timer.periodic(
                                const Duration(seconds: 1),
                                    (timer) {
                                  if (!flagServerResponse) {
                                    Navigator.pop(dialogContext);
                                    timer.cancel();
                                  }
                                },
                              );
                            }
                          }
                          else{
                            displayToast('Internet indisponiple');
                          }
                        },
                        child: Text('Mot de passe oublié',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 7, left: 20, right: 20),
                      child: GestureDetector(
                        child: Text('(Renseigner l\'email)',
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    )*/
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 45, left: 20, right: 20),
                  child: Container(
                    margin: const EdgeInsets.only(top: 20),
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WidgetStateColor.resolveWith(
                                (states) => states.contains(WidgetState.pressed)
                                ? Colors.blue.shade700
                                : Colors.blue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        requestForNotificationPermission();
                      },
                      child: Text('Se connecter',
                          style: const TextStyle(color: Colors.white)
                      ),
                    ),
                  )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
