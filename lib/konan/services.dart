import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cnmci/konan/repositories/user_repository.dart';
import 'package:cnmci/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'beans/accountsigninresponse.dart';
import 'beans/accountsigninresponse_refresh.dart';
import 'model/user.dart';
import 'objets/constants.dart';

class MesServices{


  // M E T H O D S  :
  Future<String> checkJwtExpiration() async{
    final UserRepository _userRepository = UserRepository();
    String jwtToReturn = "";

    var temps = DateTime.fromMillisecondsSinceEpoch(globalUser!.milliseconds);
    var now = DateTime.now();
    final difference = now.difference(temps);
    if(difference.inMinutes >= 300){ // durée EXPIRATION : 5h
      // REFRESH :
      final url = Uri.parse('${dotenv.env['URL_BACKEND']}authentification');
      try {
        var response = await post(url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "identifiant": globalUser!.email,
              "motdepasse": globalUser!.pwd
            })
        ).timeout(const Duration(seconds: timeOutValue));

        if (response.statusCode == 200) {
          AccountSignInResponseRefresh donnee =  AccountSignInResponseRefresh.fromJson(json.decode(response.body));
          // Ici, adapte selon la réponse de ton backend
          User user = User(
              id: globalUser!.id,
              nom: globalUser!.nom,
              email: globalUser!.email,
              pwd: globalUser!.pwd,
              jwt: donnee.data.token,
              profil: globalUser!.profil,
              milliseconds: DateTime.now().millisecondsSinceEpoch
          );
          _userRepository.update(user);
          globalUser = user;
          jwtToReturn = donnee.data.token;
        }
      }
      catch(e){
        jwtToReturn = "";
      }
      return jwtToReturn;
    }
    else{
      return globalUser!.jwt;
    }
  }


  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
    );

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  Future<bool> determinePositionStream() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return false;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return true;
  }

  void displayDialog(BuildContext context, String paymentUrl){
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext dContext) {
          return AlertDialog(
            titleTextStyle: TextStyle(
              color: Colors.deepOrange,
              fontSize: 18,
              fontWeight: FontWeight.bold
            ),
              title: GestureDetector(
                child: Text('Scannez le QR code (Fermer)'),
                onTap: (){
                  Navigator.pop(dContext);
                },
              ),
              content: SizedBox(
                  height: 300,
                  width: 300,
                  child: QrImageView(
                    data: paymentUrl,
                    version: QrVersions.auto,
                    size: 280,
                    errorCorrectionLevel: QrErrorCorrectLevel.H,
                    backgroundColor: Colors.white,
                  )
              )
          );
        }
    );
  }

  Widget displayFromLocalOrFirebase(String image){
    return image.isNotEmpty && image.length < 41 ? CachedNetworkImage(
        imageUrl: "https://firebasestorage.googleapis.com/v0/b/cnm-ci.firebasestorage.app/o/$image?alt=media",
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.fill,
            ),
          ),
        ),
        placeholder: (context, url) => const CircularProgressIndicator(
          color: Colors.brown,
        ),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ) : 
      image.length >= 41 ? Image.memory(base64Decode(image),
        width: 60,
        height: 80,
        fit: BoxFit.fill) :
      Icon(Icons.person,
      size: 30,
      )
    ;
  }

  String processEntityName(String name, int limit){
    return name.length > (limit + 1) ? '${name.substring(0, limit)}...' : name;
  }
}