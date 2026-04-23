import 'package:aed_map/models/aed.dart';
import 'package:aed_map/models/pending_change.dart';
import 'package:aed_map/models/user.dart';
import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

abstract class EditState extends Equatable {
  final bool enabled;
  final LatLng cursor;
  final User? user;
  final List<PendingChange> pendingChanges;
  final String? errorMessage;

  @override
  List<Object?> get props => [enabled, cursor, user, pendingChanges, errorMessage];

  const EditState({
    required this.enabled,
    required this.cursor,
    required this.user,
    required this.pendingChanges,
    this.errorMessage,
  });

  EditState copyWith({
    bool? enabled,
    LatLng? cursor,
    User? user,
    List<PendingChange>? pendingChanges,
    String? errorMessage,
  });
}

class EditReady extends EditState {
  const EditReady({
    required super.enabled,
    required super.cursor,
    super.user,
    super.pendingChanges = const [],
    super.errorMessage,
  });

  @override
  EditReady copyWith({
    bool? enabled,
    LatLng? cursor,
    User? user,
    List<PendingChange>? pendingChanges,
    String? errorMessage,
  }) {
    return EditReady(
      enabled: enabled ?? this.enabled,
      cursor: cursor ?? this.cursor,
      user: user ?? this.user,
      pendingChanges: pendingChanges ?? this.pendingChanges,
      errorMessage: errorMessage,
    );
  }
}

class EditInProgress extends EditState {
  const EditInProgress({
    required super.enabled,
    required super.cursor,
    required this.defibrillator,
    super.user,
    super.pendingChanges = const [],
    super.errorMessage,
    this.indoor = 'no',
    this.access = 'public',
    this.description = '',
  });

  final Defibrillator defibrillator;
  final String indoor;
  final String access;
  final String description;

  @override
  List<Object?> get props => [
        enabled,
        cursor,
        indoor,
        access,
        defibrillator.indoor,
        defibrillator,
        description,
        pendingChanges,
        errorMessage,
      ];

  @override
  EditInProgress copyWith({
    Defibrillator? defibrillator,
    bool? enabled,
    LatLng? cursor,
    String? indoor,
    String? access,
    String? description,
    User? user,
    List<PendingChange>? pendingChanges,
    String? errorMessage,
  }) {
    return EditInProgress(
      defibrillator: defibrillator ?? this.defibrillator,
      enabled: enabled ?? this.enabled,
      cursor: cursor ?? this.cursor,
      indoor: indoor ?? this.indoor,
      access: access ?? this.access,
      description: description ?? this.description,
      user: user ?? this.user,
      pendingChanges: pendingChanges ?? this.pendingChanges,
      errorMessage: errorMessage,
    );
  }
}