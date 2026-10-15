import 'dart:convert';
import 'dart:io';

import 'package:aed_map/models/aed.dart';
import 'package:aed_map/models/trip.dart';
import 'package:aed_map/repositories/geolocation_repository.dart';
import 'package:aed_map/repositories/points_repository.dart';
import 'package:aed_map/repositories/routing_repository.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:latlong2/latlong.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class FakeGeolocationRepository extends GeolocationRepository {
  FakeGeolocationRepository(this.location);

  final LatLng location;

  @override
  Future<({LatLng location, bool permissionDenied})> locate() async =>
      (location: location, permissionDenied: false);
}

class FakePointsRepository extends PointsRepository {
  FakePointsRepository(this.dataset);

  final File dataset;

  @override
  Future<File> get cacheFile async => dataset;

  @override
  Future<void> updateDefibrillators() async {}
}

class FakeRoutingRepository extends RoutingRepository {
  FakeRoutingRepository(this.trip);

  final Trip? trip;

  @override
  Future<Trip?> navigate(LatLng current, Defibrillator defibrillator) async =>
      trip;
}

class FakeGeolocatorPlatform extends GeolocatorPlatform
    with MockPlatformInterfaceMixin {
  FakeGeolocatorPlatform(this.location);

  final LatLng location;

  Position get position => Position(
        latitude: location.latitude,
        longitude: location.longitude,
        timestamp: DateTime(2026),
        accuracy: 5,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );

  @override
  Future<LocationPermission> checkPermission() async =>
      LocationPermission.whileInUse;

  @override
  Future<LocationPermission> requestPermission() async =>
      LocationPermission.whileInUse;

  @override
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Stream<ServiceStatus> getServiceStatusStream() =>
      Stream.value(ServiceStatus.enabled);

  @override
  Future<Position?> getLastKnownPosition(
          {bool forceLocationManager = false}) async =>
      position;

  @override
  Future<Position> getCurrentPosition(
          {LocationSettings? locationSettings}) async =>
      position;

  @override
  Stream<Position> getPositionStream({LocationSettings? locationSettings}) =>
      Stream.value(position);
}

class ScreenshotFonts {
  static const systemFontPath = '/System/Library/Fonts/SFNS.ttf';
  static const systemFamilies = [
    'CupertinoSystemText',
    'CupertinoSystemDisplay',
    '.SF Pro Text',
    '.SF Pro Display',
    '.SF UI Text',
    '.SF UI Display',
    '.AppleSystemUIFont',
    'Roboto',
  ];

  static Future<void> load() async {
    final manifest = jsonDecode(
            await rootBundle.loadString('FontManifest.json')) as List<dynamic>;
    for (final entry in manifest) {
      final loader = FontLoader(entry['family'] as String);
      for (final font in entry['fonts'] as List<dynamic>) {
        loader.addFont(rootBundle.load(font['asset'] as String));
      }
      await loader.load();
    }
    final systemFont = File(systemFontPath).readAsBytesSync();
    for (final family in systemFamilies) {
      final loader = FontLoader(family)
        ..addFont(Future.value(ByteData.sublistView(systemFont)));
      await loader.load();
    }
  }
}

class FixtureTileProvider extends TileProvider {
  FixtureTileProvider(this.directory);

  final Directory directory;

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      FileImage(File(
          '${directory.path}/${coordinates.z}/${coordinates.x}/${coordinates.y}.png'));
}
