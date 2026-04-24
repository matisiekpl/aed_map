import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../constants.dart';

class GeolocationRepository {
  Future<({LatLng location, bool permissionDenied})> locate() async {
    if (kDebugMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      return (location: warsaw, permissionDenied: false);
    }
    try {
      bool serviceEnabled;
      LocationPermission permission;
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return (location: warsaw, permissionDenied: false);
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return (location: warsaw, permissionDenied: true);
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return (location: warsaw, permissionDenied: true);
      }
      var position = await Geolocator.getLastKnownPosition();
      if (position == null) {
        return (location: warsaw, permissionDenied: false);
      }
      return (
        location: LatLng(position.latitude, position.longitude),
        permissionDenied: false,
      );
    } catch (err) {
      return (location: warsaw, permissionDenied: false);
    }
  }
}
