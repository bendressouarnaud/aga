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
import '../getxcontroller/compagnon_controller_x.dart';
import '../main.dart';
import 'beans/message_response.dart';
import 'model/compagnon.dart';
import 'model/artisan.dart';
import 'objets/constants.dart';
import 'package:geolocator/geolocator.dart';

class InterfacePriseCompagnonPhoto extends StatefulWidget {
  const InterfacePriseCompagnonPhoto({Key? key}) : super(key: key);

  @override
  State<InterfacePriseCompagnonPhoto> createState() => _InterfacePriseCompagnonPhoto();
}

class _InterfacePriseCompagnonPhoto extends State<InterfacePriseCompagnonPhoto> with WidgetsBindingObserver {

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

  XFile? photo;
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

  TextEditingController photoController = TextEditingController();
  TextEditingController photoDiplomeController = TextEditingController();
  TextEditingController photoRectoController = TextEditingController();
  TextEditingController photoVersoController = TextEditingController();

  double _currentDiscreteSliderValue = 8.0;



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
                  label: const Text("Photo Compagnon",
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
                        photo = image;
                        photoController.text = photo!.name;
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
                    controller: photoController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Photo Compagnon...',
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
                  backgroundColor: MaterialStateColor.resolveWith((states) => Colors.blueGrey)
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
                // Next :
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: Colors.white,
              ),
            ),
            Visibility(
                visible: photo != null && gpsPermission,
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
                    if(!streamGps) {
                      // check on ville :
                      if (photoController.text.isEmpty) {
                        displayToast(
                            'Veuillez prendre obligatoirement une PHOTO du Compagnon !');
                        return;
                      }

                      // Get GPS POSITION :
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
                                            position.accuracy.toStringAsFixed(
                                                2));
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

    sendData();

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

  Future<void> sendData() async {
    // First Call this :
    var localToken = await MesServices().checkJwtExpiration();
    final url = Uri.parse('${dotenv.env['URL_BACKEND']}manage-compagnonmobile');
    try {
      var response = await post(url,
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer $localToken'
          },
          body: jsonEncode({
            "id" : 0,
            "civilite" : compagnonToManage.civilite,
            "nom" : compagnonToManage.nom,
            "prenom" : compagnonToManage.prenom,
            "date_naissance" : compagnonToManage.date_naissance,
            "lieu_naissance" : compagnonToManage.lieu_naissance.toString(),
            "lieu_naissance_autre" : compagnonToManage.lieu_naissance_autre,
            "nationalite" : compagnonToManage.nationalite.toString(),
            "sexe" : "",
            "numero_piece" : compagnonToManage.numero_piece,
            "piece_delivre" : compagnonToManage.piece_delivre.toString(),
            "date_emission_piece" : compagnonToManage.date_emission_piece,
            "specialite" : compagnonToManage.specialite.toString(),
            "ville_residence" : compagnonToManage.commune_residence.toString(),
            "quartier_residence" : compagnonToManage.quartier_residence,
            "adresse_postal" : compagnonToManage.adresse_postal,
            "contact1" : compagnonToManage.contact1,
            "contact2" : compagnonToManage.contact2,
            "email" : compagnonToManage.email,
            "photo_compagnon" : photo != null ? convertPhotoToString(photo!) : "",
            "photo_cni_recto" : photoRecto != null ? convertPhotoToString(photoRecto!) : "",
            "photo_cni_verso" : photoVerso != null ? convertPhotoToString(photoVerso!) : "",
            "photo_diplome" : photoDiplome != null ? convertPhotoToString(photoDiplome!) : "",
            "longitude" : longitude.toString(),
            "latitude" : latitude.toString(),
            "entity_id": compagnonToManage.artisan_id > 0 ? compagnonToManage.artisan_id : compagnonToManage.entreprise_id,
            "source": compagnonToManage.artisan_id > 0 ? 1 : 0,
            "date_debut_compagnonage" : compagnonToManage.date_debut_compagnonnage,
            "type_document" : compagnonToManage.type_document,
            "niveau_etude" : compagnonToManage.niveau_etude,
            "classe" : compagnonToManage.classe,
            "diplome" : compagnonToManage.diplome,
            "cnps" : compagnonToManage.cnps,
            "cmu" : compagnonToManage.cmu,
            "statut_compagnon" : compagnonToManage.statut_compagnon,
            "numero_immatriculation" : compagnonToManage.numero_immatriculation,
          })
      ).timeout(const Duration(seconds: timeOutValue));

      if (response.statusCode == 200) {
        MessageResponse reponse = MessageResponse.fromJson(
            json.decode(response.body));
        Compagnon compagnon = Compagnon(
            id: reponse.id,
            nom: compagnonToManage.nom,
            prenom: compagnonToManage.prenom,
            civilite: compagnonToManage.civilite,
            date_naissance: compagnonToManage.date_naissance,
            numero_immatriculation: compagnonToManage.numero_immatriculation,
            lieu_naissance_autre: compagnonToManage.lieu_naissance_autre,
            lieu_naissance: compagnonToManage.lieu_naissance,
            nationalite: compagnonToManage.nationalite,
            sexe: '',
            type_document: compagnonToManage.type_document,
            niveau_etude: compagnonToManage.niveau_etude,
            specialite: compagnonToManage.specialite,
            classe: compagnonToManage.classe,
            diplome: compagnonToManage.diplome,
            apprentissage_metier: compagnonToManage.apprentissage_metier,
            date_debut_compagnonnage: compagnonToManage.date_debut_compagnonnage,
            commune_residence: compagnonToManage.commune_residence,
            quartier_residence: compagnonToManage.quartier_residence,
            adresse_postal: compagnonToManage.adresse_postal,
            numero_piece: compagnonToManage.numero_piece,
            piece_delivre: compagnonToManage.piece_delivre,
            date_emission_piece: compagnonToManage.date_emission_piece,
            photo: photo != null ? convertPhotoToString(photo!) : "",
            photo_cni_recto: photoRecto != null ? convertPhotoToString(photoRecto!) : "",
            photo_cni_verso: photoVerso != null ? convertPhotoToString(photoVerso!) : "",
            photo_diplome: photoDiplome != null ? convertPhotoToString(photoDiplome!) : "",
            contact1: compagnonToManage.contact1,
            contact2: compagnonToManage.contact2,
            email: compagnonToManage.email,
            statut_kyc: 0,
            statut_paiement: 0,
            longitude: longitude,
            latitude: latitude,
            cnps: compagnonToManage.cnps,
            cmu: compagnonToManage.cmu,
            artisan_id: compagnonToManage.artisan_id,
            entreprise_id: compagnonToManage.entreprise_id,
          millisecondes: compagnonToManage.millisecondes,
            statut_compagnon: compagnonToManage.statut_compagnon
        );
        compagnonControllerX.addItem(compagnon);
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
      child: Column(
          children: photoDocuments()
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(compagnonToManage.id == 0 ? 'Nouveau Compagnon' : 'Modification Compagnon'),
        ),
        body: _buildUI()
    );
  }

}

