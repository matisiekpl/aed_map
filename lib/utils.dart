import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:settings_ui/settings_ui.dart';

import 'models/aed.dart';
export 'package:google_polyline_algorithm/google_polyline_algorithm.dart'
    show decodePolyline;

String? formatOpeningHours(String? input) {
  if (input == null) return null;
  input = input
      .replaceAll("Mo", "Pon")
      .replaceAll("Tu", "Wt")
      .replaceAll("We", "Śr")
      .replaceAll("Th", "Czw")
      .replaceAll("Fr", "Pt")
      .replaceAll("Sa", "Sob")
      .replaceAll("Su", "Niedz")
      .split(";")
      .map((k) => k.trim())
      .join("\n");
  return input;
}

extension PolylineExt on List<List<num>> {
  List<LatLng> unpackPolyline() =>
      map((p) => LatLng(p[0].toDouble(), p[1].toDouble())).toList();
}

extension StringExt on dynamic {
  String? purge() {
    if (this == null) return null;
    if (this.isEmpty) return null;
    return this;
  }
}

ColorFilter colorFilter = const ColorFilter.matrix(<double>[
  -1,
  0,
  0,
  0,
  255,
  0,
  -1,
  0,
  0,
  255,
  0,
  0,
  -1,
  0,
  255,
  0,
  0,
  0,
  1,
  0,
]);

ColorFilter invert = const ColorFilter.matrix(<double>[
  -1,
  0,
  0,
  0,
  255,
  0,
  -1,
  0,
  0,
  255,
  0,
  0,
  -1,
  0,
  255,
  0,
  0,
  0,
  1,
  0,
]);

String generateRandomString(int len) {
  var r = Random();
  return String.fromCharCodes(
      List.generate(len, (index) => r.nextInt(33) + 89));
}

const settingsListDarkTheme = SettingsThemeData(
    settingsListBackground: Colors.black,
    settingsSectionBackground: Color(0xFF1B1C1E),
    trailingTextColor: Colors.white,
    tileDescriptionTextColor: Color(0xFFA5A4A7),
    settingsTileTextColor: Colors.white,
    titleTextColor: Colors.white,
    dividerColor: Color(0xFF363437),
    tileHighlightColor: Color(0xFF2C2C2F));

List<AED> getDefibrillatorsWithin5KM(List<AED> aeds, LatLng location) =>
    aeds.where((aed) {
      var distance = Geolocator.distanceBetween(location.latitude,
          location.longitude, aed.location.latitude, aed.location.longitude);
      return distance < 5000;
    }).toList();

List<AED> getDefibrillatorsWithImages(List<AED> aeds) =>
    aeds.where((aed) => aed.image?.isNotEmpty ?? false).toList();
