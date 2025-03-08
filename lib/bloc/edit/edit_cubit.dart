import 'dart:io';

import 'package:aed_map/bloc/edit/edit_state.dart';
import 'package:aed_map/constants.dart';
import 'package:aed_map/main.dart';
import 'package:aed_map/models/aed.dart';
import 'package:aed_map/repositories/geolocation_repository.dart';
import 'package:aed_map/repositories/points_repository.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:latlong2/latlong.dart';

class EditCubit extends Cubit<EditState> {
  EditCubit(
      {required this.pointsRepository, required this.geolocationRepository})
      : super(EditReady(enabled: false, cursor: warsaw));

  final PointsRepository pointsRepository;
  final GeolocationRepository geolocationRepository;

  enter() async {
    if (!await pointsRepository.authenticate()) return;
    analytics.event(name: enterEditModeEvent);
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      mixpanel.track(enterEditModeEvent);
    }
    emit(state.copyWith(
        enabled: true,
        cursor: await geolocationRepository.locate(),
        user: await pointsRepository.getUser()));
  }

  logout() async {
    await pointsRepository.logout();
  }

  exit() => emit(state.copyWith(enabled: false));

  moveCursor(LatLng position) => emit(state.copyWith(cursor: position));

  cancel() => emit(EditReady(enabled: false, cursor: state.cursor));

  add() async {
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
        description: defibrillator.description ?? ''));
  }

  edit(Defibrillator defibrillator) async {
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
        description: defibrillator.description ?? ''));
  }

  editDescription(String value) {
    var s = state;
    if (s is EditInProgress) {
      s.defibrillator.description = value;
      emit(s.copyWith(defibrillator: s.defibrillator, description: value));
    }
  }

  editOperator(String value) {
    var s = state;
    if (s is EditInProgress) {
      s.defibrillator.operator = value;
      emit(s.copyWith(defibrillator: s.defibrillator));
    }
  }

  editPhone(String value) {
    var s = state;
    if (s is EditInProgress) {
      s.defibrillator.phone = value;
      emit(s.copyWith(defibrillator: s.defibrillator));
    }
  }

  editOpeningHours(String value) {
    var s = state;
    if (s is EditInProgress) {
      s.defibrillator.openingHours = value;
      emit(s.copyWith(defibrillator: s.defibrillator));
    }
  }

  editIndoor(bool value) {
    var s = state;
    if (s is EditInProgress) {
      var contents = value ? 'yes' : 'no';
      s.defibrillator.indoor = contents;
      emit(s.copyWith(defibrillator: s.defibrillator, indoor: contents));
    }
  }

  editAccess(String value) {
    var s = state;
    if (s is EditInProgress) {
      s.defibrillator.access = value;
      emit(s.copyWith(defibrillator: s.defibrillator, access: value));
    }
  }

  Future<Defibrillator?> save() async {
    var s = state;
    if (s is EditInProgress) {
      if (s.defibrillator.id == 0) {
        await pointsRepository.insertDefibrillator(s.defibrillator);
        analytics.event(name: saveInsertEvent);
        if (!Platform.environment.containsKey('FLUTTER_TEST')) {
          mixpanel.track(saveInsertEvent,
              properties: s.defibrillator.getEventProperties());
        }
      } else {
        await pointsRepository.updateDefibrillator(s.defibrillator);
        analytics.event(name: saveUpdateEvent);
        if (!Platform.environment.containsKey('FLUTTER_TEST')) {
          mixpanel.track(saveUpdateEvent,
              properties: s.defibrillator.getEventProperties());
        }
      }
      emit(EditReady(enabled: false, cursor: state.cursor));
      Future.delayed(const Duration(seconds: 2)).then((_) async {
        final remoteConfig = FirebaseRemoteConfig.instance;
        if (remoteConfig.getBool('request_review')) {
          var isAvailable = await InAppReview.instance.isAvailable();
          if (isAvailable) {
            await InAppReview.instance.requestReview();
          }
          if (!Platform.environment.containsKey('FLUTTER_TEST')) {
            mixpanel.track(requestReviewEvent, properties: {
              'available': isAvailable,
            });
          }
        }
      });
      return s.defibrillator;
    }
    return null;
  }

  delete(Defibrillator defibrillator) async {
    await pointsRepository.deleteDefibrillator(defibrillator.id);
    emit(EditReady(enabled: false, cursor: state.cursor));
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      mixpanel.track(deleteEvent,
          properties: defibrillator.getEventProperties());
    }
  }
}
