import 'package:aed_map/bloc/panel/panel_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('PanelCubit', () {
    late PanelCubit panelCubit;
    setUp(() {
      panelCubit = PanelCubit();
    });

    test('initial state is PanelState', () {
      expect(panelCubit.state.visible, true);
      expect(panelCubit.state.open, false);
    });

    test('open', () {
      panelCubit.open();
      expect(panelCubit.state.open, true);
    });

    test('cancel', () {
      panelCubit.cancel();
      expect(panelCubit.state.open, false);
    });

    test('show', () {
      panelCubit.show();
      expect(panelCubit.state.visible, true);
    });

    test('hide', () {
      panelCubit.hide();
      expect(panelCubit.state.visible, false);
    });

    tearDown(() {
      panelCubit.close();
    });
  });
}
