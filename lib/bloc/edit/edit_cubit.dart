import 'package:aed_map/bloc/edit/edit_state.dart';
import 'package:aed_map/constants.dart';
import 'package:aed_map/repositories/points_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

import '../../models/aed.dart';

class EditCubit extends Cubit<EditState> {
  EditCubit({required this.pointsRepository}) : super(EditReady(enabled: false, cursor: warsaw));

  final PointsRepository pointsRepository;

  enter() async {
    if (!await pointsRepository.authenticate()) return;
    emit(state.copyWith(enabled: true));
  }

  exit() => emit(state.copyWith(enabled: false));

  moveCursor(LatLng position) => emit(state.copyWith(cursor: position));

  cancel() => emit(EditReady(enabled: false, cursor: state.cursor));

  add() async {
    AED aed = AED(location: LatLng(state.cursor.latitude, state.cursor.longitude), id: 0);
    emit(EditInProgress(
        enabled: false,
        cursor: state.cursor,
        aed: aed,
        access: aed.access ?? 'yes',
        indoor: aed.indoor,
        description: aed.description ?? ''));
  }

  edit(AED aed) async {
    if (!await pointsRepository.authenticate()) return;
    aed = aed.copyWith();
    emit(EditInProgress(
        enabled: false,
        cursor: state.cursor,
        aed: aed,
        access: aed.access ?? 'yes',
        indoor: aed.indoor,
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
      s.aed.indoor = value;
      emit(s.copyWith(aed: s.aed, indoor: value));
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
        await pointsRepository.insertDefibrillator(s.aed);
      } else {
        await pointsRepository.updateDefibrillator(s.aed);
      }
      emit(EditReady(enabled: false, cursor: state.cursor));
      return s.aed;
    }
    return null;
  }
}
