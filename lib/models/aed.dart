import 'dart:typed_data';

import 'package:aed_map/constants.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:xml/xml.dart';

import '../generated/i18n/app_localizations.dart';

class Defibrillator {
  LatLng location;
  String? description;
  Map<String, String> descriptionTranslations;
  int id;
  String? indoor;
  String? operator;
  String? phone;
  int? distance = 0;
  String? openingHours;
  String? access;
  String? image;
  Uint8List? photoBytes;

  Defibrillator(
      {required this.location,
      required this.id,
      this.description,
      this.descriptionTranslations = const {},
      this.indoor,
      this.operator,
      this.phone,
      this.openingHours,
      this.image = '',
      this.access = 'yes',
      List<int>? photoBytes})
      : photoBytes = photoBytes != null ? Uint8List.fromList(photoBytes) : null;

  static Map<String, String> parseLocationTranslations(
      Map<String, dynamic> tags) {
    final translations = <String, String>{};
    const prefix = 'defibrillator:location:';
    tags.forEach((key, value) {
      if (key.startsWith(prefix) && value != null) {
        translations[key.substring(prefix.length)] = value.toString();
      }
    });
    return translations;
  }

  String? localizedDescription(String languageCode) {
    final translation = descriptionTranslations[languageCode];
    if (translation != null && translation.isNotEmpty) return translation;
    if (description != null && description!.isNotEmpty) return description;
    for (final value in descriptionTranslations.values) {
      if (value.isNotEmpty) return value;
    }
    return null;
  }

  String? get photoId {
    final url = image;
    if (url == null || url.isEmpty) return null;
    try {
      final segments = Uri.parse(url).pathSegments;
      if (segments.isEmpty) return null;
      final filename = segments.last;
      if (filename.isEmpty) return null;
      final dot = filename.lastIndexOf('.');
      if (dot <= 0) return filename;
      return filename.substring(0, dot);
    } catch (_) {
      return null;
    }
  }

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

  String getIndoorText(AppLocalizations appLocalizations) {
    if (indoor == 'yes') return appLocalizations.yes;
    if (indoor == 'no') return appLocalizations.no;
    return indoor ?? 'unknown';
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
      {List<List<String>> oldTags = const [],
      Set<String> removedTags = const {}}) {
    final trimmedDescription = description?.trim() ?? '';
    final trimmedOpeningHours = openingHours?.trim() ?? '';
    final trimmedOperator = operator?.trim() ?? '';
    final trimmedPhone = phone?.trim() ?? '';
    final trimmedImage = image?.trim() ?? '';
    final trimmedTranslations = {
      for (final entry in descriptionTranslations.entries)
        entry.key: entry.value.trim()
    }..removeWhere((languageCode, value) => value.isEmpty);
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
        if (trimmedDescription.isNotEmpty) {
          builder.element('tag', attributes: {
            'k': 'defibrillator:location',
            'v': trimmedDescription
          });
        }
        trimmedTranslations.forEach((languageCode, value) {
          builder.element('tag', attributes: {
            'k': 'defibrillator:location:$languageCode',
            'v': value
          });
        });
        builder.element('tag',
            attributes: {'k': 'emergency', 'v': 'defibrillator'});
        if (trimmedImage.isNotEmpty) {
          builder.element('tag', attributes: {'k': 'image', 'v': trimmedImage});
        }
        builder
            .element('tag', attributes: {'k': 'indoor', 'v': indoor ?? 'no'});
        if (trimmedOpeningHours.isNotEmpty) {
          builder.element('tag',
              attributes: {'k': 'opening_hours', 'v': trimmedOpeningHours});
        }
        if (trimmedOperator.isNotEmpty) {
          builder.element('tag',
              attributes: {'k': 'operator', 'v': trimmedOperator});
        }
        if (trimmedPhone.isNotEmpty) {
          builder.element('tag', attributes: {'k': 'phone', 'v': trimmedPhone});
        }

        final writtenTags = {
          'phone',
          'operator',
          'opening_hours',
          'indoor',
          'emergency',
          'access',
          'defibrillator:location',
          ...trimmedTranslations.keys
              .map((languageCode) => 'defibrillator:location:$languageCode'),
          if (trimmedImage.isNotEmpty) 'image',
        };

        oldTags
            .where((attr) =>
                !writtenTags.contains(attr[0]) &&
                !removedTags.contains(attr[0]))
            .forEach((attr) {
          builder.element('tag', attributes: {'k': attr[0], 'v': attr[1]});
        });
      });
    });
    final document = builder.buildDocument();
    return document.toXmlString();
  }

  Defibrillator copyWith({
    LatLng? location,
    String? description,
    Map<String, String>? descriptionTranslations,
    int? id,
    String? indoor,
    String? operator,
    String? phone,
    int? distance,
    String? openingHours,
    String? access,
    String? image,
    Uint8List? photoBytes,
    Map? colors,
    Map? filenames,
  }) {
    return Defibrillator(
      location: location ?? this.location,
      description: description ?? this.description,
      descriptionTranslations:
          descriptionTranslations ?? this.descriptionTranslations,
      id: id ?? this.id,
      indoor: indoor ?? this.indoor,
      operator: operator ?? this.operator,
      phone: phone ?? this.phone,
      openingHours: openingHours ?? this.openingHours,
      access: access ?? this.access,
      image: image ?? this.image,
      photoBytes: photoBytes ?? this.photoBytes,
    );
  }

  static bool tagsEqual(Defibrillator a, Defibrillator b) {
    return a.description == b.description &&
        a.descriptionTranslations.length == b.descriptionTranslations.length &&
        a.descriptionTranslations.entries.every(
            (entry) => b.descriptionTranslations[entry.key] == entry.value) &&
        a.indoor == b.indoor &&
        a.operator == b.operator &&
        a.phone == b.phone &&
        a.openingHours == b.openingHours &&
        a.access == b.access &&
        a.image == b.image;
  }

  Map<String, dynamic> getEventProperties() {
    return {
      'aed_id': id,
      'aed_node_url': osmNodePrefix + id.toString(),
      'aed_latitude': location.latitude,
      'aed_longitude': location.longitude,
      'aed_indoor': indoor,
      'aed_operator': operator,
      'aed_phone': phone,
      'aed_distance': distance,
      'aed_opening_hours': openingHours,
      'aed_access': access,
      'aed_image': image
    };
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
