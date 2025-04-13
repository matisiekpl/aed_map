import 'package:aed_map/bloc/points/points_state.dart';
import 'package:aed_map/constants.dart';
import 'package:aed_map/main.dart';
import 'package:aed_map/models/aed.dart';
import 'package:aed_map/repositories/geolocation_repository.dart';
import 'package:aed_map/repositories/points_repository.dart';
import 'package:aed_map/shared/utils.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:latlong2/latlong.dart';

class PointsCubit extends Cubit<PointsState> {
  PointsCubit(
      {required this.pointsRepository, required this.geolocationRepository})
      : super(PointsLoadInProgress());

  final PointsRepository pointsRepository;
  final GeolocationRepository geolocationRepository;

  load() async {
    var position = await geolocationRepository.locate();
    var defibrillators = await pointsRepository
        .loadDefibrillators(LatLng(position.latitude, position.longitude));
    emit(PointsLoadSuccess(
        defibrillators: defibrillators,
        selected: defibrillators.first,
        markers: _getMarkers(defibrillators),
        lastUpdateTime: await pointsRepository.getLastUpdateTime(),
        refreshing: false,
        hash: generateRandomString(32)));
  }

  refresh() async {
    var s = state;
    if (s is PointsLoadSuccess) {
      emit(s.copyWith(refreshing: true));
    }
    await pointsRepository.updateDefibrillators();
    var position = await geolocationRepository.locate();
    var defibrillators = await pointsRepository
        .loadDefibrillators(LatLng(position.latitude, position.longitude));
    emit(PointsLoadSuccess(
        defibrillators: defibrillators,
        selected: defibrillators.first,
        markers: _getMarkers(defibrillators),
        lastUpdateTime: await pointsRepository.getLastUpdateTime(),
        refreshing: false,
        hash: generateRandomString(32)));
  }

  select(Defibrillator defibrillator) {
    FirebaseAnalytics.instance.logSelectContent(
        contentType: 'aed', itemId: defibrillator.id.toString());
    HapticFeedback.mediumImpact();
    analytics.event(name: selectEvent);
    mixpanel.track(selectEvent, properties: defibrillator.getEventProperties());
    if (state is PointsLoadSuccess) {
      emit((state as PointsLoadSuccess)
          .copyWith(selected: defibrillator, hash: generateRandomString(32)));
    }

    loadImage();
  }

  update(Defibrillator defibrillator) {
    if (state is PointsLoadSuccess) {
      if (defibrillator.id == 0) {
        var newDefibrillators = List<Defibrillator>.from(
            (state as PointsLoadSuccess).defibrillators)
          ..insert(0, defibrillator);
        emit((state as PointsLoadSuccess).copyWith(
            defibrillators: newDefibrillators,
            markers: _getMarkers(newDefibrillators),
            selected: defibrillator));
      } else {
        var updatedDefibrillators = List<Defibrillator>.from(
            (state as PointsLoadSuccess).defibrillators)
          ..removeWhere((x) => x.id == defibrillator.id)
          ..insert(0, defibrillator);
        emit((state as PointsLoadSuccess).copyWith(
            selected: defibrillator,
            defibrillators: updatedDefibrillators,
            markers: _getMarkers(updatedDefibrillators)));
      }
    }
  }

  List<Marker> _getMarkers(List<Defibrillator> defibrillators) {
    var brightness = MediaQueryData.fromView(
            WidgetsBinding.instance.platformDispatcher.views.single)
        .platformBrightness;
    return defibrillators
        .take(1000)
        .map((defibrillator) {
          if (defibrillator.access == 'yes') {
            return Marker(
              point: defibrillator.location,
              key: Key(defibrillators.indexOf(defibrillator).toString()),
              child: Container(
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
                    child: SvgPicture.asset('assets/green_aed.svg')),
              ),
            );
          }
          if (defibrillator.access == 'customers') {
            return Marker(
              point: defibrillator.location,
              key: Key(defibrillators.indexOf(defibrillator).toString()),
              child: Container(
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
                    child: SvgPicture.asset('assets/yellow_aed.svg')),
              ),
            );
          }
          if (defibrillator.access == 'private' ||
              defibrillator.access == 'permissive') {
            return Marker(
              point: defibrillator.location,
              key: Key(defibrillators.indexOf(defibrillator).toString()),
              child: Container(
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
                    child: SvgPicture.asset('assets/blue_aed.svg')),
              ),
            );
          }
          if (defibrillator.access == 'no') {
            return Marker(
              point: defibrillator.location,
              key: Key(defibrillators.indexOf(defibrillator).toString()),
              child: Container(
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
                    child: SvgPicture.asset('assets/red_aed.svg')),
              ),
            );
          }
          if (defibrillator.access == 'unknown') {
            return Marker(
              point: defibrillator.location,
              key: Key(defibrillators.indexOf(defibrillator).toString()),
              child: Container(
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
                    child: SvgPicture.asset('assets/grey_aed.svg')),
              ),
            );
          }
          return Marker(
            point: defibrillator.location,
            key: Key(defibrillators.indexOf(defibrillator).toString()),
            child: Container(
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
                  child: SvgPicture.asset('assets/green_aed.svg')),
            ),
          );
        })
        .cast<Marker>()
        .toList();
  }

  loadImage() async {
    var state = this.state;
    if (state is PointsLoadSuccess) {
      var images = await pointsRepository.getImages(state.selected);
      var defibrillator =
          state.selected.copyWith(images: images, image: images.firstOrNull);
      emit(state.copyWith(
          selected: defibrillator, hash: generateRandomString(32)));
    }
  }
}
