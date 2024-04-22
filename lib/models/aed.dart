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

  AED(
      {required this.location,
      required this.id,
      this.description,
      this.indoor = false,
      this.operator,
      this.phone,
      this.openingHours,
      this.image = '',
      this.access = 'yes'});

  String? getAccessComment(AppLocalizations appLocalizations) {
    return translateAccessComment(access, appLocalizations);
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
    if (!colors.containsKey(access)) return colors[''];
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
    if (!filenames.containsKey(access)) return filenames[''];
    return filenames[access];
  }

  dynamic toXml(int changesetId, int version,
      {List<List<String>> oldTags = const []}) {
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

        if (access != null && access.toString().isNotEmpty) {
          builder.element('tag',
              attributes: {'k': 'access', 'v': access.toString()});
        }
        if (description != null && description.toString().isNotEmpty) {
          builder.element('tag', attributes: {
            'k': 'defibrillator:location',
            'v': description.toString()
          });
        }
        builder.element('tag',
            attributes: {'k': 'emergency', 'v': 'defibrillator'});
        if (image != null && image.toString().isNotEmpty) {
          builder.element('tag', attributes: {'k': 'image', 'v': image ?? ''});
        }
        builder.element('tag',
            attributes: {'k': 'indoor', 'v': indoor ? 'yes' : 'no'});
        if (openingHours != null && openingHours.toString().isNotEmpty) {
          builder.element('tag',
              attributes: {'k': 'opening_hours', 'v': openingHours ?? ''});
        }
        if (operator != null && operator.toString().isNotEmpty) {
          builder.element('tag',
              attributes: {'k': 'operator', 'v': operator ?? ''});
        }
        if (phone != null && phone.toString().isNotEmpty) {
          builder.element('tag', attributes: {'k': 'phone', 'v': phone ?? ''});
        }

        oldTags
            .where((attr) => [
                  'phone',
                  'operator',
                  'opening_hours',
                  'indoor',
                  'emergency',
                  'access',
                  'defibrillator:location'
                ].contains(attr[0]))
            .forEach((attr) {
          builder.element('tag', attributes: {'k': attr[0], 'v': attr[1]});
        });
      });
    });
    final document = builder.buildDocument();
    return document.toXmlString();
  }

  AED copyWith({
    LatLng? location,
    String? description,
    int? id,
    bool? indoor,
    String? operator,
    String? phone,
    int? distance,
    String? openingHours,
    String? access,
    String? image,
    Map? colors,
    Map? filenames,
  }) {
    return AED(
      location: location ?? this.location,
      description: description ?? this.description,
      id: id ?? this.id,
      indoor: indoor ?? this.indoor,
      operator: operator ?? this.operator,
      phone: phone ?? this.phone,
      openingHours: openingHours ?? this.openingHours,
      access: access ?? this.access,
      image: image ?? this.image,
    );
  }
}

String translateAccessComment(
    String? access, AppLocalizations appLocalizations) {
  if (access == null) return '';
  Map comments = {
    'yes': appLocalizations.accessYes,
    'customers': appLocalizations.accessCustomers,
    'private': appLocalizations.accessPrivate,
    'permissive': appLocalizations.accessPermissive,
    'no': appLocalizations.accessNo,
    'unknown': appLocalizations.accessUnknown,
  };
  return comments[access] ?? '';
}
