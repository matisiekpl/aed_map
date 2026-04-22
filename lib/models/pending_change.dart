import 'dart:convert';

import 'package:aed_map/models/aed.dart';
import 'package:latlong2/latlong.dart';

enum PendingChangeType { add, edit, delete }

class PendingChange {
  final PendingChangeType type;
  final int defibrillatorId;
  final Defibrillator snapshot;
  final DateTime createdAt;

  PendingChange({
    required this.type,
    required this.defibrillatorId,
    required this.snapshot,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'defibrillatorId': defibrillatorId,
      'createdAt': createdAt.toIso8601String(),
      'snapshot': {
        'id': snapshot.id,
        'lat': snapshot.location.latitude,
        'lon': snapshot.location.longitude,
        'description': snapshot.description,
        'indoor': snapshot.indoor,
        'operator': snapshot.operator,
        'phone': snapshot.phone,
        'openingHours': snapshot.openingHours,
        'access': snapshot.access,
      },
    };
  }

  static PendingChange fromJson(Map<String, dynamic> json) {
    final snapshotJson = json['snapshot'] as Map<String, dynamic>;
    return PendingChange(
      type: PendingChangeType.values.firstWhere((e) => e.name == json['type']),
      defibrillatorId: json['defibrillatorId'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      snapshot: Defibrillator(
        id: snapshotJson['id'] as int,
        location: LatLng(snapshotJson['lat'] as double, snapshotJson['lon'] as double),
        description: snapshotJson['description'] as String?,
        indoor: snapshotJson['indoor'] as String?,
        operator: snapshotJson['operator'] as String?,
        phone: snapshotJson['phone'] as String?,
        openingHours: snapshotJson['openingHours'] as String?,
        access: snapshotJson['access'] as String?,
      ),
    );
  }

  static List<PendingChange> decodeList(String jsonString) {
    final list = jsonDecode(jsonString) as List<dynamic>;
    return list.map((item) => PendingChange.fromJson(item as Map<String, dynamic>)).toList();
  }

  static String encodeList(List<PendingChange> changes) {
    return jsonEncode(changes.map((change) => change.toJson()).toList());
  }
}