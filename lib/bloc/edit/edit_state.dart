import 'package:aed_map/models/aed.dart';
import 'package:aed_map/models/user.dart';
import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

abstract class EditState extends Equatable {
  final bool enabled;
  final LatLng cursor;
  final User? user;
  final bool isImageUploading;

  @override
  List<Object?> get props => [enabled, cursor, user, isImageUploading];

  const EditState({
    required this.enabled,
    required this.cursor,
    required this.user,
    this.isImageUploading = false,
  });

  EditState copyWith({
    bool? enabled,
    LatLng? cursor,
    User? user,
    bool? isImageUploading,
  });
}

class EditReady extends EditState {
  const EditReady(
      {required super.enabled, required super.cursor, super.user, super.isImageUploading});

  @override
  EditReady copyWith({
    bool? enabled,
    LatLng? cursor,
    User? user,
    bool? isImageUploading,
  }) {
    return EditReady(
      enabled: enabled ?? this.enabled,
      cursor: cursor ?? this.cursor,
      user: user ?? this.user,
      isImageUploading: isImageUploading ?? this.isImageUploading,
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
      this.description = '',
      super.isImageUploading});

  final Defibrillator defibrillator;
  final String indoor;
  final String access;
  final String description;

  @override
  List<Object?> get props =>
      [enabled, cursor, indoor, access, defibrillator.indoor, defibrillator, description, isImageUploading];

  @override
  EditInProgress copyWith({
    Defibrillator? defibrillator,
    bool? enabled,
    LatLng? cursor,
    String? indoor,
    String? access,
    String? description,
    User? user,
    bool? isImageUploading,
  }) {
    return EditInProgress(
      defibrillator: defibrillator ?? this.defibrillator,
      enabled: enabled ?? this.enabled,
      cursor: cursor ?? this.cursor,
      indoor: indoor ?? this.indoor,
      access: access ?? this.access,
      description: description ?? this.description,
      user: user ?? this.user,
      isImageUploading: isImageUploading ?? this.isImageUploading,
    );
  }
}
