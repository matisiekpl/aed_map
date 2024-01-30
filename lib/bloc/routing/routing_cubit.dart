import 'package:aed_map/bloc/routing/routing_state.dart';
import 'package:aed_map/repositories/geolocation_repository.dart';
import 'package:aed_map/repositories/routing_repository.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

import '../../models/aed.dart';

class RoutingCubit extends Cubit<RoutingState> {
  RoutingCubit(
      {required this.geolocationRepository, required this.routingRepository})
      : super(RoutingReady());

  final GeolocationRepository geolocationRepository;
  final RoutingRepository routingRepository;

  navigate(LatLng source, AED aed) async {
    FirebaseAnalytics.instance.logSearch(searchTerm: aed.id.toString());
    HapticFeedback.lightImpact();
    emit(RoutingCalculatingInProgress());
    var trip = await routingRepository.navigate(
        await geolocationRepository.locate(), aed);
    if (trip != null) {
      HapticFeedback.heavyImpact();
      emit(RoutingSuccess(trip: trip));
    } else {
      emit(RoutingReady());
    }
  }

  cancel() {
    emit(RoutingReady());
  }
}
