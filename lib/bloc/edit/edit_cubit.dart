import 'dart:io';

import 'package:aed_map/bloc/edit/edit_state.dart';
import 'package:aed_map/constants.dart';
import 'package:aed_map/main.dart';
import 'package:aed_map/models/aed.dart';
import 'package:aed_map/models/osm_api_exception.dart';
import 'package:aed_map/models/pending_change.dart';
import 'package:aed_map/repositories/geolocation_repository.dart';
import 'package:aed_map/repositories/pending_changes_repository.dart';
import 'package:aed_map/repositories/points_repository.dart';
import 'package:aed_map/repositories/user_created_defibrillator_repository.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:latlong2/latlong.dart';

class EditCubit extends Cubit<EditState> {
  EditCubit({
    required this.pointsRepository,
    required this.geolocationRepository,
    required this.pendingChangesRepository,
    required this.userCreatedDefibrillatorRepository,
  }) : super(EditReady(enabled: false, cursor: warsaw));

  final PointsRepository pointsRepository;
  final GeolocationRepository geolocationRepository;
  final PendingChangesRepository pendingChangesRepository;
  final UserCreatedDefibrillatorRepository userCreatedDefibrillatorRepository;

  Future<void> loadPendingChanges() async {
    final pendingChanges = await pendingChangesRepository.fetch();
    emit(state.copyWith(pendingChanges: pendingChanges));
  }

  Future<void> reconcilePendingChanges(List<Defibrillator> freshDataset) async {
    final reconciledChanges =
        await pendingChangesRepository.reconcile(freshDataset);
    emit(state.copyWith(pendingChanges: reconciledChanges));
  }

  Future<void> enter() async {
    analytics.event(name: enterEditModeEvent);
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      mixpanel.track(enterEditModeEvent);
    }
    emit(state.copyWith(
        enabled: true,
        cursor: await geolocationRepository.locate(),
        user: await pointsRepository.getUser()));
  }

  Future<void> logout() async {
    await pointsRepository.logout();
  }

  void exit() => emit(state.copyWith(enabled: false));

  void moveCursor(LatLng position) => emit(state.copyWith(cursor: position));

  void cancel() => emit(EditReady(
        enabled: false,
        cursor: state.cursor,
        pendingChanges: state.pendingChanges,
      ));

  Future<void> add() async {
    analytics.event(name: addEvent);
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      mixpanel.track(addEvent);
    }
    Defibrillator defibrillator = Defibrillator(
        location: LatLng(state.cursor.latitude, state.cursor.longitude), id: 0);
    emit(EditInProgress(
        enabled: false,
        cursor: state.cursor,
        defibrillator: defibrillator,
        access: defibrillator.access ?? 'yes',
        indoor: defibrillator.indoor ?? 'no',
        description: defibrillator.description ?? '',
        pendingChanges: state.pendingChanges));
  }

  Future<void> edit(Defibrillator defibrillator) async {
    analytics.event(name: editEvent);
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      mixpanel.track(editEvent);
    }
    if (!await pointsRepository.authenticate()) return;
    defibrillator = defibrillator.copyWith();
    emit(EditInProgress(
        enabled: false,
        cursor: state.cursor,
        defibrillator: defibrillator,
        access: defibrillator.access ?? 'yes',
        indoor: defibrillator.indoor ?? 'no',
        description: defibrillator.description ?? '',
        pendingChanges: state.pendingChanges));
  }

  void editDescription(String value) {
    var s = state;
    if (s is EditInProgress) {
      s.defibrillator.description = value;
      emit(s.copyWith(defibrillator: s.defibrillator, description: value));
    }
  }

  void editOperator(String value) {
    var s = state;
    if (s is EditInProgress) {
      s.defibrillator.operator = value;
      emit(s.copyWith(defibrillator: s.defibrillator));
    }
  }

  void editPhone(String value) {
    var s = state;
    if (s is EditInProgress) {
      s.defibrillator.phone = value;
      emit(s.copyWith(defibrillator: s.defibrillator));
    }
  }

  void editOpeningHours(String value) {
    var s = state;
    if (s is EditInProgress) {
      s.defibrillator.openingHours = value;
      emit(s.copyWith(defibrillator: s.defibrillator.copyWith()));
    }
  }

  void editIndoor(bool value) {
    var s = state;
    if (s is EditInProgress) {
      var contents = value ? 'yes' : 'no';
      s.defibrillator.indoor = contents;
      emit(s.copyWith(defibrillator: s.defibrillator, indoor: contents));
    }
  }

  void editAccess(String value) {
    var s = state;
    if (s is EditInProgress) {
      s.defibrillator.access = value;
      emit(s.copyWith(defibrillator: s.defibrillator, access: value));
    }
  }

  Future<Defibrillator?> save() async {
    if (!await pointsRepository.authenticate()) return null;
    var s = state;
    if (s is EditInProgress) {
      try {
        if (s.defibrillator.id == 0) {
          var saved =
              await pointsRepository.insertDefibrillator(s.defibrillator);
          await userCreatedDefibrillatorRepository.add(saved.id);
          await pendingChangesRepository.register(PendingChange(
            type: PendingChangeType.add,
            defibrillatorId: saved.id,
            snapshot: saved.copyWith(),
            createdAt: DateTime.now(),
          ));
          analytics.event(name: saveInsertEvent);
          if (!Platform.environment.containsKey('FLUTTER_TEST')) {
            mixpanel.track(saveInsertEvent,
                properties: saved.getEventProperties());
          }
          final updatedPendingChanges = await pendingChangesRepository.fetch();
          emit(EditReady(
              enabled: false,
              cursor: state.cursor,
              pendingChanges: updatedPendingChanges));
          maybeRequestReview();
          return saved;
        } else {
          var saved =
              await pointsRepository.updateDefibrillator(s.defibrillator);
          await pendingChangesRepository.register(PendingChange(
            type: PendingChangeType.edit,
            defibrillatorId: saved.id,
            snapshot: saved.copyWith(),
            createdAt: DateTime.now(),
          ));
          analytics.event(name: saveUpdateEvent);
          if (!Platform.environment.containsKey('FLUTTER_TEST')) {
            mixpanel.track(saveUpdateEvent,
                properties: saved.getEventProperties());
          }
          final updatedPendingChanges = await pendingChangesRepository.fetch();
          emit(EditReady(
              enabled: false,
              cursor: state.cursor,
              pendingChanges: updatedPendingChanges));
          maybeRequestReview();
          return saved;
        }
      } on OsmApiException catch (exception) {
        emit(s.copyWith(errorMessage: mapOsmError(exception)));
        return null;
      }
    }
    return null;
  }

  Future<void> delete(Defibrillator defibrillator) async {
    try {
      await pointsRepository.deleteDefibrillator(defibrillator.id);
      await userCreatedDefibrillatorRepository.remove(defibrillator.id);
      await pendingChangesRepository.register(PendingChange(
        type: PendingChangeType.delete,
        defibrillatorId: defibrillator.id,
        snapshot: defibrillator.copyWith(),
        createdAt: DateTime.now(),
      ));
      final updatedPendingChanges = await pendingChangesRepository.fetch();
      emit(EditReady(
          enabled: false,
          cursor: state.cursor,
          pendingChanges: updatedPendingChanges));
      if (!Platform.environment.containsKey('FLUTTER_TEST')) {
        mixpanel.track(deleteEvent,
            properties: defibrillator.getEventProperties());
      }
    } on OsmApiException catch (exception) {
      emit(state.copyWith(errorMessage: mapOsmError(exception)));
    }
  }

  String mapOsmError(OsmApiException exception) {
    switch (exception.statusCode) {
      case 401:
      case 403:
        return 'osmErrorUnauthorized';
      case 404:
      case 410:
        return 'osmErrorNotFound';
      case 409:
        return 'osmErrorConflict';
      default:
        return 'osmErrorGeneric:${exception.statusCode}:${exception.body}';
    }
  }

  void maybeRequestReview() {
    if (kDebugMode) return;
    Future.delayed(const Duration(seconds: 2)).then((_) async {
      final remoteConfig = FirebaseRemoteConfig.instance;
      if (remoteConfig.getBool('request_review')) {
        var isAvailable = await InAppReview.instance.isAvailable();
        if (isAvailable) {
          await InAppReview.instance.requestReview();
        }
        if (!Platform.environment.containsKey('FLUTTER_TEST')) {
          mixpanel.track(requestReviewEvent,
              properties: {'available': isAvailable});
        }
      }
    });
  }
}
