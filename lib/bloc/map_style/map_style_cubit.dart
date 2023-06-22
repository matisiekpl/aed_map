import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';

import '../../constants.dart';
import 'map_style_state.dart';

class MapStyleCubit extends Cubit<MapStyleState> {
  MapStyleCubit() : super(MapStyleState());

  load() async {
    var style = await StyleReader(uri: maps).read();
    emit(state.copyWith(style: style));
  }
}
