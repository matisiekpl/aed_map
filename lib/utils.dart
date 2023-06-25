import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:latlong2/latlong.dart';
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
  return String.fromCharCodes(List.generate(len, (index) => r.nextInt(33) + 89));
}