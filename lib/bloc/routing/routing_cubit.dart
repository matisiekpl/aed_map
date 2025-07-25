import 'dart:io';

import 'package:aed_map/bloc/routing/routing_state.dart';
import 'package:aed_map/constants.dart';
import 'package:aed_map/main.dart';
import 'package:aed_map/models/aed.dart';
import 'package:aed_map/repositories/geolocation_repository.dart';
import 'package:aed_map/repositories/routing_repository.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

class RoutingCubit extends Cubit<RoutingState> {
  RoutingCubit(
      {required this.geolocationRepository, required this.routingRepository})
      : super(RoutingReady());

  final GeolocationRepository geolocationRepository;
  final RoutingRepository routingRepository;

  Future<void> navigate(LatLng source, Defibrillator defibrillator) async {
    HapticFeedback.lightImpact();
    emit(RoutingCalculatingInProgress());
    var trip = await routingRepository.navigate(
        await geolocationRepository.locate(), defibrillator);
    if (trip != null) {
      HapticFeedback.heavyImpact();
      emit(RoutingSuccess(trip: trip));
    } else {
      emit(RoutingReady());
    }
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      FirebaseAnalytics.instance.logSearch(searchTerm: defibrillator.id.toString());
      mixpanel.track(navigateEvent, properties: defibrillator.getEventProperties());
    }
  }

  void cancel() {
    emit(RoutingReady());
  }
}
