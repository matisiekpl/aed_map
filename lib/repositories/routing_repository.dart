import 'dart:convert';

import 'package:aed_map/constants.dart';
import 'package:aed_map/models/aed.dart';
import 'package:aed_map/models/trip.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class RoutingRepository {
  Future<Trip?> navigate(LatLng current, Defibrillator defibrillator) async {
    try {
      var payload = {
        'costing': 'pedestrian',
        'costing_options': {
          'pedestrian': {'walking_speed': 9}
        },
        'units': 'meters',
        'id': 'aed_navigation',
        'locations': [
          {
            'lat': current.latitude,
            'lon': current.longitude,
          },
          {'lat': defibrillator.location.latitude, 'lon': defibrillator.location.longitude}
        ]
      };
      var response = await http.get(Uri.parse('$valhalla/route?json=${jsonEncode(payload)}'));
      var result = json.decode(response.body);
      return Trip(
          result['trip']['legs'][0]['shape'], result['trip']['summary']['time'], result['trip']['summary']['length']);
    } catch (err) {
      return null;
    }
  }
}
