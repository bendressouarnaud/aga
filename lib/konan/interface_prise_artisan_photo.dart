import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:camera/camera.dart';
import 'package:cnmci/konan/repositories/artisan_repository.dart';
import 'package:cnmci/konan/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart';

import '../getxcontroller/artisan_controller_x.dart';
import '../main.dart';
import 'beans/message_response.dart';
import 'model/artisan.dart';
import 'objets/constants.dart';
import 'package:geolocator/geolocator.dart';

class InterfacePriseArtisanPhoto extends StatefulWidget {
  const InterfacePriseArtisanPhoto({Key? key}) : super(key: key);

  @override
  State<InterfacePriseArtisanPhoto> createState() => _InterfacePriseArtisanPhoto();
}

class _InterfacePriseArtisanPhoto extends State<InterfacePriseArtisanPhoto> with WidgetsBindingObserver {

  // Attributes :
  double spacingSteps = 40;
  int stepForPhoto = 0;
  int artisanId = 0;
  bool cameraOnPause = false;

  late BuildContext dialogContext;
  bool flagSendData = false;
  bool flagServerResponse = false;
  bool closeAlertDialog = false;

  CameraController? _cameraController;
  late Future<void> _initializeControllerFuture;
  late CameraDescription laCamera;

  XFile? photoArtisan;
  XFile? photoDiplome;
  XFile? photoRecto;
  XFile? photoVerso;

  // Gps Permission
  bool gpsPermission = true;
  double latitude = 0.0;
  double longitude = 0.0;
  double precisionGps = 0.0;
  bool streamGps = false;
  late StreamSubscription<Position> positionStream;

  TextEditingController photoArtisanController = TextEditingController();
  TextEditingController photoDiplomeController = TextEditingController();
  TextEditingController photoRectoController = TextEditingController();
  TextEditingController photoVersoController = TextEditingController();

  double _currentDiscreteSliderValue = 8.0;
  //final ArtisanRepository _artisanRepository = ArtisanRepository();
  //final ArtisanControllerX _artisanControllerX = Get.put(ArtisanControllerX());


  // METHODS :
  @override
  void initState() {
    super.initState();
    setUpCameraController();
  }

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

    if(_cameraController?.value.isInitialized == false){
      return;
    }

    if(state == AppLifecycleState.inactive){
      _cameraController?.dispose();
    }
    else if(state == AppLifecycleState.resumed){
      // set up :
      setUpCameraController();
    }
  }

  Future<void> setUpCameraController() async{
    final cameras = await availableCameras();
    laCamera = cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.back);

    _cameraController = CameraController(
      // Get a specific camera from the list of available cameras.
      laCamera,
      // Define the resolution to use.
      ResolutionPreset.high,
    );
    // Next, initialize the controller. This returns a Future.
    //_initializeControllerFuture = _cameraController!.initialize();
    _cameraController?.initialize().then((_){
      if(!mounted){
        return;
      }
      setState(() {

      });
    }).catchError(
        (Object e){
          print(e);
        }
    );
  }

  void releaseCamera(){
    if(_cameraController != null && _cameraController?.value.isInitialized == true){
      _cameraController!.dispose();
    }
  }

  @override
  void dispose() {
    super.dispose();

    // In case BACK BUTTON is pressed :
    if(streamGps){
      streamGps = false;
      positionStream.cancel();
    }

    // Dispose of the controller when the widget is disposed.
    releaseCamera();
    //_artisanControllerX.dispose();
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
                color: Colors.black,
                fontWeight: FontWeight.normal,
              ),),
          ),
          Container(
              margin: EdgeInsets.only(left: spacingSteps, right: spacingSteps),
              child: Text('2',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),)
          ),
          Container(
              margin: EdgeInsets.only(left: spacingSteps, right: spacingSteps),
              child: Text('3',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),)
          ),
        ],
      ),
    );
  }

  List<Widget> photoDocuments(){
    return [
      lesEtapes(),
      Visibility(
          visible: stepForPhoto > 0,
          child: Container(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 30),
            height: MediaQuery.sizeOf(context).height * 0.50,
            width: MediaQuery.sizeOf(context).width * 0.80,
            child: CameraPreview(_cameraController!),
          )
      ),

      Visibility(
          visible: stepForPhoto > 0,
          child: Container(
              margin: EdgeInsets.only(top: 15, right: 10, left: 10, bottom: 15),
              child: ElevatedButton.icon(
                style: ButtonStyle(
                    backgroundColor: WidgetStateColor.resolveWith((states) => boutonAnnuler)
                ),
                label: const Text("Annuler",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                    )
                ),
                onPressed: () async {
                  try {
                    await _cameraController!.pausePreview();
                    cameraOnPause = true;
                    // Reset :
                    setState(() {
                      stepForPhoto = 0;
                    });
                    /*
                    await _cameraController!.pausePreview();
                    setState(() {
                      stepForPhoto = 0;
                    });*/
                  } catch (e) {
                    // Nothing
                  }
                },
                icon: const Icon(
                  Icons.cancel,
                  size: 20,
                  color: Colors.white,
                ),
              )
          )
      ),

      Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(left: 10, right: 10, top: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: (MediaQuery.of(context).size.width / 2) - 20,
                child: ElevatedButton.icon(
                  style: ButtonStyle(
                      backgroundColor: WidgetStateColor.resolveWith((states) => Colors.brown)
                  ),
                  label: const Text("Photo Artisan",
                      style: TextStyle(
                          color: Colors.white
                      )
                  ),
                  onPressed: () async {
                    try {
                      // Ensure that the camera is initialized.
                      //await _initializeControllerFuture;
                      if(stepForPhoto == 0){
                        setState(() {
                          if(cameraOnPause){
                            cameraOnPause = false;
                            _cameraController!.resumePreview();
                          }
                          stepForPhoto++;
                        });
                      }
                      else{
                        final image = await _cameraController!.takePicture();
                        photoArtisan = image;
                        photoArtisanController.text = photoArtisan!.name;
                        await _cameraController!.pausePreview();
                        cameraOnPause = true;
                        // Reset :
                        setState(() {
                          stepForPhoto = 0;
                        });
                      }
                    } catch (e) {
                      // If an error occurs, log the error to the console.
                      //print('Erreur ....$e');
                    }
                  },
                  icon: const Icon(
                    Icons.person_pin,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                  width: (MediaQuery.of(context).size.width / 2) - 20,
                  child: TextField(
                    enabled: false,
                    controller: photoArtisanController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Photo Artisan...',
                    ),
                    style: TextStyle(
                        height: 0.8
                    ),
                    textAlignVertical: TextAlignVertical.bottom,
                    textAlign: TextAlign.right,
                  )
              ),
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
                child: ElevatedButton.icon(
                  style: ButtonStyle(
                      backgroundColor: WidgetStateColor.resolveWith((states) => Colors.grey)
                  ),
                  label: const Text("Photo Diplôme",
                      style: TextStyle(
                          color: Colors.white
                      )
                  ),
                  onPressed: () async {
                    try {
                      // Ensure that the camera is initialized.
                      //await _initializeControllerFuture;
                      if(stepForPhoto == 0){
                        setState(() {
                          if(cameraOnPause){
                            cameraOnPause = false;
                            _cameraController!.resumePreview();
                          }
                          stepForPhoto++;
                        });
                      }
                      else{
                        final image = await _cameraController!.takePicture();
                        photoDiplome = image;
                        photoDiplomeController.text = photoDiplome!.name;
                        await _cameraController!.pausePreview();
                        cameraOnPause = true;
                        // Reset :
                        setState(() {
                          stepForPhoto = 0;
                        });
                      }
                    } catch (e) {
                      // If an error occurs, log the error to the console.
                      //print('Erreur ....$e');
                    }
                  },
                  icon: const Icon(
                    Icons.school,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                  width: (MediaQuery.of(context).size.width / 2) - 20,
                  child: TextField(
                    enabled: false,
                    controller: photoDiplomeController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Photo Diplôme...',
                    ),
                    style: TextStyle(
                        height: 0.8
                    ),
                    textAlignVertical: TextAlignVertical.bottom,
                    textAlign: TextAlign.right,
                  )
              ),
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
                child: ElevatedButton.icon(
                  style: ButtonStyle(
                      backgroundColor: WidgetStateColor.resolveWith((states) => Colors.orangeAccent)
                  ),
                  label: const Text("Pièce Recto",
                      style: TextStyle(
                          color: Colors.white
                      )
                  ),
                  onPressed: () async {
                    try {
                      // Ensure that the camera is initialized.
                      //await _initializeControllerFuture;
                      if(stepForPhoto == 0){
                        setState(() {
                          if(cameraOnPause){
                            cameraOnPause = false;
                            _cameraController!.resumePreview();
                          }
                          stepForPhoto++;
                        });
                      }
                      else{
                        final image = await _cameraController!.takePicture();
                        photoRecto = image;
                        photoRectoController.text = photoRecto!.name;
                        await _cameraController!.pausePreview();
                        cameraOnPause = true;
                        // Reset :
                        setState(() {
                          stepForPhoto = 0;
                        });
                      }
                    } catch (e) {
                      // If an error occurs, log the error to the console.
                      //print('Erreur ....$e');
                    }
                  },
                  icon: const Icon(
                    Icons.person,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                  width: (MediaQuery.of(context).size.width / 2) - 20,
                  child: TextField(
                    enabled: false,
                    controller: photoRectoController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Photo Recto...',
                    ),
                    style: TextStyle(
                        height: 0.8
                    ),
                    textAlignVertical: TextAlignVertical.bottom,
                    textAlign: TextAlign.right,
                  )
              ),
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
                child: ElevatedButton.icon(
                  style: ButtonStyle(
                      backgroundColor: WidgetStateColor.resolveWith((states) => Colors.cyan)
                  ),
                  label: const Text("Pièce Verso",
                      style: TextStyle(
                          color: Colors.white
                      )
                  ),
                  onPressed: () async {
                    try {
                      // Ensure that the camera is initialized.
                      //await _initializeControllerFuture;
                      if(stepForPhoto == 0){
                        setState(() {
                          if(cameraOnPause){
                            cameraOnPause = false;
                            _cameraController!.resumePreview();
                          }
                          stepForPhoto++;
                        });
                      }
                      else{
                        final image = await _cameraController!.takePicture();
                        photoVerso = image;
                        photoVersoController.text = photoVerso!.name;
                        await _cameraController!.pausePreview();
                        cameraOnPause = true;
                        // Reset :
                        setState(() {
                          stepForPhoto = 0;
                        });
                      }
                    } catch (e) {
                      // If an error occurs, log the error to the console.
                      //print('Erreur ....$e');
                    }
                  },
                  icon: const Icon(
                    Icons.person_outline,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                  width: (MediaQuery.of(context).size.width / 2) - 20,
                  child: TextField(
                    enabled: false,
                    controller: photoVersoController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Photo Recto...',
                    ),
                    style: TextStyle(
                        height: 0.8
                    ),
                    textAlignVertical: TextAlignVertical.bottom,
                    textAlign: TextAlign.right,
                  )
              ),
            ],
          )
      ),
      SizedBox(
        height: 40,
      ),
      Visibility(
        visible: streamGps,
          child: Container(
            margin: EdgeInsets.only(left: 10, right: 10, top: 20),
            child: Text('Précision actuelle : $precisionGps m'),
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
      Container(
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

                if(stepForPhoto > 0){
                  // Close CAMERA
                  _cameraController?.pausePreview();
                  _cameraController?.dispose();
                }
                if(streamGps){
                  positionStream.pause();
                  positionStream.cancel();
                }
                // Leave :
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: Colors.white,
              ),
            ),
            Visibility(
              visible: photoArtisan != null && gpsPermission,
                child: ElevatedButton.icon(
                  style: ButtonStyle(
                      iconAlignment: IconAlignment.end,
                      backgroundColor: WidgetStateColor.resolveWith((states) => Colors.brown)
                  ),
                  label: Text("Enregistrer",
                      style: TextStyle(
                          color: Colors.white
                      )
                  ),
                  onPressed: () async {

                    print('Valeur de streamGps : $streamGps');

                    if(!streamGps) {
                      // check on ville :
                      if (photoArtisanController.text.isEmpty) {
                        displayToast(
                            'Veuillez prendre obligatoirement une PHOTO de l\'artisan !');
                        return;
                      }

                      // Get GPS POSITION :
                      try {
                        var getstreamGpsData = await MesServices()
                            .determinePositionStream();

                        print('Valeur de getstreamGpsData : $getstreamGpsData');

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
                                            position.accuracy.toStringAsFixed(
                                                2));
                                        if (precisionGps < gpsPrecisionAccuracy ||
                                            precisionGps < _currentDiscreteSliderValue) {
                                          // Reset this :
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
                        setState(() {
                          gpsPermission = false;
                        });
                      }
                    }
                  },
                  icon: Icon(
                    Icons.send,
                    size: 20,
                    color: Colors.white,
                  ),
                )
            )
          ],
        ),
      )
    ];
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

    sendArtisanData();

    Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (!flagServerResponse) {
          Navigator.pop(dialogContext);
          timer.cancel();

          if (!flagSendData) {
            Navigator.pop(context, 1);
          } else {
            displayToast('Traitement impossible');
          }
        }
      },
    );
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

  String convertPhotoToString(XFile data){
    final bytes = io.File(data.path).readAsBytesSync();
    String img64 = base64Encode(bytes);
    return img64;
  }

  Future<void> sendArtisanData() async {
    // First Call this :
    var localToken = await MesServices().checkJwtExpiration();
    final url = Uri.parse('${dotenv.env['URL_BACKEND']}manage-artisanmobile');
    try {
      var response = await post(url,
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer $localToken'
          },
          body: jsonEncode({
            "id" : artisanId,
            "civilite" : artisanToManage.civilite,
            "nom" : artisanToManage.nom,
            "prenom" : artisanToManage.prenom,
            "date_naissance" : artisanToManage.date_naissance,
            "lieu_naissance" : artisanToManage.lieu_naissance.toString(),
            "lieu_naissance_autre" : artisanToManage.lieu_naissance_autre,
            "nationalite" : artisanToManage.nationalite.toString(),
            "cnps" : artisanToManage.cnps,
            "cmu" : artisanToManage.cmu,
            "chiffre_affaire" : artisanToManage.chiffre_affaire,
            "presence_compte_bancaire" : artisanToManage.presence_compte_bancaire,
            "type_compte_bancaire" : artisanToManage.type_compte_bancaire,
            "regime_social" : artisanToManage.regime_social,
            "regime_travailleur" : artisanToManage.regime_travailleur,
            "regime_imposition_taxe_communale" : artisanToManage.regime_imposition_taxe_communale,
            "regime_imposition_micro_entreprise" : artisanToManage.regime_imposition_micro_entreprise,
            "comptabilite" : artisanToManage.comptabilite,
            "sexe" : "",
            "statut_matrimonial" : artisanToManage.statut_matrimonial.toString(),
            "type_document" : artisanToManage.type_document.toString(),
            "numero_piece" : artisanToManage.numero_piece,
            "piece_delivre" : artisanToManage.piece_delivre.toString(),
            "date_emission_piece" : artisanToManage.date_emission_piece,
            "niveau_etude" : artisanToManage.niveau_etude.toString(),
            "formation" : artisanToManage.formation.toString(),
            "specialite" : artisanToManage.specialite.toString(),
            "classe" : artisanToManage.classe.toString(),
            "diplome" : artisanToManage.diplome.toString(),
            "ville_residence" : artisanToManage.commune_residence.toString(),
            "quartier_residence" : artisanToManage.quartier_residence,
            "adresse_postal" : artisanToManage.adresse_postal,
            "contact1" : artisanToManage.contact1,
            "contact2" : artisanToManage.contact2,
            "email" : artisanToManage.email,

            "photo_artisan" : photoArtisan != null ? convertPhotoToString(photoArtisan!) : "",
            "photo_cni_recto" : photoRecto != null ? convertPhotoToString(photoRecto!) : "",
            "photo_cni_verso" : photoVerso != null ? convertPhotoToString(photoVerso!) : "",
            "photo_diplome" : photoDiplome != null ? convertPhotoToString(photoDiplome!) : "",

            "longitude" : longitude.toString(),
            "latitude" : latitude.toString(),
            "crm" : artisanToManage.crm,
            "departement" : artisanToManage.departement,
            "sous_pref" : artisanToManage.sous_prefecture,
            "activite_principale" : artisanToManage.activite_principale,
            "activite_secondaire" : artisanToManage.activite_secondaire,
            "raison_social" : artisanToManage.raison_social,
            "sigle" : artisanToManage.sigle,
            "date_creation" : artisanToManage.date_creation,
            "ville_commune" : artisanToManage.commune_activite.toString(),
            "quartier" : artisanToManage.quartier_activite_id,
            "niveau_equipement" : artisanToManage.niveau_equipement.toString(),
            "rccm" : artisanToManage.rccm,
            "salarie_homme" : 0,
            "salarie_femme" : 0,
            "auxiliaire_homme" : 0,
            "auxiliaire_femme" : 0,
            "apprenti_homme" : 0,
            "apprenti_femme" : 0,
            "statut_artisan" : artisanToManage.statut_artisan,
            "numero_registre" : artisanToManage.numero_registre
          })
      ).timeout(const Duration(seconds: timeOutValue));

      if (response.statusCode == 200) {
        MessageResponse reponse = MessageResponse.fromJson(
            json.decode(response.body));
        Artisan artisan = Artisan(
            id: reponse.id,
            nom: artisanToManage.nom,
            prenom: artisanToManage.prenom,
            civilite: artisanToManage.civilite,
            date_naissance: artisanToManage.date_naissance,
            numero_registre: artisanToManage.numero_registre,
            lieu_naissance_autre: artisanToManage.lieu_naissance_autre,
            lieu_naissance: artisanToManage.lieu_naissance,
            nationalite: artisanToManage.nationalite,
            statut_matrimonial: artisanToManage.statut_matrimonial,
            type_document: artisanToManage.type_document,
            niveau_etude: artisanToManage.niveau_etude,
            formation: artisanToManage.formation,
            classe: artisanToManage.classe,
            diplome: artisanToManage.diplome,
            commune_residence: artisanToManage.commune_residence,
            activite: artisanToManage.activite,
            sexe: '',
            numero_piece: artisanToManage.numero_piece,
            piece_delivre: artisanToManage.piece_delivre,
            date_emission_piece: artisanToManage.date_emission_piece,
            metier: artisanToManage.metier,
            quartier_residence: artisanToManage.quartier_residence,
            adresse_postal: artisanToManage.adresse_postal,
            contact1: artisanToManage.contact1,
            contact2: artisanToManage.contact2,
            email: artisanToManage.email,
            photo_artisan: photoArtisan != null ? convertPhotoToString(photoArtisan!) : "",
            photo_cni_recto: photoRecto != null ? convertPhotoToString(photoRecto!) : "",
            photo_cni_verso: photoVerso != null ? convertPhotoToString(photoVerso!) : "",
            photo_diplome: photoDiplome != null ? convertPhotoToString(photoDiplome!) : "",
            date_expiration_carte: '',
            statut_kyc: 0,
            statut_paiement: 0,
            longitude: 0.0,
            latitude: 0.0,
            regime_social: artisanToManage.regime_social,
            regime_travailleur: artisanToManage.regime_travailleur,
            regime_imposition_taxe_communale: artisanToManage.regime_imposition_taxe_communale,
            regime_imposition_micro_entreprise: artisanToManage.regime_imposition_micro_entreprise,
            comptabilite: artisanToManage.comptabilite,
            chiffre_affaire: artisanToManage.chiffre_affaire,
            cnps: artisanToManage.cnps,
            cmu: artisanToManage.cmu,
            presence_compte_bancaire: artisanToManage.presence_compte_bancaire,
            type_compte_bancaire: artisanToManage.type_compte_bancaire,
            crm: artisanToManage.crm,
            departement: artisanToManage.departement,
            sous_prefecture: artisanToManage.sous_prefecture,

            specialite: artisanToManage.specialite,
            activite_principale: artisanToManage.activite_principale,
            activite_secondaire: artisanToManage.activite_secondaire,
            raison_social: artisanToManage.raison_social,
            sigle: artisanToManage.sigle,
            date_creation: artisanToManage.date_creation,
            commune_activite: artisanToManage.commune_activite,
            quartier_activite: artisanToManage.quartier_activite,
            rccm: artisanToManage.rccm,
            niveau_equipement: artisanToManage.niveau_equipement,
          millisecondes: artisanToManage.millisecondes,
            quartier_activite_id: artisanToManage.quartier_activite_id,
            statut_artisan: artisanToManage.statut_artisan
        );
        artisanControllerX.addItem(artisan);
        //_artisanRepository.insert(artisan);
        flagSendData = false;
      } else {
        displayToast("Impossible de récupérer les données de références");
      }
    } catch (e) {
      displayToast("Impossible de traiter les données de référence : $e");
    } finally {
      streamGps = false;
      flagServerResponse = false;
    }
  }

  Widget _buildUI(){
    if(_cameraController == null || _cameraController?.value.isInitialized == false){
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return SingleChildScrollView(
      child: PopScope(
        canPop: checkActionsBeforePop(),
          child: Column(
              children: photoDocuments()
          )
      )
    );
  }

  bool checkActionsBeforePop(){
    if(stepForPhoto > 0){
      return false;
    }
    else if(streamGps){
      return false;
    }
    else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(artisanToManage.id == 0 ? 'Nouvel Artisan' : 'Modification Artisan'),
        ),
        body: _buildUI()
    );
  }

}

