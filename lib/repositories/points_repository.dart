import 'dart:convert';
import 'dart:io';

import 'package:aed_map/constants.dart';
import 'package:aed_map/main.dart';
import 'package:aed_map/models/aed.dart';
import 'package:aed_map/models/osm_api_exception.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:latlong2/latlong.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:xml/xml.dart';

import '../models/user.dart';

class PointsRepository {
  static const String defibrillatorListKey = 'aed_list_json_2';
  static const String defibrillatorListUpdateTimestamp = 'aed_update';

  static const devMode = kDebugMode;

  Future<File> get cacheFile async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return File('ignore_$defibrillatorListKey.geojson');
    }
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$defibrillatorListKey.geojson');
  }

  Future<void> updateDefibrillators() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      var response = await http.get(
          Uri.parse('https://openaedmap.org/api/v1/countries/WORLD.geojson'));
      if (utf8.decode(response.bodyBytes).isNotEmpty) {
        await (await cacheFile).writeAsString(utf8.decode(response.bodyBytes));
        await prefs.setString(
            defibrillatorListUpdateTimestamp, DateTime.now().toIso8601String());
      }
    } catch (err) {
      print('Failed to load defibrillators from internet!');
    }
  }

  Future<void> loadLocalDefibrillators() async {
    String data =
        await rootBundle.loadString("assets/world.geojson", cache: false);
    data = data.replaceAll("@osm_id", "osm_id");
    await (await cacheFile).writeAsString(data);
  }

  Future<DateTime> getLastUpdateTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var value = prefs.getString(defibrillatorListUpdateTimestamp);
    if (value == null) return DateTime.now();
    return DateTime.parse(value);
  }

  Future<(List<Defibrillator>, int)> loadDefibrillators(
      LatLng currentLocation) async {
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      await mixpanel.registerSuperProperties({
        "\$latitude": currentLocation.latitude,
        "\$longitude": currentLocation.longitude
      });
      mixpanel.getPeople().set('\$latitude', currentLocation.latitude);
      mixpanel.getPeople().set('\$longitude', currentLocation.longitude);
    }
    List<Defibrillator> defibrillators = [];
    if (!(await (await cacheFile).exists())) {
      await loadLocalDefibrillators();
    }
    updateDefibrillators();
    print('Using file ${(await cacheFile).path}');
    var contents = await (await cacheFile).readAsString();
    var idLabel = 'osm_id';
    if (contents.contains('@osm_id')) {
      idLabel = '@osm_id';
    }

    var jsonList = jsonDecode(contents)['features'];
    jsonList.forEach((row) {
      var id = row['properties'][idLabel];
      var lang = Platform.localeName.split('_')[0];
      var locationDescription = row['properties']['defibrillator:location:$lang'] ?? row['properties']['defibrillator:location'];
      var description = row['properties']['description:$lang'] ?? row['properties']['description'] ?? row['properties']['note'];
      defibrillators.add(Defibrillator(
          location: LatLng(row['geometry']['coordinates'][1],
              row['geometry']['coordinates'][0]),
          id: id,
          locationDescription: locationDescription,
          description: description,
          level: row['properties']['level'],
          indoor: row['properties']['indoor'],
          operator: row['properties']['operator'],
          phone: row['properties']['phone'],
          openingHours: row['properties']['opening_hours'],
          access: row['properties']['access'],
          image: row['properties']['image']));
    });
    print('Loaded ${defibrillators.length} defibrillators!');
    defibrillators = defibrillators.map((defibrillator) {
      const Distance distance = Distance(calculator: Haversine());
      defibrillator.distance =
          distance(currentLocation, defibrillator.location).ceil();
      return defibrillator;
    }).toList();
    defibrillators.sort((a, b) => a.distance!.compareTo(b.distance!));
    final defibrillatorsCount = defibrillators.length;
    return (
      defibrillators.take(visiblePointsCount).toList(),
      defibrillatorsCount
    );
  }

  String? token;

  Future<bool> authenticate() async {
    if (token != null || devMode) return true;
    mixpanel.track(loginEvent);
    var clientId = 'fMwHrWOkZCboGJR1umv202RX2aBLBFgMt8SLqg1iktA';
    var clientSecret = 'zhfFUhRW5KnjsQnGbZR0gnZObfvuxn-F-_HOxLNd72A';
    try {
      var preferredAuthProvider = Platform.isIOS ? 'apple' : 'google';
      final result = await FlutterWebAuth2.authenticate(
          url:
              "https://www.openstreetmap.org/oauth2/authorize?preferred_auth_provider=$preferredAuthProvider&client_id=$clientId&redirect_uri=aedmap://success&response_type=code&scope=write_api%20read_prefs",
          callbackUrlScheme: "aedmap");
      final code = Uri.parse(result).queryParameters['code'];
      print('Got OAuth2 code: $code');
      var response = await http.post(
          Uri.parse(
              'https://www.openstreetmap.org/oauth2/token?grant_type=authorization_code&redirect_uri=aedmap://success&client_id=$clientId&client_secret=$clientSecret&code=$code'),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'});
      token = json.decode(response.body)['access_token'];
      print('Got OAuth2 token: $token');
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
        Sentry.configureScope((scope) => scope.setUser(SentryUser(
              id: user.id.toString(),
              username: user.name,
            )));
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
    if (response.statusCode != 200) {
      throw OsmApiException(response.statusCode, response.body);
    }
    return int.parse(response.body.toString());
  }

  Future<Defibrillator> insertDefibrillator(Defibrillator defibrillator, String lang) async {
    if (!devMode) {
      var changesetId = await getChangesetId();
      var response = await http.put(
          Uri.parse('https://api.openstreetmap.org/api/0.6/node/create'),
          headers: {
            'Content-Type': 'text/xml',
            'Authorization': 'Bearer $token'
          },
          body: defibrillator.toXml(changesetId, 1, lang));
      if (response.statusCode != 200) {
        throw OsmApiException(response.statusCode, response.body);
      }
      var id = int.parse(response.body.toString());
      defibrillator.id = id;
    } else {
      defibrillator.id = 9999;
    }
    updateDefibrillators();
    return defibrillator;
  }

  Future<Defibrillator> updateDefibrillator(Defibrillator defibrillator, String lang) async {
    if (devMode) {
      return defibrillator;
    }
    var changesetId = await getChangesetId();
    var fetchResponse = await http.get(
        Uri.parse(
            'https://api.openstreetmap.org/api/0.6/node/${defibrillator.id}'),
        headers: {
          'Content-Type': 'text/xml',
          'Authorization': 'Bearer $token'
        });
    if (fetchResponse.statusCode != 200) {
      throw OsmApiException(fetchResponse.statusCode, fetchResponse.body);
    }
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
    var xml = defibrillator.toXml(changesetId, int.parse(oldVersion), lang,
        oldTags: oldTagsPairs);
    var putResponse = await http.put(
        Uri.parse(
            'https://api.openstreetmap.org/api/0.6/node/${defibrillator.id}'),
        headers: {'Content-Type': 'text/xml', 'Authorization': 'Bearer $token'},
        body: xml);
    if (putResponse.statusCode != 200) {
      throw OsmApiException(putResponse.statusCode, putResponse.body);
    }
    updateDefibrillators();
    return defibrillator;
  }

  Future<void> uploadPhoto({required int nodeId, required File file}) async {
    if (token == null) {
      throw Exception('Not authenticated');
    }
    var uri = Uri.parse('https://back.openaedmap.org/api/v1/photos/upload');
    var request = http.MultipartRequest('POST', uri);
    request.fields['node_id'] = nodeId.toString();
    request.fields['file_license'] = 'CC0';
    request.fields['oauth2_credentials'] = json.encode({
      'access_token': token,
      'token_type': 'Bearer',
      'scope': 'read_prefs',
    });
    final bytes = await file.readAsBytes();
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: 'photo.jpg',
      contentType: MediaType('application', 'octet-stream'),
    ));
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    print('Photo upload response [${response.statusCode}]: ${response.body}');
    if (response.statusCode != 200) {
      throw OsmApiException(response.statusCode, response.body);
    }
  }

  Future<void> reportPhoto(String photoId) async {
    var response = await http.post(
        Uri.parse('https://back.openaedmap.org/api/v1/photos/report'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
        },
        body: 'id=${Uri.encodeComponent(photoId)}');
    if (response.statusCode != 200) {
      throw OsmApiException(response.statusCode, response.body);
    }
  }

  Future<String?> getBackendImageUrl(int nodeId) async {
    try {
      var response = await http
          .get(Uri.parse('https://back.openaedmap.org/api/v1/node/$nodeId'));
      var payload = json.decode(response.body);
      if ((payload['elements'] as List<dynamic>).isNotEmpty) {
        var element = payload['elements'][0] as Map<String, dynamic>;
        var tags = element['tags'] as Map<String, dynamic>?;
        return tags?['image'] as String?;
      }
    } catch (_) {}
    return null;
  }

  Future<Defibrillator?> getNode(int id, String lang) async {
    try {
      var response = await http.get(
          Uri.parse('https://api.openstreetmap.org/api/0.6/node/$id.json'));
      var payload = json.decode(response.body);
      if ((payload['elements'] as List<dynamic>).isNotEmpty) {
        var element = payload['elements'][0] as Map<String, dynamic>;
        var tags = element['tags'] as Map<String, dynamic>;
        return Defibrillator(
          location: LatLng(element['lat'], element['lon']),
          id: id,
          access: tags['access'],
          locationDescription: tags['defibrillator:location:$lang'] ??
              tags['defibrillator:location'],
          description: tags['description:$lang'] ??
              tags['description'] ??
              tags['note'],
          indoor: tags['indoor'],
          level: tags['level'],
          openingHours: tags['opening_hours'],
          operator: tags['operator'],
          phone: tags['phone'],
          image: tags['image'],
        );
      }
    } catch (_) {}
    return null;
  }

  Future<bool> deleteDefibrillator(int nodeId) async {
    if (devMode) {
      return true;
    }
    var changesetId = await getChangesetId();
    var fetchResponse = await http.get(
        Uri.parse('https://api.openstreetmap.org/api/0.6/node/$nodeId'),
        headers: {
          'Content-Type': 'text/xml',
          'Authorization': 'Bearer $token'
        });
    if (fetchResponse.statusCode != 200) {
      throw OsmApiException(fetchResponse.statusCode, fetchResponse.body);
    }
    final document = XmlDocument.parse(fetchResponse.body);
    final oldVersion = document
        .findAllElements('node')
        .first
        .attributes
        .where((attr) => attr.name.toString() == 'version')
        .first
        .value;

    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0"');
    builder.element('osm', nest: () {
      builder.element('node', attributes: {
        'id': nodeId.toString(),
        'version': oldVersion,
        'changeset': changesetId.toString(),
        'lat': document
            .findAllElements('node')
            .first
            .attributes
            .where((attr) => attr.name.toString() == 'lat')
            .first
            .value,
        'lon': document
            .findAllElements('node')
            .first
            .attributes
            .where((attr) => attr.name.toString() == 'lon')
            .first
            .value,
      });
    });
    final deleteDocument = builder.buildDocument();

    var response = await http.delete(
        Uri.parse('https://api.openstreetmap.org/api/0.6/node/$nodeId'),
        headers: {'Content-Type': 'text/xml', 'Authorization': 'Bearer $token'},
        body: deleteDocument.toXmlString());

    if (response.statusCode != 200) {
      Sentry.captureMessage(
          'Error deleting node: ${response.statusCode}, ${response.body}');
      throw OsmApiException(response.statusCode, response.body);
    }

    await updateDefibrillators();
    return true;
  }
}
