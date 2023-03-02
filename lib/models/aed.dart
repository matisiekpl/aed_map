import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:xml/xml.dart';

class AED {
  LatLng location;
  String? description;
  int id;
  bool indoor;
  String? operator;
  String? phone;
  int? distance = 0;
  String? openingHours;
  String? access;
  String? image;

  AED(this.location, this.id, this.description, this.indoor, this.operator,
      this.phone, this.openingHours, this.access);

  String? getAccessComment(BuildContext context) {
    return translateAccessComment(access, context);
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
      '': Colors.grey,
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
      '': 'grey_aed.svg',
    };
    return filenames[access];
  }

  dynamic toXml(int changesetId, int version) {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0"');
    builder.element('osm', attributes: {'version': '0.6'}, nest: () {
      builder.element('node', nest: () {
        builder.attribute('id', id);
        builder.attribute('visible', 'true');
        builder.attribute('version', version);
        builder.attribute('changeset', changesetId.toString());
        builder.attribute('timestamp', DateTime.now().toString());
        builder.attribute('user', '');
        builder.attribute('uid', '');
        builder.attribute('lat', location.latitude);
        builder.attribute('lon', location.longitude);

        if (access.toString().isNotEmpty) {
          builder.element('tag',
              attributes: {'k': 'access', 'v': access.toString()});
        }
        if (description.toString().isNotEmpty) {
          builder.element('tag', attributes: {
            'k': 'defibrillator:location:pl',
            'v': description.toString()
          });
        }
        builder.element('tag',
            attributes: {'k': 'emergency', 'v': 'defibrillator'});
        if (image.toString().isNotEmpty) {
          builder.element('tag', attributes: {'k': 'image', 'v': image ?? ''});
        }
        builder.element('tag',
            attributes: {'k': 'indoor', 'v': indoor ? 'yes' : 'no'});
        if (openingHours.toString().isNotEmpty) {
          builder.element('tag',
              attributes: {'k': 'opening_hours', 'v': openingHours ?? ''});
        }
        if (operator.toString().isNotEmpty) {
          builder.element('tag',
              attributes: {'k': 'operator', 'v': operator ?? ''});
        }
        if (phone.toString().isNotEmpty) {
          builder.element('tag', attributes: {'k': 'phone', 'v': phone ?? ''});
        }
      });
    });
    final document = builder.buildDocument();
    return document.toXmlString();
  }
}

String? translateAccessComment(String? access, BuildContext context) {
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
