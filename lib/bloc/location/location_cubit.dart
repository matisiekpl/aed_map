import 'package:aed_map/bloc/location/location_state.dart';
import 'package:aed_map/repositories/geolocation_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

class LocationCubit extends Cubit<LocationState> {
  LocationCubit({required this.geolocationRepository}) : super(LocationReady());

  final GeolocationRepository geolocationRepository;

  locate() async {
    if (state is LocationReady) {
      emit(LocationDetermining());
      var location = await geolocationRepository.locate();
      emit(
          LocationDetermined(location: location, center: location, zoom: 16));
    }
  }

  move(LatLng center) {
    var s = state;
    if (s is LocationDetermined) {
      emit(s.copyWith(center: center));
    }
  }

  center() {
    var s = state;
    if (s is LocationDetermined) {
      emit(s.copyWith(center: s.location, zoom: 18));
    }
  }
}
