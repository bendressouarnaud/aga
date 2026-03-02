import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:camera/camera.dart';
import 'package:cnmci/konan/beans/stats_bean_manager.dart';
import 'package:cnmci/konan/repositories/artisan_repository.dart';
import 'package:cnmci/konan/services.dart';
import 'package:file_picker/file_picker.dart';
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
import 'model/entreprise.dart';
import 'objets/constants.dart';
import 'package:geolocator/geolocator.dart';

class InterfacePriseEntreprisePhoto extends StatefulWidget {
  const InterfacePriseEntreprisePhoto({Key? key}) : super(key: key);

  @override
  State<InterfacePriseEntreprisePhoto> createState() => _InterfacePriseEntreprisePhoto();
}

class _InterfacePriseEntreprisePhoto extends State<InterfacePriseEntreprisePhoto> with WidgetsBindingObserver {

  // Attributes :
  double spacingSteps = 40;
  int stepForPhoto = 0;
  int artisanId = 0;
  bool cameraOnPause = false;

  late BuildContext dialogContext;
  bool flagSendData = false;
  bool flagServerResponse = false;
  bool closeAlertDialog = false;
  bool switchUploadFile = false;

  CameraController? _cameraController;
  late Future<void> _initializeControllerFuture;
  late CameraDescription laCamera;

  XFile? photoRecto;
  XFile? photoVerso;
  XFile? photoCommerce;
  XFile? photoDfe;
  //
  bool uploadPhotoCommerce = false;
  bool uploadPhotoDfe = false;
  bool uploadPhotoRecto = false;
  bool uploadPhotoVerso = false;

  io.File? fileUploadPhotoCommerce;
  io.File? fileUploadPhotoDfe;
  io.File? fileUploadPhotoRecto;
  io.File? fileUploadPhotoVerso;

  // Gps Permission
  bool gpsPermission = true;
  double latitude = 0.0;
  double longitude = 0.0;
  double precisionGps = 0.0;
  bool streamGps = false;
  late StreamSubscription<Position> positionStream;

  TextEditingController photoCommerceController = TextEditingController();
  TextEditingController photoDfeController = TextEditingController();
  TextEditingController photoRectoController = TextEditingController();
  TextEditingController photoVersoController = TextEditingController();

  double _currentDiscreteSliderValue = 8.0;
  //final ArtisanRepository _artisanRepository = ArtisanRepository();
  //final ArtisanControllerX _artisanControllerX = Get.put(ArtisanControllerX());


  // METHODS :
  @override
  void initState() {
    super.initState();

    // init :
    photoCommerceController.text = "";
    photoDfeController.text = "";
    photoRectoController.text = "";
    photoVersoController.text = "";
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
          visible: stepForPhoto > 7,
          child: Container(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 30),
            height: MediaQuery.sizeOf(context).height * 0.50,
            width: MediaQuery.sizeOf(context).width * 0.80,
            child: CameraPreview(_cameraController!),
          )
      ),

      Visibility(
          visible: stepForPhoto == 7,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pièce Recto Gérant',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18
              ),
            ),
            Divider(
              height: 3,
              thickness: 2,
              color: Colors.brown,
            )
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
                child: ElevatedButton.icon(
                  style: ButtonStyle(
                      backgroundColor: WidgetStateColor.resolveWith((states) => Colors.deepOrangeAccent)
                  ),
                  label: const Text("Appareil photo",
                      style: TextStyle(
                          color: Colors.white
                      )
                  ),
                  onPressed: () async {
                    try {
                      // Ensure that the camera is initialized.
                      if (stepForPhoto == 0) {
                        //setState(() {
                        if (cameraOnPause) {
                          cameraOnPause = false;
                          _cameraController!.resumePreview();
                        }
                        stepForPhoto++;
                        //});
                        displayCameraDialog(3);
                      }
                    } catch (e) {
                      // If an error occurs, log the error to the console.
                      //print('Erreur ....$e');
                    }
                  },
                  icon: const Icon(
                    Icons.camera_alt_outlined,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                  width: (MediaQuery.of(context).size.width / 2) - 20,
                  child: ElevatedButton.icon(
                    style: ButtonStyle(
                        backgroundColor: WidgetStateColor.resolveWith((states) => photoIdentite)
                    ),
                    label: const Text("Uploader",
                        style: TextStyle(
                            color: Colors.white
                        )
                    ),
                    onPressed: () async {
                      try {
                        // Try to pick files :
                        FilePickerResult? result = await FilePicker.platform.pickFiles();
                        if (result != null) {
                          fileUploadPhotoRecto = io.File(result.files.single.path!);
                          photoRectoController.text = result.files.single.name;
                          setState(() {
                            uploadPhotoRecto = true;
                          });
                        }
                      } catch (e) {
                        // If an error occurs, log the error to the console.
                        //print('Erreur ....$e');
                      }
                    },
                    icon: const Icon(
                      Icons.upload_file,
                      size: 20,
                      color: Colors.white,
                    ),
                  )
              ),
            ],
          )
      ),
      Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
          child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: TextField(
                enabled: false,
                controller: photoRectoController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Fichier Recto...',
                ),
                style: TextStyle(
                    height: 0.8
                ),
                textAlignVertical: TextAlignVertical.bottom,
                textAlign: TextAlign.right,
              )
          )
      ),

      Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.only(left: 10, right: 10, top: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pièce Verso Gérant',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18
              ),
            ),
            Divider(
              height: 3,
              thickness: 2,
              color: Colors.brown,
            )
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
                child: ElevatedButton.icon(
                  style: ButtonStyle(
                      backgroundColor: WidgetStateColor.resolveWith((states) => Colors.blue)
                  ),
                  label: const Text("Appareil photo",
                      style: TextStyle(
                          color: Colors.white
                      )
                  ),
                  onPressed: () async {
                    try {
                      // Ensure that the camera is initialized.
                      if (stepForPhoto == 0) {
                        //setState(() {
                        if (cameraOnPause) {
                          cameraOnPause = false;
                          _cameraController!.resumePreview();
                        }
                        stepForPhoto++;
                        //});
                        displayCameraDialog(4);
                      }
                    } catch (e) {
                      // If an error occurs, log the error to the console.
                      //print('Erreur ....$e');
                    }
                  },
                  icon: const Icon(
                    Icons.camera_alt_outlined,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                  width: (MediaQuery.of(context).size.width / 2) - 20,
                  child: ElevatedButton.icon(
                    style: ButtonStyle(
                        backgroundColor: WidgetStateColor.resolveWith((states) => photoIdentite)
                    ),
                    label: const Text("Uploader",
                        style: TextStyle(
                            color: Colors.white
                        )
                    ),
                    onPressed: () async {
                      try {
                        // Try to pick files :
                        FilePickerResult? result = await FilePicker.platform.pickFiles();
                        if (result != null) {
                          fileUploadPhotoVerso = io.File(result.files.single.path!);
                          photoVersoController.text = result.files.single.name;
                          setState(() {
                            uploadPhotoVerso = true;
                          });
                        }
                      } catch (e) {
                        // If an error occurs, log the error to the console.
                        //print('Erreur ....$e');
                      }
                    },
                    icon: const Icon(
                      Icons.upload_file,
                      size: 20,
                      color: Colors.white,
                    ),
                  )
              ),
            ],
          )
      ),
      Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
          child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: TextField(
                enabled: false,
                controller: photoVersoController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Fichier Verso...',
                ),
                style: TextStyle(
                    height: 0.8
                ),
                textAlignVertical: TextAlignVertical.bottom,
                textAlign: TextAlign.right,
              )
          )
      ),
      
      Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.only(left: 10, right: 10, top: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Photo Registre Commerce',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18
              ),
            ),
            Divider(
              height: 3,
              thickness: 2,
              color: Colors.brown,
            )
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
                child: ElevatedButton.icon(
                  style: ButtonStyle(
                      backgroundColor: WidgetStateColor.resolveWith((states) => Colors.brown)
                  ),
                  label: const Text("Appareil photo",
                      style: TextStyle(
                          color: Colors.white
                      )
                  ),
                  onPressed: () async {
                    try {
                      // Ensure that the camera is initialized.
                      if (stepForPhoto == 0) {
                        //setState(() {
                          if (cameraOnPause) {
                            cameraOnPause = false;
                            _cameraController!.resumePreview();
                          }
                          stepForPhoto++;
                        //});
                          displayCameraDialog(1);
                      }
                      else {
                        final image = await _cameraController!.takePicture();
                        photoCommerce = image;
                        photoCommerceController.text = photoCommerce!.name;
                        await _cameraController!.pausePreview();
                        cameraOnPause = true;
                        uploadPhotoCommerce = false;
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
                    Icons.camera_alt_outlined,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                  width: (MediaQuery.of(context).size.width / 2) - 20,
                  child: ElevatedButton.icon(
                    style: ButtonStyle(
                        backgroundColor: WidgetStateColor.resolveWith((states) => photoIdentite)
                    ),
                    label: const Text("Uploader",
                        style: TextStyle(
                            color: Colors.white
                        )
                    ),
                    onPressed: () async {
                      try {
                        // Try to pick files :
                        FilePickerResult? result = await FilePicker.platform.pickFiles();
                        if (result != null) {
                          fileUploadPhotoCommerce = io.File(result.files.single.path!);
                          photoCommerceController.text = result.files.single.name;
                          setState(() {
                            uploadPhotoCommerce = true;
                          });
                        }
                      } catch (e) {
                        // If an error occurs, log the error to the console.
                        //print('Erreur ....$e');
                      }
                    },
                    icon: const Icon(
                      Icons.upload_file,
                      size: 20,
                      color: Colors.white,
                    ),
                  )
              ),
            ],
          )
      ),
      Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
          child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: TextField(
                enabled: false,
                controller: photoCommerceController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Photo Registre Commerce...',
                ),
                style: TextStyle(
                    height: 0.8
                ),
                textAlignVertical: TextAlignVertical.bottom,
                textAlign: TextAlign.right,
              )
          )
      ),

      Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.only(left: 10, right: 10, top: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Photo DFE',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18
              ),
            ),
            Divider(
              height: 3,
              thickness: 2,
              color: Colors.brown,
            )
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
                child: ElevatedButton.icon(
                  style: ButtonStyle(
                      backgroundColor: WidgetStateColor.resolveWith((states) => Colors.grey)
                  ),
                  label: const Text("Appareil photo",
                      style: TextStyle(
                          color: Colors.white
                      )
                  ),
                  onPressed: () async {
                    try {
                      // Ensure that the camera is initialized.
                      if (stepForPhoto == 0) {
                        //setState(() {
                        if (cameraOnPause) {
                          cameraOnPause = false;
                          _cameraController!.resumePreview();
                        }
                        stepForPhoto++;
                        //});
                        displayCameraDialog(2);
                      }
                    } catch (e) {
                      // If an error occurs, log the error to the console.
                      //print('Erreur ....$e');
                    }
                  },
                  icon: const Icon(
                    Icons.camera_alt_outlined,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                  width: (MediaQuery.of(context).size.width / 2) - 20,
                  child: ElevatedButton.icon(
                    style: ButtonStyle(
                        backgroundColor: WidgetStateColor.resolveWith((states) => photoIdentite)
                    ),
                    label: const Text("Uploader",
                        style: TextStyle(
                            color: Colors.white
                        )
                    ),
                    onPressed: () async {
                      try {
                        // Try to pick files :
                        FilePickerResult? result = await FilePicker.platform.pickFiles();
                        if (result != null) {
                          fileUploadPhotoDfe = io.File(result.files.single.path!);
                          photoDfeController.text = result.files.single.name;
                          setState(() {
                            uploadPhotoDfe = true;
                          });
                        }
                      } catch (e) {
                        // If an error occurs, log the error to the console.
                        //print('Erreur ....$e');
                      }
                    },
                    icon: const Icon(
                      Icons.upload_file,
                      size: 20,
                      color: Colors.white,
                    ),
                  )
              ),
            ],
          )
      ),
      Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
          child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: TextField(
                enabled: false,
                controller: photoDfeController,
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
              visible: ((photoRecto != null || fileUploadPhotoRecto != null) && gpsPermission) ||
                  entrepriseToManage.id != 0,
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
                    if(entrepriseToManage.id == 0) {
                      if (!streamGps) {
                        // check on ville :
                        if (photoRectoController.text.isEmpty) {
                          displayToast(
                              'Veuillez prendre obligatoirement une PHOTO RECTO de la pièce du Gérant !');
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
                                          if (precisionGps <
                                              gpsPrecisionAccuracy ||
                                              precisionGps <
                                                  _currentDiscreteSliderValue) {
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
                    }
                    else{
                      //
                      displayDataSending();
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

  void displayCameraDialog(int step){
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          dialogContext = context;
          return PopScope(
              canPop: false,
              child: AlertDialog(
                  title: Text('Prendre photo'),
                  content: Container(
                    padding: const EdgeInsets.only(left: 5, right: 5, top: 5),
                    height: MediaQuery.sizeOf(context).height * 0.50,
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 5, bottom: 15),
                          height: MediaQuery.sizeOf(context).height * 0.40,
                          width: MediaQuery.sizeOf(context).width * 0.90,
                          child: CameraPreview(_cameraController!),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              style: ButtonStyle(
                                  backgroundColor: WidgetStateColor.resolveWith((states) => Colors.redAccent)
                              ),
                              label: const Text("Annuler",
                                  style: TextStyle(
                                      color: Colors.white
                                  )
                              ),
                              onPressed: () async {
                                cancelCameraDialog();
                              },
                              icon: const Icon(
                                Icons.upload_file,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                            ElevatedButton.icon(
                              style: ButtonStyle(
                                  backgroundColor: WidgetStateColor.resolveWith((states) => photoIdentite)
                              ),
                              label: const Text("Capturer",
                                  style: TextStyle(
                                      color: Colors.white
                                  )
                              ),
                              onPressed: () async {
                                try {
                                  final image = await _cameraController!.takePicture();
                                  switch(step){
                                    case 1:
                                      // Registre commerce :
                                      photoCommerce = image;
                                      photoCommerceController.text = image.name;
                                      uploadPhotoCommerce = false;
                                      break;

                                    case 2:
                                      // DFE :
                                      photoDfe = image;
                                      photoDfeController.text = image.name;
                                      uploadPhotoDfe = false;
                                      break;

                                    case 3:
                                      photoRecto = image;
                                      photoRectoController.text = image.name;
                                      uploadPhotoRecto = false;
                                      break;

                                    default:
                                      photoVerso = image;
                                      photoVersoController.text = image.name;
                                      uploadPhotoVerso = false;
                                      break;
                                  }
                                  await _cameraController!.pausePreview();
                                  cameraOnPause = true;
                                  // Reset :
                                  closeCameraDialog();
                                } catch (e) {
                                  // If an error occurs, log the error to the console.
                                  //print('Erreur ....$e');
                                }
                              },
                              icon: const Icon(
                                Icons.upload_file,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
              )
          );
        }
        );
  }

  void cancelCameraDialog() async{
    Navigator.pop(dialogContext);
    await _cameraController!.pausePreview();
    cameraOnPause = true;
    // Reset :
    setState(() {
      stepForPhoto = 0;
    });
  }

  void closeCameraDialog(){
    Navigator.pop(dialogContext);
    setState(() {
      stepForPhoto = 0;
    });
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

  String convertUploadedFile(io.File file){
    final bytes = file.readAsBytesSync();
    String img64 = base64Encode(bytes);
    return img64;
  }

  // Check if PHOTO ARTISAN has been taken :
  String checkPhotoRecto(){
    if(photoRectoController.text.isNotEmpty) {
      if (uploadPhotoRecto) {
        return convertUploadedFile(fileUploadPhotoRecto!);
      }
      else if (photoRecto != null) {
        return convertPhotoToString(photoRecto!);
      }
      else {
        // This BLOCK is not necessary :
        return "";
      }
    }
    else{
      return entrepriseToManage.photoCniRecto;
    }
  }

  String factoriseDocumentProcessing(TextEditingController editingController, bool uploadPhoto, io.File? fileUpload, XFile? photoEntite, int choice){
    if(editingController.text.isNotEmpty) {
      if (uploadPhoto) {
        return convertUploadedFile(fileUpload!);
      }
      else if (photoEntite != null) {
        return convertPhotoToString(photoEntite);
      }
      else {
        // This BLOCK is not necessary :
        return "";
      }
    }
    else{
      if(choice == 1){
        return entrepriseToManage.photoCniVerso;
      }
      else if(choice == 2){
        return entrepriseToManage.photoRegistreCommerce;
      }
      else{
        return entrepriseToManage.photoDfe;
      }
    }
  }

  String checkOtherPhotoType(XFile? picture, String photo, String libPhoto){
    if(libPhoto.isNotEmpty) {
      return convertPhotoToString(picture!);
    }
    else{
      return photo;
    }
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
          body: jsonEncode({
            "crm_id": entrepriseToManage.crm,
            "departement_id": entrepriseToManage.departement,
            "sous_prefecture_id": entrepriseToManage.sous_prefecture,
            "gerant_id": 0,
            "civilite": entrepriseToManage.civilite,
            "nom": entrepriseToManage.nom,
            "prenom": entrepriseToManage.prenom,
            "date_naissance": entrepriseToManage.date_naissance,
            "lieu_naissance": entrepriseToManage.lieu_naissance.toString(),
            "lieu_naissance_autre": entrepriseToManage.lieu_naissance_autre,
            "nationalite": entrepriseToManage.nationalite.toString(),
            "sexe": "",
            "statut_matrimonial": entrepriseToManage.statut_matrimonial,
            "type_document": entrepriseToManage.type_document.toString(),
            "numero_piece": entrepriseToManage.numero_piece,
            "piece_delivre": entrepriseToManage.piece_delivre.toString(),
            "date_emission_piece": entrepriseToManage.date_emission_piece,
            "ville_residence": entrepriseToManage.commune_residence,
            "quartier_residence": entrepriseToManage.quartier_residence,
            "adresse_postal": entrepriseToManage.adresse_postal,
            "contact1": entrepriseToManage.contact1,
            "contact2": entrepriseToManage.contact2,
            "email": entrepriseToManage.email,
            "numero_id": 0,
            "numero_rea": "",
            "forme_juridique": entrepriseToManage.forme_juridique,
            "activite_principale": entrepriseToManage.activite_principale,
            "activite_secondaire": entrepriseToManage.activite_secondaire,
            "raison_social": entrepriseToManage.denomination,
            "sigle": entrepriseToManage.sigle,
            "objet_social": entrepriseToManage.objet_social,
            "date_creation": entrepriseToManage.date_creation,
            "rccm": entrepriseToManage.rccm,
            "date_rccm": entrepriseToManage.date_rccm,
            "capital_social": entrepriseToManage.capital_social,
            "regime_fiscal": entrepriseToManage.regime_fiscal,//.id.toString(),
            "nombre_associer": entrepriseToManage.total_associe,
            "duree_personne_morale": entrepriseToManage.duree_personne_morale,
            "numero_cnps": entrepriseToManage.cnps_entreprise,
            "compte_contribuable": entrepriseToManage.compte_contribuable,
            "ilot_lot": entrepriseToManage.lot,
            "contact_entreprise": entrepriseToManage.telephone,
            "adresse": entrepriseToManage.adresse_postal,
            "longitude": longitude,
            "latitude": latitude,
            "commune": entrepriseToManage.commune_siege,
            "quartier": entrepriseToManage.quartier_siege_id,
            "livraison_carte": entrepriseToManage.livraisonCarte,

            "photo_cni_recto" : uploadPhotoRecto ? convertUploadedFile(fileUploadPhotoRecto!) :
              photoRecto != null ? convertPhotoToString(photoRecto!) : "",
            "photo_cni_verso" : uploadPhotoVerso ? convertUploadedFile(fileUploadPhotoVerso!) :
              photoVerso != null ? convertPhotoToString(photoVerso!) : "",
            "photo_registre_commerce" : uploadPhotoCommerce ? convertUploadedFile(fileUploadPhotoCommerce!) :
              photoCommerce != null ? convertPhotoToString(photoCommerce!) : "",
            "photo_dfe" : uploadPhotoDfe ? convertUploadedFile(fileUploadPhotoDfe!) :
              photoDfe != null ? convertPhotoToString(photoDfe!) : ""
          })
      ).timeout(const Duration(seconds: timeOutValue));

      if (response.statusCode == 200) {
        MessageResponse reponse = MessageResponse.fromJson(
            json.decode(response.body));
        Entreprise entreprise = Entreprise(
            id: reponse.id,
            crm: entrepriseToManage.crm,
            departement: entrepriseToManage.departement,
            sous_prefecture: entrepriseToManage.sous_prefecture,
            civilite: entrepriseToManage.civilite,
            nom: entrepriseToManage.nom,
            prenom: entrepriseToManage.prenom,
            date_naissance: entrepriseToManage.date_naissance,
            lieu_naissance: entrepriseToManage.lieu_naissance,
            lieu_naissance_autre: entrepriseToManage.lieu_naissance_autre,
            nationalite: entrepriseToManage.nationalite,
            statut_matrimonial: entrepriseToManage.statut_matrimonial,
            type_document: entrepriseToManage.type_document,
            numero_piece: entrepriseToManage.numero_piece,
            piece_delivre: entrepriseToManage.piece_delivre,
            date_emission_piece: entrepriseToManage.date_emission_piece,
            commune_residence: entrepriseToManage.commune_residence,
            quartier_residence: entrepriseToManage.quartier_residence,
            adresse_postal: entrepriseToManage.adresse_postal,
            contact1: entrepriseToManage.contact1,
            contact2: entrepriseToManage.contact2,
            email: entrepriseToManage.email,

            forme_juridique: entrepriseToManage.forme_juridique,
            activite_principale: entrepriseToManage.activite_principale,
            activite_secondaire: entrepriseToManage.activite_secondaire,
            denomination: entrepriseToManage.denomination,
            sigle: entrepriseToManage.sigle,
            date_creation: entrepriseToManage.date_creation,
            objet_social: entrepriseToManage.objet_social,
            rccm: entrepriseToManage.rccm,
            date_rccm: entrepriseToManage.date_rccm,
            capital_social: entrepriseToManage.capital_social,
            regime_fiscal: entrepriseToManage.regime_fiscal,
            duree_personne_morale: entrepriseToManage.duree_personne_morale,
            cnps_entreprise: entrepriseToManage.cnps_entreprise,
            compte_contribuable: entrepriseToManage.compte_contribuable,
            total_associe: entrepriseToManage.total_associe,
            commune_siege: entrepriseToManage.commune_siege,
            quartier_siege: entrepriseToManage.quartier_siege,
            lot: entrepriseToManage.lot,
            telephone: entrepriseToManage.telephone,
            statut_kyc: 0,
            statut_paiement: 0,
            longitude: longitude,
            latitude: latitude,
            millisecondes: DateTime.now().millisecondsSinceEpoch,
            quartier_siege_id: entrepriseToManage.quartier_siege_id,
            livraisonCarte: entrepriseToManage.livraisonCarte,

            photoCniRecto: checkPhotoRecto(),
            photoCniVerso: factoriseDocumentProcessing(photoVersoController, uploadPhotoVerso, fileUploadPhotoVerso, photoVerso, 1),
            photoRegistreCommerce: factoriseDocumentProcessing(photoCommerceController, uploadPhotoCommerce, fileUploadPhotoCommerce, photoCommerce, 2),
            photoDfe: factoriseDocumentProcessing(photoDfeController, uploadPhotoDfe, fileUploadPhotoDfe, photoDfe, 3)
        );
        entrepriseControllerX.addItem(entreprise);
        // Refresh :
        entrepriseToManage = entreprise;
        flagSendData = false;
      } else {
        displayToast("Impossible de transmettre les données de l'Artisan !");
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
          title: Text(entrepriseToManage.id == 0 ? 'Création Entreprise' : 'Modification Entreprise'),
          /*actions: [
            IconButton(
                onPressed: () {
                  setState(() {
                    switchUploadFile = !switchUploadFile;
                    // Reset :
                    fileUploadPhotoArtisan = null;
                    uploadPhotoArtisan = false;
                  });
                },
                icon: Icon(switchUploadFile ? Icons.file_upload : Icons.file_upload_outlined, color: Colors.brown)
            )
          ],*/
        ),
        body: _buildUI()
    );
  }

}

