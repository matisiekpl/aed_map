import 'package:aed_map/bloc/points/points_state.dart';
import 'package:aed_map/repositories/geolocation_repository.dart';
import 'package:aed_map/repositories/points_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:latlong2/latlong.dart';

import '../../constants.dart';
import '../../main.dart';
import '../../models/aed.dart';

class PointsCubit extends Cubit<PointsState> {
  PointsCubit(
      {required this.pointsRepository, required this.geolocationRepository})
      : super(PointsLoadInProgress());

  final PointsRepository pointsRepository;
  final GeolocationRepository geolocationRepository;

  load() async {
    var position = await geolocationRepository.locate();
    var aeds = await pointsRepository
        .loadAEDs(LatLng(position.latitude, position.longitude));
    emit(PointsLoadSuccess(
        aeds: aeds, selected: aeds.first, markers: _getMarkers(aeds)));
  }

  select(AED aed) {
    analytics.event(name: selectEvent);
    if (state is PointsLoadSuccess) {
      emit((state as PointsLoadSuccess).copyWith(selected: aed));
    }
  }

  update(AED aed) {
    if (state is PointsLoadSuccess) {
      if (aed.id == 0) {
        var newAeds = List<AED>.from((state as PointsLoadSuccess).aeds)
          ..add(aed);
        emit((state as PointsLoadSuccess).copyWith(
            aeds: newAeds, markers: _getMarkers(newAeds), selected: aed));
      } else {
        var updatedAeds = List<AED>.from((state as PointsLoadSuccess).aeds)
            .map((e) => e.id == aed.id ? aed : e)
            .toList();
        emit((state as PointsLoadSuccess).copyWith(
            selected: aed,
            aeds: updatedAeds,
            markers: _getMarkers(updatedAeds)));
      }
    }
  }

  List<Marker> _getMarkers(List<AED> aeds) => aeds
      .map((aed) {
        if (aed.access == 'yes') {
          return Marker(
            point: aed.location,
            key: Key(aeds.indexOf(aed).toString()),
            builder: (ctx) => ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SvgPicture.asset('assets/green_aed.svg')),
          );
        }
        if (aed.access == 'customers') {
          return Marker(
            point: aed.location,
            key: Key(aeds.indexOf(aed).toString()),
            builder: (ctx) => ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SvgPicture.asset('assets/yellow_aed.svg')),
          );
        }
        if (aed.access == 'private' || aed.access == 'permissive') {
          return Marker(
            point: aed.location,
            key: Key(aeds.indexOf(aed).toString()),
            builder: (ctx) => ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SvgPicture.asset('assets/blue_aed.svg')),
          );
        }
        if (aed.access == 'no') {
          return Marker(
            point: aed.location,
            key: Key(aeds.indexOf(aed).toString()),
            builder: (ctx) => ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SvgPicture.asset('assets/red_aed.svg')),
          );
        }
        if (aed.access == 'unknown') {
          return Marker(
            point: aed.location,
            key: Key(aeds.indexOf(aed).toString()),
            builder: (ctx) => ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SvgPicture.asset('assets/grey_aed.svg')),
          );
        }
        return Marker(
          point: aed.location,
          key: Key(aeds.indexOf(aed).toString()),
          builder: (ctx) => ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SvgPicture.asset('assets/green_aed.svg')),
        );
      })
      .cast<Marker>()
      .toList();
}
