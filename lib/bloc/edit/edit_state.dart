import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

import '../../models/aed.dart';

abstract class EditState extends Equatable {
  final bool enabled;
  final LatLng cursor;

  @override
  List<Object?> get props => [enabled, cursor];

  const EditState({
    required this.enabled,
    required this.cursor,
  });

  EditState copyWith({
    bool? enabled,
    LatLng? cursor,
  });
}

class EditReady extends EditState {
  const EditReady({required super.enabled, required super.cursor});

  @override
  EditReady copyWith({
    bool? enabled,
    LatLng? cursor,
  }) {
    return EditReady(
      enabled: enabled ?? this.enabled,
      cursor: cursor ?? this.cursor,
    );
  }
}

class EditInProgress extends EditState {
  const EditInProgress(
      {required super.enabled,
      required super.cursor,
      required this.aed,
      this.indoor = false,
      this.access = 'public',
      this.description = ''});

  final AED aed;
  final bool indoor;
  final String access;

  final String description;

  @override
  List<Object?> get props =>
      [enabled, cursor, indoor, access, aed.indoor, aed, description];

  @override
  EditInProgress copyWith({
    AED? aed,
    bool? enabled,
    LatLng? cursor,
    bool? indoor,
    String? access,
    String? description,
  }) {
    return EditInProgress(
      aed: aed ?? this.aed,
      enabled: enabled ?? this.enabled,
      cursor: cursor ?? this.cursor,
      indoor: indoor ?? this.indoor,
      access: access ?? this.access,
      description: description ?? this.description,
    );
  }
}
