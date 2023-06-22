import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

class LocationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LocationStateReady extends LocationState {}

class LocationStateDetermining extends LocationState {}

class LocationStateLocated extends LocationState {
  final LatLng location;

  LocationStateLocated({
    required this.location,
  });

  @override
  List<Object?> get props => [location];
}
