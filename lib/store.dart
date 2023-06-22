import 'dart:convert';
import 'dart:io';

import 'package:aed_map/models/trip.dart';
import 'package:dio/dio.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nude_detector/flutter_nude_detector.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import 'constants.dart';
import 'models/aed.dart';

class Store {
  static Store instance = Store();

  Future<LatLng> determinePosition() async {
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
          row['properties']['defibrillator:location'] ??
              row['properties']['defibrillator:location:pl'],
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

    return aeds;
  }

  String? token;

  Future<bool> authenticate() async {
    if (token != null) return true;
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
    token = json.decode(response.body)['access_token'];
    if (kDebugMode) {
      print('Got OAuth2 token: $token');
    }
    return token != null;
  }

  Future<int> getChangesetId() async {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0"');
    builder.element('osm', attributes: {'version': '0.6'}, nest: () {
      builder.element('changeset', nest: () {
        builder.element('tag',
            attributes: {'k': 'created_by', 'v': 'AED Map for Android/iOS'});
        builder.element('tag', attributes: {
          'k': 'comment',
          'v': 'Defibrillator modified via AED Map #aed'
        });
      });
    });
    final document = builder.buildDocument();
    var response = await http.put(
        Uri.parse('https://api.openstreetmap.org/api/0.6/changeset/create'),
        headers: {'Content-Type': 'text/xml', 'Authorization': 'Bearer $token'},
        body: document.toXmlString());
    return int.parse(response.body.toString());
  }

  Future<AED> insertDefibrillator(AED aed) async {
    var changesetId = await getChangesetId();
    var response = await http.put(
        Uri.parse('https://api.openstreetmap.org/api/0.6/node/create'),
        headers: {'Content-Type': 'text/xml', 'Authorization': 'Bearer $token'},
        body: aed.toXml(changesetId, 1));
    var id = int.parse(response.body.toString());
    aed.id = id;
    if (kDebugMode) {
      print('https://www.openstreetmap.org/node/$id');
    }
    return aed;
  }

  Future<AED> updateDefibrillator(AED aed) async {
    var changesetId = await getChangesetId();
    var fetchResponse = await http.get(
        Uri.parse('https://api.openstreetmap.org/api/0.6/node/${aed.id}'),
        headers: {
          'Content-Type': 'text/xml',
          'Authorization': 'Bearer $token'
        });
    final document = XmlDocument.parse(fetchResponse.body);
    final oldVersion = document
        .findAllElements('node')
        .first
        .attributes
        .where((attr) => attr.name.toString() == 'version')
        .first
        .value;
    var oldTags = document.findAllElements('tag');
    var oldTagsPairs = oldTags.map((tag) {
      return [
        tag.attributes.where((attr) => attr.name.toString() == 'k').first.value,
        tag.attributes.where((attr) => attr.name.toString() == 'v').first.value
      ];
    }).toList();
    var xml =
        aed.toXml(changesetId, int.parse(oldVersion), oldTags: oldTagsPairs);
    await http.put(
        Uri.parse('https://api.openstreetmap.org/api/0.6/node/${aed.id}'),
        headers: {'Content-Type': 'text/xml', 'Authorization': 'Bearer $token'},
        body: xml);
    if (kDebugMode) {
      print('https://www.openstreetmap.org/node/${aed.id}');
    }
    return aed;
  }

  sendFeedback(UserFeedback feedback) async {
    final now = DateTime.now();
    final id = now.microsecondsSinceEpoch.toString();
    var content = feedback.text;
    await http
        .post(Uri.parse('http://feedback.aedmapa.pl:5000/feedback'), body: {
      'body': content,
      'id': id.toString(),
      'screenshot': base64Encode(feedback.screenshot)
    });
    if (kDebugMode) {
      print('Feedback sent!');
    }
  }

  final String imagesApiUrl = "http://srv3.enteam.pl:1444";

  Future<String?> uploadImage(String filename) async {
    final image = decodeImage(File(filename).readAsBytesSync())!;
    final thumbnail = copyResize(image, width: 512);
    filename = '$filename.jpg';
    File(filename).writeAsBytesSync(encodePng(thumbnail));
    final hasNudity = await FlutterNudeDetector.detect(path: filename);
    if (hasNudity) return null;
    var formData = FormData.fromMap(
        {'file': await MultipartFile.fromFile(filename, filename: filename)});
    var response = await Dio().post('$imagesApiUrl/images', data: formData);
    var tag = response.data['filename'];
    return '$imagesApiUrl/$tag';
  }

  Future<Trip?> navigate(LatLng current, AED aed) async {
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
          {'lat': aed.location.latitude, 'lon': aed.location.longitude}
        ]
      };
      var response = await http
          .get(Uri.parse('$valhalla/route?json=${json.encode(payload)}'));
      var result = json.decode(response.body);
      return Trip(
          result['trip']['legs'][0]['shape'],
          result['trip']['summary']['time'],
          result['trip']['summary']['length']);
    } catch (err) {
      return null;
    }
  }

  Future<LatLng> locate() async {
    if (kDebugMode) {
      return LatLng(warsaw.latitude, warsaw.longitude);
    } else {
      return await Store.instance.determinePosition();
    }
  }
}
