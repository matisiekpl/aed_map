import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  String? getAccessComment(BuildContext context) {
    if (access == null) return null;
    Map comments = {
      'yes': AppLocalizations.of(context)!.accessYes,
      'customers': AppLocalizations.of(context)!.accessCustomers,
      'private': AppLocalizations.of(context)!.accessPrivate,
      'permissive': AppLocalizations.of(context)!.accessPermissive,
      'no': AppLocalizations.of(context)!.accessNo,
      'unknown': AppLocalizations.of(context)!.accessUnknown,
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
