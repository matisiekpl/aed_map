import 'package:aed_map/models/aed.dart';
import 'package:aed_map/models/user.dart';
import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

abstract class EditState extends Equatable {
  final bool enabled;
  final LatLng cursor;
  final User? user;

  @override
  List<Object?> get props => [enabled, cursor, user];

  const EditState({
    required this.enabled,
    required this.cursor,
    required this.user,
  });

  EditState copyWith({
    bool? enabled,
    LatLng? cursor,
    User? user,
  });
}

class EditReady extends EditState {
  const EditReady(
      {required super.enabled, required super.cursor, super.user});

  @override
  EditReady copyWith({
    bool? enabled,
    LatLng? cursor,
    User? user,
  }) {
    return EditReady(
      enabled: enabled ?? this.enabled,
      cursor: cursor ?? this.cursor,
      user: user ?? this.user,
    );
  }
}

class EditInProgress extends EditState {
  const EditInProgress(
      {required super.enabled,
      required super.cursor,
      required this.defibrillator,
      super.user,
      this.indoor = 'no',
      this.access = 'public',
      this.description = ''});

  final Defibrillator defibrillator;
  final String indoor;
  final String access;

  final String description;

  @override
  List<Object?> get props =>
      [enabled, cursor, indoor, access, defibrillator.indoor, defibrillator, description];

  @override
  EditInProgress copyWith({
    Defibrillator? defibrillator,
    bool? enabled,
    LatLng? cursor,
    String? indoor,
    String? access,
    String? description,
    User? user,
  }) {
    return EditInProgress(
      defibrillator: defibrillator ?? this.defibrillator,
      enabled: enabled ?? this.enabled,
      cursor: cursor ?? this.cursor,
      indoor: indoor ?? this.indoor,
      access: access ?? this.access,
      description: description ?? this.description,
      user: user ?? this.user,
    );
  }
}
