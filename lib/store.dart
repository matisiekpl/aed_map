import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'constants.dart';
import 'models/aed.dart';

class Store {
  static Store instance = Store();

  Future<LatLng> determinePosition() async {
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
    var position = await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 2));
    return LatLng(position.latitude, position.longitude);
  }

  static const String aedListKey = 'aed_list_json';

  updateAEDs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse('https://aed.openstreetmap.org.pl/aed_poland.geojson'));
      await prefs.setString(aedListKey, response.body);
    } catch (err) {
      if (kDebugMode) {
        print('Failed to load AEDs from internet!');
      }
    }
  }

  loadLocalAEDs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String data = await rootBundle.loadString("assets/aed_poland.geojson");
    await prefs.setString(aedListKey, data);
  }

  Future<List<AED>> loadAEDs(LatLng currentLocation) async {
    List<AED> aeds = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(aedListKey)) await loadLocalAEDs();
    updateAEDs();
    var contents = prefs.getString(aedListKey)!;
    var jsonList = jsonDecode(contents)['features'];
    jsonList.forEach((row) {
      aeds.add(AED(
          LatLng(row['geometry']['coordinates'][1],
              row['geometry']['coordinates'][0]),
          row['properties']['osm_id'],
          row['properties']['defibrillator:location'],
          row['properties']['indoor'] == 'yes',
          row['properties']['operator'],
          row['properties']['phone'],
          row['properties']['opening_hours'],
          row['properties']['access']));
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

    print(aeds[0].toXml(777));

    return aeds;
  }

  void authenticate() async {
    var clientId = 'fMwHrWOkZCboGJR1umv202RX2aBLBFgMt8SLqg1iktA';
    var clientSecret = 'zhfFUhRW5KnjsQnGbZR0gnZObfvuxn-F-_HOxLNd72A';
    final result = await FlutterWebAuth.authenticate(
        url:
            "https://www.openstreetmap.org/oauth2/authorize?client_id=$clientId&redirect_uri=aedmap://success&response_type=code&scope=write_api",
        callbackUrlScheme: "aedmap");
    final code = Uri.parse(result).queryParameters['code'];
    if (kDebugMode) {
      print('Got OAuth2 code: $code');
    }
    var response = await http.post(
        Uri.parse(
            'https://www.openstreetmap.org/oauth2/token?grant_type=authorization_code&redirect_uri=aedmap://success&client_id=$clientId&client_secret=$clientSecret&code=$code'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'});
    var token = json.decode(response.body)['access_token'];
    if (kDebugMode) {
      print('Got OAuth2 token: $token');
    }
  }
}
