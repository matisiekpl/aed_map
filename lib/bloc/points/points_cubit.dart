import 'dart:async';

import 'package:aed_map/bloc/theme/theme_cubit.dart';

import 'package:aed_map/bloc/edit/edit_cubit.dart';
import 'package:aed_map/bloc/edit/edit_state.dart';
import 'package:aed_map/bloc/points/points_state.dart';
import 'package:aed_map/constants.dart';
import 'package:aed_map/main.dart';
import 'package:aed_map/models/aed.dart';
import 'package:aed_map/models/pending_change.dart';
import 'package:aed_map/repositories/geolocation_repository.dart';
import 'package:aed_map/repositories/points_repository.dart';
import 'package:aed_map/shared/utils.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:latlong2/latlong.dart';

class PointsCubit extends Cubit<PointsState> {
  PointsCubit({
    required this.pointsRepository,
    required this.geolocationRepository,
    required this.editCubit,
    required this.themeCubit,
  }) : super(PointsLoadInProgress()) {
    _themeSubscription = themeCubit.stream.listen((themeMode) {
      if (_prevThemeMode != themeMode) {
        _prevThemeMode = themeMode;
        rebuildMarkers();
      }
    });
    _editSubscription = editCubit.stream
        .distinct((previous, current) =>
            previous.pendingChanges == current.pendingChanges)
        .listen((editState) => applyPendingChanges(editState.pendingChanges));
  }

  ThemeMode _prevThemeMode = ThemeMode.system;

  final PointsRepository pointsRepository;
  final GeolocationRepository geolocationRepository;
  final EditCubit editCubit;
  final ThemeCubit themeCubit;
  late final StreamSubscription<EditState> _editSubscription;
  late final StreamSubscription<ThemeMode> _themeSubscription;

  @override
  Future<void> close() {
    _editSubscription.cancel();
    _themeSubscription.cancel();
    return super.close();
  }

  Future<void> load() async {
    var position = (await geolocationRepository.locate()).location;
    final (nearbyDefibrillators, defibrillatorsCount) = await pointsRepository
        .loadDefibrillators(LatLng(position.latitude, position.longitude));
    await editCubit.reconcilePendingChanges(nearbyDefibrillators);
    final pendingChanges = editCubit.state.pendingChanges;
    final (mergedDefibrillators, pendingIds) =
        mergeWithPendingChanges(nearbyDefibrillators, pendingChanges);
    emit(PointsLoadSuccess(
        defibrillators: mergedDefibrillators,
        defibrillatorsCount: defibrillatorsCount,
        selected: mergedDefibrillators.first,
        markers: buildMarkers(mergedDefibrillators, pendingIds),
        lastUpdateTime: await pointsRepository.getLastUpdateTime(),
        refreshing: false,
        pendingIds: pendingIds,
        hash: generateRandomString(32)));
  }

  Future<void> refresh() async {
    var s = state;
    if (s is PointsLoadSuccess) {
      emit(s.copyWith(refreshing: true));
    }
    await pointsRepository.updateDefibrillators();
    var position = (await geolocationRepository.locate()).location;
    final (nearbyDefibrillators, defibrillatorsCount) = await pointsRepository
        .loadDefibrillators(LatLng(position.latitude, position.longitude));
    await editCubit.reconcilePendingChanges(nearbyDefibrillators);
    final pendingChanges = editCubit.state.pendingChanges;
    final (mergedDefibrillators, pendingIds) =
        mergeWithPendingChanges(nearbyDefibrillators, pendingChanges);
    emit(PointsLoadSuccess(
        defibrillators: mergedDefibrillators,
        defibrillatorsCount: defibrillatorsCount,
        selected: mergedDefibrillators.first,
        markers: buildMarkers(mergedDefibrillators, pendingIds),
        lastUpdateTime: await pointsRepository.getLastUpdateTime(),
        refreshing: false,
        pendingIds: pendingIds,
        hash: generateRandomString(32)));
  }

  void applyPendingChanges(List<PendingChange> pendingChanges) {
    var s = state;
    if (s is! PointsLoadSuccess) return;
    final baseDefibrillators = s.defibrillators
        .where((defibrillator) => !pendingChanges
            .any((change) => change.defibrillatorId == defibrillator.id))
        .toList();
    final (mergedDefibrillators, pendingIds) =
        mergeWithPendingChanges(baseDefibrillators, pendingChanges);
    emit(s.copyWith(
        defibrillators: mergedDefibrillators,
        markers: buildMarkers(mergedDefibrillators, pendingIds),
        pendingIds: pendingIds,
        hash: generateRandomString(32)));
  }

  (List<Defibrillator>, Set<int>) mergeWithPendingChanges(
      List<Defibrillator> defibrillators, List<PendingChange> pendingChanges) {
    final deleteIds = pendingChanges
        .where((change) => change.type == PendingChangeType.delete)
        .map((change) => change.defibrillatorId)
        .toSet();

    var merged = defibrillators
        .where((defibrillator) => !deleteIds.contains(defibrillator.id))
        .toList();

    final pendingIds = <int>{};
    for (final change in pendingChanges) {
      if (change.type == PendingChangeType.delete) continue;
      pendingIds.add(change.defibrillatorId);
      merged.removeWhere(
          (defibrillator) => defibrillator.id == change.defibrillatorId);
      merged.insert(0, change.snapshot);
    }

    return (merged, pendingIds);
  }

  void select(Defibrillator defibrillator) {
    FirebaseAnalytics.instance.logSelectContent(
        contentType: 'aed', itemId: defibrillator.id.toString());
    HapticFeedback.mediumImpact();
    analytics.event(name: selectEvent);
    mixpanel.track(selectEvent, properties: defibrillator.getEventProperties());
    if (state is PointsLoadSuccess) {
      emit((state as PointsLoadSuccess)
          .copyWith(selected: defibrillator, hash: generateRandomString(32)));
    }
  }

  void update(Defibrillator defibrillator) {
    if (state is PointsLoadSuccess) {
      final currentState = state as PointsLoadSuccess;
      if (defibrillator.id == 0) {
        var newDefibrillators =
            List<Defibrillator>.from(currentState.defibrillators)
              ..insert(0, defibrillator);
        emit(currentState.copyWith(
            defibrillators: newDefibrillators,
            markers: buildMarkers(newDefibrillators, currentState.pendingIds),
            selected: defibrillator));
      } else {
        var updatedDefibrillators =
            List<Defibrillator>.from(currentState.defibrillators)
              ..removeWhere((existing) => existing.id == defibrillator.id)
              ..insert(0, defibrillator);
        emit(currentState.copyWith(
            selected: defibrillator,
            defibrillators: updatedDefibrillators,
            markers:
                buildMarkers(updatedDefibrillators, currentState.pendingIds)));
      }
    }
  }

  void rebuildMarkers() {
    if (state is PointsLoadSuccess) {
      final s = state as PointsLoadSuccess;
      emit(s.copyWith(
          markers: buildMarkers(s.defibrillators, s.pendingIds)));
    }
  }

  List<Marker> buildMarkers(
      List<Defibrillator> defibrillators, Set<int> pendingIds) {
    var systemBrightness = MediaQueryData.fromView(
            WidgetsBinding.instance.platformDispatcher.views.single)
        .platformBrightness;
    var brightness = themeCubit.state == ThemeMode.light
        ? Brightness.light
        : themeCubit.state == ThemeMode.dark
            ? Brightness.dark
            : systemBrightness;
    return defibrillators
        .take(visiblePointsCount)
        .map((defibrillator) {
          final isPending = pendingIds.contains(defibrillator.id);
          final svgAsset = 'assets/${defibrillator.getIconFilename()}';
          return Marker(
            point: defibrillator.location,
            key: Key('${defibrillators.indexOf(defibrillator)}_$brightness'),
            child: isPending
                ? DottedBorder(
                    options: RoundedRectDottedBorderOptions(
                      radius: const Radius.circular(8),
                      dashPattern: const [4, 3],
                      color: brightness == Brightness.light
                          ? Colors.black
                          : Colors.white,
                      strokeWidth: 2,
                    ),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SvgPicture.asset(svgAsset)),
                  )
                : Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: brightness == Brightness.light
                              ? Colors.black
                              : Colors.white,
                          width: 2),
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                    ),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SvgPicture.asset(svgAsset)),
                  ),
          );
        })
        .cast<Marker>()
        .toList();
  }
}
