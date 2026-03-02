import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class InterfaceDisplayCarte extends StatefulWidget {
  final Set<Marker> lesMarkers;
  const InterfaceDisplayCarte({super.key, required this.lesMarkers});

  @override
  State<InterfaceDisplayCarte> createState() => _InterfaceDisplayCarte();
}

class _InterfaceDisplayCarte extends State<InterfaceDisplayCarte> {
  final Completer<GoogleMapController> _controller =
  Completer<GoogleMapController>();

  /*static const CameraPosition _kLake = CameraPosition(
    bearing: 192.8334901395799,
    target: LatLng(37.43296265331129, -122.08832357078792),
    tilt: 59.440717697143555,
    zoom: 19.151926040649414,
  );*/

  @override
  Widget build(BuildContext context) {

    CameraPosition kGooglePlex = CameraPosition(
      target: LatLng(widget.lesMarkers.first.position.latitude,
          widget.lesMarkers.first.position.longitude),
      zoom: 14.4746,
    );

    return Scaffold(
      body: GoogleMap(
        //myLocationEnabled: true,
        mapToolbarEnabled: true,
        mapType: MapType.normal,
        initialCameraPosition: kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: widget.lesMarkers
      ),
      /*floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToTheLake,
        label: const Text('To the lake!'),
        icon: const Icon(Icons.directions_boat),
      ),*/
    );
  }

  /*Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }*/
}