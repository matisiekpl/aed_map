import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:http/http.dart' as http;

import 'constants.dart';
import 'models/aed.dart';

class Store {
  static Store instance = Store();

  Future<LatLng> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('Location services are disabled.');

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return warsaw;
    }
    if (permission == LocationPermission.deniedForever) return warsaw;
    var position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }

  Future<List<AED>> loadAEDs(LatLng currentLocation) async {
    var response = await http.get(Uri.parse('https://aed.openstreetmap.org.pl/aed_poland.geojson'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load AEDs');
    }
    List<AED> aeds = [];
    var jsonList = jsonDecode(response.body)['features'];
    jsonList.forEach((row) {
      aeds.add(AED(LatLng(row['geometry']['coordinates'][1], row['geometry']['coordinates'][0]), row['properties']['osm_id'], row['properties']['defibrillator:location'],
          row['properties']['indoor'] == 'yes', row['properties']['operator'], row['properties']['phone'], row['properties']['opening_hours']));
    });
    if (kDebugMode) {
      print('Loaded ${aeds.length} AEDs!');
    }
    aeds = aeds.map((aed) {
      const Distance distance = Distance();
      aed.distance = distance(currentLocation, aed.location).ceil();
      return aed;
    }).toList();
    aeds.sort((a, b) => a.distance!.compareTo(b.distance!));
    return aeds;
  }
}
