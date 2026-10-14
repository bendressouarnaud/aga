import 'dart:async';

import 'package:flutter/material.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';

class InterfaceDisplayCarte extends StatefulWidget {
  //final Set<Marker> lesMarkers;
  //const InterfaceDisplayCarte({super.key, required this.lesMarkers});
  const InterfaceDisplayCarte({super.key});

  @override
  State<InterfaceDisplayCarte> createState() => _InterfaceDisplayCarte();
}

class _InterfaceDisplayCarte extends State<InterfaceDisplayCarte> {
  /*final Completer<GoogleMapController> _controller =
  Completer<GoogleMapController>();*/

  @override
  Widget build(BuildContext context) {

    /*CameraPosition kGooglePlex = CameraPosition(
      target: LatLng(widget.lesMarkers.first.position.latitude,
          widget.lesMarkers.first.position.longitude),
      zoom: 14.4746,
    );*/

    return Scaffold(
      /*body: GoogleMap(
        //myLocationEnabled: true,
        mapToolbarEnabled: true,
        mapType: MapType.normal,
        initialCameraPosition: kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: widget.lesMarkers
      )*/
    );
  }

}