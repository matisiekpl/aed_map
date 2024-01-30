import 'package:aed_map/bloc/points/points_cubit.dart';
import 'package:aed_map/bloc/points/points_state.dart';
import 'package:aed_map/bloc/routing/routing_cubit.dart';
import 'package:aed_map/bloc/routing/routing_state.dart';
import 'package:aed_map/constants.dart';
import 'package:aed_map/repositories/geolocation_repository.dart';
import 'package:aed_map/repositories/points_repository.dart';
import 'package:aed_map/repositories/routing_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'utils.dart';

void main() {
  CustomBindings();
  TestWidgetsFlutterBinding.ensureInitialized();
  group('RoutingCubit', () {
    late RoutingCubit routingCubit;
    late PointsCubit pointsCubit;
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      var geolocationRepository = GeolocationRepository();
      routingCubit = RoutingCubit(
          routingRepository: RoutingRepository(),
          geolocationRepository: geolocationRepository);
      pointsCubit = PointsCubit(
          pointsRepository: PointsRepository(),
          geolocationRepository: geolocationRepository);
    });

    test('initial state is RoutingInitial', () {
      expect(routingCubit.state, RoutingReady());
    });

    test('navigate', () async {
      pointsCubit.load();
      await Future.delayed(const Duration(seconds: 1));
      routingCubit.navigate(
          warsaw, (pointsCubit.state as PointsLoadSuccess).aeds.first);
      expect(routingCubit.state, isA<RoutingCalculatingInProgress>());
      await Future.delayed(const Duration(seconds: 5));
      expect(routingCubit.state, isA<RoutingSuccess>());
      expect((routingCubit.state as RoutingSuccess).trip.length,
          greaterThanOrEqualTo(0));
    });
  });
}
