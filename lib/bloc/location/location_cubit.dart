import 'package:aed_map/bloc/location/location_state.dart';
import 'package:aed_map/store.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocationCubit extends Cubit<LocationState> {
  LocationCubit() : super(LocationStateReady());

  locate() async {
    if (state is LocationStateReady) {
      emit(LocationStateDetermining());
      var location = await Store.instance.locate();
      emit(LocationStateLocated(location: location));
    }
  }
}
