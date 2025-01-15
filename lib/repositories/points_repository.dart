import 'dart:convert';

import 'package:aed_map/constants.dart';
import 'package:aed_map/main.dart';
import 'package:aed_map/models/aed.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:latlong2/latlong.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class PointsRepository {
  static const String aedListKey = 'aed_list_json_2';
  static const String aedUpdateTimestamp = 'aed_update';

  updateAEDs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse('https://openaedmap.org/api/v1/countries/WORLD.geojson'));
      await prefs.setString(aedListKey, utf8.decode(response.bodyBytes));
      await prefs.setString(
          aedUpdateTimestamp, DateTime.now().toIso8601String());
    } catch (err) {
      if (kDebugMode) {
        print('Failed to load AEDs from internet!');
      }
    }
  }

  loadLocalAEDs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String data = await rootBundle.loadString("assets/world.geojson");
    data = data.replaceAll("@osm_id", "osm_id");
    await prefs.setString(aedListKey, data);
  }

  Future<DateTime> getLastUpdateTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var value = prefs.getString(aedUpdateTimestamp);
    if (value == null) return DateTime.now();
    return DateTime.parse(value);
  }

  Future<List<AED>> loadAEDs(LatLng currentLocation) async {
    List<AED> aeds = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(aedListKey)) await loadLocalAEDs();
    updateAEDs();
    var contents = prefs.getString(aedListKey)!;
    var idLabel = 'osm_id';
    if (contents.contains('@osm_id')) {
      idLabel = '@osm_id';
    }
    var jsonList = jsonDecode(contents)['features'];
    jsonList.forEach((row) {
      aeds.add(AED(
          location: LatLng(row['geometry']['coordinates'][1],
              row['geometry']['coordinates'][0]),
          id: row['properties'][idLabel],
          description: row['properties']['defibrillator:location'] ??
              row['properties']['defibrillator:location:pl'],
          indoor: row['properties']['indoor'],
          operator: row['properties']['operator'],
          phone: row['properties']['phone'],
          openingHours: row['properties']['opening_hours'],
          access: row['properties']['access']));
    });
    if (kDebugMode) {
      print('Loaded ${aeds.length} AEDs!');
    }
    aeds = aeds.map((aed) {
      const Distance distance = Distance(calculator: Haversine());
      aed.distance = distance(currentLocation, aed.location).ceil();
      return aed;
    }).toList();
    aeds.sort((a, b) => a.distance!.compareTo(b.distance!));
    return aeds.toList();
  }

  String? token;

  Future<bool> authenticate() async {
    if (token != null || kDebugMode) return true;
    mixpanel.track(loginEvent);
    var clientId = 'fMwHrWOkZCboGJR1umv202RX2aBLBFgMt8SLqg1iktA';
    var clientSecret = 'zhfFUhRW5KnjsQnGbZR0gnZObfvuxn-F-_HOxLNd72A';
    try {
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
      mixpanel.track(authenticatedEvent);
      return token != null;
    } on Exception catch (_) {
      return false;
    }
  }

  Future<int> getChangesetId() async {
    var packageInfo = await PackageInfo.fromPlatform();
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0"');
    builder.element('osm', attributes: {'version': '0.6'}, nest: () {
      builder.element('changeset', nest: () {
        builder.element('tag', attributes: {
          'k': 'created_by',
          'v': 'AED Map for Android/iOS (aedmap v${packageInfo.version})'
        });
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
    try {
      var changesetId = await getChangesetId();
      if (!kDebugMode) {
        var response = await http.put(
            Uri.parse('https://api.openstreetmap.org/api/0.6/node/create'),
            headers: {
              'Content-Type': 'text/xml',
              'Authorization': 'Bearer $token'
            },
            body: aed.toXml(changesetId, 1));
        var id = int.parse(response.body.toString());
        aed.id = id;
      } else {
        aed.id = 9999;
      }
      if (kDebugMode) {}
      updateAEDs();
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
    }
    return aed;
  }

  Future<AED> updateDefibrillator(AED aed) async {
    if (kDebugMode) {
      return aed;
    }
    try {
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
          tag.attributes
              .where((attr) => attr.name.toString() == 'k')
              .first
              .value,
          tag.attributes
              .where((attr) => attr.name.toString() == 'v')
              .first
              .value
        ];
      }).toList();
      var xml =
          aed.toXml(changesetId, int.parse(oldVersion), oldTags: oldTagsPairs);
      await http.put(
          Uri.parse('https://api.openstreetmap.org/api/0.6/node/${aed.id}'),
          headers: {
            'Content-Type': 'text/xml',
            'Authorization': 'Bearer $token'
          },
          body: xml);
      updateAEDs();
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
    }
    return aed;
  }

  Future<String?> getImage(AED aed) async {
    try {
      var response = await http
          .get(Uri.parse('https://back.openaedmap.org/api/v1/node/${aed.id}'));
      var result = jsonDecode(response.body);
      if (result['elements'][0]['@photo_url'].toString().length > 10) {
        return 'https://back.openaedmap.org${result['elements'][0]['@photo_url']}';
      }
      return null;
    } catch (err) {
      return null;
    }
  }
}
