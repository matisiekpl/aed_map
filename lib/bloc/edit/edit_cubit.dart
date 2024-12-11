import 'dart:io';

import 'package:aed_map/bloc/edit/edit_state.dart';
import 'package:aed_map/constants.dart';
import 'package:aed_map/main.dart';
import 'package:aed_map/models/aed.dart';
import 'package:aed_map/repositories/geolocation_repository.dart';
import 'package:aed_map/repositories/points_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        enabled: true, cursor: await geolocationRepository.locate()));
  }

  exit() => emit(state.copyWith(enabled: false));

  moveCursor(LatLng position) => emit(state.copyWith(cursor: position));

  cancel() => emit(EditReady(enabled: false, cursor: state.cursor));

  add() async {
    analytics.event(name: addEvent);
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      mixpanel.track(addEvent);
    }
    AED aed = AED(
        location: LatLng(state.cursor.latitude, state.cursor.longitude), id: 0);
    emit(EditInProgress(
        enabled: false,
        cursor: state.cursor,
        aed: aed,
        access: aed.access ?? 'yes',
        indoor: aed.indoor ?? 'no',
        description: aed.description ?? ''));
  }

  edit(AED aed) async {
    analytics.event(name: editEvent);
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      mixpanel.track(editEvent);
    }
    if (!await pointsRepository.authenticate()) return;
    aed = aed.copyWith();
    emit(EditInProgress(
        enabled: false,
        cursor: state.cursor,
        aed: aed,
        access: aed.access ?? 'yes',
        indoor: aed.indoor ?? 'no',
        description: aed.description ?? ''));
  }

  editDescription(String value) {
    var s = state;
    if (s is EditInProgress) {
      s.aed.description = value;
      emit(s.copyWith(aed: s.aed, description: value));
    }
  }

  editOperator(String value) {
    var s = state;
    if (s is EditInProgress) {
      s.aed.operator = value;
      emit(s.copyWith(aed: s.aed));
    }
  }

  editPhone(String value) {
    var s = state;
    if (s is EditInProgress) {
      s.aed.phone = value;
      emit(s.copyWith(aed: s.aed));
    }
  }

  editOpeningHours(String value) {
    var s = state;
    if (s is EditInProgress) {
      s.aed.openingHours = value;
      emit(s.copyWith(aed: s.aed));
    }
  }

  editIndoor(bool value) {
    var s = state;
    if (s is EditInProgress) {
      var contents = value ? 'yes' : 'no';
      s.aed.indoor = contents;
      emit(s.copyWith(aed: s.aed, indoor: contents));
    }
  }

  editAccess(String value) {
    var s = state;
    if (s is EditInProgress) {
      s.aed.access = value;
      emit(s.copyWith(aed: s.aed, access: value));
    }
  }

  Future<AED?> save() async {
    var s = state;
    if (s is EditInProgress) {
      if (s.aed.id == 0) {
        analytics.event(name: saveInsertEvent);
        if (!Platform.environment.containsKey('FLUTTER_TEST')) {
          mixpanel.track(saveInsertEvent, properties: {'aed': s.aed.id});
        }
        await pointsRepository.insertDefibrillator(s.aed);
      } else {
        analytics.event(name: saveUpdateEvent);
        if (!Platform.environment.containsKey('FLUTTER_TEST')) {
          mixpanel.track(saveUpdateEvent, properties: {'aed': s.aed.id});
        }
        await pointsRepository.updateDefibrillator(s.aed);
      }
      emit(EditReady(enabled: false, cursor: state.cursor));
      return s.aed;
    }
    return null;
  }
}
