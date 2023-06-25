import 'package:aed_map/bloc/location/location_cubit.dart';
import 'package:aed_map/bloc/location/location_state.dart';
import 'package:aed_map/repositories/geolocation_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('LocationCubit', () {
    late LocationCubit locationCubit;
    setUp(() {
      locationCubit =
          LocationCubit(geolocationRepository: GeolocationRepository());
    });

    test('initial state is LocationReady', () {
      expect(locationCubit.state, LocationReady());
    });

    test('locate', () async {
      await locationCubit.locate();
      expect(locationCubit.state, isA<LocationDetermined>());
      await Future.delayed(const Duration(seconds: 1));
      expect(locationCubit.state, isA<LocationDetermined>());
    });

    test('move', () async {
      await locationCubit.locate();
      expect(locationCubit.state, isA<LocationDetermined>());
      locationCubit.move(LatLng(3, 7));
      expect(locationCubit.state, isA<LocationDetermined>());
      expect((locationCubit.state as LocationDetermined).center, LatLng(3, 7));
    });

    test('center', () async {
      await locationCubit.locate();
      await Future.delayed(const Duration(seconds: 1));
      expect(locationCubit.state, isA<LocationDetermined>());
      locationCubit.center();
      expect((locationCubit.state as LocationDetermined).center,
          (locationCubit.state as LocationDetermined).location);
    });
  });
}
