import 'package:aed_map/bloc/routing/routing_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

import '../../models/aed.dart';
import '../../store.dart';

class RoutingCubit extends Cubit<RoutingState> {
  RoutingCubit() : super(RoutingStateNotShowing());

  navigate(LatLng source, AED aed) async {
    emit(RoutingStateCalculating());
    var trip =
        await Store.instance.navigate(await Store.instance.locate(), aed);
    if (trip != null) {
      emit(RoutingStateShowing(trip: trip));
    } else {
      emit(RoutingStateNotShowing());
    }
  }

  cancel() {
    emit(RoutingStateNotShowing());
  }
}
