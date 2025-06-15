import 'package:aed_map/bloc/panel/panel_state.dart';
import 'package:aed_map/shared/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PanelCubit extends Cubit<PanelState> {
  PanelCubit()
      : super(PanelState(
            open: true, visible: true, hash: generateRandomString(32)));

  void open() => emit(state.copyWith(open: true, hash: generateRandomString(32)));

  void cancel() => emit(state.copyWith(open: false, hash: generateRandomString(32)));

  void show() => emit(state.copyWith(visible: true, hash: generateRandomString(32)));

  void hide() =>
      emit(state.copyWith(visible: false, hash: generateRandomString(32)));
}
