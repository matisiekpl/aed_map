import 'package:aed_map/models/aed.dart';
import 'package:aed_map/models/pending_change.dart';
import 'package:aed_map/models/user.dart';
import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

enum PhotoStatus {
  idle,
  uploading,
  uploadSuccess,
  uploadFailure,
  reporting,
  reportSuccess,
  reportFailure,
}

abstract class EditState extends Equatable {
  final bool enabled;
  final LatLng cursor;
  final User? user;
  final List<PendingChange> pendingChanges;
  final String? errorMessage;
  final PhotoStatus photoStatus;
  final String? photoErrorMessage;
  final Defibrillator? photoUpdatedDefibrillator;

  @override
  List<Object?> get props => [
        enabled,
        cursor,
        user,
        pendingChanges,
        errorMessage,
        photoStatus,
        photoErrorMessage,
        photoUpdatedDefibrillator,
      ];

  const EditState({
    required this.enabled,
    required this.cursor,
    required this.user,
    required this.pendingChanges,
    this.errorMessage,
    this.photoStatus = PhotoStatus.idle,
    this.photoErrorMessage,
    this.photoUpdatedDefibrillator,
  });

  EditState copyWith({
    bool? enabled,
    LatLng? cursor,
    User? user,
    List<PendingChange>? pendingChanges,
    String? errorMessage,
    PhotoStatus? photoStatus,
    String? photoErrorMessage,
    Defibrillator? photoUpdatedDefibrillator,
  });
}

class EditReady extends EditState {
  const EditReady({
    required super.enabled,
    required super.cursor,
    super.user,
    super.pendingChanges = const [],
    super.errorMessage,
    super.photoStatus,
    super.photoErrorMessage,
    super.photoUpdatedDefibrillator,
  });

  @override
  EditReady copyWith({
    bool? enabled,
    LatLng? cursor,
    User? user,
    List<PendingChange>? pendingChanges,
    String? errorMessage,
    PhotoStatus? photoStatus,
    String? photoErrorMessage,
    Defibrillator? photoUpdatedDefibrillator,
  }) {
    return EditReady(
      enabled: enabled ?? this.enabled,
      cursor: cursor ?? this.cursor,
      user: user ?? this.user,
      pendingChanges: pendingChanges ?? this.pendingChanges,
      errorMessage: errorMessage,
      photoStatus: photoStatus ?? this.photoStatus,
      photoErrorMessage: photoErrorMessage,
      photoUpdatedDefibrillator: photoUpdatedDefibrillator,
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
    super.photoStatus,
    super.photoErrorMessage,
    super.photoUpdatedDefibrillator,
    this.indoor = 'no',
    this.access = 'public',
    this.description = '',
    this.originalImage = '',
  });

  final Defibrillator defibrillator;
  final String indoor;
  final String access;
  final String description;
  final String? originalImage;

  @override
  List<Object?> get props => [
        enabled,
        cursor,
        indoor,
        access,
        defibrillator.indoor,
        defibrillator,
        description,
        originalImage,
        pendingChanges,
        errorMessage,
        photoStatus,
        photoErrorMessage,
        photoUpdatedDefibrillator,
      ];

  @override
  EditInProgress copyWith({
    Defibrillator? defibrillator,
    bool? enabled,
    LatLng? cursor,
    String? indoor,
    String? access,
    String? description,
    String? originalImage,
    User? user,
    List<PendingChange>? pendingChanges,
    String? errorMessage,
    PhotoStatus? photoStatus,
    String? photoErrorMessage,
    Defibrillator? photoUpdatedDefibrillator,
  }) {
    return EditInProgress(
      defibrillator: defibrillator ?? this.defibrillator,
      enabled: enabled ?? this.enabled,
      cursor: cursor ?? this.cursor,
      indoor: indoor ?? this.indoor,
      access: access ?? this.access,
      description: description ?? this.description,
      originalImage: originalImage ?? this.originalImage,
      user: user ?? this.user,
      pendingChanges: pendingChanges ?? this.pendingChanges,
      errorMessage: errorMessage,
      photoStatus: photoStatus ?? this.photoStatus,
      photoErrorMessage: photoErrorMessage,
      photoUpdatedDefibrillator: photoUpdatedDefibrillator,
    );
  }
}
