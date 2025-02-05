import 'dart:convert';
import 'dart:io';

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

import '../models/user.dart';

class PointsRepository {
  static const String defibrillatorListKey = 'aed_list_json_2';
  static const String defibrillatorListUpdateTimestamp = 'aed_update';

  updateDefibrillators() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse('https://openaedmap.org/api/v1/countries/WORLD.geojson'));
      await prefs.setString(defibrillatorListKey, utf8.decode(response.bodyBytes));
      await prefs.setString(
          defibrillatorListUpdateTimestamp, DateTime.now().toIso8601String());
    } catch (err) {
      if (kDebugMode) {
        print('Failed to load defibrillators from internet!');
      }
    }
  }

  loadLocalDefibrillators() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String data = await rootBundle.loadString("assets/world.geojson");
    data = data.replaceAll("@osm_id", "osm_id");
    await prefs.setString(defibrillatorListKey, data);
  }

  Future<DateTime> getLastUpdateTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var value = prefs.getString(defibrillatorListUpdateTimestamp);
    if (value == null) return DateTime.now();
    return DateTime.parse(value);
  }

  Future<List<Defibrillator>> loadDefibrillators(LatLng currentLocation) async {
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      await mixpanel.registerSuperProperties({
        "\$latitude": currentLocation.latitude,
        "\$longitude": currentLocation.longitude
      });
      mixpanel.getPeople().set('\$latitude', currentLocation.latitude);
      mixpanel.getPeople().set('\$longitude', currentLocation.longitude);
    }
    List<Defibrillator> defibrillators = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(defibrillatorListKey)) await loadLocalDefibrillators();
    updateDefibrillators();
    var contents = prefs.getString(defibrillatorListKey)!;
    var idLabel = 'osm_id';
    if (contents.contains('@osm_id')) {
      idLabel = '@osm_id';
    }
    var jsonList = jsonDecode(contents)['features'];
    jsonList.forEach((row) {
      defibrillators.add(Defibrillator(
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
      print('Loaded ${defibrillators.length} defibrillators!');
    }
    defibrillators = defibrillators.map((defibrillator) {
      const Distance distance = Distance(calculator: Haversine());
      defibrillator.distance = distance(currentLocation, defibrillator.location).ceil();
      return defibrillator;
    }).toList();
    defibrillators.sort((a, b) => a.distance!.compareTo(b.distance!));
    return defibrillators.toList();
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
              "https://www.openstreetmap.org/oauth2/authorize?client_id=$clientId&redirect_uri=aedmap://success&response_type=code&scope=write_api%20read_prefs",
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
      await getUser();
      return token != null;
    } on Exception catch (_) {
      return false;
    }
  }

  Future<User?> getUser() async {
    if (token == null) {
      return null;
    }
    try {
      var response = await http.get(
          Uri.parse('https://api.openstreetmap.org/api/0.6/user/details.json'),
          headers: {'Authorization': 'Bearer $token'});
      var payload = json.decode(response.body)['user'];
      var user = User(id: payload['id'], name: payload['display_name']);
      if (payload.containsKey('img')) {
        user = user.copyWith(avatar: payload['img']['href']);
      }
      if (!Platform.environment.containsKey('FLUTTER_TEST')) {
        mixpanel.identify(user.id.toString());
        mixpanel.getPeople().set('\$user_id', user.id);
        mixpanel.getPeople().set('\$name', user.name);
        mixpanel.getPeople().set('\$avatar', user.avatar);
        await mixpanel.flush();
      }
      return user;
    } catch (err) {
      return User(id: 0, name: 'Unknown');
    }
  }

  Future<void> logout() async {
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      await mixpanel.reset();
    }
    token = null;
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

  Future<Defibrillator> insertDefibrillator(Defibrillator defibrillator) async {
    try {
      var changesetId = await getChangesetId();
      if (!kDebugMode) {
        var response = await http.put(
            Uri.parse('https://api.openstreetmap.org/api/0.6/node/create'),
            headers: {
              'Content-Type': 'text/xml',
              'Authorization': 'Bearer $token'
            },
            body: defibrillator.toXml(changesetId, 1));
        var id = int.parse(response.body.toString());
        defibrillator.id = id;
      } else {
        defibrillator.id = 9999;
      }
      if (kDebugMode) {}
      updateDefibrillators();
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
    }
    return defibrillator;
  }

  Future<Defibrillator> updateDefibrillator(Defibrillator defibrillator) async {
    if (kDebugMode) {
      return defibrillator;
    }
    try {
      var changesetId = await getChangesetId();
      var fetchResponse = await http.get(
          Uri.parse('https://api.openstreetmap.org/api/0.6/node/${defibrillator.id}'),
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
      defibrillator.toXml(changesetId, int.parse(oldVersion), oldTags: oldTagsPairs);
      await http.put(
          Uri.parse('https://api.openstreetmap.org/api/0.6/node/${defibrillator.id}'),
          headers: {
            'Content-Type': 'text/xml',
            'Authorization': 'Bearer $token'
          },
          body: xml);
      updateDefibrillators();
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
    }
    return defibrillator;
  }

  Future<String?> getImage(Defibrillator defibrillator) async {
    try {
      var response = await http
          .get(Uri.parse('https://back.openaedmap.org/api/v1/node/${defibrillator.id}'));
      var result = jsonDecode(response.body);
      if (result['elements'][0]['@photo_url'].toString().length > 10) {
        return 'https://back.openaedmap.org${result['elements'][0]['@photo_url']}';
      }
      return null;
    } catch (err) {
      return null;
    }
  }

  // Future<Defibrillator>
}
