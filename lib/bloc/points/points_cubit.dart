import 'package:aed_map/bloc/points/points_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

import '../../constants.dart';
import '../../models/aed.dart';
import '../../store.dart';

class PointsCubit extends Cubit<PointsState> {
  PointsCubit() : super(PointsStateLoading());

  load() async {
    List<AED> aeds = [];
    if (kDebugMode) {
      aeds = await Store.instance
          .loadAEDs(LatLng(warsaw.latitude, warsaw.longitude));
    } else {
      var position = await Store.instance.determinePosition();
      aeds = await Store.instance
          .loadAEDs(LatLng(position.latitude, position.longitude));
    }
    emit(PointsStateLoaded(aeds: aeds, selected: aeds.first));
  }

  select(AED aed) {
    if (state is PointsStateLoaded) {
      emit((state as PointsStateLoaded).copyWith(selected: aed));
    }
  }
}
