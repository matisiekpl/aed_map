import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../constants.dart';

class GeolocationRepository {
  Future<LatLng> locate() async {
    if (kDebugMode) {
      return warsaw;
    }
    try {
      bool serviceEnabled;
      LocationPermission permission;
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return warsaw;

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return warsaw;
      }
      if (permission == LocationPermission.deniedForever) return warsaw;
      var position = await Geolocator.getLastKnownPosition();
      if (position == null) return warsaw;
      return LatLng(position.latitude, position.longitude);
    } catch (err) {
      return warsaw;
    }
  }
}
