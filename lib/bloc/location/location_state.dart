import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

class LocationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LocationReady extends LocationState {}

class LocationDetermining extends LocationState {}

class LocationDetermined extends LocationState {
  final LatLng location;
  final LatLng center;
  final int zoom;
  final bool permissionDenied;

  LocationDetermined({
    required this.location,
    required this.center,
    required this.zoom,
    this.permissionDenied = false,
  });

  @override
  List<Object?> get props => [location, center, permissionDenied];

  LocationDetermined copyWith({
    LatLng? location,
    LatLng? center,
    int? zoom,
    bool? permissionDenied,
  }) {
    return LocationDetermined(
      location: location ?? this.location,
      center: center ?? this.center,
      zoom: zoom ?? this.zoom,
      permissionDenied: permissionDenied ?? this.permissionDenied,
    );
  }
}
