import 'dart:io';

import 'package:aed_map/bloc/edit/edit_cubit.dart';
import 'package:aed_map/bloc/points/points_cubit.dart';
import 'package:aed_map/bloc/points/points_state.dart';
import 'package:aed_map/repositories/geolocation_repository.dart';
import 'package:aed_map/repositories/pending_changes_repository.dart';
import 'package:aed_map/repositories/points_repository.dart';
import 'package:aed_map/repositories/user_created_defibrillator_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'utils.dart';

void main() {
  CustomBindings();
  TestWidgetsFlutterBinding.ensureInitialized();
  group('PointsCubit', () {
    late PointsCubit pointsCubit;
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      // Seed the cache file PointsRepository reads in tests. On CI the file
      // does not exist and rootBundle assets are unavailable, so we provide a
      // minimal valid GeoJSON to avoid a JSON decode error on empty input.
      await File('ignore_${PointsRepository.defibrillatorListKey}.geojson')
          .writeAsString(
              '{"type":"FeatureCollection","features":[{"type":"Feature","geometry":{"type":"Point","coordinates":[21.0,52.0]},"properties":{"osm_id":1,"access":"yes"}}]}');
      final geolocationRepository = GeolocationRepository();
      final editCubit = EditCubit(
          pointsRepository: PointsRepository(),
          geolocationRepository: geolocationRepository,
          pendingChangesRepository: PendingChangesRepository(),
          userCreatedDefibrillatorRepository: UserCreatedDefibrillatorRepository());
      pointsCubit = PointsCubit(
          pointsRepository: PointsRepository(),
          geolocationRepository: geolocationRepository,
          editCubit: editCubit);
    });

    test('initial state is PointsLoadInProgress', () {
      expect(pointsCubit.state, PointsLoadInProgress());
    });

    test('load', () async {
      await pointsCubit.load();
      expect(pointsCubit.state, isA<PointsLoadSuccess>());
    });

    test('update', () async {
      await pointsCubit.load();
      var defibrillator = (pointsCubit.state as PointsLoadSuccess).defibrillators.first;
      pointsCubit.update(defibrillator);
      expect((pointsCubit.state as PointsLoadSuccess).selected, defibrillator);
    });

    tearDown(() {
      pointsCubit.close();
    });
  });
}
