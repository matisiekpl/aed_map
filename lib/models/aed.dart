import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class AED {
  LatLng location;
  String? description;
  int id;
  bool indoor;
  String? operator;
  String? phone;
  int? distance;
  String? openingHours;
  String? access;

  AED(this.location, this.id, this.description, this.indoor, this.operator,
      this.phone, this.openingHours, this.access);

  String? getAccessComment() {
    if (access == null) return null;
    Map comments = {
      'yes': 'publicznie dostępny',
      'customers': 'tylko w godzinach pracy',
      'private': 'za zgodą właściciela',
      'permissive': 'publicznie do odwołania',
      'no': 'niedostępny',
      'unknown': 'nieznany',
    };
    return comments[access];
  }

  Color getColor() {
    if (access == null) return Colors.grey;
    Map colors = {
      'yes': Colors.green,
      'customers': Colors.yellow,
      'private': Colors.blue,
      'permissive': Colors.blue,
      'no': Colors.red,
      'unknown': Colors.grey,
    };
    return colors[access];
  }

  String getIconFilename() {
    if (access == null) return 'green_aed.svg';
    Map filenames = {
      'yes': 'green_aed.svg',
      'customers': 'yellow_aed.svg',
      'private': 'blue_aed.svg',
      'permissive': 'blue_aed.svg',
      'no': 'red_aed.svg',
      'unknown': 'grey_aed.svg',
    };
    return filenames[access];
  }
}
